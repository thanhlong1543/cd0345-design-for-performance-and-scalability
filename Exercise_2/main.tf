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

resource "aws_iam_policy" "lambda_iam_policy" {
  name        = "lambda_iam_policy"
  path        = "/"
  description = "AWS IAM Policy for aws lambda"
  policy      = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        "Resource" : "arn:aws:logs:*:*:*",
        "Effect" : "Allow"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_iam_policy_to_iam_role" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = aws_iam_policy.lambda_iam_policy.arn
}


data "archive_file" "zip_python_code" {
  type        = "zip"
  source_dir  = "${path.module}/python"
  output_path = "${path.module}/python/greeting-python.zip"
}

resource "aws_lambda_function" "lambda_by_terraform" {
  filename      = "${path.module}/python/greeting-python.zip"
  function_name = "lambda_by_terraform"
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "greet_lambda.lambda_handler"
  runtime       = "python3.8"
  depends_on    = [aws_iam_role_policy_attachment.attach_iam_policy_to_iam_role]
  environment {
    variables = {
      greeting = "environment greeting"
    }
  }
}
