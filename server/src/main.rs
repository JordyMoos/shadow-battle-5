#![deny(warnings)]
extern crate futures;
extern crate pretty_env_logger;
extern crate warp;

use std::collections::HashMap;
use std::sync::{Arc, Mutex, atomic::{AtomicUsize, Ordering}};

use futures::{Future, Stream};
use futures::sync::mpsc;
use warp::Filter;
use warp::ws::{Message, WebSocket};

/// Unique id counter
static NEXT_CONNECTION_ID: AtomicUsize = AtomicUsize::new(1);

/// State of current connections
type Connections = Arc<Mutex<HashMap<usize, mpsc::UnboundedSender<Message>>>>;


fn main() {
    pretty_env_logger::init();

    let connections = Arc::new(Mutex::new(HashMap::new()));
    let connections = warp::any().map(move || connections.clone());

    // GET /ws -> websocket upgrade
    let ws_handler = warp::path("ws")
        .and(warp::ws2())
        .and(connections)
        .map(|ws: warp::ws::Ws2, connections| {
            ws.on_upgrade(move |socket| {
                user_connected(socket, connections)
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


fn user_connected(ws: WebSocket, connections: Connections) -> impl Future<Item = (), Error = ()> {
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
        .for_each(move |_msg| {
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


fn connection_disconnected(my_id: usize, connections: &Connections) {
    eprintln!("good bye: {}", my_id);

    // Stream closed up, so remove from the list
    connections
        .lock()
        .unwrap()
        .remove(&my_id);
}




static INDEX_HTML: &str = r#"
Hi from rust
"#;