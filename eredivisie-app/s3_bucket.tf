# -------------------------------------------------------------
# API Data
# -------------------------------------------------------------
resource "random_pet" "api-data-name" {
  prefix = "${var.environment}-api-data"
  length = 3
}

resource "aws_s3_bucket" "api-data" {
  bucket = random_pet.api-data-name.id
  acl    = "private"

  tags = {
    Name        = "api data"
    Environment = "${var.environment}"
  }
}

resource "aws_s3_bucket_object" "api-data-object" {
  bucket   = aws_s3_bucket.api-data.id
  key      = "eredivisie_results.csv"
  source   = "${path.module}/data/eredivisie_results.csv"
  etag     = filemd5("${path.module}/data/eredivisie_results.csv")
}

# -------------------------------------------------------------
# Lambda Logic
# -------------------------------------------------------------

resource "random_pet" "lambda-bucket-name" {
  prefix = "${var.environment}-lambda-bucket"
  length = 3
}

resource "aws_s3_bucket" "lambda-bucket" {
  bucket = random_pet.lambda-bucket-name.id

  acl           = "private"
  force_destroy = true

  tags = {
    Environment = "${var.environment}"
  }
}

data "archive_file" "lambda_api" {
  type = "zip"

  source_dir  = "${path.module}/lambda/lambda_payload/api"
  output_path = "api.zip"

}

resource "aws_s3_bucket_object" "lambda_api" {
  bucket = aws_s3_bucket.lambda-bucket.id

  key    = "api.zip"
  source = data.archive_file.lambda_api.output_path

  etag = filemd5(data.archive_file.lambda_api.output_path)

  tags = {
    Name        = "api lambda code"
    Environment = "${var.environment}"
  }
}
