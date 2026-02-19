#!/bin/bash

# Update system
apt-get update -y
apt-get upgrade -y

# Install essential tools
apt-get install -y \
    curl \
    wget \
    unzip \
    git \
    htop \
    vim \
    awscli

# Install kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
mv kubectl /usr/local/bin/

# Install AWS CLI v2
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
./aws/install

# Install eksctl
curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
mv /tmp/eksctl /usr/local/bin

# Install Helm
curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | tee /usr/share/keyrings/helm.gpg > /dev/null
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | tee /etc/apt/sources.list.d/helm-stable-debian.list
apt-get update
apt-get install helm -y

# Configure kubectl for EKS cluster
aws eks update-kubeconfig --region $(curl -s http://169.254.169.254/latest/meta-data/placement/region) --name ${cluster_name}

# Create a welcome message
cat << 'EOF' > /etc/motd

Welcome to the EKS Bastion Host!

Available tools:
- kubectl (Kubernetes CLI)
- aws (AWS CLI v2)
- eksctl (EKS management tool)
- helm (Kubernetes package manager)

The kubectl is already configured for your EKS cluster: ${cluster_name}

EOF

echo "Bastion host setup completed!" > /var/log/user-data.log