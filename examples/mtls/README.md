# mTLS Example

CloudFront distribution that requires viewer client certificates and authenticates itself to the origin with a client certificate. Requires `hashicorp/aws ~> 6.51`.

- `trust_stores` creates an `aws_cloudfront_trust_store` from a CA bundle (PEM) stored in S3; the distribution references it with `viewer_mtls_config.trust_store_config.trust_store_key`
- `viewer_mtls_config.mode = "required"`: viewers without a valid client certificate are rejected during the TLS handshake
- `custom_origin_config.origin_mtls_config` presents an ACM client certificate to the origin (only when `origin_client_certificate_arn` is set)
- `cache_tag_config` reads cache tags from the `Cache-Tag` origin response header (invalidation by tag)
- `custom_origin_config.ip_address_type = "dualstack"` and `response_completion_timeout = 60` on the origin
- Optional `anycast_ip_list_id` and connection function (`connection_functions` + `connection_function_association.key`)

## Usage

```bash
terraform init
terraform plan \
  -var account_name=prod \
  -var project_name=api \
  -var 'aliases=["api.example.com"]' \
  -var acm_certificate_arn=arn:aws:acm:us-east-1:111111111111:certificate/abc \
  -var ca_bundle_bucket=my-ca-bundles \
  -var origin_domain_name=origin.example.com
```

The connection function service quota is zero by default. Request an increase before using `-var create_connection_function=true`. The origin client certificate must be imported into ACM in `us-east-1` and include the TLS Client Authentication extended key usage.

## Inputs

| Name                          | Description                                              | Type         | Default         |
| ----------------------------- | -------------------------------------------------------- | ------------ | --------------- |
| region                        | AWS region                                               | string       | `us-east-1`     |
| account_name                  | Account name for resource naming                         | string       | (required)      |
| project_name                  | Project name for resource naming                         | string       | (required)      |
| aliases                       | Alternate domain names                                   | list(string) | (required)      |
| acm_certificate_arn           | ACM certificate (us-east-1) for the aliases              | string       | (required)      |
| ca_bundle_bucket              | S3 bucket with the CA bundle                             | string       | (required)      |
| ca_bundle_key                 | S3 key of the CA bundle                                  | string       | `ca-bundle.pem` |
| ca_bundle_region              | Region of the CA bundle bucket                           | string       | `us-east-1`     |
| origin_domain_name            | Domain name of the HTTPS origin                          | string       | (required)      |
| origin_client_certificate_arn | ACM client certificate for origin mTLS (null = disabled) | string       | `null`          |
| anycast_ip_list_id            | Existing Anycast static IP list ID                       | string       | `null`          |
| create_connection_function    | Create and associate the connection function             | bool         | `false`         |

## Outputs

| Name                     | Description                         |
| ------------------------ | ----------------------------------- |
| distribution_id          | CloudFront distribution ID          |
| distribution_domain_name | CloudFront distribution domain name |
| trust_store_ids          | CloudFront trust store IDs          |
| connection_function_arns | CloudFront connection function ARNs |
