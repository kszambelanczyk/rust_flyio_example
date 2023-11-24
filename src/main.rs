#![allow(unused)]

use std::net::SocketAddr;

use axum::{response::Html, routing::get, Router};

#[tokio::main]
async fn main() {
    let hello_router = Router::new()
        .route("/hello", get(|| async { Html("<h1>Hello, World!</h1>") }))
        .route("/", get(|| async { Html("<h1>Main page</h1><p>Trial 1</p>") }));

    let addr = SocketAddr::from(([0, 0, 0, 0, 0, 0, 0, 0], 8080));
    println!("Listening on {addr}\n");

    axum::Server::bind(&addr)
        // .serve(main_page.into_make_service())
        .serve(hello_router.into_make_service())
        .await
        .unwrap();
}
