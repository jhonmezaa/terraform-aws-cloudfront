# =============================================================================
# Origin Access Controls (OAC)
# =============================================================================

resource "aws_cloudfront_origin_access_control" "this" {
  for_each = { for k, v in var.origin_access_controls : k => v if var.create }

  name = local.origin_access_control_names[each.key]

  description                       = each.value.description != null ? each.value.description : "OAC for ${local.name_prefix}cf-${var.account_name}-${var.project_name}-${each.key}"
  origin_access_control_origin_type = each.value.origin_access_control_origin_type
  signing_behavior                  = each.value.signing_behavior
  signing_protocol                  = each.value.signing_protocol
}

# =============================================================================
# VPC Origins (private ALB / NLB / EC2 behind CloudFront)
# =============================================================================

resource "aws_cloudfront_vpc_origin" "this" {
  for_each = { for k, v in var.vpc_origins : k => v if var.create }

  vpc_origin_endpoint_config {
    name                   = local.vpc_origin_names[each.key]
    arn                    = each.value.arn
    http_port              = each.value.http_port
    https_port             = each.value.https_port
    origin_protocol_policy = each.value.origin_protocol_policy

    origin_ssl_protocols {
      items    = each.value.origin_ssl_protocols
      quantity = length(each.value.origin_ssl_protocols)
    }
  }

  dynamic "timeouts" {
    for_each = each.value.timeouts != null ? [each.value.timeouts] : []

    content {
      create = timeouts.value.create
      update = timeouts.value.update
      delete = timeouts.value.delete
    }
  }

  tags = merge(
    local.tags_common,
    each.value.tags,
    {
      Name      = local.vpc_origin_names[each.key]
      ManagedBy = "Terraform"
    }
  )
}
