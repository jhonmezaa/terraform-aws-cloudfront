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

variable "alb_arn" {
  description = "ARN of the internal Application Load Balancer used as VPC origin."
  type        = string
}

variable "alb_dns_name" {
  description = "DNS name of the internal Application Load Balancer."
  type        = string
}
