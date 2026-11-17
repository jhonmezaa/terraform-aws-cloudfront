locals {
  # =============================================================================
  # Region Prefix Mapping
  # =============================================================================

  region_prefix_map = {
    # US Regions
    "us-east-1" = "ause1"
    "us-east-2" = "ause2"
    "us-west-1" = "ausw1"
    "us-west-2" = "ausw2"
    # EU Regions
    "eu-west-1"    = "euwe1"
    "eu-west-2"    = "euwe2"
    "eu-west-3"    = "euwe3"
    "eu-central-1" = "euce1"
    "eu-central-2" = "euce2"
    "eu-north-1"   = "euno1"
    "eu-south-1"   = "euso1"
    "eu-south-2"   = "euso2"
    # AP Regions
    "ap-southeast-1" = "apse1"
    "ap-southeast-2" = "apse2"
    "ap-southeast-3" = "apse3"
    "ap-southeast-4" = "apse4"
    "ap-northeast-1" = "apne1"
    "ap-northeast-2" = "apne2"
    "ap-northeast-3" = "apne3"
    "ap-south-1"     = "apso1"
    "ap-south-2"     = "apso2"
    "ap-east-1"      = "apea1"
    # SA Regions
    "sa-east-1" = "saea1"
    # CA Regions
    "ca-central-1" = "cace1"
    "ca-west-1"    = "cawe1"
    # ME Regions
    "me-south-1"   = "meso1"
    "me-central-1" = "mece1"
    # AF Regions
    "af-south-1" = "afso1"
    # IL Regions
    "il-central-1" = "ilce1"
  }

  region_prefix = var.region_prefix != null ? var.region_prefix : lookup(
    local.region_prefix_map,
    data.aws_region.current.region,
    data.aws_region.current.region
  )

  # Name prefix: includes region prefix with trailing dash, or empty string
  name_prefix = var.use_region_prefix ? "${local.region_prefix}-" : ""

  # Common tags (`tags` is kept as a deprecated alias of `tags_common`)
  tags_common = merge(var.tags_common, var.tags)

  # =============================================================================
  # Resource Names
  # =============================================================================
  # Each name can be overridden with an explicit `name` and is truncated to the
  # AWS limit (functions, OAC and VPC origins: 64; policies: 128).

  distribution_names = {
    for k, v in var.distributions : k => "${local.name_prefix}cf-${var.account_name}-${var.project_name}-${k}"
  }

  origin_access_control_names = {
    for k, v in var.origin_access_controls : k => substr(coalesce(v.name, "${local.name_prefix}cf-oac-${var.account_name}-${var.project_name}-${k}"), 0, 64)
  }

  vpc_origin_names = {
    for k, v in var.vpc_origins : k => substr(coalesce(v.name, "${local.name_prefix}cf-vpco-${var.account_name}-${var.project_name}-${k}"), 0, 64)
  }

  cache_policy_names_map = {
    for k, v in var.cache_policies : k => substr(coalesce(v.name, "${local.name_prefix}cf-cp-${var.account_name}-${var.project_name}-${k}"), 0, 128)
  }

  origin_request_policy_names_map = {
    for k, v in var.origin_request_policies : k => substr(coalesce(v.name, "${local.name_prefix}cf-orp-${var.account_name}-${var.project_name}-${k}"), 0, 128)
  }

  response_headers_policy_names_map = {
    for k, v in var.response_headers_policies : k => substr(coalesce(v.name, "${local.name_prefix}cf-rhp-${var.account_name}-${var.project_name}-${k}"), 0, 128)
  }

  # CloudFront Function names only allow [a-zA-Z0-9-_]; hyphens are converted to underscores
  function_names = {
    for k, v in var.functions : k => substr(coalesce(v.name, replace("${local.name_prefix}cf_fn_${var.account_name}_${var.project_name}_${k}", "-", "_")), 0, 64)
  }

  # Connection functions follow the same character rules as CloudFront Functions
  connection_function_names = {
    for k, v in var.connection_functions : k => substr(coalesce(v.name, replace("${local.name_prefix}cf_cfn_${var.account_name}_${var.project_name}_${k}", "-", "_")), 0, 64)
  }

  trust_store_names = {
    for k, v in var.trust_stores : k => substr(coalesce(v.name, "${local.name_prefix}cf-ts-${var.account_name}-${var.project_name}-${k}"), 0, 64)
  }

  # Legacy forwarded values used when a behavior has no cache policy and no `forwarded_values`
  default_forwarded_values = {
    query_string            = false
    query_string_cache_keys = null
    headers                 = null
    cookies = {
      forward           = "none"
      whitelisted_names = null
    }
  }

  # =============================================================================
  # Cache Behavior Policy Resolution
  # =============================================================================

  # Collect all cache policy names referenced by behaviors for data source lookup
  all_cache_behaviors = flatten([
    for dist_key, dist in var.distributions : concat(
      [dist.default_cache_behavior],
      dist.ordered_cache_behavior
    )
  ])

  cache_policy_names = toset([
    for b in local.all_cache_behaviors : b.cache_policy_name
    if b.cache_policy_name != null
  ])

  origin_request_policy_names = toset([
    for b in local.all_cache_behaviors : b.origin_request_policy_name
    if b.origin_request_policy_name != null
  ])

  response_headers_policy_names = toset([
    for b in local.all_cache_behaviors : b.response_headers_policy_name
    if b.response_headers_policy_name != null
  ])
}
