# =============================================================================
# Origin Request Policies
# =============================================================================

resource "aws_cloudfront_origin_request_policy" "this" {
  for_each = { for k, v in var.origin_request_policies : k => v if var.create }

  name = "${local.name_prefix}cf-orp-${var.account_name}-${var.project_name}-${each.key}"

  comment = each.value.comment

  cookies_config {
    cookie_behavior = each.value.cookies_config.cookie_behavior

    dynamic "cookies" {
      for_each = length(each.value.cookies_config.cookies) > 0 ? [true] : []

      content {
        items = each.value.cookies_config.cookies
      }
    }
  }

  headers_config {
    header_behavior = each.value.headers_config.header_behavior

    dynamic "headers" {
      for_each = length(each.value.headers_config.headers) > 0 ? [true] : []

      content {
        items = each.value.headers_config.headers
      }
    }
  }

  query_strings_config {
    query_string_behavior = each.value.query_strings_config.query_string_behavior

    dynamic "query_strings" {
      for_each = length(each.value.query_strings_config.query_strings) > 0 ? [true] : []

      content {
        items = each.value.query_strings_config.query_strings
      }
    }
  }
}
