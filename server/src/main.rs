#![deny(warnings)]
#![allow(dead_code)]
extern crate futures;
extern crate pretty_env_logger;
extern crate warp;
extern crate serde;
extern crate serde_json;
#[macro_use] extern crate serde_derive;

use std::collections::HashMap;
use std::sync::{Arc, Mutex, atomic::{AtomicUsize, Ordering}};

use futures::{Future, Stream};
use futures::sync::mpsc;
use warp::Filter;
use warp::ws::{Message, WebSocket};
use std::error::Error;

/// Unique id counter
static NEXT_CONNECTION_ID: AtomicUsize = AtomicUsize::new(1);

type Connections = Arc<Mutex<HashMap<usize, mpsc::UnboundedSender<Message>>>>;

static NEXT_USER_ID: AtomicUsize = AtomicUsize::new(1);
#[allow(dead_code)]
struct UserData {
    id: usize,
    username: String,
    money: i32,
}

type Users = Arc<Mutex<HashMap<usize, UserData>>>;

#[derive(Deserialize)]
enum Requests {
    Register { username: String },
}

#[derive(Serialize)]
enum Responses {
    UsernameAlreadyExists { username: String },
//    Error { message: String},
    Registered { id: usize, username: String },
}


fn main() {
    pretty_env_logger::init();

    // Fake database
    let users: Users = Arc::new(Mutex::new(HashMap::new()));
    users.lock().unwrap().insert(1, UserData { id: 1, username: "jordy".to_string(), money: 100});
    users.lock().unwrap().insert(2, UserData { id: 2, username: "bert".to_string(), money: 200});
    users.lock().unwrap().insert(3, UserData { id: 3, username: "ernie".to_string(), money: 300});
    NEXT_USER_ID.fetch_add(3, Ordering::Relaxed);
    let users = warp::any().map(move || users.clone());

    let connections = Arc::new(Mutex::new(HashMap::new()));
    let connections = warp::any().map(move || connections.clone());

    // GET /ws -> websocket upgrade
    let ws_handler = warp::path("ws")
        .and(warp::ws2())
        .and(connections)
        .and(users)
        .map(|ws: warp::ws::Ws2, connections, users| {
            ws.on_upgrade(move |socket| {
                user_connected(socket, connections, users)
            })
        });

    // Get / -> index.html
    let index = warp::path::end()
        .map(|| {
            warp::http::Response::builder()
                .header("content-type", "text/html; charset=utf-8")
                .body(INDEX_HTML)
        });

    let routes = index.or(ws_handler);

    warp::serve(routes)
        .run(([127,0 ,0, 1], 3030));
}


fn user_connected(ws: WebSocket, connections: Connections, users: Users) -> impl Future<Item = (), Error = ()> {
    let my_id = NEXT_CONNECTION_ID.fetch_add(1, Ordering::Relaxed);
    eprintln!("New char connection: {}", my_id);

    // Split the socket into a sender and receive of messages.
    let (connection_ws_tx, connection_ws_rx) = ws.split();

    // Use an unbounded channel to handle buffering and flushing of messages to the websocket
    let (tx, rx) = mpsc::unbounded();
    warp::spawn(
        rx
            .map_err(|()| -> warp::Error { unreachable!("unbounded rx never errors")})
            .forward(connection_ws_tx)
            .map(|_tx_rx| ())
            .map_err(|ws_err| eprintln!("websocket send error: {}", ws_err))
    );

    // Save the sender in our list of connections
    connections
        .lock()
        .unwrap()
        .insert(my_id, tx);

    // Return a `Future` that is basically a state machine managing tis specific connection
    // Make an extra clone to give to our disconnection handler
    let connections2 = connections.clone();

    connection_ws_rx
        .for_each(move |msg| {
            handle_message(my_id, msg, &connections, &users);
            Ok(())
        })
        // for_each will keep processing as long as the connection stays alive
        // Once it disconnected, then ...
        .then(move |result| {
            connection_disconnected(my_id, &connections2);
            result
        })
        // If at any time, there was a websocket error, log herre
        .map_err(move |e| {
            eprintln!("websocket error(uid={}): {}", my_id, e);
        })
}


fn handle_message(my_id: usize, msg: Message, connections: &Connections, users: &Users) {
    let request_as_result = msg
        .to_str().map_err(|_err| "Could not transform body to string".to_string())
        .and_then(|string_msg|
            as_request(string_msg)
                .map_err(|err| err.description().to_string())
        );

    let request = if let Ok(r) = request_as_result {
        r
    } else {
        eprintln!("Could not convert body to valid Requests");
        return;
    };

    match request {
        Requests::Register { username } => handle_register(my_id, connections, users, username),
    };
}


fn handle_register(my_id: usize, connections: &Connections, users: &Users, username: String) {
    eprintln!("I'm in handle_register with username: {}", username);
    if username_exists(users, &username) {
        let response = Responses::UsernameAlreadyExists {
            username
        };
        send_response(my_id, connections, response);
    } else {
        // @todo we need to add the user here
        let response = Responses::Registered {
            id : 0,
            username
        };
        send_response(my_id, connections, response);
    }
}


fn send_response(my_id: usize, connections: &Connections, response: Responses) {
    for (&uid, tx) in connections.lock().unwrap().iter() {
        if my_id == uid {
            match tx.unbounded_send(Message::text(serde_json::to_string(&response).unwrap())) {
                Ok(()) => (),
                Err(_disconnected) => {}
            }
        }
    }
}


fn as_request(string_msg: &str) -> serde_json::Result<Requests> {
    serde_json::from_str(string_msg)
}


fn connection_disconnected(my_id: usize, connections: &Connections) {
    eprintln!("good bye: {}", my_id);

    // Stream closed up, so remove from the list
    connections
        .lock()
        .unwrap()
        .remove(&my_id);
}

fn username_exists(users: &Users, username: &String) -> bool {
    users
        .lock()
        .unwrap()
        .iter()
        .map(|(_user_id, user_data)| &user_data.username)
        .any(|existing_username| username == existing_username)
}


static INDEX_HTML: &str = r#"
Hi from rust
"#;