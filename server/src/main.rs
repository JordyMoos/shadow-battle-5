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
    let users = warp::any().map(move || users.clone());

    // GET /ws -> websocket upgrade
    let ws_handler = warp::path("ws")
        .and(warp::ws2())
        .and(connections)
        .map(|ws: warp::ws::Ws2, connections| {
            ws.on_upgrade(move |socket| {
                user_connected(socket, connections)
            })
        });

    
}
