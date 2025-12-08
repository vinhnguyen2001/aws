output "website_url" {
  description = "Public endpoint of S3 static website hosting"
  value       = aws_s3_bucket_website_configuration.aws_boostup_bucket_website.website_endpoint
}
