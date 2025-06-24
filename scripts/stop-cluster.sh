#!/bin/bash
#
# Stops the Spark cluster services.
#
# By default, this script stops the running containers.
# Use the --clean flag to perform a full teardown, which removes
# containers and the network.

set -e

# --- Argument Parsing ---
CLEAN=false
if [[ "$1" == "--clean" ]]; then
    CLEAN=true
elif [[ "$1" == "-h" ]] || [[ "$1" == "--help" ]]; then
    echo "Usage: $0 [--clean]"
    echo ""
    echo "Stops the Spark cluster services."
    echo "  --clean    Stops and removes containers and the network."
    exit 0
elif [[ -n "$1" ]]; then
    echo "ERROR: Unknown option: $1"
    echo "Usage: $0 [--clean]"
    exit 1
fi

# Ensure the script is run from the project root
cd "$(dirname "$0")/.."

if [ ! -f "docker-compose.yml" ]; then
    echo "ERROR: docker-compose.yml not found. Please run this script from the project root."
    exit 1
fi

# --- Cluster Shutdown ---
if [ "$CLEAN" = true ]; then
    echo "INFO: Stopping and removing all cluster containers and networks..."
    docker compose down --remove-orphans
    echo "INFO: Cluster has been completely removed."
else
    echo "INFO: Stopping all cluster containers..."
    docker compose stop
    echo "INFO: Cluster containers stopped."
    echo "INFO: Run with '--clean' to remove containers and networks completely."
fi
