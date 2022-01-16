provider "aws" {
  region = "ap-southeast-2"
}

data "archive_file" "bootstrap-zip" {
  type        = "zip"
  source_file  = "./target/x86_64-unknown-linux-musl/release/bootstrap"
  output_path = "bootstrap.zip"
}

resource "aws_iam_role" "lambda-iam" {
  name = "lambda-iam"
  assume_role_policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Action" : "sts:AssumeRole",
          "Principal" : {
            "Service" : "lambda.amazonaws.com"
          },
          "Effect" : "Allow"
          "Sid" : ""
        }
      ]
    }
  )
}


resource "aws_lambda_function" "lambda" {
  filename         = "bootstrap.zip"
<<<<<<< HEAD
  function_name    = "aws-lamda-rust-test-terraform"
=======
  function_name    = "aws-lamda-test-terrform"
>>>>>>> e4233f806bf4f8a90784b2201823ca77960f0631
  role             = aws_iam_role.lambda-iam.arn
  handler          = "lambda.lambda_handler"
  source_code_hash = data.archive_file.bootstrap-zip.output_base64sha256
  runtime          = "provided.al2"
}

resource "aws_apigatewayv2_api" "lambda-api" {
  name          = "v2-http-api"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_stage" "lambda-stage" {
  api_id      = aws_apigatewayv2_api.lambda-api.id
  name        = "$default"
  auto_deploy = true
}

resource "aws_apigatewayv2_integration" "lambda-integration" {
  api_id               = aws_apigatewayv2_api.lambda-api.id
  integration_type     = "AWS_PROXY"
  integration_method   = "POST"
  integration_uri      = aws_lambda_function.lambda.invoke_arn
  passthrough_behavior = "WHEN_NO_MATCH"
}

resource "aws_apigatewayv2_route" "lambda-route" {
  api_id    = aws_apigatewayv2_api.lambda-api.id
<<<<<<< HEAD
  route_key = "ANY /{proxy+}"
=======
  route_key = "GET /{proxy+}"
>>>>>>> e4233f806bf4f8a90784b2201823ca77960f0631
  target    = "integrations/${aws_apigatewayv2_integration.lambda-integration.id}"
}

resource "aws_lambda_permission" "api-gw" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda.arn
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.lambda-api.execution_arn}/*/*/*"
}




