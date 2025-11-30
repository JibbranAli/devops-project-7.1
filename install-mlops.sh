#!/bin/bash
#
# One-Line Installer for MLOps Pipeline
# Usage: curl -fsSL https://raw.githubusercontent.com/JibbranAli/devops-project-7.1/main/install-mlops.sh | sudo bash
#

set -e

echo "╔════════════════════════════════════════════════════════╗"
echo "║                                                        ║"
echo "║     MLOps Pipeline - One-Line Installer               ║"
echo "║     For Amazon Linux 2023                             ║"
echo "║                                                        ║"
echo "╚════════════════════════════════════════════════════════╝"
echo ""

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo "❌ Please run with sudo"
    exit 1
fi

# Get actual user
ACTUAL_USER=${SUDO_USER:-ec2-user}

echo "👤 User: $ACTUAL_USER"
echo "📍 Working directory: /home/$ACTUAL_USER"
echo ""

# Clone repository
echo "[1/3] 📥 Cloning repository..."
cd /home/$ACTUAL_USER
if [ -d "devops-project-7.1" ]; then
    echo "Directory exists, pulling latest..."
    cd devops-project-7.1
    sudo -u $ACTUAL_USER git pull origin main
else
    sudo -u $ACTUAL_USER git clone https://github.com/JibbranAli/devops-project-7.1.git
    cd devops-project-7.1
fi

# Make scripts executable
chmod +x scripts/*.sh

# Run setup
echo ""
echo "[2/3] 🔧 Running setup..."
bash scripts/setup.sh

# Start services
echo ""
echo "[3/3] 🚀 Starting services..."
sudo -u $ACTUAL_USER bash scripts/start.sh

echo ""
echo "╔════════════════════════════════════════════════════════╗"
echo "║                                                        ║"
echo "║     ✅ Installation Complete!                          ║"
echo "║                                                        ║"
echo "╚════════════════════════════════════════════════════════╝"
echo ""
echo "Your MLOps pipeline is running!"
echo ""
echo "📁 Project location: /home/$ACTUAL_USER/devops-project-7.1"
echo ""
echo "Run tests:"
echo "  cd /home/$ACTUAL_USER/devops-project-7.1"
echo "  bash scripts/test.sh"
echo ""
