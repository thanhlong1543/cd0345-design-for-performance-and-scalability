provider "aws" {
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  region     = var.aws_region
}

resource "aws_iam_role" "lambda_role" {
  name               = "Lambda Function Role"
  assume_role_policy = {
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
  }

}

resource "aws_iam_policy" "lambda_iam_policy" {
  name        = "lambda_iam_policy"
  path        = "/"
  description = "AWS IAM Policy for aws lambda"
  policy      = {
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
  }
}

resource "aws_iam_role_policy_attachment" "attach_iam_policy_to_iam_role" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_iam_policy.arn
}

data "archive_file" "zip_python_code" {
  type        = "zip"
  source_dir  = "${path.module}/"
  output_path = "${path.module}/greeting-python.zip"
}

resource "aws_lambda_function" "lambda_by_terraform" {
  filename      = "${path.module}/greeting-python.zip"
  function_name = "lambda by terraform"
  role          = aws_iam_role.lambda_role.arn
  handler       = "greet_lambda.lambda_handler"
  runtime       = "python3.8"
  depends_on    = [aws_iam_role_policy_attachment.attach_iam_policy_to_iam_role]
  environment {
    variables = {
      greeting = "environment greeting"
    }
  }
}
