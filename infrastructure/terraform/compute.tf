# Instance Template for MIG
resource "google_compute_instance_template" "app" {
  name_prefix = "${var.app_name}-template-"
  description = "Instance template for ecommerce application"
  project     = var.project_id
  region      = var.primary_region

  machine_type = var.machine_type
  
  # Boot disk with Ubuntu 22.04 LTS Minimal
  boot_disk {
    auto_delete = true
    source_image = "projects/ubuntu-os-cloud/global/images/ubuntu-2204-lts-v20240101"
  }

  network_interface {
    network            = google_compute_network.main.name
    subnetwork         = google_compute_subnetwork.primary.name
    subnetwork_project = var.project_id

    # Assign external IP (will be removed with Cloud NAT)
    access_config {
      nat_ip = null
    }
  }

  service_account {
    email  = google_service_account.app_vm.email
    scopes = ["cloud-platform"]
  }

  metadata = {
    startup-script = file("${path.module}/../scripts/startup-script.sh")
    enable-oslogin = "TRUE"
    block-project-ssh-keys = "FALSE"
  }

  tags = ["http-server", "https-server", "allow-ssh"]

  labels = var.labels

  # Prevent accidental resource deletion
  lifecycle {
    create_before_destroy = true
  }
}

# Managed Instance Group (Regional, Multi-Zone)
resource "google_compute_region_instance_group_manager" "app_mig" {
  name               = "${var.app_name}-mig"
  base_instance_name = "${var.app_name}-instance"
  project            = var.project_id
  region             = var.primary_region

  version {
    instance_template = google_compute_instance_template.app.id
    name              = "primary"
  }

  # Initial instance count (will be managed by autoscaler)
  target_size = var.min_instances

  update_policy {
    type                         = "PROACTIVE"
    minimal_action               = "REPLACE"
    max_surge_fixed              = 2
    max_unavailable_fixed        = 1
    instance_redistribution_type = "PROACTIVE"
  }

  auto_healing_policies {
    health_check      = google_compute_health_check.app.id
    initial_delay_sec = 300
  }
}

# Health Check for MIG
resource "google_compute_health_check" "app" {
  name        = "${var.app_name}-health-check"
  description = "Health check for ecommerce app MIG"
  project     = var.project_id

  timeout_sec         = 10
  check_interval_sec  = 15
  healthy_threshold   = 1
  unhealthy_threshold = 3

  http_health_check {
    port         = 8080
    request_path = "/health"
  }

  log_config {
    enable = true
  }
}

# Autoscaler for MIG
resource "google_compute_region_autoscaler" "app_autoscaler" {
  name       = "${var.app_name}-autoscaler"
  target     = google_compute_region_instance_group_manager.app_mig.id
  region     = var.primary_region
  project    = var.project_id

  autoscaling_policy {
    min_replicas    = var.min_instances
    max_replicas    = var.max_instances
    cooldown_period = 300

    cpu_utilization {
      target            = var.target_cpu_utilization
      predictive_method = "OPTIMIZE_FOR_SERVING"
    }

    scale_in_control {
      max_scaled_in_replicas {
        fixed   = 1
        percent = 10
      }
      time_window_sec = 600
    }
  }
}

# Outputs for instance group
output "mig_id" {
  value       = google_compute_region_instance_group_manager.app_mig.id
  description = "ID of the Managed Instance Group"
}

output "mig_instance_group" {
  value       = google_compute_region_instance_group_manager.app_mig.instance_group
  description = "Instance group URL of the MIG"
}
