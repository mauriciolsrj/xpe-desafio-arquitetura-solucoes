# Service Account for VMs
resource "google_service_account" "app_vm" {
  account_id   = "${var.app_name}-vm-sa"
  display_name = "Service Account for ecommerce VMs"
  description  = "Service account for ecommerce application instances"
  project      = var.project_id
}

# IAM Role: Cloud SQL Client
resource "google_project_iam_member" "cloudsql_client" {
  project = var.project_id
  role    = "roles/cloudsql.client"
  member  = "serviceAccount:${google_service_account.app_vm.email}"

  depends_on = [google_service_account.app_vm]
}

# IAM Role: Logging Writer
resource "google_project_iam_member" "logging_writer" {
  project = var.project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.app_vm.email}"

  depends_on = [google_service_account.app_vm]
}

# IAM Role: Monitoring Metric Writer
resource "google_project_iam_member" "monitoring_metric_writer" {
  project = var.project_id
  role    = "roles/monitoring.metricWriter"
  member  = "serviceAccount:${google_service_account.app_vm.email}"

  depends_on = [google_service_account.app_vm]
}

# IAM Role: Compute Instance Admin (optional for instance management)
resource "google_project_iam_member" "compute_instance_admin" {
  project = var.project_id
  role    = "roles/compute.instanceAdmin.v1"
  member  = "serviceAccount:${google_service_account.app_vm.email}"

  depends_on = [google_service_account.app_vm]
}

# IAM Role: Artifact Registry Reader (for pulling container images)
resource "google_project_iam_member" "artifact_registry_reader" {
  project = var.project_id
  role    = "roles/artifactregistry.reader"
  member  = "serviceAccount:${google_service_account.app_vm.email}"

  depends_on = [google_service_account.app_vm]
}

# Outputs
output "service_account_email" {
  value       = google_service_account.app_vm.email
  description = "Email of the service account for VMs"
}

output "service_account_id" {
  value       = google_service_account.app_vm.unique_id
  description = "Unique ID of the service account"
}
