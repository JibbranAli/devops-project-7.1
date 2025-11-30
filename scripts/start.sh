#!/bin/bash
#
# Start Services Script for Amazon Linux
# Starts all Docker containers
#

set -e

# Get script directory and project root
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$( cd "$SCRIPT_DIR/.." && pwd )"

# Change to project root
cd "$PROJECT_ROOT"

echo "=========================================="
echo "Starting MLOps Pipeline Services"
echo "=========================================="
echo ""

# Check if model exists
if [ ! -f "app/model.pkl" ]; then
    echo "❌ Model not found!"
    echo ""
    echo "Please train the model first:"
    echo "  python3 app/train_model.py"
    echo ""
    exit 1
fi

echo "✅ Model found: $(ls -lh app/model.pkl | awk '{print $5}')"
echo ""

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker is not running!"
    echo ""
    echo "Starting Docker..."
    sudo systemctl start docker
    sleep 3
fi

# Stop any existing containers
echo "🛑 Stopping any existing containers..."
docker-compose down 2>/dev/null || true

# Start containers
echo ""
echo "🚀 Starting Docker containers..."
docker-compose up -d

echo ""
echo "⏳ Waiting for services to start (15 seconds)..."
sleep 15

# Check status
echo ""
echo "📊 Container Status:"
docker-compose ps

# Get public IP
PUBLIC_IP=$(curl -s --connect-timeout 2 http://169.254.169.254/latest/meta-data/public-ipv4 2>/dev/null || curl -s https://api.ipify.org 2>/dev/null || hostname -I | awk '{print $1}')

# Test API health
echo ""
echo "🔍 Testing API health..."
if curl -f http://localhost:5000/health > /dev/null 2>&1; then
    echo "✅ Flask API is healthy"
else
    echo "⚠️  Flask API is starting... (may take a few more seconds)"
fi

echo ""
echo "=========================================="
echo "✅ MLOps Pipeline is Running!"
echo "=========================================="
echo ""
echo "📍 Your IP: $PUBLIC_IP"
echo ""
echo "🌐 Access your services:"
echo "  Streamlit UI:  http://${PUBLIC_IP}:8501"
echo "  Flask API:     http://${PUBLIC_IP}:5000"
echo "  Health Check:  http://${PUBLIC_IP}:5000/health"
echo ""
echo "🧪 Test the API:"
echo "  curl http://${PUBLIC_IP}:5000/health"
echo ""
echo "  curl -X POST http://${PUBLIC_IP}:5000/predict \\"
echo "    -H \"Content-Type: application/json\" \\"
echo "    -d '{\"sepal_length\": 5.1, \"sepal_width\": 3.5, \"petal_length\": 1.4, \"petal_width\": 0.2}'"
echo ""
echo "📋 Useful commands:"
echo "  View logs:        docker-compose logs -f"
echo "  Check status:     docker-compose ps"
echo "  Stop services:    bash scripts/stop.sh"
echo "  Run tests:        bash scripts/test.sh"
echo ""
echo "⚠️  If you can't access from browser, check Security Group:"
echo "   - Port 5000 must be open"
echo "   - Port 8501 must be open"
echo "=========================================="
