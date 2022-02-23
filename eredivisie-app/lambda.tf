# -------------------------------------------------------------
# API Lambda function
# -------------------------------------------------------------

resource "random_uuid" "lambda" {}

resource "aws_lambda_function" "api" {
  function_name = "${var.environment}-eredivisie-lambda-${random_uuid.lambda.result}"

  s3_bucket = aws_s3_bucket.lambda-bucket.id
  s3_key    = aws_s3_bucket_object.lambda_api.key

  runtime = "python3.7"
  handler = "lambda_function.lambda_handler"

  source_code_hash = data.archive_file.lambda_api.output_base64sha256

  role = aws_iam_role.lambda_exec.arn

  layers = [aws_lambda_layer_version.lambda_layer_pandas.arn, "arn:aws:lambda:eu-central-1:292169987271:layer:AWSLambda-Python37-SciPy1x:35"]

  environment {
    variables = {
      BUCKET_NAME = aws_s3_bucket.api-data.id
      BUCKET_KEY  = aws_s3_bucket_object.api-data-object.key
    }
  }

  tags = {
    Name        = "api lambda"
    Environment = "${var.environment}"
  }
}

# -------------------------------------------------------------
# Lambda layer
# -------------------------------------------------------------

resource "aws_lambda_layer_version" "lambda_layer_pandas" {
  filename   = "../lambda/layers/pandas/python.zip"
  layer_name = "pandas"

  compatible_runtimes = ["python3.7"]
}

# -------------------------------------------------------------
# Lambda policies
# -------------------------------------------------------------

# Create role for creating lambda function
resource "aws_iam_role" "lambda_exec" {
  name = "serverless_lambda"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

# Create policy to access s3 bucket
resource "aws_iam_policy" "s3_bucket_policy" {
  name        = "s3-api-data-bucket-access"
  description = "Policy for accessing s3 bucket containing api data"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:*"
      ],
      "Effect": "Allow",
      "Resource": "${aws_s3_bucket.api-data.arn}/*"
    }
  ]
}
EOF
}

# Add policy to lambda_exec role
resource "aws_iam_role_policy_attachment" "lambda_policy" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = aws_iam_policy.s3_bucket_policy.arn
}