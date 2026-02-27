# =============================================================================
# Origin Access Controls (OAC)
# =============================================================================

resource "aws_cloudfront_origin_access_control" "this" {
  for_each = { for k, v in var.origin_access_controls : k => v if var.create }

  name = "${local.name_prefix}cf-oac-${var.account_name}-${var.project_name}-${each.key}"

  description                       = each.value.description != null ? each.value.description : "OAC for ${local.name_prefix}cf-${var.account_name}-${var.project_name}-${each.key}"
  origin_access_control_origin_type = each.value.origin_access_control_origin_type
  signing_behavior                  = each.value.signing_behavior
  signing_protocol                  = each.value.signing_protocol
}
