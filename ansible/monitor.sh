#!/bin/bash

#Update system
sudo yum update -y


#Install Prometheus
PROM_VERSION="2.45.0"
cd /tmp
wget https://github.com/prometheus/prometheus/releases/download/v$PROM_VERSION/prometheus-$PROM_VERSION.linux-amd64.tar.gz
tar -xvzf prometheus-$PROM_VERSION.linux-amd64.tar.gz
mv prometheus-$PROM_VERSION.linux-amd64 prometheus

sudo cp prometheus/prometheus /usr/local/bin/
sudo cp prometheus/promtool /usr/local/bin/

sudo mkdir -p /etc/prometheus
sudo cp -r prometheus/consoles /etc/prometheus
sudo cp -r prometheus/console_libraries /etc/prometheus
sudo cp prometheus/prometheus.yml /etc/prometheus

#Create user prometheus if not exist
id -u prometheus &>/dev/null || sudo useradd --no-create-home --shell /bin/false prometheus

#Modify prometheus.yml file
sudo tee /etc/prometheus/prometheus.yml > /dev/null <<EOF
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'node_exporter'
    static_configs:
      - targets: ['localhost:9100']

rule_files:
  - "alert.rules.yml"

alerting:
  alertmanagers:
    - static_configs:
        - targets:
          - 'localhost:9093'
EOF

#Create Prometheus service
sudo tee /etc/systemd/system/prometheus.service > /dev/null <<EOF
[Unit]
Description=Prometheus Monitoring
Wants=network-online.target
After=network-online.target

[Service]
User=prometheus
ExecStart=/usr/local/bin/prometheus \\
  --config.file=/etc/prometheus/prometheus.yml \\
  --storage.tsdb.path=/var/lib/prometheus/

[Install]
WantedBy=multi-user.target
EOF

#Install Alertmanager
ALERT_VERSION="0.26.0"
cd /tmp
wget https://github.com/prometheus/alertmanager/releases/download/v$ALERT_VERSION/alertmanager-$ALERT_VERSION.linux-amd64.tar.gz
tar -xvzf alertmanager-$ALERT_VERSION.linux-amd64.tar.gz
mv alertmanager-$ALERT_VERSION.linux-amd64 alertmanager

sudo cp alertmanager/alertmanager /usr/local/bin/
sudo cp alertmanager/amtool /usr/local/bin/

sudo mkdir -p /etc/alertmanager /var/lib/alertmanager

#Create  Alertmanager Systemd Service
sudo tee /etc/systemd/system/alertmanager.service > /dev/null <<EOF
[Unit]
Description=Alertmanager
Wants=network-online.target
After=network-online.target

[Service]
User=ec2-user
ExecStart=/usr/local/bin/alertmanager \\
  --config.file=/etc/alertmanager/alertmanager.yml \\
  --storage.path=/var/lib/alertmanager/

[Install]
WantedBy=multi-user.target
EOF

#Create alert rules file
sudo tee /etc/prometheus/alert.rules.yml > /dev/null <<EOF
groups:
- name: system-alerts
  rules:
  - alert: HighCPUUsage
    expr: 100 - (avg by(instance) (rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100) > 85
    for: 5m
    labels:
      severity: warning
    annotations:
      summary: "High CPU Usage on {{ .instance }}"
      description: "CPU usage is above 85% for more than 5 minute."
EOF

#Create alertmanager file
sudo tee /etc/alertmanager/alertmanager.yml > /dev/null <<EOF
global:
  resolve_timeout: 5m

route:
  group_by: ['alertname']
  group_wait: 30s
  group_interval: 5m
  repeat_interval: 3h
  receiver: 'slack-notifications'

receivers:
  - name: 'slack-notifications'
    slack_configs:
      - api_url: 'https://hooks.slack.com/services/'  # Replace with your Slack webhook URL
        channel: '#project-name'  # Replace with required Slack channel
        send_resolved: true
EOF


sudo mkdir -p /var/lib/prometheus
sudo chown -R prometheus:prometheus /etc/prometheus /var/lib/prometheus
sudo systemctl daemon-reload
sudo systemctl enable prometheus
sudo systemctl start prometheus

sudo systemctl enable alertmanager
sudo systemctl start alertmanager

# Install Node Exporter
NODE_VERSION="1.3.1"
cd /tmp
wget https://github.com/prometheus/node_exporter/releases/download/v$NODE_VERSION/node_exporter-$NODE_VERSION.linux-amd64.tar.gz
tar -xvzf node_exporter-$NODE_VERSION.linux-amd64.tar.gz
mv node_exporter-$NODE_VERSION.linux-amd64 node_exporter

sudo cp node_exporter/node_exporter /usr/local/bin/

# Create Node Exporter service
sudo tee /etc/systemd/system/node_exporter.service > /dev/null <<EOF
[Unit]
Description=Node Exporter
Wants=network-online.target
After=network-online.target

[Service]
User=nobody
ExecStart=/usr/local/bin/node_exporter

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable node_exporter
sudo systemctl start node_exporter

# Install Grafana
sudo tee /etc/yum.repos.d/grafana.repo > /dev/null <<EOF
[grafana]
name=Grafana OSS
baseurl=https://packages.grafana.com/oss/rpm
repo_gpgcheck=1
enabled=1
gpgcheck=1
gpgkey=https://packages.grafana.com/gpg.key
EOF

sudo yum install grafana -y
sudo systemctl daemon-reload
sudo systemctl enable grafana-server
sudo systemctl start grafana-server

