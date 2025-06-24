#!/bin/bash
#
# Starts the Spark cluster.
#
# This script ensures a clean state by tearing down any existing services
# before building and starting a new Spark master and a configurable
# number of worker nodes.
#
# The number of workers is controlled by the WORKER_COUNT variable in the .env file.

set -e

# Ensure the script is run from the project root
cd "$(dirname "$0")/.."

# --- Configuration and Validation ---
echo "INFO: Starting Spark cluster setup..."

if [ ! -f ".env" ]; then
    echo "ERROR: .env file not found. Please create one from .env.example."
    exit 1
fi

# Source environment variables to validate them
export $(grep -v '^#' .env | xargs)

if ! [[ "${WORKER_COUNT}" =~ ^[0-9]+$ ]] || [ "${WORKER_COUNT}" -lt 1 ]; then
    echo "ERROR: Invalid WORKER_COUNT defined in .env. Must be a positive integer."
    exit 1
fi

echo "INFO: Configuration: ${WORKER_COUNT} worker(s), ${SPARK_WORKER_MEMORY:-2g} memory, ${SPARK_WORKER_CORES:-2} cores per worker."

# --- Cluster Initialization ---
echo "INFO: Stopping any existing cluster services..."
docker compose down --remove-orphans

echo "INFO: Building images and starting the cluster..."

# This single command builds images if they are out of date, creates and starts
# the master and all workers, and detaches from the terminal.
# The '--remove-orphans' flag cleans up any containers from previously scaled-down services.
docker compose up -d --build --remove-orphans --scale spark-worker=${WORKER_COUNT}

# --- Final Status ---
echo ""
echo "--------------------------------------------------"
echo "Spark Cluster has been initiated successfully."
echo "--------------------------------------------------"
echo "Access the Spark Master UI: http://localhost:${SPARK_MASTER_UI_PORT:-8080}"
echo "Access JupyterLab:        http://localhost:${JUPYTER_PORT:-8888}"
echo ""
echo "Use 'docker compose ps' to see the status of all services."
echo "Use './scripts/stop-cluster.sh' to stop the cluster."
