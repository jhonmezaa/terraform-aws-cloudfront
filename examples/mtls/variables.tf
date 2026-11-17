variable "region" {
  description = "AWS region."
  type        = string
  default     = "us-east-1"
}

variable "account_name" {
  description = "Account name for resource naming."
  type        = string
}

variable "project_name" {
  description = "Project name for resource naming."
  type        = string
}

variable "aliases" {
  description = "Alternate domain names (CNAMEs) for the distribution."
  type        = list(string)
}

variable "acm_certificate_arn" {
  description = "ARN of the ACM certificate (us-east-1) that covers the aliases."
  type        = string
}

variable "ca_bundle_bucket" {
  description = "S3 bucket that holds the CA certificates bundle (PEM) for the trust store."
  type        = string
}

variable "ca_bundle_key" {
  description = "S3 object key of the CA certificates bundle."
  type        = string
  default     = "ca-bundle.pem"
}

variable "ca_bundle_region" {
  description = "Region of the S3 bucket that holds the CA certificates bundle."
  type        = string
  default     = "us-east-1"
}

variable "origin_domain_name" {
  description = "Domain name of the HTTPS origin."
  type        = string
}

variable "origin_client_certificate_arn" {
  description = "ARN of the ACM client certificate (us-east-1, TLS client authentication EKU) presented to the origin. Null disables origin mTLS."
  type        = string
  default     = null
}

variable "anycast_ip_list_id" {
  description = "ID of an existing CloudFront Anycast static IP list. Null to use the default CloudFront IPs."
  type        = string
  default     = null
}

variable "create_connection_function" {
  description = "Create and associate the example connection function (requires a service quota increase)."
  type        = bool
  default     = false
}
