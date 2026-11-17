# Changelog

All notable changes to this project will be documented in this file.

## [v1.2.0] - 2026-11-17

### Added

- Viewer mTLS: `viewer_mtls_config` on distributions (`mode`, `trust_store_config` with `trust_store_id` or `trust_store_key`, `advertise_trust_store_ca_names`, `ignore_certificate_expiry`)
- `trust_stores` input and `aws_cloudfront_trust_store` resource (CA bundle in S3), with `trust_stores` / `trust_store_ids` outputs
- `connection_functions` input and `aws_cloudfront_connection_function` resource, `connection_function_association` (`id` or `key`) on distributions, and `connection_functions` / `connection_function_arns` outputs
- `anycast_ip_list_id` and `cache_tag_config` on distributions
- Origins: `response_completion_timeout`, `custom_origin_config.ip_address_type`, `custom_origin_config.origin_mtls_config` and `vpc_origin_config.owner_account_id`
- Validations (Spanish messages) for `viewer_mtls_config.mode`, `trust_store_config` without ID or key, `connection_function_association` without ID or key, and `ip_address_type`
- `mtls` example

### Changed

- Minimum AWS provider raised from `>= 6.0` to `>= 6.51` (examples: `~> 6.51`); these arguments and resources do not exist in earlier provider versions

### Upgrade notes

- Requires `hashicorp/aws >= 6.51`. Run `terraform init -upgrade` if your lock file pins an older 6.x provider. Configurations with an upper bound below 6.51 must stay on v1.1.0.
- No other action needed: every new input is optional and defaults to `null` / `{}`, so existing distributions plan no changes and no resource is recreated.

## [v1.1.0] - 2026-11-17

### Added

- `vpc_origins` input and `aws_cloudfront_vpc_origin` resource for private ALB, NLB or EC2 origins, plus `vpc_origin_config` (`vpc_origin_id` or `vpc_origin_key`) on distribution origins and `vpc_origins` / `vpc_origin_ids` outputs
- `grpc_config` on default and ordered cache behaviors
- Optional `name` override for origin access controls, cache policies, origin request policies, response headers policies and functions
- `tags_common` input (project convention); tags now also include `ManagedBy = "Terraform"`
- `vpc-origin` example and a README for every example

### Fixed

- `cache_policy_id` used `coalesce()` without `try()`, so any behavior without a cache policy (legacy `forwarded_values` mode) failed with "no non-null, non-empty-string arguments"
- Behaviors without a cache policy and without `forwarded_values` now get a default `forwarded_values` (no query string, cookies `none`), and `cookies` defaults to `forward = "none"`; the AWS API requires both
- Generated names are truncated to the AWS limits (64 for OAC, VPC origins and functions, 128 for policies and the default distribution comment)
- `complete` example: the `api` cache policy used `max_ttl = 0` together with headers and query strings in the cache key, which AWS rejects
- Validation error messages for `account_name` and `project_name` are now in Spanish, per the project convention

### Changed

- Removed the unused `aws_caller_identity` and `aws_partition` data sources
- Examples use `tags_common` and `examples/<name>/versions.tf`
- README: `source` ref, inputs/outputs, naming and tags sections updated

### Deprecated

- `tags`: use `tags_common`. It is still merged on top of `tags_common`, so existing configurations keep working

### Upgrade notes

- No resource is recreated. Distributions and VPC origins get the new `ManagedBy = "Terraform"` tag (in-place update). If you set `ManagedBy` yourself in `tags`, the module value `Terraform` now takes precedence.
- Existing names do not change: truncation only affects names that exceeded the AWS limit and therefore could not be created before.

## [v1.0.5] - 2026-10-27

### Fixed

- Replace deprecated `data.aws_region.current.id` with `data.aws_region.current.region` (AWS provider v6)

### Changed

- Normalize CHANGELOG headings to `## [vX.Y.Z] - date`

## [v1.0.4] - 2026-10-27

### Changed

- Use minimum-only version constraints in the reusable module, per HashiCorp guidance: AWS provider `~> 6.0` -> `>= 6.0`
- Set module `required_version` to `>= 1.3` (was `~> 1.0`), the real minimum required by the use of `optional()` object attributes in variable types (Terraform 1.3+)
- Examples (root modules) keep pessimistic constraints: `required_version` `~> 1.3` and AWS provider `~> 6.0`
- Update README requirements table

## [v1.0.3] - 2026-03-01

### Fixed

- Wrap `coalesce()` with `try(..., null)` for `origin_access_control_id` in distribution origins
- Fixes `coalesce(null, null)` error when using custom origins (ALB, API Gateway) without OAC

## [v1.0.2] - 2026-02-28

### Changed

- Documentation updates (CHANGELOG, README)

## [v1.0.1] - 2026-02-28

### Fixed

- Wrap `coalesce()` with `try(..., null)` for optional policy IDs in cache behaviors

## [v1.0.0] - 2026-02-27

### Added

- CloudFront distributions with `for_each` pattern supporting multiple distributions
- Origin Access Controls (OAC) for S3 and other origin types
- Custom cache policies with full configuration support
- Origin request policies for header/cookie/query string forwarding
- Response headers policies with CORS, security headers, custom headers, and server timing
- CloudFront Functions with runtime and publish support
- Monitoring subscriptions for real-time metrics
- Support for S3 origins, custom origins (ALB, API Gateway, HTTP), and origin groups (failover)
- Ordered cache behaviors with policy-based and legacy forwarded values support
- Function associations (CloudFront Functions and Lambda@Edge)
- Viewer certificate configuration (ACM, IAM, CloudFront default)
- Geo restriction (whitelist/blacklist)
- Custom error responses
- Standard access logging to S3
- Named policy lookups via AWS data sources (e.g., `Managed-CachingOptimized`)
- Cross-reference support between module resources via keys (cache_policy_key, function_key, etc.)
- Region prefix naming convention consistent with other modules
- S3 origin example
- Complete example with S3 + ALB origins, custom policies, functions, and security headers
