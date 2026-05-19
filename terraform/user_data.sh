#!/bin/bash
set -euo pipefail

dnf update -y

dnf install -y docker
systemctl enable docker
systemctl start docker

curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

dnf install -y amazon-cloudwatch-agent

# Connexion a GHCR (le token doit etre un classic PAT avec read:packages)
echo "${github_token}" | docker login ghcr.io -u "${github_actor}" --password-stdin

docker pull ghcr.io/${github_repo}:${image_tag}
docker run -d \
  --name app \
  --restart unless-stopped \
  -p 80:5000 \
  --log-driver=awslogs \
  --log-opt awslogs-group=/devops-pipeline/app \
  --log-opt awslogs-region=${aws_region} \
  ghcr.io/${github_repo}:${image_tag}

cat > /opt/aws/amazon-cloudwatch-agent/etc/config.json << 'EOF'
{
  "metrics": {
    "namespace": "DevOpsPipeline",
    "metrics_collected": {
      "cpu": {
        "measurement": ["cpu_usage_idle", "cpu_usage_user", "cpu_usage_system"],
        "metrics_collection_interval": 60
      },
      "mem": {
        "measurement": ["mem_used_percent"],
        "metrics_collection_interval": 60
      },
      "disk": {
        "measurement": ["used_percent"],
        "resources": ["/", "/docker"],
        "metrics_collection_interval": 60
      }
    }
  }
}
EOF

systemctl enable amazon-cloudwatch-agent
systemctl start amazon-cloudwatch-agent
