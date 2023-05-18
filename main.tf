# data "aws_iam_policy_document" "assume_role" {
#   statement {
#     effect = "Allow"

#     principals {
#       type        = "Service"
#       identifiers = ["lambda.amazonaws.com"]
#     }

#     actions = ["sts:AssumeRole"]
#   }
# }

# resource "aws_iam_role" "iam_for_lambda" {
#   name               = "iam_for_lambda"
#   assume_role_policy = data.aws_iam_policy_document.assume_role.json
# }

data "archive_file" "lambda" {
  type             = "zip"
  source_dir       = "${path.module}/lambda_code"
  output_path      = "lambda_function_payload.zip"
  output_file_mode = "0666"

}

# resource "aws_lambda_function" "test_lambda" {
#   # If the file is not in the current working directory you will need to include a
#   # path.module in the filename.
#   filename      = "lambda_function_payload.zip"
#   function_name = "lambda_function_name"
#   role          = aws_iam_role.iam_for_lambda.arn
#   handler       = "index.test"

#   source_code_hash = data.archive_file.lambda.output_base64sha256

#   runtime = "nodejs16.x"

#   environment {
#     variables = {
#       foo = "bar"
#     }
#   }
# }
