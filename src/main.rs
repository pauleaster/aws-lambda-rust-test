use lambda_http::{
    handler,
    lambda_runtime::{self, Context, Error},
    IntoResponse, Request, RequestExt, Response,
};

#[tokio::main]
async fn main() -> Result<(), Error> {
    lambda_runtime::run(handler(func)).await?;
    Ok(())
}

async fn func(event: Request, _: Context) -> Result<impl IntoResponse, Error> {
    let parameters = event.query_string_parameters();
    let mut data_string = String::default();
    let mut keys_string = String::default();
    for (keys,data) in parameters.iter() {
        data_string += data;
        keys_string += keys;
        data_string += ",";
        keys_string += ",";
            }
    data_string = String::from("data: ") + &data_string;
    keys_string = String::from("keys: ") + &keys_string;
    let response = (data_string + &String::from("\n") + &keys_string).into_response();
    Ok(response)
}
//     for (data,keys) in parameters.iter() {
        
//     }
//     let opt_parameters = parameters.get_all()
//     Ok(match event.query_string_parameters().get_all("many") {
//         Some(parameters) => format!("{:?}", parameters).into_response(),
//         _ => Response::builder()
//             .status(400)
//             .body("No parameters found".into())
//             .expect("failed to render response"),
//     })
// }