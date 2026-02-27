# =============================================================================
# S3 Origin Example
# CloudFront distribution serving content from an S3 bucket with OAC
# =============================================================================

module "cloudfront" {
  source = "../../cloudfront"

  account_name = var.account_name
  project_name = var.project_name

  # OAC for S3 bucket access
  origin_access_controls = {
    s3-bucket = {
      description                       = "OAC for S3 bucket origin"
      origin_access_control_origin_type = "s3"
      signing_behavior                  = "always"
      signing_protocol                  = "sigv4"
    }
  }

  # CloudFront distribution
  distributions = {
    website = {
      comment             = "S3 static website distribution"
      default_root_object = "index.html"
      price_class         = "PriceClass_100"

      origin = [
        {
          origin_id                 = "s3-origin"
          domain_name               = "${var.bucket_name}.s3.amazonaws.com"
          origin_access_control_key = "s3-bucket"
        }
      ]

      default_cache_behavior = {
        target_origin_id       = "s3-origin"
        viewer_protocol_policy = "redirect-to-https"
        allowed_methods        = ["GET", "HEAD", "OPTIONS"]
        cached_methods         = ["GET", "HEAD"]
        compress               = true
        cache_policy_name      = "Managed-CachingOptimized"
      }

      custom_error_response = [
        {
          error_code            = 404
          response_code         = 200
          response_page_path    = "/index.html"
          error_caching_min_ttl = 10
        },
        {
          error_code            = 403
          response_code         = 200
          response_page_path    = "/index.html"
          error_caching_min_ttl = 10
        }
      ]

      viewer_certificate = {
        cloudfront_default_certificate = true
      }
    }
  }

  tags = {
    Environment = var.account_name
    Project     = var.project_name
    ManagedBy   = "terraform"
  }
}
