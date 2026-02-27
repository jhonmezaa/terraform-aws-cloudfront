# =============================================================================
# Distribution Outputs
# =============================================================================

output "distributions" {
  description = "Map of CloudFront distribution attributes."
  value = {
    for k, v in aws_cloudfront_distribution.this : k => {
      id                             = v.id
      arn                            = v.arn
      domain_name                    = v.domain_name
      hosted_zone_id                 = v.hosted_zone_id
      status                         = v.status
      etag                           = v.etag
      last_modified_time             = v.last_modified_time
      caller_reference               = v.caller_reference
      in_progress_validation_batches = v.in_progress_validation_batches
      trusted_signers                = v.trusted_signers
    }
  }
}

output "distribution_ids" {
  description = "Map of distribution keys to their IDs."
  value       = { for k, v in aws_cloudfront_distribution.this : k => v.id }
}

output "distribution_arns" {
  description = "Map of distribution keys to their ARNs."
  value       = { for k, v in aws_cloudfront_distribution.this : k => v.arn }
}

output "distribution_domain_names" {
  description = "Map of distribution keys to their domain names."
  value       = { for k, v in aws_cloudfront_distribution.this : k => v.domain_name }
}

output "distribution_hosted_zone_ids" {
  description = "Map of distribution keys to their Route 53 hosted zone IDs."
  value       = { for k, v in aws_cloudfront_distribution.this : k => v.hosted_zone_id }
}

# =============================================================================
# Origin Access Control Outputs
# =============================================================================

output "origin_access_controls" {
  description = "Map of Origin Access Control attributes."
  value = {
    for k, v in aws_cloudfront_origin_access_control.this : k => {
      id   = v.id
      etag = v.etag
    }
  }
}

output "origin_access_control_ids" {
  description = "Map of OAC keys to their IDs."
  value       = { for k, v in aws_cloudfront_origin_access_control.this : k => v.id }
}

# =============================================================================
# Cache Policy Outputs
# =============================================================================

output "cache_policies" {
  description = "Map of cache policy attributes."
  value = {
    for k, v in aws_cloudfront_cache_policy.this : k => {
      id   = v.id
      etag = v.etag
    }
  }
}

output "cache_policy_ids" {
  description = "Map of cache policy keys to their IDs."
  value       = { for k, v in aws_cloudfront_cache_policy.this : k => v.id }
}

# =============================================================================
# Origin Request Policy Outputs
# =============================================================================

output "origin_request_policies" {
  description = "Map of origin request policy attributes."
  value = {
    for k, v in aws_cloudfront_origin_request_policy.this : k => {
      id   = v.id
      etag = v.etag
    }
  }
}

output "origin_request_policy_ids" {
  description = "Map of origin request policy keys to their IDs."
  value       = { for k, v in aws_cloudfront_origin_request_policy.this : k => v.id }
}

# =============================================================================
# Response Headers Policy Outputs
# =============================================================================

output "response_headers_policies" {
  description = "Map of response headers policy attributes."
  value = {
    for k, v in aws_cloudfront_response_headers_policy.this : k => {
      id   = v.id
      etag = v.etag
    }
  }
}

output "response_headers_policy_ids" {
  description = "Map of response headers policy keys to their IDs."
  value       = { for k, v in aws_cloudfront_response_headers_policy.this : k => v.id }
}

# =============================================================================
# CloudFront Function Outputs
# =============================================================================

output "functions" {
  description = "Map of CloudFront Function attributes."
  value = {
    for k, v in aws_cloudfront_function.this : k => {
      arn             = v.arn
      etag            = v.etag
      name            = v.name
      status          = v.status
      live_stage_etag = v.live_stage_etag
    }
  }
}

output "function_arns" {
  description = "Map of function keys to their ARNs."
  value       = { for k, v in aws_cloudfront_function.this : k => v.arn }
}

# =============================================================================
# Monitoring Subscription Outputs
# =============================================================================

output "monitoring_subscriptions" {
  description = "Map of monitoring subscription IDs."
  value       = { for k, v in aws_cloudfront_monitoring_subscription.this : k => v.id }
}
