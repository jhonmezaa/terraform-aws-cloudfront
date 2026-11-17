output "distribution_id" {
  description = "CloudFront distribution ID."
  value       = module.cloudfront.distribution_ids["app"]
}

output "distribution_domain_name" {
  description = "CloudFront distribution domain name."
  value       = module.cloudfront.distribution_domain_names["app"]
}

output "vpc_origin_ids" {
  description = "CloudFront VPC origin IDs."
  value       = module.cloudfront.vpc_origin_ids
}
