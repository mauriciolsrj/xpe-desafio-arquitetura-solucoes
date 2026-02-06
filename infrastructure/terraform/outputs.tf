output "project_id" {
  value       = var.project_id
  description = "GCP Project ID"
}

output "vpc_id" {
  value       = google_compute_network.main.id
  description = "VPC network ID"
}

output "vpc_self_link" {
  value       = google_compute_network.main.self_link
  description = "VPC network self link"
}

output "subnet_id" {
  value       = google_compute_subnetwork.primary.id
  description = "Primary subnet ID"
}

output "mig_name" {
  value       = google_compute_region_instance_group_manager.app_mig.name
  description = "Name of the Managed Instance Group"
}

output "backend_service_id" {
  value       = google_compute_backend_service.app.id
  description = "ID of the backend service"
}

output "https_rule_ip" {
  value       = google_compute_global_forwarding_rule.https.ip_address
  description = "IP address of HTTPS forwarding rule"
}

output "cloud_armor_policy_id" {
  value       = google_compute_security_policy.policy.id
  description = "Cloud Armor security policy ID"
}

output "startup_script_service_account" {
  value       = google_service_account.app_vm.email
  description = "Service account email for VM startup scripts"
}

output "deployment_summary" {
  value = {
    application               = var.app_name
    environment              = var.environment
    region                   = var.primary_region
    dr_region                = var.dr_region
    mig_zones                = var.zones
    min_instances            = var.min_instances
    max_instances            = var.max_instances
    target_cpu_utilization   = var.target_cpu_utilization
    database_version         = "PostgreSQL ${var.db_version}"
    load_balancer_ip         = google_compute_global_forwarding_rule.https.ip_address
    sql_primary_instance     = var.db_instance_name
    sql_replica_instance     = google_sql_database_instance.read_replica.name
    cloud_armor_enabled      = true
    ha_enabled               = true
    point_in_time_recovery   = true
  }
  description = "Summary of the deployed infrastructure"
}
