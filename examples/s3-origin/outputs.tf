output "distribution_id" {
  description = "CloudFront distribution ID."
  value       = module.cloudfront.distribution_ids["website"]
}

output "distribution_domain_name" {
  description = "CloudFront distribution domain name."
  value       = module.cloudfront.distribution_domain_names["website"]
}

output "oac_id" {
  description = "Origin Access Control ID."
  value       = module.cloudfront.origin_access_control_ids["s3-bucket"]
}
