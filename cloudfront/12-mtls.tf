# =============================================================================
# Trust Stores (viewer mTLS CA bundles)
# =============================================================================

resource "aws_cloudfront_trust_store" "this" {
  for_each = { for k, v in var.trust_stores : k => v if var.create }

  name = local.trust_store_names[each.key]

  ca_certificates_bundle_source {
    ca_certificates_bundle_s3_location {
      bucket  = each.value.ca_certificates_bundle_s3_location.bucket
      key     = each.value.ca_certificates_bundle_s3_location.key
      region  = each.value.ca_certificates_bundle_s3_location.region
      version = each.value.ca_certificates_bundle_s3_location.version
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
      Name      = local.trust_store_names[each.key]
      ManagedBy = "Terraform"
    }
  )
}

# =============================================================================
# Connection Functions (run during the viewer TLS handshake)
# =============================================================================

resource "aws_cloudfront_connection_function" "this" {
  for_each = { for k, v in var.connection_functions : k => v if var.create }

  name                     = local.connection_function_names[each.key]
  connection_function_code = each.value.code
  publish                  = each.value.publish

  connection_function_config {
    comment = coalesce(each.value.comment, local.connection_function_names[each.key])
    runtime = each.value.runtime

    dynamic "key_value_store_association" {
      for_each = each.value.key_value_store_arns

      content {
        key_value_store_arn = key_value_store_association.value
      }
    }
  }

  tags = merge(
    local.tags_common,
    each.value.tags,
    {
      Name      = local.connection_function_names[each.key]
      ManagedBy = "Terraform"
    }
  )
}
