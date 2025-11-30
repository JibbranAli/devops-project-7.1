#!/bin/bash
#
# Jenkins Installation Script
# Installs and configures Jenkins for CI/CD
#

set -e

echo "=========================================="
echo "Installing Jenkins"
echo "=========================================="
echo ""

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo "❌ Please run with sudo: sudo ./scripts/install_jenkins.sh"
    exit 1
fi

# Install Java (required for Jenkins)
echo "[1/4] ☕ Installing Java..."
yum install -y java-17-amazon-corretto java-17-amazon-corretto-devel || \
yum install -y java-11-amazon-corretto java-11-amazon-corretto-devel || \
yum install -y java-11-openjdk java-11-openjdk-devel

java -version

# Add Jenkins repository
echo ""
echo "[2/4] 📦 Adding Jenkins repository..."
wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key

# Install Jenkins
echo ""
echo "[3/4] 🔧 Installing Jenkins..."
yum install -y jenkins

# Add jenkins user to docker group
usermod -aG docker jenkins

# Start Jenkins
echo ""
echo "[4/4] 🚀 Starting Jenkins..."
systemctl daemon-reload
systemctl start jenkins
systemctl enable jenkins

# Wait for Jenkins to initialize
echo ""
echo "⏳ Waiting for Jenkins to initialize (30 seconds)..."
sleep 30

# Get public IP
PUBLIC_IP=$(curl -s --connect-timeout 2 http://169.254.169.254/latest/meta-data/public-ipv4 2>/dev/null || curl -s https://api.ipify.org 2>/dev/null || hostname -I | awk '{print $1}')

# Get Jenkins initial password
JENKINS_PASSWORD=""
if [ -f /var/lib/jenkins/secrets/initialAdminPassword ]; then
    JENKINS_PASSWORD=$(cat /var/lib/jenkins/secrets/initialAdminPassword)
fi

echo ""
echo "=========================================="
echo "✅ Jenkins Installed Successfully!"
echo "=========================================="
echo ""
echo "Access Jenkins:"
echo "  URL: http://${PUBLIC_IP}:8080"
echo ""
if [ -n "$JENKINS_PASSWORD" ]; then
    echo "Initial Admin Password:"
    echo "  $JENKINS_PASSWORD"
    echo ""
    echo "⚠️  IMPORTANT: Copy this password!"
else
    echo "Get password with:"
    echo "  sudo cat /var/lib/jenkins/secrets/initialAdminPassword"
fi
echo ""
echo "=========================================="
echo "Next Steps:"
echo "=========================================="
echo ""
echo "1. Open Jenkins: http://${PUBLIC_IP}:8080"
echo "2. Enter the initial admin password"
echo "3. Install suggested plugins"
echo "4. Create admin user"
echo "5. Create a new Pipeline job:"
echo "   - Name: mlops-pipeline"
echo "   - Type: Pipeline"
echo "   - Pipeline from SCM: Git"
echo "   - Repository: https://github.com/JibbranAli/devops-project-7.1.git"
echo "   - Script Path: Jenkinsfile"
echo ""
echo "⚠️  Make sure port 8080 is open in your Security Group"
echo "=========================================="
