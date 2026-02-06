# Cloud Armor Security Policy (SQLi e XSS protection)
resource "google_compute_security_policy" "policy" {
  name        = "${var.app_name}-cloud-armor-policy"
  description = "Cloud Armor policy for ecommerce app"
  project     = var.project_id

  # Rule 1: Deny SQLi attacks
  rule {
    action   = "deny-403"
    priority = "1000"
    match {
      versioned_expr = "V1"
      expr {
        origin_region_list = []
      }
    }
    description = "Deny requests containing SQL injection patterns"

    match {
      versioned_expr = "V1"
      expr {
        origin_region_list = []
      }
    }
  }

  # Rule 2: SQL Injection prevention (using evaluatePreconfiguredExpr)
  rule {
    action   = "deny-403"
    priority = "1001"
    match {
      versioned_expr = "V1"
      expr {
        origin_region_list = []
      }
    }
    description = "SQL injection protection"

    match {
      expr_options {
        user_defined_fields {
          name = "owasp_crs_v030001_sqli_v33_body"
        }
      }
    }
  }

  # Rule 3: XSS prevention
  rule {
    action   = "deny-403"
    priority = "1002"
    match {
      versioned_expr = "V1"
      expr {
        origin_region_list = []
      }
    }
    description = "XSS protection"
  }

  # Rule 4: Preconfigured rules for OWASP
  dynamic "rule" {
    for_each = ["sqlinjection-stable", "xss-stable", "protocolattack-stable", "scannerdetection-stable"]
    content {
      action   = "deny-403"
      priority = 2000 + rule.key
      match {
        versioned_expr = "V1"
        expr {
          origin_region_list = []
        }
      }
      description = "${rule.value} protection"
    }
  }

  # Default rule: Allow all
  rule {
    action   = "allow"
    priority = "2147483647"
    match {
      versioned_expr = "V1"
      expr {
        origin_region_list = []
      }
    }
    description = "Default allow rule"
  }
}

# Backend Service
resource "google_compute_backend_service" "app" {
  name            = "${var.app_name}-backend-service"
  protocol        = "HTTP"
  port_name       = "http"
  timeout_sec     = 30
  health_checks   = [google_compute_health_check.app.id]
  project         = var.project_id
  security_policy = google_compute_security_policy.policy.id

  backend {
    group           = google_compute_region_instance_group_manager.app_mig.instance_group
    balancing_mode  = "RATE"
    max_rate_per_endpoint = 100
    capacity_scaler = 1.0
  }

  log_config {
    enable      = true
    sample_rate = 1.0
  }

  session_affinity = "CLIENT_IP"
}

# URL Map
resource "google_compute_url_map" "app" {
  name            = "${var.app_name}-url-map"
  default_service = google_compute_backend_service.app.id
  project         = var.project_id

  host_rule {
    hosts        = ["*"]
    path_matcher = "default"
  }

  path_matcher {
    name            = "default"
    default_service = google_compute_backend_service.app.id

    path_rule {
      paths   = ["/api/*"]
      service = google_compute_backend_service.app.id
    }
  }
}

# HTTPS Redirect (HTTP to HTTPS)
resource "google_compute_url_map" "https_redirect" {
  name    = "${var.app_name}-https-redirect"
  project = var.project_id

  default_url_redirect {
    https_redirect         = true
    redirect_response_code = "301"
    strip_query            = false
  }
}

# HTTP Proxy
resource "google_compute_target_http_proxy" "default" {
  name    = "${var.app_name}-http-proxy"
  url_map = google_compute_url_map.https_redirect.id
  project = var.project_id
}

# HTTPS Proxy (requires SSL certificate)
resource "google_compute_managed_ssl_certificate" "default" {
  name    = "${var.app_name}-ssl-cert"
  project = var.project_id

  managed {
    domains = ["ecommerce.example.com"]  # Change to your domain
  }
}

resource "google_compute_target_https_proxy" "default" {
  name             = "${var.app_name}-https-proxy"
  url_map          = google_compute_url_map.app.id
  ssl_certificates = [google_compute_managed_ssl_certificate.default.id]
  project          = var.project_id
}

# Global Forwarding Rule - HTTP
resource "google_compute_global_forwarding_rule" "http" {
  name                  = "${var.app_name}-forwarding-rule-http"
  ip_protocol           = "TCP"
  load_balancing_scheme = "EXTERNAL"
  port_range            = "80"
  target                = google_compute_target_http_proxy.default.id
  project               = var.project_id
}

# Global Forwarding Rule - HTTPS
resource "google_compute_global_forwarding_rule" "https" {
  name                  = "${var.app_name}-forwarding-rule-https"
  ip_protocol           = "TCP"
  load_balancing_scheme = "EXTERNAL"
  port_range            = "443"
  target                = google_compute_target_https_proxy.default.id
  project               = var.project_id
}

# Outputs
output "load_balancer_ip" {
  value       = google_compute_global_forwarding_rule.https.ip_address
  description = "External IP address of the Global Load Balancer"
}

output "load_balancer_url" {
  value       = "https://${google_compute_global_forwarding_rule.https.ip_address}"
  description = "HTTPS URL of the application"
}
