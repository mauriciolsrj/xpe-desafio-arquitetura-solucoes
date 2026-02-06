# Uptime Check (optional, for external monitoring)
resource "google_monitoring_uptime_check_config" "http" {
  project      = var.project_id
  display_name = "${var.app_name}-uptime-check"
  timeout      = "10s"
  period       = "60s"

  http_check {
    path           = "/health"
    port           = 80
    request_method = "GET"
    use_ssl        = false
  }

  monitored_resource {
    type = "uptime-url"
    labels = {
      host = google_compute_global_forwarding_rule.https.ip_address
    }
  }

  selected_regions = ["USA", "EUROPE", "ASIA_PACIFIC"]
}

# Alert Policy for P99 Latency > 500ms
resource "google_monitoring_alert_policy" "latency_p99" {
  project      = var.project_id
  display_name = "${var.app_name} - P99 Latency Alert (> 500ms)"
  combiner     = "OR"

  conditions {
    display_name = "P99 Latency exceeds 500ms"

    condition_threshold {
      filter          = "resource.type=\"global\" AND metric.type=\"compute.googleapis.com/https/request_latencies\" AND resource.label.url_map_name=\"${google_compute_url_map.app.name}\""
      duration        = "300s"
      comparison      = "COMPARISON_GT"
      threshold_value = 500000  # microseconds

      aggregations {
        alignment_period  = "60s"
        per_series_aligner = "ALIGN_PERCENTILE_99"
      }
    }
  }

  notification_channels = []  # Add your notification channels here

  alert_strategy {
    alert_suppression {
      description = "Suppress alerts for 1 hour"
      enabled     = false
    }
  }
}

# Alert Policy for Error Rate > 1%
resource "google_monitoring_alert_policy" "error_rate" {
  project      = var.project_id
  display_name = "${var.app_name} - Error Rate Alert (> 1%)"
  combiner     = "OR"

  conditions {
    display_name = "Error rate exceeds 1%"

    condition_threshold {
      filter          = "resource.type=\"global\" AND metric.type=\"compute.googleapis.com/https/request_count\" AND resource.label.url_map_name=\"${google_compute_url_map.app.name}\" AND metric.label.response_code_class=\"5xx\""
      duration        = "300s"
      comparison      = "COMPARISON_GT"
      threshold_value = 1  # 1% as derived from rate calculation

      aggregations {
        alignment_period   = "60s"
        per_series_aligner = "ALIGN_RATE"
      }
    }
  }

  notification_channels = []  # Add your notification channels here
}

# Custom Dashboard for Application Metrics
resource "google_monitoring_dashboard" "app_dashboard" {
  project        = var.project_id
  dashboard_json = jsonencode({
    displayName = "${var.app_name} - Application Dashboard"
    mosaicLayout = {
      columns = 12
      tiles = [
        {
          width  = 6
          height = 4
          widget = {
            title = "MIG Instance Count"
            xyChart = {
              dataSets = [
                {
                  timeSeriesQuery = {
                    timeSeriesFilter = {
                      filter = "metric.type=\"compute.googleapis.com/instance_group/size\" resource.type=\"instance_group\" resource.label.instance_group_name=\"${google_compute_region_instance_group_manager.app_mig.name}\""
                      aggregation = {
                        alignmentPeriod  = "60s"
                        perSeriesAligner = "ALIGN_MEAN"
                      }
                    }
                  }
                }
              ]
            }
          }
        },
        {
          xPos   = 6
          width  = 6
          height = 4
          widget = {
            title = "CPU Utilization"
            xyChart = {
              dataSets = [
                {
                  timeSeriesQuery = {
                    timeSeriesFilter = {
                      filter = "metric.type=\"compute.googleapis.com/instance/cpu/utilization\" resource.type=\"gce_instance\" resource.label.instance_group_name=\"${google_compute_region_instance_group_manager.app_mig.name}\""
                      aggregation = {
                        alignmentPeriod  = "60s"
                        perSeriesAligner = "ALIGN_MEAN"
                      }
                    }
                  }
                }
              ]
            }
          }
        },
        {
          yPos   = 4
          width  = 6
          height = 4
          widget = {
            title = "Request Latency (P99)"
            xyChart = {
              dataSets = [
                {
                  timeSeriesQuery = {
                    timeSeriesFilter = {
                      filter = "metric.type=\"compute.googleapis.com/https/request_latencies\""
                      aggregation = {
                        alignmentPeriod  = "60s"
                        perSeriesAligner = "ALIGN_PERCENTILE_99"
                      }
                    }
                  }
                }
              ]
            }
          }
        },
        {
          xPos   = 6
          yPos   = 4
          width  = 6
          height = 4
          widget = {
            title = "HTTP Request Distribution (by Status)"
            xyChart = {
              dataSets = [
                {
                  timeSeriesQuery = {
                    timeSeriesFilter = {
                      filter = "metric.type=\"compute.googleapis.com/https/request_count\""
                      aggregation = {
                        alignmentPeriod      = "60s"
                        perSeriesAligner     = "ALIGN_RATE"
                        crossSeriesReducer   = "REDUCE_SUM"
                        groupByFields = [
                          "metric.response_code_class"
                        ]
                      }
                    }
                  }
                }
              ]
            }
          }
        }
      ]
    }
  })
}

# Log Sink for Application Logs
resource "google_logging_project_sink" "app_logs" {
  name        = "${var.app_name}-log-sink"
  destination = "logging.googleapis.com/projects/${var.project_id}/logs/${var.app_name}-app-logs"
  filter      = "resource.type=\"gce_instance\" AND labels.instance_group_name=\"${google_compute_region_instance_group_manager.app_mig.name}\""

  unique_writer_identity = true
}

# Outputs
output "alert_policy_latency_id" {
  value       = google_monitoring_alert_policy.latency_p99.id
  description = "ID of the latency alert policy"
}

output "alert_policy_error_rate_id" {
  value       = google_monitoring_alert_policy.error_rate.id
  description = "ID of the error rate alert policy"
}

output "dashboard_id" {
  value       = google_monitoring_dashboard.app_dashboard.id
  description = "ID of the monitoring dashboard"
}
