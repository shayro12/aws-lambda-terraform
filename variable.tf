variable "aws_region" {

}
variable "default_tags" {

}
variable "email_address" {

}
variable "managed_policy_arns" {
  type        = list(string)
  description = "arn of managed iam policies (by deafualt allow to create cloudwatch log group)"
  default     = ["arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"]
}
variable "bucket-name" {
  description = "name of the bucket that will trigger the lambda"
  nullable    = true

}
variable "s3-trigger" {
  type        = bool
  description = "create s3 trigger configuration?"
  default     = true
}
variable "ses" {
  description = "create ses configuration?"
  default     = true
  type        = bool
}
