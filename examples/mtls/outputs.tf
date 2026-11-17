output "distribution_id" {
  description = "CloudFront distribution ID."
  value       = module.cloudfront.distribution_ids["app"]
}

output "distribution_domain_name" {
  description = "CloudFront distribution domain name."
  value       = module.cloudfront.distribution_domain_names["app"]
}

output "trust_store_ids" {
  description = "CloudFront trust store IDs."
  value       = module.cloudfront.trust_store_ids
}

output "connection_function_arns" {
  description = "CloudFront connection function ARNs (empty unless create_connection_function = true)."
  value       = module.cloudfront.connection_function_arns
}
