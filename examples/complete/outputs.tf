output "distribution_id" {
  description = "CloudFront distribution ID."
  value       = module.cloudfront.distribution_ids["main"]
}

output "distribution_domain_name" {
  description = "CloudFront distribution domain name."
  value       = module.cloudfront.distribution_domain_names["main"]
}

output "distribution_hosted_zone_id" {
  description = "CloudFront Route 53 hosted zone ID."
  value       = module.cloudfront.distribution_hosted_zone_ids["main"]
}

output "oac_ids" {
  description = "Origin Access Control IDs."
  value       = module.cloudfront.origin_access_control_ids
}

output "cache_policy_ids" {
  description = "Cache policy IDs."
  value       = module.cloudfront.cache_policy_ids
}

output "origin_request_policy_ids" {
  description = "Origin request policy IDs."
  value       = module.cloudfront.origin_request_policy_ids
}

output "response_headers_policy_ids" {
  description = "Response headers policy IDs."
  value       = module.cloudfront.response_headers_policy_ids
}

output "function_arns" {
  description = "CloudFront Function ARNs."
  value       = module.cloudfront.function_arns
}
