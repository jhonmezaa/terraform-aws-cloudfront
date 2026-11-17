# Complete Example

CloudFront distribution with:

- S3 origin through OAC (default behavior) and ALB custom origin for `/api/*`
- Custom cache policies (`static-assets`, `api`), origin request policy and response headers policy with security headers
- CloudFront Functions (viewer request URL rewrite and viewer response headers)
- ACM certificate and alias, geo restriction, custom error responses
- Standard access logging to S3 and a real-time metrics monitoring subscription

## Usage

```bash
terraform init
terraform plan \
  -var account_name=prod \
  -var project_name=myapp \
  -var bucket_name=my-bucket \
  -var alb_dns_name=my-alb-123.us-east-1.elb.amazonaws.com \
  -var domain_name=www.example.com \
  -var acm_certificate_arn=arn:aws:acm:us-east-1:111111111111:certificate/xxxx \
  -var logging_bucket=my-logs.s3.amazonaws.com
```

The ACM certificate must be in `us-east-1`. The logging bucket must have ACLs enabled (CloudFront standard logging v1 requirement).

## Inputs

| Name                | Description                               | Type   | Default     |
| ------------------- | ----------------------------------------- | ------ | ----------- |
| region              | AWS region                                | string | `us-east-1` |
| account_name        | Account name for resource naming          | string | (required)  |
| project_name        | Project name for resource naming          | string | (required)  |
| bucket_name         | Name of the S3 bucket used as origin      | string | (required)  |
| alb_dns_name        | DNS name of the ALB for the API origin    | string | (required)  |
| domain_name         | Custom domain name for the distribution   | string | (required)  |
| acm_certificate_arn | ARN of the ACM certificate (us-east-1)    | string | (required)  |
| logging_bucket      | S3 bucket domain name for access logs     | string | (required)  |

## Outputs

| Name                        | Description                         |
| --------------------------- | ----------------------------------- |
| distribution_id             | CloudFront distribution ID          |
| distribution_domain_name    | CloudFront distribution domain name |
| distribution_hosted_zone_id | Route 53 hosted zone ID             |
| oac_ids                     | Origin Access Control IDs           |
| cache_policy_ids            | Cache policy IDs                    |
| origin_request_policy_ids   | Origin request policy IDs           |
| response_headers_policy_ids | Response headers policy IDs         |
| function_arns               | CloudFront Function ARNs            |
