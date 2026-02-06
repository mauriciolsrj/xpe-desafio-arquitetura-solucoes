#!/bin/bash
# Startup Script for Google Cloud Ops Agent Installation and Configuration
# This script is executed when the VM instance starts

set -e
set -x

# Log output to file
exec 1> >(logger -s -t $(basename $0))
exec 2>&1

echo "=== Starting Ops Agent Installation and Configuration ==="

# Update system packages
apt-get update
apt-get upgrade -y

# Install required dependencies
apt-get install -y \
    curl \
    wget \
    gnupg \
    lsb-release \
    ca-certificates \
    apt-transport-https

# Add Google Cloud Ops Agent repository
echo "deb https://packages.cloud.google.com/apt google-cloud-ops-agent-$(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/google-cloud-ops-agent.list

# Import Google Cloud public key
curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -

# Update package list again with new repository
apt-get update

# Install Google Cloud Ops Agent
apt-get install -y google-cloud-ops-agent

echo "=== Configuring Ops Agent ==="

# Create Ops Agent configuration file
cat > /etc/google-cloud-ops-agent/config.yaml <<'EOF'
# Google Cloud Ops Agent Configuration

logging:
  receivers:
    syslog:
      type: files
      include_paths:
        - /var/log/syslog
        - /var/log/messages
    app_logs:
      type: files
      include_paths:
        - /var/log/app/*.log
        - /var/log/ecommerce/*.log
  service:
    pipelines:
      default_pipeline:
        receivers: [syslog, app_logs]

metrics:
  receivers:
    hostmetrics:
      type: hostmetrics
      collection_interval: 60s
  processors:
    batch:
      type: batch
      send_batch_size: 100
      timeout: 10s
  exporters:
    google_cloud_monitoring:
      type: google_cloud_monitoring
      metric_prefix: "custom.googleapis.com/"
  service:
    pipelines:
      default_pipeline:
        receivers: [hostmetrics]
        processors: [batch]
        exporters: [google_cloud_monitoring]

EOF

# Start and enable Ops Agent
systemctl start google-cloud-ops-agent
systemctl enable google-cloud-ops-agent

echo "=== Installing Application Dependencies ==="

# Install Node.js runtime (for example ecommerce app)
curl -sL https://deb.nodesource.com/setup_18.x | bash -
apt-get install -y nodejs

# Install nginx as reverse proxy
apt-get install -y nginx

# Configure nginx as reverse proxy with health check endpoint
cat > /etc/nginx/sites-available/default <<'EOF'
server {
    listen 8080 default_server;
    listen [::]:8080 default_server;

    # Health check endpoint for Load Balancer
    location /health {
        access_log off;
        return 200 "healthy\n";
        add_header Content-Type text/plain;
    }

    # Proxy to application backend
    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;

        # Timeouts
        proxy_connect_timeout 10s;
        proxy_send_timeout 30s;
        proxy_read_timeout 30s;
    }
}
EOF

# Test nginx configuration
nginx -t

# Start and enable nginx
systemctl restart nginx
systemctl enable nginx

echo "=== Setting Up Application Logging Directories ==="

# Create application log directory
mkdir -p /var/log/ecommerce
mkdir -p /var/log/app
chmod 755 /var/log/ecommerce
chmod 755 /var/log/app

echo "=== Installing Cloud SQL Proxy ==="

# Install Cloud SQL Proxy for secure database connectivity
curl -o cloud-sql-proxy https://dl.google.com/cloudsql/cloud_sql_proxy.linux.amd64
chmod +x cloud-sql-proxy
mv cloud-sql-proxy /usr/local/bin/

# Create systemd service for Cloud SQL Proxy (optional, if using Unix socket)
# This would be configured based on your Cloud SQL instance connection name

echo "=== Custom Metrics Configuration ==="

# Example: Custom metric for application performance
cat > /usr/local/bin/send-custom-metrics.sh <<'EOF'
#!/bin/bash

# Send custom application metrics to Cloud Monitoring
# This script can be scheduled via cron or called by your application

PROJECT_ID=$(gcloud config get-value project)
RESOURCE_TYPE="gce_instance"
INSTANCE_ID=$(curl -s http://metadata.google.internal/computeMetadata/v1/instance/id -H "Metadata-Flavor: Google")
ZONE=$(curl -s http://metadata.google.internal/computeMetadata/v1/instance/zone -H "Metadata-Flavor: Google" | cut -d'/' -f4)

# Example: Send custom metric for request processing time
# gcloud monitoring metrics-write custom.googleapis.com/request_processing_time \
#   --value=<value> \
#   --resource-type=$RESOURCE_TYPE \
#   --resource-labels=instance_id=$INSTANCE_ID,zone=$ZONE

echo "Custom metrics sent at $(date)"
EOF

chmod +x /usr/local/bin/send-custom-metrics.sh

echo "=== Setting Up Log Monitoring ==="

# Create a cron job to rotate application logs
cat > /etc/logrotate.d/ecommerce <<'EOF'
/var/log/ecommerce/*.log {
    daily
    rotate 7
    compress
    delaycompress
    missingok
    notifempty
    create 0640 root root
    sharedscripts
    postrotate
        systemctl reload nginx > /dev/null 2>&1 || true
    endscript
}
EOF

echo "=== Verifying Installations ==="

# Verify Ops Agent is running
systemctl status google-cloud-ops-agent || echo "Ops Agent status check returned: $?"

# Verify nginx is running
systemctl status nginx || echo "Nginx status check returned: $?"

# Check Node.js installation
node --version
npm --version

echo "=== Startup Script Completed Successfully ==="
echo "$(date): Setup completed. System is ready for application deployment."

# Optional: Signal completion to GCP's startup script handler
touch /var/lib/google/startup-script.completed
