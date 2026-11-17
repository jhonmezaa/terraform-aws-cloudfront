# =============================================================================
# mTLS Example
# CloudFront distribution that requires viewer client certificates (viewer
# mTLS with a trust store), presents a client certificate to the origin
# (origin mTLS), extracts cache tags from origin responses and, optionally,
# runs a connection function during the TLS handshake.
# =============================================================================

module "cloudfront" {
  source = "../../cloudfront"

  account_name = var.account_name
  project_name = var.project_name

  # CA bundle (PEM) in S3 used to validate viewer client certificates
  trust_stores = {
    clients = {
      ca_certificates_bundle_s3_location = {
        bucket = var.ca_bundle_bucket
        key    = var.ca_bundle_key
        region = var.ca_bundle_region
      }
    }
  }

  # The default service quota for connection functions is zero: request an
  # increase before setting create_connection_function = true
  connection_functions = var.create_connection_function ? {
    check-org = {
      comment = "Allow only client certificates issued to the expected organization"
      code    = file("${path.module}/functions/connection.js")
    }
  } : {}

  distributions = {
    app = {
      comment = "CloudFront distribution with viewer and origin mTLS"
      aliases = var.aliases

      viewer_certificate = {
        acm_certificate_arn = var.acm_certificate_arn
        ssl_support_method  = "sni-only"
      }

      viewer_mtls_config = {
        mode = "required"
        trust_store_config = {
          trust_store_key                = "clients"
          advertise_trust_store_ca_names = true
          ignore_certificate_expiry      = false
        }
      }

      connection_function_association = var.create_connection_function ? { key = "check-org" } : null

      anycast_ip_list_id = var.anycast_ip_list_id

      cache_tag_config = {
        header_name = "Cache-Tag"
      }

      origin = [
        {
          origin_id                   = "api"
          domain_name                 = var.origin_domain_name
          response_completion_timeout = 60
          custom_origin_config = {
            origin_protocol_policy = "https-only"
            ip_address_type        = "dualstack"
            origin_mtls_config = var.origin_client_certificate_arn != null ? {
              client_certificate_arn = var.origin_client_certificate_arn
            } : null
          }
        }
      ]

      default_cache_behavior = {
        target_origin_id           = "api"
        viewer_protocol_policy     = "https-only"
        allowed_methods            = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
        cached_methods             = ["GET", "HEAD"]
        cache_policy_name          = "Managed-CachingOptimized"
        origin_request_policy_name = "Managed-AllViewerExceptHostHeader"
      }
    }
  }

  tags_common = {
    Environment = var.account_name
    Project     = var.project_name
  }
}
