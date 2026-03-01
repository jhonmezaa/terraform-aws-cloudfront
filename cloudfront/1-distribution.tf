# =============================================================================
# CloudFront Distributions
# =============================================================================

resource "aws_cloudfront_distribution" "this" {
  for_each = { for k, v in var.distributions : k => v if var.create }

  comment                         = each.value.comment != null ? each.value.comment : "${local.name_prefix}cf-${var.account_name}-${var.project_name}-${each.key}"
  enabled                         = each.value.enabled
  is_ipv6_enabled                 = each.value.is_ipv6_enabled
  http_version                    = each.value.http_version
  price_class                     = each.value.price_class
  default_root_object             = each.value.default_root_object
  web_acl_id                      = each.value.web_acl_id
  retain_on_delete                = each.value.retain_on_delete
  wait_for_deployment             = each.value.wait_for_deployment
  staging                         = each.value.staging
  continuous_deployment_policy_id = each.value.continuous_deployment_policy_id
  aliases                         = each.value.aliases

  # ===========================================================================
  # Default Cache Behavior
  # ===========================================================================

  default_cache_behavior {
    target_origin_id       = each.value.default_cache_behavior.target_origin_id
    viewer_protocol_policy = each.value.default_cache_behavior.viewer_protocol_policy
    allowed_methods        = each.value.default_cache_behavior.allowed_methods
    cached_methods         = each.value.default_cache_behavior.cached_methods
    compress               = each.value.default_cache_behavior.compress

    # Policy-based configuration
    cache_policy_id = coalesce(
      each.value.default_cache_behavior.cache_policy_id,
      each.value.default_cache_behavior.cache_policy_key != null ? try(aws_cloudfront_cache_policy.this[each.value.default_cache_behavior.cache_policy_key].id, null) : null,
      each.value.default_cache_behavior.cache_policy_name != null ? try(data.aws_cloudfront_cache_policy.this[each.value.default_cache_behavior.cache_policy_name].id, null) : null,
      null
    )

    origin_request_policy_id = try(coalesce(
      each.value.default_cache_behavior.origin_request_policy_id,
      each.value.default_cache_behavior.origin_request_policy_key != null ? try(aws_cloudfront_origin_request_policy.this[each.value.default_cache_behavior.origin_request_policy_key].id, null) : null,
      each.value.default_cache_behavior.origin_request_policy_name != null ? try(data.aws_cloudfront_origin_request_policy.this[each.value.default_cache_behavior.origin_request_policy_name].id, null) : null,
    ), null)

    response_headers_policy_id = try(coalesce(
      each.value.default_cache_behavior.response_headers_policy_id,
      each.value.default_cache_behavior.response_headers_policy_key != null ? try(aws_cloudfront_response_headers_policy.this[each.value.default_cache_behavior.response_headers_policy_key].id, null) : null,
      each.value.default_cache_behavior.response_headers_policy_name != null ? try(data.aws_cloudfront_response_headers_policy.this[each.value.default_cache_behavior.response_headers_policy_name].id, null) : null,
    ), null)

    # Legacy TTL settings (only when not using cache policy)
    default_ttl = each.value.default_cache_behavior.default_ttl
    min_ttl     = each.value.default_cache_behavior.min_ttl
    max_ttl     = each.value.default_cache_behavior.max_ttl

    # Legacy forwarded values (only when not using cache policy)
    dynamic "forwarded_values" {
      for_each = (
        each.value.default_cache_behavior.cache_policy_id == null &&
        each.value.default_cache_behavior.cache_policy_key == null &&
        each.value.default_cache_behavior.cache_policy_name == null &&
        each.value.default_cache_behavior.forwarded_values != null
      ) ? [each.value.default_cache_behavior.forwarded_values] : []

      content {
        query_string            = forwarded_values.value.query_string
        query_string_cache_keys = forwarded_values.value.query_string_cache_keys
        headers                 = forwarded_values.value.headers

        dynamic "cookies" {
          for_each = forwarded_values.value.cookies != null ? [forwarded_values.value.cookies] : []

          content {
            forward           = cookies.value.forward
            whitelisted_names = cookies.value.whitelisted_names
          }
        }
      }
    }

    # CloudFront Function associations
    dynamic "function_association" {
      for_each = each.value.default_cache_behavior.function_association

      content {
        event_type = function_association.value.event_type
        function_arn = coalesce(
          function_association.value.function_arn,
          function_association.value.function_key != null ? try(aws_cloudfront_function.this[function_association.value.function_key].arn, null) : null
        )
      }
    }

    # Lambda@Edge associations
    dynamic "lambda_function_association" {
      for_each = each.value.default_cache_behavior.lambda_function_association

      content {
        event_type   = lambda_function_association.value.event_type
        lambda_arn   = lambda_function_association.value.lambda_arn
        include_body = lambda_function_association.value.include_body
      }
    }

    field_level_encryption_id = each.value.default_cache_behavior.field_level_encryption_id
    realtime_log_config_arn   = each.value.default_cache_behavior.realtime_log_config_arn
    smooth_streaming          = each.value.default_cache_behavior.smooth_streaming
    trusted_key_groups        = each.value.default_cache_behavior.trusted_key_groups
    trusted_signers           = each.value.default_cache_behavior.trusted_signers
  }

  # ===========================================================================
  # Ordered Cache Behaviors
  # ===========================================================================

  dynamic "ordered_cache_behavior" {
    for_each = each.value.ordered_cache_behavior

    content {
      path_pattern           = ordered_cache_behavior.value.path_pattern
      target_origin_id       = ordered_cache_behavior.value.target_origin_id
      viewer_protocol_policy = ordered_cache_behavior.value.viewer_protocol_policy
      allowed_methods        = ordered_cache_behavior.value.allowed_methods
      cached_methods         = ordered_cache_behavior.value.cached_methods
      compress               = ordered_cache_behavior.value.compress

      # Policy-based configuration
      cache_policy_id = coalesce(
        ordered_cache_behavior.value.cache_policy_id,
        ordered_cache_behavior.value.cache_policy_key != null ? try(aws_cloudfront_cache_policy.this[ordered_cache_behavior.value.cache_policy_key].id, null) : null,
        ordered_cache_behavior.value.cache_policy_name != null ? try(data.aws_cloudfront_cache_policy.this[ordered_cache_behavior.value.cache_policy_name].id, null) : null,
        null
      )

      origin_request_policy_id = try(coalesce(
        ordered_cache_behavior.value.origin_request_policy_id,
        ordered_cache_behavior.value.origin_request_policy_key != null ? try(aws_cloudfront_origin_request_policy.this[ordered_cache_behavior.value.origin_request_policy_key].id, null) : null,
        ordered_cache_behavior.value.origin_request_policy_name != null ? try(data.aws_cloudfront_origin_request_policy.this[ordered_cache_behavior.value.origin_request_policy_name].id, null) : null,
      ), null)

      response_headers_policy_id = try(coalesce(
        ordered_cache_behavior.value.response_headers_policy_id,
        ordered_cache_behavior.value.response_headers_policy_key != null ? try(aws_cloudfront_response_headers_policy.this[ordered_cache_behavior.value.response_headers_policy_key].id, null) : null,
        ordered_cache_behavior.value.response_headers_policy_name != null ? try(data.aws_cloudfront_response_headers_policy.this[ordered_cache_behavior.value.response_headers_policy_name].id, null) : null,
      ), null)

      # Legacy TTL settings
      default_ttl = ordered_cache_behavior.value.default_ttl
      min_ttl     = ordered_cache_behavior.value.min_ttl
      max_ttl     = ordered_cache_behavior.value.max_ttl

      # Legacy forwarded values
      dynamic "forwarded_values" {
        for_each = (
          ordered_cache_behavior.value.cache_policy_id == null &&
          ordered_cache_behavior.value.cache_policy_key == null &&
          ordered_cache_behavior.value.cache_policy_name == null &&
          ordered_cache_behavior.value.forwarded_values != null
        ) ? [ordered_cache_behavior.value.forwarded_values] : []

        content {
          query_string            = forwarded_values.value.query_string
          query_string_cache_keys = forwarded_values.value.query_string_cache_keys
          headers                 = forwarded_values.value.headers

          dynamic "cookies" {
            for_each = forwarded_values.value.cookies != null ? [forwarded_values.value.cookies] : []

            content {
              forward           = cookies.value.forward
              whitelisted_names = cookies.value.whitelisted_names
            }
          }
        }
      }

      # CloudFront Function associations
      dynamic "function_association" {
        for_each = ordered_cache_behavior.value.function_association

        content {
          event_type = function_association.value.event_type
          function_arn = coalesce(
            function_association.value.function_arn,
            function_association.value.function_key != null ? try(aws_cloudfront_function.this[function_association.value.function_key].arn, null) : null
          )
        }
      }

      # Lambda@Edge associations
      dynamic "lambda_function_association" {
        for_each = ordered_cache_behavior.value.lambda_function_association

        content {
          event_type   = lambda_function_association.value.event_type
          lambda_arn   = lambda_function_association.value.lambda_arn
          include_body = lambda_function_association.value.include_body
        }
      }

      field_level_encryption_id = ordered_cache_behavior.value.field_level_encryption_id
      realtime_log_config_arn   = ordered_cache_behavior.value.realtime_log_config_arn
      smooth_streaming          = ordered_cache_behavior.value.smooth_streaming
      trusted_key_groups        = ordered_cache_behavior.value.trusted_key_groups
      trusted_signers           = ordered_cache_behavior.value.trusted_signers
    }
  }

  # ===========================================================================
  # Origins
  # ===========================================================================

  dynamic "origin" {
    for_each = each.value.origin

    content {
      origin_id           = origin.value.origin_id
      domain_name         = origin.value.domain_name
      origin_path         = origin.value.origin_path
      connection_attempts = origin.value.connection_attempts
      connection_timeout  = origin.value.connection_timeout

      origin_access_control_id = try(coalesce(
        origin.value.origin_access_control_id,
        origin.value.origin_access_control_key != null ? try(aws_cloudfront_origin_access_control.this[origin.value.origin_access_control_key].id, null) : null
      ), null)

      dynamic "custom_origin_config" {
        for_each = origin.value.custom_origin_config != null ? [origin.value.custom_origin_config] : []

        content {
          http_port                = custom_origin_config.value.http_port
          https_port               = custom_origin_config.value.https_port
          origin_protocol_policy   = custom_origin_config.value.origin_protocol_policy
          origin_ssl_protocols     = custom_origin_config.value.origin_ssl_protocols
          origin_keepalive_timeout = custom_origin_config.value.origin_keepalive_timeout
          origin_read_timeout      = custom_origin_config.value.origin_read_timeout
        }
      }

      dynamic "s3_origin_config" {
        for_each = origin.value.s3_origin_config != null ? [origin.value.s3_origin_config] : []

        content {
          origin_access_identity = s3_origin_config.value.origin_access_identity
        }
      }

      dynamic "origin_shield" {
        for_each = origin.value.origin_shield != null ? [origin.value.origin_shield] : []

        content {
          enabled              = origin_shield.value.enabled
          origin_shield_region = origin_shield.value.origin_shield_region
        }
      }

      dynamic "custom_header" {
        for_each = origin.value.custom_header

        content {
          name  = custom_header.value.name
          value = custom_header.value.value
        }
      }
    }
  }

  # ===========================================================================
  # Origin Groups (Failover)
  # ===========================================================================

  dynamic "origin_group" {
    for_each = each.value.origin_group

    content {
      origin_id = origin_group.value.origin_id

      failover_criteria {
        status_codes = origin_group.value.failover_status_codes
      }

      member {
        origin_id = origin_group.value.primary_member_origin_id
      }

      member {
        origin_id = origin_group.value.secondary_member_origin_id
      }
    }
  }

  # ===========================================================================
  # Viewer Certificate
  # ===========================================================================

  viewer_certificate {
    acm_certificate_arn            = each.value.viewer_certificate.acm_certificate_arn
    iam_certificate_id             = each.value.viewer_certificate.iam_certificate_id
    cloudfront_default_certificate = each.value.viewer_certificate.cloudfront_default_certificate
    minimum_protocol_version       = each.value.viewer_certificate.minimum_protocol_version
    ssl_support_method             = each.value.viewer_certificate.acm_certificate_arn != null || each.value.viewer_certificate.iam_certificate_id != null ? each.value.viewer_certificate.ssl_support_method : null
  }

  # ===========================================================================
  # Geo Restriction
  # ===========================================================================

  restrictions {
    geo_restriction {
      restriction_type = each.value.geo_restriction.restriction_type
      locations        = each.value.geo_restriction.locations
    }
  }

  # ===========================================================================
  # Custom Error Responses
  # ===========================================================================

  dynamic "custom_error_response" {
    for_each = each.value.custom_error_response

    content {
      error_code            = custom_error_response.value.error_code
      response_code         = custom_error_response.value.response_code
      response_page_path    = custom_error_response.value.response_page_path
      error_caching_min_ttl = custom_error_response.value.error_caching_min_ttl
    }
  }

  # ===========================================================================
  # Logging Configuration
  # ===========================================================================

  dynamic "logging_config" {
    for_each = each.value.logging_config != null ? [each.value.logging_config] : []

    content {
      bucket          = logging_config.value.bucket
      prefix          = logging_config.value.prefix
      include_cookies = logging_config.value.include_cookies
    }
  }

  tags = merge(
    var.tags,
    each.value.tags,
    {
      Name = "${local.name_prefix}cf-${var.account_name}-${var.project_name}-${each.key}"
    }
  )

  depends_on = [
    aws_cloudfront_function.this,
    aws_cloudfront_origin_access_control.this,
    aws_cloudfront_cache_policy.this,
    aws_cloudfront_origin_request_policy.this,
    aws_cloudfront_response_headers_policy.this,
  ]
}
