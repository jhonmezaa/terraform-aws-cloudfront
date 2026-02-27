# =============================================================================
# CloudFront Functions
# =============================================================================

resource "aws_cloudfront_function" "this" {
  for_each = { for k, v in var.functions : k => v if var.create }

  name    = replace("${local.name_prefix}cf_fn_${var.account_name}_${var.project_name}_${each.key}", "-", "_")
  runtime = each.value.runtime
  comment = each.value.comment
  code    = each.value.code
  publish = each.value.publish

  key_value_store_associations = each.value.key_value_store_associations
}
