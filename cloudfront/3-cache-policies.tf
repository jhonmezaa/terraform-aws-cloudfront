# =============================================================================
# Cache Policies
# =============================================================================

resource "aws_cloudfront_cache_policy" "this" {
  for_each = { for k, v in var.cache_policies : k => v if var.create }

  name = "${local.name_prefix}cf-cp-${var.account_name}-${var.project_name}-${each.key}"

  comment     = each.value.comment
  default_ttl = each.value.default_ttl
  max_ttl     = each.value.max_ttl
  min_ttl     = each.value.min_ttl

  parameters_in_cache_key_and_forwarded_to_origin {
    enable_accept_encoding_brotli = each.value.parameters_in_cache_key_and_forwarded_to_origin.enable_accept_encoding_brotli
    enable_accept_encoding_gzip   = each.value.parameters_in_cache_key_and_forwarded_to_origin.enable_accept_encoding_gzip

    cookies_config {
      cookie_behavior = each.value.parameters_in_cache_key_and_forwarded_to_origin.cookies_config.cookie_behavior

      dynamic "cookies" {
        for_each = length(each.value.parameters_in_cache_key_and_forwarded_to_origin.cookies_config.cookies) > 0 ? [true] : []

        content {
          items = each.value.parameters_in_cache_key_and_forwarded_to_origin.cookies_config.cookies
        }
      }
    }

    headers_config {
      header_behavior = each.value.parameters_in_cache_key_and_forwarded_to_origin.headers_config.header_behavior

      dynamic "headers" {
        for_each = length(each.value.parameters_in_cache_key_and_forwarded_to_origin.headers_config.headers) > 0 ? [true] : []

        content {
          items = each.value.parameters_in_cache_key_and_forwarded_to_origin.headers_config.headers
        }
      }
    }

    query_strings_config {
      query_string_behavior = each.value.parameters_in_cache_key_and_forwarded_to_origin.query_strings_config.query_string_behavior

      dynamic "query_strings" {
        for_each = length(each.value.parameters_in_cache_key_and_forwarded_to_origin.query_strings_config.query_strings) > 0 ? [true] : []

        content {
          items = each.value.parameters_in_cache_key_and_forwarded_to_origin.query_strings_config.query_strings
        }
      }
    }
  }
}
