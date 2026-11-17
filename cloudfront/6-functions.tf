# =============================================================================
# CloudFront Functions
# =============================================================================

resource "aws_cloudfront_function" "this" {
  for_each = { for k, v in var.functions : k => v if var.create }

  name    = local.function_names[each.key]
  runtime = each.value.runtime
  comment = each.value.comment
  code    = each.value.code
  publish = each.value.publish

  key_value_store_associations = each.value.key_value_store_associations
}
