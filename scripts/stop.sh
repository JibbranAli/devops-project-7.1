#!/bin/bash
#
# Stop Services Script
# Stops all Docker containers
#

# Get script directory and project root
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$( cd "$SCRIPT_DIR/.." && pwd )"

# Change to project root
cd "$PROJECT_ROOT"

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
