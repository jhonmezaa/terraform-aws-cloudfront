# VPC Origin Example

CloudFront distribution in front of an internal (private) Application Load Balancer using a CloudFront VPC origin. The ALB does not need to be internet-facing.

- `vpc_origins` creates the `aws_cloudfront_vpc_origin` and the origin references it with `vpc_origin_config.vpc_origin_key`
- Caching disabled (`Managed-CachingDisabled`) and all viewer headers except `Host` forwarded (`Managed-AllViewerExceptHostHeader`)
- gRPC enabled on `/grpc/*` with `grpc_config`

## Usage

```bash
terraform init
terraform plan \
  -var account_name=prod \
  -var project_name=api \
  -var alb_arn=arn:aws:elasticloadbalancing:us-east-1:111111111111:loadbalancer/app/internal/abc \
  -var alb_dns_name=internal-abc.us-east-1.elb.amazonaws.com
```

The ALB security group must allow inbound traffic from the `com.amazonaws.global.cloudfront.origin-facing` managed prefix list. Creating a VPC origin can take several minutes.

## Inputs

| Name         | Description                              | Type   | Default     |
| ------------ | ---------------------------------------- | ------ | ----------- |
| region       | AWS region                               | string | `us-east-1` |
| account_name | Account name for resource naming         | string | (required)  |
| project_name | Project name for resource naming         | string | (required)  |
| alb_arn      | ARN of the internal ALB                  | string | (required)  |
| alb_dns_name | DNS name of the internal ALB             | string | (required)  |

## Outputs

| Name                     | Description                         |
| ------------------------ | ----------------------------------- |
| distribution_id          | CloudFront distribution ID          |
| distribution_domain_name | CloudFront distribution domain name |
| vpc_origin_ids           | CloudFront VPC origin IDs           |
