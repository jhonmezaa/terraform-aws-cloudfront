# =============================================================================
# Monitoring Subscriptions (Real-time Metrics)
# =============================================================================

resource "aws_cloudfront_monitoring_subscription" "this" {
  for_each = {
    for k, v in var.distributions : k => v
    if var.create && v.create_monitoring_subscription
  }

  distribution_id = aws_cloudfront_distribution.this[each.key].id

  monitoring_subscription {
    realtime_metrics_subscription_config {
      realtime_metrics_subscription_status = each.value.realtime_metrics_subscription_status
    }
  }
}
