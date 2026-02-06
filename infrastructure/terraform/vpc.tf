# VPC Network
resource "google_compute_network" "main" {
  name                    = var.vpc_name
  auto_create_subnetworks = false
  routing_mode            = "REGIONAL"
  project                 = var.project_id

  depends_on = [google_project_service.required_apis["compute.googleapis.com"]]
}

# Regional Subnet (Primary)
resource "google_compute_subnetwork" "primary" {
  name          = "${var.app_name}-subnet-primary"
  ip_cidr_range = var.subnet_cidr
  region        = var.primary_region
  network       = google_compute_network.main.id
  project       = var.project_id

  private_ip_google_access = true

  log_config {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
}

# Firewall: Allow Google Cloud Load Balancer traffic
resource "google_compute_firewall" "allow_glb" {
  name    = "${var.app_name}-allow-glb"
  network = google_compute_network.main.name
  project = var.project_id

  allow {
    protocol = "tcp"
    ports    = ["80", "443", "8080"]
  }

  source_ranges = [
    "130.211.0.0/22",  # Google Cloud Load Balancer range
    "35.191.0.0/16"    # Google Cloud Load Balancer range
  ]

  target_tags = ["http-server", "https-server"]
}

# Firewall: Allow internal communication
resource "google_compute_firewall" "allow_internal" {
  name    = "${var.app_name}-allow-internal"
  network = google_compute_network.main.name
  project = var.project_id

  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }

  allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }

  allow {
    protocol = "icmp"
  }

  source_ranges = [var.subnet_cidr]
}

# Firewall: Allow IAP for SSH (optional, for debugging)
resource "google_compute_firewall" "allow_iap_ssh" {
  name    = "${var.app_name}-allow-iap-ssh"
  network = google_compute_network.main.name
  project = var.project_id

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = [
    "35.235.240.0/20"  # IAP range
  ]

  target_tags = ["allow-ssh"]
}

# Firewall: Allow external SSH from specific IP (if needed)
resource "google_compute_firewall" "allow_ssh_admin" {
  name    = "${var.app_name}-allow-ssh-admin"
  network = google_compute_network.main.name
  project = var.project_id

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]  # CHANGE THIS: Restrict to your admin IP
  target_tags   = ["allow-ssh"]

  # This rule is for demonstration. In production, use more restrictive source ranges.
}

# Cloud Router for Cloud NAT (for outbound internet access from VMs)
resource "google_compute_router" "main" {
  name    = "${var.app_name}-router"
  region  = var.primary_region
  network = google_compute_network.main.id
  project = var.project_id

  bgp {
    asn = 64514
  }
}

# Cloud NAT for private VM internet access
resource "google_compute_router_nat" "nat" {
  name                               = "${var.app_name}-nat"
  router                             = google_compute_router.main.name
  region                             = google_compute_router.main.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
  project                            = var.project_id

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}
