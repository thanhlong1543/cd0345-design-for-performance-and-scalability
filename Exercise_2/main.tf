provider "aws" {
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  region     = var.aws_region
}

resource "aws_iam_role" "iam_for_lambda" {
  name               = "iam_for_lambda"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : "sts:AssumeRole",
        "Principal" : {
          "Service" : "lambda.amazonaws.com"
        },
        "Effect" : "Allow",
        "Sid" : ""
      }
    ]
  })
}


data "archive_file" "zip_python_code" {
  type        = "zip"
  source_dir  = "${path.module}/"
  output_path = "${path.module}/greeting-python.zip"
}

resource "aws_lambda_function" "lambda_by_terraform" {
  filename      = "${path.module}/greeting-python.zip"
  function_name = "lambda_by_terraform"
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "greet_lambda.lambda_handler"
  runtime       = "python3.8"
  environment {
    variables = {
      greeting = "environment greeting"
    }
  }
}
