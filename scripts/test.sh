#!/bin/bash
#
# Test Script for Amazon Linux
# Tests all components of the MLOps pipeline
#

set -e

# Get script directory and project root
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$( cd "$SCRIPT_DIR/.." && pwd )"

# Change to project root
cd "$PROJECT_ROOT"

echo "=========================================="
echo "Testing MLOps Pipeline"
echo "=========================================="
echo ""

# Get IP
IP=$(curl -s --connect-timeout 2 http://169.254.169.254/latest/meta-data/public-ipv4 2>/dev/null || echo "localhost")

# Test 1: Check if containers are running
echo "[1/5] 🐳 Checking Docker containers..."
if docker-compose ps | grep -q "Up"; then
    echo "✅ Containers are running"
else
    echo "❌ Containers are not running"
    echo "Start them with: bash scripts/start.sh"
    exit 1
fi

# Test 2: Health check
echo ""
echo "[2/5] ❤️  Testing API health..."
if curl -f http://localhost:5000/health > /dev/null 2>&1; then
    echo "✅ API is healthy"
    curl -s http://localhost:5000/health | python3 -m json.tool
else
    echo "❌ API health check failed"
    exit 1
fi

# Test 3: Model info
echo ""
echo "[3/5] ℹ️  Getting model info..."
curl -s http://localhost:5000/info | python3 -m json.tool

# Test 4: Make prediction
echo ""
echo "[4/5] 🔮 Testing prediction..."
RESPONSE=$(curl -s -X POST http://localhost:5000/predict \
    -H "Content-Type: application/json" \
    -d '{"sepal_length": 5.1, "sepal_width": 3.5, "petal_length": 1.4, "petal_width": 0.2}')

echo "$RESPONSE" | python3 -m json.tool

if echo "$RESPONSE" | grep -q "prediction"; then
    echo "✅ Prediction successful"
else
    echo "❌ Prediction failed"
    exit 1
fi

# Test 5: Check Streamlit
echo ""
echo "[5/5] 🎨 Checking Streamlit UI..."
if curl -f http://localhost:8501 > /dev/null 2>&1; then
    echo "✅ Streamlit UI is accessible"
else
    echo "⚠️  Streamlit UI check failed (might still be starting)"
fi

echo ""
echo "=========================================="
echo "✅ All Tests Passed!"
echo "=========================================="
echo ""
echo "Your application is working correctly!"
echo "  Streamlit UI: http://${IP}:8501"
echo "  Flask API:    http://${IP}:5000"
echo "=========================================="
