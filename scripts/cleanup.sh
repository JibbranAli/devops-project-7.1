#!/bin/bash
#
# Complete Cleanup Script
# Removes all MLOps components, containers, images, and services
#

set -e

# Get script directory and project root
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$( cd "$SCRIPT_DIR/.." && pwd )"

# Change to project root
cd "$PROJECT_ROOT"

echo "╔════════════════════════════════════════════════════════╗"
echo "║                                                        ║"
echo "║          MLOps Pipeline - Complete Cleanup            ║"
echo "║                                                        ║"
echo "╚════════════════════════════════════════════════════════╝"
echo ""

# Warning
echo "⚠️  WARNING: This will remove:"
echo "   - All Docker containers"
echo "   - All Docker images"
echo "   - Jenkins service and data"
echo "   - Trained ML models"
echo "   - All project files"
echo ""

read -p "Are you sure you want to continue? (yes/no): " CONFIRM

if [ "$CONFIRM" != "yes" ]; then
    echo "Cleanup cancelled."
    exit 0
fi

echo ""
echo "════════════════════════════════════════════════════════"
echo "Starting Cleanup..."
echo "════════════════════════════════════════════════════════"
echo ""

# Step 1: Stop and remove Docker containers
echo "[1/8] 🛑 Stopping Docker containers..."
if command -v docker-compose &> /dev/null; then
    docker-compose down -v 2>/dev/null || true
    echo "✅ Containers stopped"
else
    echo "⚠️  docker-compose not found, skipping"
fi

# Step 2: Remove Docker images
echo ""
echo "[2/8] 🗑️  Removing Docker images..."
if command -v docker &> /dev/null; then
    # Remove MLOps images
    docker rmi mlops-flask-api:latest 2>/dev/null || true
    docker rmi mlops-streamlit-ui:latest 2>/dev/null || true
    
    # Remove dangling images
    docker image prune -f 2>/dev/null || true
    
    echo "✅ Docker images removed"
else
    echo "⚠️  Docker not found, skipping"
fi

# Step 3: Stop and disable Jenkins
echo ""
echo "[3/8] 🛑 Stopping Jenkins..."
if command -v systemctl &> /dev/null && systemctl list-units --full -all | grep -q jenkins; then
    systemctl stop jenkins 2>/dev/null || true
    systemctl disable jenkins 2>/dev/null || true
    echo "✅ Jenkins stopped"
else
    echo "⚠️  Jenkins not running, skipping"
fi

# Step 4: Remove Jenkins (optional - ask user)
echo ""
read -p "[4/8] Remove Jenkins completely? (yes/no): " REMOVE_JENKINS

if [ "$REMOVE_JENKINS" = "yes" ]; then
    echo "Removing Jenkins..."
    
    # Remove Jenkins package
    yum remove -y jenkins 2>/dev/null || true
    
    # Remove Jenkins data
    rm -rf /var/lib/jenkins 2>/dev/null || true
    rm -rf /var/cache/jenkins 2>/dev/null || true
    rm -rf /var/log/jenkins 2>/dev/null || true
    
    # Remove Jenkins repository
    rm -f /etc/yum.repos.d/jenkins.repo 2>/dev/null || true
    
    echo "✅ Jenkins removed"
else
    echo "⚠️  Jenkins kept (only stopped)"
fi

# Step 5: Remove trained models
echo ""
echo "[5/8] 🗑️  Removing trained models..."
rm -f app/model.pkl 2>/dev/null || true
rm -f app/models/*.pkl 2>/dev/null || true
echo "✅ Models removed"

# Step 6: Remove Python packages (optional)
echo ""
read -p "[6/8] Remove Python packages? (yes/no): " REMOVE_PYTHON

if [ "$REMOVE_PYTHON" = "yes" ]; then
    echo "Removing Python packages..."
    pip3 uninstall -y flask scikit-learn streamlit numpy pandas joblib 2>/dev/null || true
    echo "✅ Python packages removed"
else
    echo "⚠️  Python packages kept"
fi

# Step 7: Remove Docker (optional)
echo ""
read -p "[7/8] Remove Docker completely? (yes/no): " REMOVE_DOCKER

if [ "$REMOVE_DOCKER" = "yes" ]; then
    echo "Removing Docker..."
    
    # Stop Docker
    systemctl stop docker 2>/dev/null || true
    
    # Remove Docker
    yum remove -y docker docker-compose 2>/dev/null || true
    
    # Remove Docker data
    rm -rf /var/lib/docker 2>/dev/null || true
    rm -rf /var/lib/containerd 2>/dev/null || true
    
    echo "✅ Docker removed"
else
    echo "⚠️  Docker kept"
fi

# Step 8: Remove project directory (optional)
echo ""
read -p "[8/8] Remove entire project directory? (yes/no): " REMOVE_PROJECT

if [ "$REMOVE_PROJECT" = "yes" ]; then
    echo "⚠️  This will delete all project files!"
    read -p "Are you absolutely sure? (yes/no): " CONFIRM_DELETE
    
    if [ "$CONFIRM_DELETE" = "yes" ]; then
        cd ..
        rm -rf devops-project-7.1 2>/dev/null || true
        echo "✅ Project directory removed"
        echo ""
        echo "════════════════════════════════════════════════════════"
        echo "✅ Complete Cleanup Finished!"
        echo "════════════════════════════════════════════════════════"
        exit 0
    else
        echo "⚠️  Project directory kept"
    fi
else
    echo "⚠️  Project directory kept"
fi

echo ""
echo "════════════════════════════════════════════════════════"
echo "Cleanup Summary"
echo "════════════════════════════════════════════════════════"
echo ""

# Show what's still running
echo "Remaining services:"
echo ""

if systemctl is-active --quiet docker 2>/dev/null; then
    echo "  ✓ Docker: Running"
else
    echo "  ✗ Docker: Stopped/Removed"
fi

if systemctl is-active --quiet jenkins 2>/dev/null; then
    echo "  ✓ Jenkins: Running"
else
    echo "  ✗ Jenkins: Stopped/Removed"
fi

if docker ps -q 2>/dev/null | grep -q .; then
    echo "  ✓ Containers: $(docker ps -q | wc -l) running"
else
    echo "  ✗ Containers: None"
fi

if docker images -q 2>/dev/null | grep -q .; then
    echo "  ✓ Images: $(docker images -q | wc -l) present"
else
    echo "  ✗ Images: None"
fi

echo ""
echo "════════════════════════════════════════════════════════"
echo "✅ Cleanup Complete!"
echo "════════════════════════════════════════════════════════"
echo ""

if [ "$REMOVE_PROJECT" != "yes" ]; then
    echo "To redeploy, run:"
    echo "  sudo bash scripts/setup.sh"
    echo ""
fi
