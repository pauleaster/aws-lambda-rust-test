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
  function_name    = "aws-lamda-rust-test-terraform"
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
  route_key = "GET /{proxy+}"
  target    = "integrations/${aws_apigatewayv2_integration.lambda-integration.id}"
}

resource "aws_lambda_permission" "api-gw" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda.arn
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.lambda-api.execution_arn}/*/*/*"
}

# See also the following AWS managed policy: AWSLambdaBasicExecutionRole
resource "aws_iam_policy" "lambda_logging_1" {
  name        = "lambda_logging_1"
  path        = "/"
  description = "IAM policy for logging from a lambda"

  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Action" : [
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:PutLogEvents"
          ],
          "Resource" : "arn:aws:logs:*:*:*",
          "Effect" : "Deny"
        }
      ]
    }
  )
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.lambda-iam.name
  policy_arn = aws_iam_policy.lambda_logging_1.arn
}



