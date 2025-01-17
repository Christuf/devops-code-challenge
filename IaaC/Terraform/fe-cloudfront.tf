data "aws_cloudfront_origin_request_policy" "origin_request_policy" {
  name = var.origin_request_policy_name
}

data "aws_cloudfront_cache_policy" "cache_policy" {
  name = var.cache_policy_name
}

module "cdn" {
  source = "terraform-aws-modules/cloudfront/aws"
  version = "2.9.3"
  comment             = "frontend cdn"
  enabled             = true
  is_ipv6_enabled     = true
  price_class         = "PriceClass_All"
  retain_on_delete    = false
  wait_for_deployment = false
  default_root_object = "index.html"
  custom_error_response = [{
    error_caching_min_ttl = 0
    error_code            = 403
    response_code         = 200
    response_page_path    = "/index.html"
  }]
  create_origin_access_identity = true
  origin_access_identities = {
    s3_bucket_one = "cloudfront-s3-access"
  }

  origin = {
    s3_one = {
      domain_name = aws_s3_bucket.fe-bucket.bucket_domain_name
      s3_origin_config = {
        origin_access_identity = "s3_bucket_one"
      }
    origin_shield = {
    enabled = true
    origin_shield_region = "us-east-1"
     }
    }
  }


  default_cache_behavior = {
    target_origin_id           = "s3_one"
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
    cached_methods  = ["GET", "HEAD"]
    origin_request_policy_id = data.aws_cloudfront_origin_request_policy.origin_request_policy.id
    cache_policy_id = data.aws_cloudfront_cache_policy.cache_policy.id
    response_headers_policy_id = "eaab4381-ed33-4a86-88ca-d9558dc6cd63"
    compress        = true
    query_string    = false
    use_forwarded_values = false

  }
}

data "aws_iam_policy_document" "s3_cf_iam_doc" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.fe-bucket.arn}/*"]

    principals {
      type        = "AWS"
      identifiers = [module.cdn.cloudfront_origin_access_identity_iam_arns[0]]
    }
  }
  depends_on = [
    module.cdn
  ]
}


resource "aws_s3_bucket_policy" "s3_policy_cf_only" {
  bucket = aws_s3_bucket.fe-bucket.id
  policy = data.aws_iam_policy_document.s3_cf_iam_doc.json
  depends_on = [
    aws_s3_bucket.fe-bucket
  ]
}
