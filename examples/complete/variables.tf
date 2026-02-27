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

variable "bucket_name" {
  description = "Name of the S3 bucket to use as origin."
  type        = string
}

variable "alb_dns_name" {
  description = "DNS name of the ALB for API origin."
  type        = string
}

variable "domain_name" {
  description = "Custom domain name for the distribution."
  type        = string
}

variable "acm_certificate_arn" {
  description = "ARN of the ACM certificate for the custom domain."
  type        = string
}

variable "logging_bucket" {
  description = "S3 bucket domain name for access logs."
  type        = string
}
