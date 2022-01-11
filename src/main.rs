use lambda_runtime::{Context, Error};
use serde::{Deserialize, Serialize};

#[tokio::main]
async fn main() -> Result<(), Error> {
    let handler = lambda_runtime::handler_fn(handler);
    lambda_runtime::run(handler).await?;
    Ok(())
}

#[derive(Deserialize)]
struct Event {
    first_name: String,
    last_name: String,
}

impl Event {
    fn message(self) -> String {
        format!("Hello, {} {}", self.first_name, self.last_name)
    }
}

#[derive(Serialize)]
struct Output {
    message: String,
    request_id: String,
}

async fn handler(event: Event, context: Context) -> Result<Output, Error> {
    Ok(Output {
        message: event.message(),
        request_id: context.request_id,
    })
}
