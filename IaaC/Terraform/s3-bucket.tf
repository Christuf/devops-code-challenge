resource "aws_s3_bucket" "fe-bucket" {
  bucket = "fe-bucket-christuf"

  tags = {
    Name        = "Frontend S3 Bucket"
    Environment = "Production"
  }
lifecycle {
  prevent_destroy = true
}
}