data "archive_file" "create_lambda_zip" {
    type          = "zip"
    source_file   = "${path.module}/create_rds_mysql_db_snapshot.py"
    output_path   = "${path.module}/create_rds_mysql_db_snapshot.zip"
}

resource "aws_s3_bucket" "mybucket" {
  bucket = "krishnamarammydrbucket"
  acl    = "private"
}

resource "aws_s3_bucket_object" "this" {
 bucket = aws_s3_bucket.mybucket.id
 key    = "create_rds_mysql_db_snapshot.zip"
 source = "${path.module}/create_rds_mysql_db_snapshot.zip"
}

resource "aws_lambda_function" "create_lambda" {
  s3_bucket = aws_s3_bucket.mybucket.id
  s3_key = "create_rds_mysql_db_snapshot.zip"
  function_name    = "create_rds_mysql_db_snapshot"
  role             = "${aws_iam_role.iam_role_for_lambda.arn}"
  handler          = "create_rds_mysql_db_snapshot.lambda_handler"
  timeout = "300"
  vpc_config {
    subnet_ids         = ["${var.privatesubnet}"]
    security_group_ids = ["${var.websg}"]
  }
  runtime          = "python3.7"
}

resource "aws_iam_role" "iam_role_for_lambda" {
  name = "iam_role_for_lambda"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_policy" "iam_policy_for_lambda" {
  name = "iam_policy_for_lambda"
  policy = "${file("${path.module}/create_rds_mysql_db_snapshot.json")}"
}

resource "aws_iam_policy_attachment" "iam_policy_attachment_for_lambda" {
  name = "iam_policy_attachment_for_lambda"
  roles = ["${aws_iam_role.iam_role_for_lambda.name}"]
  policy_arn = "${aws_iam_policy.iam_policy_for_lambda.arn}"
}






data "archive_file" "transfer_lambda_zip" {
    type          = "zip"
    source_file   = "${path.module}/transfer_rds_mysql_db_snapshot.py"
    output_path   = "${path.module}/transfer_rds_mysql_db_snapshot.zip"
}

resource "aws_s3_bucket_object" "this_zip" {
 bucket = aws_s3_bucket.mybucket.id
 key    = "transfer_rds_mysql_db_snapshot.zip"
 source = "${path.module}/transfer_rds_mysql_db_snapshot.zip"
}

resource "aws_lambda_function" "transfer_lambda" {
  s3_bucket = aws_s3_bucket.mybucket.id
  s3_key = "transfer_rds_mysql_db_snapshot.zip"
  function_name    = "transfer_rds_mysql_db_snapshot"
  role             = "${aws_iam_role.iam_role_for_lambda.arn}"
  handler          = "transfer_rds_mysql_db_snapshot.lambda_handler"
  timeout = "300"
  vpc_config {
    subnet_ids         = ["${var.privatesubnet}"]
    security_group_ids = ["${var.websg}"]
  }
  runtime          = "python3.7"
}
