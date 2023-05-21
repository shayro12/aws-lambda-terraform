data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "iam_for_lambda" {
  name                = "iam_for_lambda"
  assume_role_policy  = data.aws_iam_policy_document.assume_role.json
  managed_policy_arns = var.managed_policy_arns //list fo managed policies arn's 
  # inline_policy {
  #   name   = "ses-lambda"
  #   policy = data.aws_iam_policy_document.lambda_ses.json
  # }
}
// policy that allow the lambda to send email from ses identity
data "aws_iam_policy_document" "lambda_ses" {
  count = var.ses ? 1 : 0
  statement {
    effect = "Allow"

    actions = [
      "ses:SendEmail",
    ]

    resources = [data.aws_ses_email_identity.ses_identity[0].arn]
  }
}
resource "aws_iam_policy" "lambda_ses" {
  count       = var.ses ? 1 : 0
  name        = "lambda_ses"
  path        = "/"
  description = "policy that allow the lambda to send email from ses identity"
  policy      = data.aws_iam_policy_document.lambda_ses[0].json
}
resource "aws_iam_role_policy_attachment" "ses" {
  count      = var.ses ? 1 : 0
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = aws_iam_policy.lambda_ses[0].arn
}

data "archive_file" "lambda" {
  type             = "zip"
  source_dir       = "${path.module}/lambda_code"
  output_path      = "lambda_function_payload.zip"
  output_file_mode = "0666"

}

resource "aws_lambda_function" "test_lambda" {
  # If the file is not in the current working directory you will need to include a
  # path.module in the filename.
  filename      = "lambda_function_payload.zip"
  function_name = "lambda_function_shay_test"
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "function.lambda_handler"

  source_code_hash = data.archive_file.lambda.output_base64sha256

  runtime = "python3.9"

  environment {
    variables = {
      email_address = var.email_address
    }
  }
}


data "aws_ses_email_identity" "ses_identity" {
  count = var.ses ? 1 : 0
  email = var.email_address
}

data "aws_s3_bucket" "bucket" {
  count  = var.s3-trigger ? 1 : 0
  bucket = var.bucket-name
}
resource "aws_s3_bucket_notification" "aws-lambda-trigger" {
  count  = var.s3-trigger ? 1 : 0
  bucket = data.aws_s3_bucket.bucket[0].id
  lambda_function {
    lambda_function_arn = aws_lambda_function.test_lambda.arn
    events              = ["s3:ObjectCreated:*"] #["s3:ObjectCreated:*", "s3:ObjectRemoved:*"]
    filter_prefix       = "lambda/"              //prefix -- scope the event to spesific location
  }
}
resource "aws_lambda_permission" "test" {
  count         = var.s3-trigger ? 1 : 0
  statement_id  = "AllowS3Invoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.test_lambda.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = "arn:aws:s3:::${data.aws_s3_bucket.bucket[0].id}"
}
