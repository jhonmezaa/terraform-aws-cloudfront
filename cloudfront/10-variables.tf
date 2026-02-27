# =============================================================================
# General Configuration Variables
# =============================================================================

variable "create" {
  description = "Whether to create CloudFront resources."
  type        = bool
  default     = true
}

# =============================================================================
# Naming Variables
# =============================================================================

variable "account_name" {
  description = "Account name for resource naming."
  type        = string

  validation {
    condition     = length(var.account_name) > 0 && length(var.account_name) <= 32
    error_message = "account_name must be between 1 and 32 characters."
  }

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.account_name))
    error_message = "account_name can only contain lowercase letters, numbers, and hyphens."
  }
}

variable "project_name" {
  description = "Project name for resource naming."
  type        = string

  validation {
    condition     = length(var.project_name) > 0 && length(var.project_name) <= 32
    error_message = "project_name must be between 1 and 32 characters."
  }

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.project_name))
    error_message = "project_name can only contain lowercase letters, numbers, and hyphens."
  }
}

variable "region_prefix" {
  description = "Region prefix for naming. If not provided, will be derived from current region."
  type        = string
  default     = null
}

variable "use_region_prefix" {
  description = "Whether to include the region prefix in resource names."
  type        = bool
  default     = true
}

variable "tags" {
  description = "Additional tags to apply to all resources."
  type        = map(string)
  default     = {}
}

# =============================================================================
# CloudFront Distributions
# =============================================================================

variable "distributions" {
  description = "Map of CloudFront distribution configurations."
  type = map(object({
    comment             = optional(string)
    enabled             = optional(bool, true)
    is_ipv6_enabled     = optional(bool, true)
    http_version        = optional(string, "http2and3")
    price_class         = optional(string, "PriceClass_100")
    default_root_object = optional(string)
    web_acl_id          = optional(string)
    retain_on_delete    = optional(bool, false)
    wait_for_deployment = optional(bool, true)
    staging             = optional(bool, false)

    continuous_deployment_policy_id = optional(string)

    aliases = optional(list(string), [])

    # Default cache behavior
    default_cache_behavior = object({
      target_origin_id       = string
      viewer_protocol_policy = optional(string, "redirect-to-https")
      allowed_methods        = optional(list(string), ["GET", "HEAD"])
      cached_methods         = optional(list(string), ["GET", "HEAD"])
      compress               = optional(bool, true)

      # Policy-based (recommended)
      cache_policy_id              = optional(string)
      cache_policy_name            = optional(string)
      cache_policy_key             = optional(string)
      origin_request_policy_id     = optional(string)
      origin_request_policy_name   = optional(string)
      origin_request_policy_key    = optional(string)
      response_headers_policy_id   = optional(string)
      response_headers_policy_name = optional(string)
      response_headers_policy_key  = optional(string)

      # Legacy TTL settings (used when no cache policy)
      default_ttl = optional(number)
      min_ttl     = optional(number)
      max_ttl     = optional(number)

      # Legacy forwarded values (used when no cache policy)
      forwarded_values = optional(object({
        query_string            = optional(bool, false)
        query_string_cache_keys = optional(list(string))
        headers                 = optional(list(string))
        cookies = optional(object({
          forward           = optional(string, "none")
          whitelisted_names = optional(list(string))
        }))
      }))

      # Function associations
      function_association = optional(list(object({
        event_type   = string
        function_arn = optional(string)
        function_key = optional(string)
      })), [])

      # Lambda@Edge associations
      lambda_function_association = optional(list(object({
        event_type   = string
        lambda_arn   = string
        include_body = optional(bool, false)
      })), [])

      field_level_encryption_id = optional(string)
      realtime_log_config_arn   = optional(string)
      smooth_streaming          = optional(bool)
      trusted_key_groups        = optional(list(string))
      trusted_signers           = optional(list(string))
    })

    # Ordered cache behaviors
    ordered_cache_behavior = optional(list(object({
      path_pattern           = string
      target_origin_id       = string
      viewer_protocol_policy = optional(string, "redirect-to-https")
      allowed_methods        = optional(list(string), ["GET", "HEAD"])
      cached_methods         = optional(list(string), ["GET", "HEAD"])
      compress               = optional(bool, true)

      # Policy-based (recommended)
      cache_policy_id              = optional(string)
      cache_policy_name            = optional(string)
      cache_policy_key             = optional(string)
      origin_request_policy_id     = optional(string)
      origin_request_policy_name   = optional(string)
      origin_request_policy_key    = optional(string)
      response_headers_policy_id   = optional(string)
      response_headers_policy_name = optional(string)
      response_headers_policy_key  = optional(string)

      # Legacy TTL settings
      default_ttl = optional(number)
      min_ttl     = optional(number)
      max_ttl     = optional(number)

      # Legacy forwarded values
      forwarded_values = optional(object({
        query_string            = optional(bool, false)
        query_string_cache_keys = optional(list(string))
        headers                 = optional(list(string))
        cookies = optional(object({
          forward           = optional(string, "none")
          whitelisted_names = optional(list(string))
        }))
      }))

      # Function associations
      function_association = optional(list(object({
        event_type   = string
        function_arn = optional(string)
        function_key = optional(string)
      })), [])

      # Lambda@Edge associations
      lambda_function_association = optional(list(object({
        event_type   = string
        lambda_arn   = string
        include_body = optional(bool, false)
      })), [])

      field_level_encryption_id = optional(string)
      realtime_log_config_arn   = optional(string)
      smooth_streaming          = optional(bool)
      trusted_key_groups        = optional(list(string))
      trusted_signers           = optional(list(string))
    })), [])

    # Origins
    origin = list(object({
      origin_id           = string
      domain_name         = string
      origin_path         = optional(string)
      connection_attempts = optional(number)
      connection_timeout  = optional(number)

      # Origin Access Control
      origin_access_control_id  = optional(string)
      origin_access_control_key = optional(string)

      # Origin Shield
      origin_shield = optional(object({
        enabled              = bool
        origin_shield_region = optional(string)
      }))

      # Custom origin configuration (ALB, API Gateway, HTTP)
      custom_origin_config = optional(object({
        http_port                = optional(number, 80)
        https_port               = optional(number, 443)
        origin_protocol_policy   = string
        origin_ssl_protocols     = optional(list(string), ["TLSv1.2"])
        origin_keepalive_timeout = optional(number)
        origin_read_timeout      = optional(number)
      }))

      # S3 origin configuration (legacy OAI)
      s3_origin_config = optional(object({
        origin_access_identity = optional(string)
      }))

      # Custom headers sent to origin
      custom_header = optional(list(object({
        name  = string
        value = string
      })), [])
    }))

    # Origin groups (failover)
    origin_group = optional(list(object({
      origin_id                  = string
      failover_status_codes      = list(number)
      primary_member_origin_id   = string
      secondary_member_origin_id = string
    })), [])

    # Viewer certificate (SSL/TLS)
    viewer_certificate = optional(object({
      acm_certificate_arn            = optional(string)
      iam_certificate_id             = optional(string)
      cloudfront_default_certificate = optional(bool)
      minimum_protocol_version       = optional(string, "TLSv1.2_2021")
      ssl_support_method             = optional(string, "sni-only")
    }), { cloudfront_default_certificate = true })

    # Geo restriction
    geo_restriction = optional(object({
      restriction_type = optional(string, "none")
      locations        = optional(list(string), [])
    }), { restriction_type = "none", locations = [] })

    # Custom error responses
    custom_error_response = optional(list(object({
      error_code            = number
      response_code         = optional(number)
      response_page_path    = optional(string)
      error_caching_min_ttl = optional(number)
    })), [])

    # Standard logging (v1)
    logging_config = optional(object({
      bucket          = string
      prefix          = optional(string)
      include_cookies = optional(bool, false)
    }))

    # Monitoring subscription
    create_monitoring_subscription       = optional(bool, false)
    realtime_metrics_subscription_status = optional(string, "Enabled")

    tags = optional(map(string), {})
  }))
  default = {}
}

# =============================================================================
# Origin Access Controls
# =============================================================================

variable "origin_access_controls" {
  description = "Map of CloudFront Origin Access Control configurations."
  type = map(object({
    description                       = optional(string)
    origin_access_control_origin_type = optional(string, "s3")
    signing_behavior                  = optional(string, "always")
    signing_protocol                  = optional(string, "sigv4")
  }))
  default = {}
}

# =============================================================================
# Cache Policies
# =============================================================================

variable "cache_policies" {
  description = "Map of CloudFront cache policy configurations."
  type = map(object({
    comment     = optional(string)
    default_ttl = optional(number, 86400)
    max_ttl     = optional(number, 31536000)
    min_ttl     = optional(number, 0)

    parameters_in_cache_key_and_forwarded_to_origin = object({
      cookies_config = object({
        cookie_behavior = string
        cookies         = optional(list(string), [])
      })
      headers_config = object({
        header_behavior = string
        headers         = optional(list(string), [])
      })
      query_strings_config = object({
        query_string_behavior = string
        query_strings         = optional(list(string), [])
      })
      enable_accept_encoding_brotli = optional(bool, true)
      enable_accept_encoding_gzip   = optional(bool, true)
    })
  }))
  default = {}
}

# =============================================================================
# Origin Request Policies
# =============================================================================

variable "origin_request_policies" {
  description = "Map of CloudFront origin request policy configurations."
  type = map(object({
    comment = optional(string)

    cookies_config = object({
      cookie_behavior = string
      cookies         = optional(list(string), [])
    })
    headers_config = object({
      header_behavior = string
      headers         = optional(list(string), [])
    })
    query_strings_config = object({
      query_string_behavior = string
      query_strings         = optional(list(string), [])
    })
  }))
  default = {}
}

# =============================================================================
# Response Headers Policies
# =============================================================================

variable "response_headers_policies" {
  description = "Map of CloudFront response headers policy configurations."
  type = map(object({
    comment = optional(string)

    cors_config = optional(object({
      access_control_allow_credentials = bool
      origin_override                  = bool
      access_control_max_age_sec       = optional(number)
      access_control_allow_headers     = list(string)
      access_control_allow_methods     = list(string)
      access_control_allow_origins     = list(string)
      access_control_expose_headers    = optional(list(string))
    }))

    custom_headers_config = optional(list(object({
      header   = string
      override = bool
      value    = string
    })))

    remove_headers_config = optional(list(object({
      header = string
    })))

    security_headers_config = optional(object({
      content_security_policy = optional(object({
        content_security_policy = string
        override                = bool
      }))
      content_type_options = optional(object({
        override = bool
      }))
      frame_options = optional(object({
        frame_option = string
        override     = bool
      }))
      referrer_policy = optional(object({
        referrer_policy = string
        override        = bool
      }))
      strict_transport_security = optional(object({
        access_control_max_age_sec = number
        override                   = bool
        include_subdomains         = optional(bool)
        preload                    = optional(bool)
      }))
      xss_protection = optional(object({
        mode_block = bool
        override   = bool
        protection = bool
        report_uri = optional(string)
      }))
    }))

    server_timing_headers_config = optional(object({
      enabled       = bool
      sampling_rate = number
    }))
  }))
  default = {}
}

# =============================================================================
# CloudFront Functions
# =============================================================================

variable "functions" {
  description = "Map of CloudFront Function configurations."
  type = map(object({
    comment = optional(string)
    runtime = optional(string, "cloudfront-js-2.0")
    code    = string
    publish = optional(bool, true)

    key_value_store_associations = optional(list(string))
  }))
  default = {}
}
