# Private Service Connection for Cloud SQL
resource "google_compute_global_address" "private_ip_address" {
  name          = "${var.app_name}-private-ip"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.main.id
  project       = var.project_id
}

resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = google_compute_network.main.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_address.name]

  depends_on = [google_project_service.required_apis["servicenetworking.googleapis.com"]]
}

# Primary Cloud SQL Instance (PostgreSQL 15) with HA
resource "google_sql_database_instance" "primary" {
  name             = var.db_instance_name
  database_version = "POSTGRES_${var.db_version}"
  region           = var.primary_region
  project          = var.project_id

  settings {
    tier              = var.db_tier
    availability_type = "REGIONAL"  # HA enabled
    disk_type         = "PD_SSD"
    disk_size         = 100
    disk_autoresize   = true
    disk_autoresize_limit = 500

    backup_configuration {
      enabled                        = true
      start_time                     = "03:00"
      point_in_time_recovery_enabled = true
      transaction_log_retention_days = 7
      backup_retention_settings {
        retained_backups = 30
        retention_unit   = "COUNT"
      }
    }

    ip_configuration {
      ipv4_enabled    = false
      private_network = google_compute_network.main.id
      require_ssl     = true

      # Cloud SQL Auth Proxy (optional, for app connectivity)
      authorized_networks {
        value = "0.0.0.0/0"
        name  = "allow-all"
      }
    }

    database_flags {
      name  = "max_connections"
      value = "200"
    }

    database_flags {
      name  = "shared_buffers"
      value = "262144"  # 2GB
    }

    user_labels = var.labels

    deletion_protection = true
  }

  deletion_protection = true

  depends_on = [google_service_networking_connection.private_vpc_connection]
}

# Read Replica (Cross-Region for DR)
resource "google_sql_database_instance" "read_replica" {
  name             = "${var.db_instance_name}-read-replica-dr"
  database_version = "POSTGRES_${var.db_version}"
  region           = var.dr_region
  project          = var.project_id

  master_instance_name = google_sql_database_instance.primary.name

  replica_configuration {
    kind                    = "SQLINSTANCE_REPLICA"
    mysql_replica_password  = null
  }

  settings {
    tier = var.db_tier

    ip_configuration {
      ipv4_enabled    = false
      private_network = google_compute_network.main.id
      require_ssl     = true
    }

    user_labels = merge(var.labels, {
      replica_type = "dr"
    })

    backup_configuration {
      enabled = false  # Replicas don't need separate backups
    }
  }

  depends_on = [google_sql_database_instance.primary]
}

# Database
resource "google_sql_database" "ecommerce" {
  name     = "ecommerce"
  instance = google_sql_database_instance.primary.name
  project  = var.project_id
}

# Root user password
resource "random_password" "db_password" {
  length  = 32
  special = true
}

resource "google_sql_user" "app_user" {
  name     = "app_user"
  instance = google_sql_database_instance.primary.name
  password = random_password.db_password.result
  project  = var.project_id
}

# Outputs
output "sql_instance_connection_name" {
  value       = google_sql_database_instance.primary.connection_name
  description = "Connection string for primary Cloud SQL instance"
  sensitive   = true
}

output "sql_instance_ip" {
  value       = google_sql_database_instance.primary.private_ip_address
  description = "Private IP of primary Cloud SQL instance"
}

output "sql_read_replica_connection_name" {
  value       = google_sql_database_instance.read_replica.connection_name
  description = "Connection string for read replica (DR)"
}

output "db_password" {
  value       = random_password.db_password.result
  description = "Database password"
  sensitive   = true
}
