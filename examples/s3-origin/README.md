# S3 Origin Example

CloudFront distribution serving a private S3 bucket through an Origin Access Control (OAC), with the AWS managed `Managed-CachingOptimized` cache policy and SPA-style error responses (403/404 -> `/index.html`).

## Usage

```bash
terraform init
terraform plan \
  -var account_name=dev \
  -var project_name=web \
  -var bucket_name=my-bucket
```

The bucket policy must allow `cloudfront.amazonaws.com` with the condition `AWS:SourceArn` = the distribution ARN (output `distribution_id` / module output `distribution_arns`).

## Inputs

| Name         | Description                         | Type   | Default     |
| ------------ | ----------------------------------- | ------ | ----------- |
| region       | AWS region                          | string | `us-east-1` |
| account_name | Account name for resource naming    | string | (required)  |
| project_name | Project name for resource naming    | string | (required)  |
| bucket_name  | Name of the S3 bucket used as origin | string | (required)  |

## Outputs

| Name                     | Description                    |
| ------------------------ | ------------------------------ |
| distribution_id          | CloudFront distribution ID     |
| distribution_domain_name | CloudFront distribution domain |
| oac_id                   | Origin Access Control ID       |
