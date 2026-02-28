# terraform-aws-cloudfront

Terraform module for AWS CloudFront distributions with origin access controls, cache policies, origin request policies, response headers policies, CloudFront Functions, and monitoring.

## Features

- **Multiple distributions** via `for_each` pattern (add/remove without recreation)
- **Origin Access Controls (OAC)** for S3, MediaStore, MediaPackage, and Lambda origins
- **Custom cache policies** with cookie, header, and query string configuration
- **Origin request policies** for forwarding headers, cookies, and query strings to origins
- **Response headers policies** with CORS, security headers, custom headers, and server timing
- **CloudFront Functions** for lightweight request/response manipulation
- **Monitoring subscriptions** for real-time CloudWatch metrics
- **Multiple origin types**: S3, custom (ALB, API Gateway, HTTP), origin groups (failover)
- **Policy-based caching** (recommended) and legacy forwarded values (backward compatible)
- **Named policy lookups** via AWS data sources (e.g., `Managed-CachingOptimized`)
- **Cross-reference keys** between module resources (`cache_policy_key`, `function_key`, etc.)
- **Consistent naming** following monorepo conventions with region prefix support

## Usage

### Basic S3 Origin

```hcl
module "cloudfront" {
  source = "github.com/jhonmezaa/terraform-aws-cloudfront//cloudfront?ref=v1.0.0"

  account_name = "prod"
  project_name = "myapp"

  origin_access_controls = {
    s3 = {
      origin_access_control_origin_type = "s3"
      signing_behavior                  = "always"
      signing_protocol                  = "sigv4"
    }
  }

  distributions = {
    website = {
      comment             = "Static website"
      default_root_object = "index.html"

      origin = [
        {
          origin_id                 = "s3"
          domain_name               = "my-bucket.s3.amazonaws.com"
          origin_access_control_key = "s3"
        }
      ]

      default_cache_behavior = {
        target_origin_id  = "s3"
        cache_policy_name = "Managed-CachingOptimized"
      }
    }
  }
}
```

### Complete Example with Multiple Origins

See [examples/complete](examples/complete/) for a full example with:

- S3 + ALB origins
- Custom cache, origin request, and response headers policies
- CloudFront Functions
- Geo restrictions
- Custom error responses
- Access logging
- Monitoring subscriptions

## Module Structure

```
cloudfront/
  0-versions.tf                    - Provider version constraints
  1-distribution.tf                - CloudFront distributions
  2-origin-access.tf               - Origin Access Controls (OAC)
  3-cache-policies.tf              - Cache policies
  4-origin-request-policies.tf     - Origin request policies
  5-response-headers-policies.tf   - Response headers policies
  6-functions.tf                   - CloudFront Functions
  7-monitoring.tf                  - Monitoring subscriptions
  8-data.tf                        - Data sources
  9-locals.tf                      - Local values
  10-variables.tf                  - Input variables
  11-outputs.tf                    - Output values
```

## Naming Convention

Resources follow the standard naming pattern:

| Resource                | Pattern                                                      |
| ----------------------- | ------------------------------------------------------------ |
| Distribution            | `{region_prefix}-cf-{account_name}-{project_name}-{key}`     |
| OAC                     | `{region_prefix}-cf-oac-{account_name}-{project_name}-{key}` |
| Cache Policy            | `{region_prefix}-cf-cp-{account_name}-{project_name}-{key}`  |
| Origin Request Policy   | `{region_prefix}-cf-orp-{account_name}-{project_name}-{key}` |
| Response Headers Policy | `{region_prefix}-cf-rhp-{account_name}-{project_name}-{key}` |
| Function                | `{region_prefix}_cf_fn_{account_name}_{project_name}_{key}`  |

## Requirements

| Name      | Version |
| --------- | ------- |
| terraform | ~> 1.0  |
| aws       | ~> 6.0  |

## Inputs

| Name                      | Description                                   | Type        | Default             |
| ------------------------- | --------------------------------------------- | ----------- | ------------------- |
| create                    | Whether to create CloudFront resources        | bool        | true                |
| account_name              | Account name for resource naming              | string      | (required)          |
| project_name              | Project name for resource naming              | string      | (required)          |
| region_prefix             | Region prefix override                        | string      | null (auto-derived) |
| use_region_prefix         | Include region prefix in names                | bool        | true                |
| tags                      | Additional tags for all resources             | map(string) | {}                  |
| distributions             | Map of CloudFront distribution configurations | map(object) | {}                  |
| origin_access_controls    | Map of OAC configurations                     | map(object) | {}                  |
| cache_policies            | Map of cache policy configurations            | map(object) | {}                  |
| origin_request_policies   | Map of origin request policy configurations   | map(object) | {}                  |
| response_headers_policies | Map of response headers policy configurations | map(object) | {}                  |
| functions                 | Map of CloudFront Function configurations     | map(object) | {}                  |

## Outputs

| Name                         | Description                                   |
| ---------------------------- | --------------------------------------------- |
| distributions                | Map of all distribution attributes            |
| distribution_ids             | Map of distribution keys to IDs               |
| distribution_arns            | Map of distribution keys to ARNs              |
| distribution_domain_names    | Map of distribution keys to domain names      |
| distribution_hosted_zone_ids | Map of distribution keys to Route 53 zone IDs |
| origin_access_controls       | Map of OAC attributes                         |
| origin_access_control_ids    | Map of OAC keys to IDs                        |
| cache_policies               | Map of cache policy attributes                |
| cache_policy_ids             | Map of cache policy keys to IDs               |
| origin_request_policies      | Map of origin request policy attributes       |
| origin_request_policy_ids    | Map of origin request policy keys to IDs      |
| response_headers_policies    | Map of response headers policy attributes     |
| response_headers_policy_ids  | Map of response headers policy keys to IDs    |
| functions                    | Map of function attributes                    |
| function_arns                | Map of function keys to ARNs                  |
| monitoring_subscriptions     | Map of monitoring subscription IDs            |

## License

MIT Licensed. See [LICENSE](LICENSE) for full details.
