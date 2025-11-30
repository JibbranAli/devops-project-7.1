#!/bin/bash
#
# Create Jenkins Pipeline Script
# Creates the MLOps pipeline in Jenkins
#

set -e

echo "╔════════════════════════════════════════════════════════╗"
echo "║                                                        ║"
echo "║          STEP 3: Create Jenkins Pipeline              ║"
echo "║                                                        ║"
echo "╚════════════════════════════════════════════════════════╝"
echo ""

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo "❌ Please run with sudo: sudo bash scripts/create_pipeline.sh"
    exit 1
fi

# Get public IP
PUBLIC_IP=$(curl -s --connect-timeout 2 http://169.254.169.254/latest/meta-data/public-ipv4 2>/dev/null || curl -s https://api.ipify.org 2>/dev/null || hostname -I | awk '{print $1}')

echo "📍 Your IP: $PUBLIC_IP"
echo ""

# Check if Jenkins is running
if ! systemctl is-active --quiet jenkins; then
    echo "❌ Jenkins is not running!"
    echo "Start it with: sudo systemctl start jenkins"
    exit 1
fi

echo "✅ Jenkins is running"
echo ""

echo "════════════════════════════════════════════════════════"
echo "Creating MLOps Pipeline in Jenkins"
echo "════════════════════════════════════════════════════════"
echo ""

echo "📋 Manual Pipeline Creation Steps:"
echo ""
echo "1. Open Jenkins: http://${PUBLIC_IP}:8080"
echo ""
echo "2. Click 'New Item' (top left)"
echo ""
echo "3. Enter item name:"
echo "   mlops-pipeline"
echo ""
echo "4. Select: Pipeline"
echo ""
echo "5. Click OK"
echo ""
echo "6. In the configuration page:"
echo ""
echo "   General Section:"
echo "   ✓ Description: MLOps Pipeline for Iris Classification"
echo ""
echo "   Build Triggers:"
echo "   ✓ Check 'Poll SCM'"
echo "   ✓ Schedule: H/5 * * * *"
echo "     (This checks GitHub every 5 minutes)"
echo ""
echo "   Pipeline Section:"
echo "   ✓ Definition: Pipeline script from SCM"
echo "   ✓ SCM: Git"
echo "   ✓ Repository URL:"
echo "     https://github.com/JibbranAli/devops-project-7.1.git"
echo "   ✓ Branch Specifier: */main"
echo "   ✓ Script Path: Jenkinsfile"
echo ""
echo "7. Click 'Save'"
echo ""
echo "8. Click 'Build Now' to start the pipeline"
echo ""
echo "════════════════════════════════════════════════════════"
echo ""
echo "🎯 What the Pipeline Does:"
echo ""
echo "   Stage 1: Checkout Code from GitHub"
echo "   Stage 2: Install Python Dependencies"
echo "   Stage 3: Train ML Model"
echo "   Stage 4: Build Docker Images (Flask + Streamlit)"
echo "   Stage 5: Stop Old Containers"
echo "   Stage 6: Deploy New Containers"
echo "   Stage 7: Health Checks"
echo "   Stage 8: Run Tests"
echo ""
echo "════════════════════════════════════════════════════════"
echo ""

# Wait for user confirmation
read -p "✋ Press ENTER after you've created the pipeline and it has run successfully..."

echo ""
echo "════════════════════════════════════════════════════════"
echo "Verifying Deployment..."
echo "════════════════════════════════════════════════════════"
echo ""

# Check if containers are running
if docker-compose ps | grep -q "Up"; then
    echo "✅ Containers are running"
    docker-compose ps
else
    echo "⚠️  Containers not running yet"
    echo "Wait for Jenkins pipeline to complete"
fi

echo ""
echo "════════════════════════════════════════════════════════"
echo "Next Step: Run Tests"
echo "════════════════════════════════════════════════════════"
echo ""
echo "After the pipeline completes successfully, run:"
echo ""
echo "   bash scripts/test.sh"
echo ""
echo "════════════════════════════════════════════════════════"
