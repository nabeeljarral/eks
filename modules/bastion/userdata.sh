#!/bin/bash

# Update OS
yum update -y

# Ensure SSM Agent is running
systemctl enable amazon-ssm-agent
systemctl start amazon-ssm-agent

# Install tools for troubleshooting
yum install -y jq unzip curl telnet wget htop

# Install AWS CLI v2
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
./aws/install

# Install kubectl (v1.30.0 to match EKS cluster)
curl -LO "https://dl.k8s.io/release/v1.30.0/bin/linux/amd64/kubectl"
install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# Verify kubectl installation
kubectl version --client

echo "Bastion setup complete" > /var/log/bastion-init.log
