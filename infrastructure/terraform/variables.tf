variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "primary_region" {
  description = "Primary region for resources"
  type        = string
  default     = "us-central1"
}

variable "dr_region" {
  description = "Disaster Recovery region"
  type        = string
  default     = "us-east1"
}

variable "zones" {
  description = "Availability zones for MIG"
  type        = list(string)
  default     = ["us-central1-a", "us-central1-b", "us-central1-c"]
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "production"
}

variable "app_name" {
  description = "Application name"
  type        = string
  default     = "ecommerce"
}

variable "vpc_name" {
  description = "VPC name"
  type        = string
  default     = "ecommerce-vpc"
}

variable "subnet_cidr" {
  description = "CIDR for primary subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "machine_type" {
  description = "Machine type for MIG instances"
  type        = string
  default     = "e2-standard-2"
}

variable "min_instances" {
  description = "Minimum instances in MIG"
  type        = number
  default     = 3
}

variable "max_instances" {
  description = "Maximum instances in MIG"
  type        = number
  default     = 6
}

variable "target_cpu_utilization" {
  description = "Target CPU utilization for autoscaling"
  type        = number
  default     = 0.70
}

variable "db_instance_name" {
  description = "Cloud SQL instance name"
  type        = string
  default     = "ecommerce-postgres-primary"
}

variable "db_version" {
  description = "PostgreSQL version"
  type        = string
  default     = "15"
}

variable "db_tier" {
  description = "Database tier"
  type        = string
  default     = "db-custom-4-16384"
}

variable "db_backup_location" {
  description = "Cloud SQL backup location"
  type        = string
  default     = "us"
}

variable "labels" {
  description = "Labels for all resources"
  type        = map(string)
  default = {
    environment = "production"
    app         = "ecommerce"
    managed_by  = "terraform"
  }
}
