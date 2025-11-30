#!/bin/bash
#
# Complete Automated Setup Script for Amazon Linux 2023
# This script installs all dependencies and sets up the MLOps pipeline
#

set -e

echo "=========================================="
echo "MLOps Pipeline - Automated Setup"
echo "For Amazon Linux 2023"
echo "=========================================="
echo ""

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo "❌ Please run with sudo: sudo bash scripts/setup.sh"
    exit 1
fi

# Get the actual user (not root)
ACTUAL_USER=${SUDO_USER:-ec2-user}
ACTUAL_HOME=$(eval echo ~$ACTUAL_USER)

echo "👤 Running as user: $ACTUAL_USER"
echo "🖥️  OS: $(cat /etc/os-release | grep PRETTY_NAME | cut -d'"' -f2)"
echo ""

# Step 1: Update system
echo "[1/8] 📦 Updating system packages..."
yum update -y

# Step 2: Install Python 3 and dependencies
echo ""
echo "[2/8] 🐍 Installing Python 3 and build tools..."
yum install -y python3 python3-pip python3-devel gcc gcc-c++ git wget curl tar gzip

python3 --version
pip3 --version

# Step 3: Install Docker
echo ""
echo "[3/8] 🐳 Installing Docker..."
if ! command -v docker &> /dev/null; then
    yum install -y docker
    systemctl start docker
    systemctl enable docker
    usermod -aG docker $ACTUAL_USER
    usermod -aG docker ec2-user 2>/dev/null || true
    echo "✅ Docker installed"
else
    echo "✅ Docker already installed"
    systemctl start docker || true
    systemctl enable docker || true
fi

docker --version

# Step 4: Install Docker Compose
echo ""
echo "[4/8] 🐙 Installing Docker Compose..."
if ! command -v docker-compose &> /dev/null; then
    DOCKER_COMPOSE_VERSION="v2.24.0"
    curl -L "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
    ln -sf /usr/local/bin/docker-compose /usr/bin/docker-compose
    echo "✅ Docker Compose installed"
else
    echo "✅ Docker Compose already installed"
fi

docker-compose --version

# Step 5: Install Python dependencies
echo ""
echo "[5/8] 📚 Installing Python dependencies..."
sudo -u $ACTUAL_USER pip3 install --user --upgrade pip
sudo -u $ACTUAL_USER pip3 install --user -r requirements.txt

# Verify installations
echo ""
echo "Verifying Python packages..."
sudo -u $ACTUAL_USER python3 -c "import flask; import sklearn; import streamlit; print('✅ All packages installed')"

# Step 6: Create app directory
echo ""
echo "[6/8] 📁 Creating directories..."
mkdir -p app/models
chown -R $ACTUAL_USER:$ACTUAL_USER app/

# Step 7: Train the model
echo ""
echo "[7/8] 🤖 Training ML model..."
sudo -u $ACTUAL_USER python3 app/train_model.py

# Verify model was created
if [ -f "app/model.pkl" ]; then
    echo "✅ Model trained successfully: $(ls -lh app/model.pkl | awk '{print $5}')"
else
    echo "❌ Model training failed!"
    exit 1
fi

# Step 8: Build Docker images
echo ""
echo "[8/8] 🏗️ Building Docker images..."
docker-compose build --no-cache

# Verify images were built
echo ""
echo "Verifying Docker images..."
docker images | grep mlops

# Get public IP
PUBLIC_IP=$(curl -s --connect-timeout 2 http://169.254.169.254/latest/meta-data/public-ipv4 2>/dev/null || curl -s https://api.ipify.org 2>/dev/null || hostname -I | awk '{print $1}')

echo ""
echo "=========================================="
echo "✅ Setup Complete!"
echo "=========================================="
echo ""
echo "📍 Your IP Address: $PUBLIC_IP"
echo ""
echo "🚀 Next steps:"
echo "  1. Start services:"
echo "     bash scripts/start.sh"
echo ""
echo "  2. Access your application:"
echo "     🌐 Streamlit UI:  http://${PUBLIC_IP}:8501"
echo "     🔌 Flask API:     http://${PUBLIC_IP}:5000"
echo "     ❤️  Health Check:  http://${PUBLIC_IP}:5000/health"
echo ""
echo "  3. Test the API:"
echo "     curl http://${PUBLIC_IP}:5000/health"
echo ""
echo "⚠️  IMPORTANT: Make sure these ports are open in your Security Group:"
echo "   - Port 5000 (Flask API)"
echo "   - Port 8501 (Streamlit UI)"
echo "   - Port 8080 (Jenkins - optional)"
echo ""
echo "📚 For Jenkins setup, run:"
echo "   sudo bash scripts/install_jenkins.sh"
echo ""
echo "🔄 Note: You may need to log out and back in for docker group to take effect"
echo "=========================================="
