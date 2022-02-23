# -------------------------------------------------------------
# API Data
# -------------------------------------------------------------

resource "random_pet" "api-data-name" {
  prefix = "${var.environment}-terraform-api-data"
  length = 5
}

resource "aws_s3_bucket" "api-data" {
  bucket = random_pet.api-data-name.id

  tags = {
    Name        = "api data"
    Environment = "${var.environment}"
  }
}

resource "aws_s3_bucket_acl" "api-data-acl" {
  bucket = aws_s3_bucket.api-data.id
  acl    = "private"
}

resource "aws_s3_object" "api-data-object" {
  for_each = fileset("../data/", "*")
  bucket   = aws_s3_bucket.api-data.id
  key      = each.value
  source   = "../data/${each.value}"
  etag     = filemd5("../data/${each.value}")
}

# -------------------------------------------------------------
# Lambda Data
# -------------------------------------------------------------

resource "random_pet" "lambda-bucket-name" {
  prefix = "${var.environment}-lambda-bucket"
  length = 5
}

resource "aws_s3_bucket" "lambda-bucket" {
  bucket = random_pet.lambda-bucket-name.id

  force_destroy = true

  tags = {
    Environment = "${var.environment}"
  }
}

resource "aws_s3_bucket_acl" "lambda-bucket-acl" {
  bucket = aws_s3_bucket.lambda-bucket.id
  acl    = "private"
}

data "archive_file" "lambda_api" {
  type = "zip"

  source_dir  = "./lambda_payload/api"
  output_path = "api.zip"

}

resource "aws_s3_object" "lambda_api" {
  bucket = aws_s3_bucket.lambda-bucket.id

  key    = "api.zip"
  source = data.archive_file.lambda_api.output_path

  etag = filemd5(data.archive_file.lambda_api.output_path)

  tags = {
    Name        = "api lambda code"
    Environment = "${var.environment}"
  }
}
