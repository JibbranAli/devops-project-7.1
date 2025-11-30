#!/bin/bash
#
# Jenkins Installation and Setup Script
# Installs Jenkins and guides through initial setup
#

set -e

# Get script directory and project root
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$( cd "$SCRIPT_DIR/.." && pwd )"

# Change to project root
cd "$PROJECT_ROOT"

echo "╔════════════════════════════════════════════════════════╗"
echo "║                                                        ║"
echo "║          STEP 2: Jenkins Installation                 ║"
echo "║                                                        ║"
echo "╚════════════════════════════════════════════════════════╝"
echo ""

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo "❌ Please run with sudo: sudo bash scripts/setup_jenkins.sh"
    exit 1
fi

# Get public IP
PUBLIC_IP=$(curl -s --connect-timeout 2 http://169.254.169.254/latest/meta-data/public-ipv4 2>/dev/null || curl -s https://api.ipify.org 2>/dev/null || hostname -I | awk '{print $1}')

echo "📍 Your IP: $PUBLIC_IP"
echo ""

# Install Jenkins if not already installed
if ! command -v jenkins &> /dev/null; then
    echo "════════════════════════════════════════════════════════"
    echo "Installing Jenkins..."
    echo "════════════════════════════════════════════════════════"
    echo ""
    
    # Install Java
    echo "[1/4] ☕ Installing Java..."
    yum install -y java-17-amazon-corretto java-17-amazon-corretto-devel 2>/dev/null || \
    yum install -y java-11-amazon-corretto java-11-amazon-corretto-devel 2>/dev/null || \
    yum install -y java-11-openjdk java-11-openjdk-devel
    
    java -version
    
    # Add Jenkins repository
    echo ""
    echo "[2/4] 📦 Adding Jenkins repository..."
    wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo 2>/dev/null
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
    
    echo ""
    echo "✅ Jenkins installed successfully!"
else
    echo "✅ Jenkins already installed"
    systemctl start jenkins || true
fi

# Wait for Jenkins to initialize
echo ""
echo "════════════════════════════════════════════════════════"
echo "Waiting for Jenkins to Initialize..."
echo "════════════════════════════════════════════════════════"
echo ""
echo "⏳ Please wait 30 seconds..."
sleep 30

# Get Jenkins initial password
JENKINS_PASSWORD=""
if [ -f /var/lib/jenkins/secrets/initialAdminPassword ]; then
    JENKINS_PASSWORD=$(cat /var/lib/jenkins/secrets/initialAdminPassword)
fi

echo ""
echo "╔════════════════════════════════════════════════════════╗"
echo "║                                                        ║"
echo "║          Jenkins Initial Setup Required                ║"
echo "║                                                        ║"
echo "╚════════════════════════════════════════════════════════╝"
echo ""
echo "🌐 Open Jenkins in your browser:"
echo ""
echo "   http://${PUBLIC_IP}:8080"
echo ""
echo "════════════════════════════════════════════════════════"
echo "🔑 Initial Admin Password:"
echo "════════════════════════════════════════════════════════"
echo ""
echo "   ${JENKINS_PASSWORD}"
echo ""
echo "════════════════════════════════════════════════════════"
echo ""
echo "⚠️  COPY THIS PASSWORD - You'll need it in the next step!"
echo ""
echo "📋 Follow these steps in Jenkins UI:"
echo ""
echo "   1. Paste the password above"
echo "   2. Click 'Install suggested plugins'"
echo "   3. Wait for plugins to install (5-10 minutes)"
echo "   4. Create admin user:"
echo "      - Username: admin"
echo "      - Password: (your choice)"
echo "      - Full name: Admin"
echo "      - Email: admin@example.com"
echo "   5. Keep default Jenkins URL"
echo "   6. Click 'Start using Jenkins'"
echo ""
echo "════════════════════════════════════════════════════════"
echo ""
echo "After completing Jenkins setup, run:"
echo ""
echo "   sudo bash scripts/create_pipeline.sh"
echo ""
echo "════════════════════════════════════════════════════════"

# Save password for later use
echo "$JENKINS_PASSWORD" > /tmp/jenkins_password.txt
chmod 600 /tmp/jenkins_password.txt
