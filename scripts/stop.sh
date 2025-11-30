#!/bin/bash
#
# Stop Services Script
# Stops all Docker containers
#

echo "=========================================="
echo "Stopping MLOps Pipeline Services"
echo "=========================================="
echo ""

docker-compose down

echo ""
echo "✅ All services stopped"
echo ""
echo "To start again: bash scripts/start.sh"
echo "=========================================="
