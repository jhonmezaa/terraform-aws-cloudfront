# =============================================================================
# Complete Example
# CloudFront with S3 + ALB origins, custom cache policies, security headers,
# CloudFront Functions, geo restriction, custom error responses, and logging
# =============================================================================

module "cloudfront" {
  source = "../../cloudfront"

  account_name = var.account_name
  project_name = var.project_name

  # ===========================================================================
  # Origin Access Controls
  # ===========================================================================

  origin_access_controls = {
    s3-assets = {
      description                       = "OAC for S3 static assets"
      origin_access_control_origin_type = "s3"
      signing_behavior                  = "always"
      signing_protocol                  = "sigv4"
    }
  }

  # ===========================================================================
  # Custom Cache Policies
  # ===========================================================================

  cache_policies = {
    static-assets = {
      comment     = "Cache policy for static assets"
      default_ttl = 86400
      max_ttl     = 31536000
      min_ttl     = 0

      parameters_in_cache_key_and_forwarded_to_origin = {
        cookies_config = {
          cookie_behavior = "none"
        }
        headers_config = {
          header_behavior = "none"
        }
        query_strings_config = {
          query_string_behavior = "none"
        }
        enable_accept_encoding_brotli = true
        enable_accept_encoding_gzip   = true
      }
    }

    api = {
      comment     = "Cache policy for API responses"
      default_ttl = 0
      max_ttl     = 0
      min_ttl     = 0

      parameters_in_cache_key_and_forwarded_to_origin = {
        cookies_config = {
          cookie_behavior = "none"
        }
        headers_config = {
          header_behavior = "whitelist"
          headers         = ["Authorization", "Accept"]
        }
        query_strings_config = {
          query_string_behavior = "all"
        }
        enable_accept_encoding_brotli = true
        enable_accept_encoding_gzip   = true
      }
    }
  }

  # ===========================================================================
  # Origin Request Policies
  # ===========================================================================

  origin_request_policies = {
    api = {
      comment = "Forward all headers to API origin"

      cookies_config = {
        cookie_behavior = "all"
      }
      headers_config = {
        header_behavior = "allViewer"
      }
      query_strings_config = {
        query_string_behavior = "all"
      }
    }
  }

  # ===========================================================================
  # Response Headers Policies
  # ===========================================================================

  response_headers_policies = {
    security = {
      comment = "Security headers for all responses"

      security_headers_config = {
        content_type_options = {
          override = true
        }
        frame_options = {
          frame_option = "DENY"
          override     = true
        }
        referrer_policy = {
          referrer_policy = "strict-origin-when-cross-origin"
          override        = true
        }
        strict_transport_security = {
          access_control_max_age_sec = 31536000
          override                   = true
          include_subdomains         = true
          preload                    = true
        }
        xss_protection = {
          mode_block = true
          override   = true
          protection = true
        }
      }

      custom_headers_config = [
        {
          header   = "X-Custom-Header"
          override = true
          value    = "custom-value"
        }
      ]
    }
  }

  # ===========================================================================
  # CloudFront Functions
  # ===========================================================================

  functions = {
    url-rewrite = {
      comment = "Rewrite URLs for SPA routing"
      runtime = "cloudfront-js-2.0"
      publish = true
      code    = <<-EOF
        function handler(event) {
          var request = event.request;
          var uri = request.uri;

          // If the URI doesn't have a file extension, rewrite to /index.html
          if (!uri.includes('.')) {
            request.uri = '/index.html';
          }

          return request;
        }
      EOF
    }

    security-headers = {
      comment = "Add security headers to viewer response"
      runtime = "cloudfront-js-2.0"
      publish = true
      code    = <<-EOF
        function handler(event) {
          var response = event.response;
          var headers = response.headers;

          headers['permissions-policy'] = { value: 'camera=(), microphone=(), geolocation=()' };

          return response;
        }
      EOF
    }
  }

  # ===========================================================================
  # Distributions
  # ===========================================================================

  distributions = {
    main = {
      comment             = "Main website distribution"
      default_root_object = "index.html"
      http_version        = "http2and3"
      price_class         = "PriceClass_100"
      aliases             = [var.domain_name]

      # Origins
      origin = [
        {
          origin_id                 = "s3-assets"
          domain_name               = "${var.bucket_name}.s3.amazonaws.com"
          origin_access_control_key = "s3-assets"
        },
        {
          origin_id   = "alb-api"
          domain_name = var.alb_dns_name
          custom_origin_config = {
            origin_protocol_policy = "https-only"
            origin_ssl_protocols   = ["TLSv1.2"]
          }
          custom_header = [
            {
              name  = "X-Custom-Origin"
              value = "cloudfront"
            }
          ]
        }
      ]

      # Default cache behavior (S3 static assets)
      default_cache_behavior = {
        target_origin_id            = "s3-assets"
        viewer_protocol_policy      = "redirect-to-https"
        allowed_methods             = ["GET", "HEAD", "OPTIONS"]
        cached_methods              = ["GET", "HEAD"]
        compress                    = true
        cache_policy_key            = "static-assets"
        response_headers_policy_key = "security"

        function_association = [
          {
            event_type   = "viewer-request"
            function_key = "url-rewrite"
          },
          {
            event_type   = "viewer-response"
            function_key = "security-headers"
          }
        ]
      }

      # Ordered cache behavior for API
      ordered_cache_behavior = [
        {
          path_pattern                = "/api/*"
          target_origin_id            = "alb-api"
          viewer_protocol_policy      = "https-only"
          allowed_methods             = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
          cached_methods              = ["GET", "HEAD"]
          compress                    = true
          cache_policy_key            = "api"
          origin_request_policy_key   = "api"
          response_headers_policy_key = "security"
        }
      ]

      # Viewer certificate (ACM)
      viewer_certificate = {
        acm_certificate_arn      = var.acm_certificate_arn
        minimum_protocol_version = "TLSv1.2_2021"
        ssl_support_method       = "sni-only"
      }

      # Geo restriction
      geo_restriction = {
        restriction_type = "whitelist"
        locations        = ["US", "CA", "GB", "DE", "FR"]
      }

      # Custom error responses (SPA routing)
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

      # Access logging
      logging_config = {
        bucket          = var.logging_bucket
        prefix          = "cloudfront/"
        include_cookies = false
      }

      # Monitoring
      create_monitoring_subscription = true

      tags = {
        Component = "frontend"
      }
    }
  }

  tags = {
    Environment = var.account_name
    Project     = var.project_name
    ManagedBy   = "terraform"
  }
}
