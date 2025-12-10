
resource "aws_s3_bucket" "aws_boostup_bucket" {
  bucket = var.bucket_name

  tags = {
    Name        = "${var.project_name}-s3-bucket"
    Environment = var.environment
  }
}


# Disable Block Public Access
resource "aws_s3_bucket_public_access_block" "aws_boostup_bucket_public_access_block" {
  bucket = aws_s3_bucket.aws_boostup_bucket.id


  # Settings to allow public access for website hosting
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}


# Configure the S3 Bucket for Website Hosting
resource "aws_s3_bucket_website_configuration" "aws_boostup_bucket_website" {
  bucket = aws_s3_bucket.aws_boostup_bucket.id


  index_document {
    suffix = "index.html"
  }
  error_document {
    key = "error.html"
  }

  depends_on = [aws_s3_bucket_public_access_block.aws_boostup_bucket_public_access_block]
}


# Set Bucket Policy to Allow Public Read Access for Website Hosting
resource "aws_s3_bucket_policy" "aws_boostup_bucket_policy" {
  bucket = aws_s3_bucket.aws_boostup_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.aws_boostup_bucket.arn}/*"
      }
    ]
  })

  depends_on = [aws_s3_bucket_website_configuration.aws_boostup_bucket_website]
}


# Upload Website Files to S3 Bucket

locals {
  source_files = fileset(var.website_source_directory, "**")
}

resource "aws_s3_object" "aws_boostup_website_files" {
  for_each = local.source_files
  
  bucket = aws_s3_bucket.aws_boostup_bucket.id
  key    = each.value
  source = "${var.website_source_directory}/${each.value}"

  content_type = lookup(
    {
      "html" = "text/html"
      "css"  = "text/css"
      "js"   = "application/javascript"
      "png"  = "image/png"
      "jpg"  = "image/jpeg"
      "gif"  = "image/gif"
      "svg"  = "image/svg+xml"
    },
    split(".", each.value)[length(split(".", each.value)) - 1],
    "application/octet-stream"
  )

  depends_on = [aws_s3_bucket_public_access_block.aws_boostup_bucket_public_access_block]
}
