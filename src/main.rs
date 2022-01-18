/*  shout out to https://www.youtube.com/watch?v=wlVcso4Ut5o
    and https://www.youtube.com/watch?v=PmtwtK6jyLc and the docs for
    lambda_http, lambda_runtime, and terraform that helped get me up and running
    in a few days.
*/

use std::collections::HashMap;

use lambda_http::{
    handler,
    lambda_runtime::{self, Context, Error},
    IntoResponse, Request, RequestExt,
};

enum Headers {
    Use,
    DontUse,
}

const USE_HEADERS: Headers = Headers::DontUse;

#[tokio::main]
async fn main() -> Result<(), Error> {
    lambda_runtime::run(handler(func)).await?;
    Ok(())
}

async fn func(event: Request, _context: Context) -> Result<impl IntoResponse, Error> {
    let parameters = event.query_string_parameters();

    let mut query = HashMap::new();
    for (keys, data) in parameters.iter() {
        query.insert(keys, data);
    }
    let response = match USE_HEADERS {
        Headers::Use => {
            let headers = event.headers();
            format!("query:\n{:#?}\nheaders:\n{:#?}", query, headers)
        }
        _ => format!("query:\n{:#?}", query),
    }
    .into_response();
    Ok(response)
}
