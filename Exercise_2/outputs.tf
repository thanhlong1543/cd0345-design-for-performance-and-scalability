# TODO: Define the output variable for the lambda function.
output "greeting" {
  description = "Hello lambda function"
  value       = "module.lambda_by_terraform.output"
}

