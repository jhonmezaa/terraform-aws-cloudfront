# =============================================================================
# VPC Origin Example
# CloudFront distribution in front of a private (internal) ALB using a
# CloudFront VPC origin, with caching disabled and gRPC enabled on /grpc/*
# =============================================================================

module "cloudfront" {
  source = "../../cloudfront"

  account_name = var.account_name
  project_name = var.project_name

  # VPC origin pointing to the internal ALB
  vpc_origins = {
    internal-alb = {
      arn                    = var.alb_arn
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  distributions = {
    app = {
      comment = "Private ALB behind CloudFront VPC origin"

      origin = [
        {
          origin_id   = "internal-alb"
          domain_name = var.alb_dns_name
          vpc_origin_config = {
            vpc_origin_key = "internal-alb"
          }
        }
      ]

      default_cache_behavior = {
        target_origin_id           = "internal-alb"
        viewer_protocol_policy     = "redirect-to-https"
        allowed_methods            = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
        cached_methods             = ["GET", "HEAD"]
        cache_policy_name          = "Managed-CachingDisabled"
        origin_request_policy_name = "Managed-AllViewerExceptHostHeader"
      }

      ordered_cache_behavior = [
        {
          path_pattern               = "/grpc/*"
          target_origin_id           = "internal-alb"
          allowed_methods            = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
          cached_methods             = ["GET", "HEAD"]
          cache_policy_name          = "Managed-CachingDisabled"
          origin_request_policy_name = "Managed-AllViewerExceptHostHeader"
          grpc_config = {
            enabled = true
          }
        }
      ]
    }
  }

  tags_common = {
    Environment = var.account_name
    Project     = var.project_name
  }
}
