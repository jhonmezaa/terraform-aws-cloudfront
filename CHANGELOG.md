# Changelog

All notable changes to this project will be documented in this file.

## [1.0.3] - 2026-03-01

### Fixed

- Wrap `coalesce()` with `try(..., null)` for `origin_access_control_id` in distribution origins
- Fixes `coalesce(null, null)` error when using custom origins (ALB, API Gateway) without OAC

## [1.0.2] - 2026-02-28

### Changed

- Documentation updates (CHANGELOG, README)

## [1.0.1] - 2026-02-28

### Fixed

- Wrap `coalesce()` with `try(..., null)` for optional policy IDs in cache behaviors

## [1.0.0] - 2026-02-27

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
