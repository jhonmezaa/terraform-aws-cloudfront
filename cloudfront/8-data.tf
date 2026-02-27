data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

data "aws_partition" "current" {}

# =============================================================================
# AWS-Managed and Named Policy Lookups
# =============================================================================

data "aws_cloudfront_cache_policy" "this" {
  for_each = var.create ? local.cache_policy_names : toset([])

  name = each.key
}

data "aws_cloudfront_origin_request_policy" "this" {
  for_each = var.create ? local.origin_request_policy_names : toset([])

  name = each.key
}

data "aws_cloudfront_response_headers_policy" "this" {
  for_each = var.create ? local.response_headers_policy_names : toset([])

  name = each.key
}
