#!/bin/bash
#
# Entrypoint for the Spark container.
# This script runs the Spark master or worker as a foreground process.

set -e

# --- Run main process based on SPARK_MODE ---

case "${SPARK_MODE}" in
  "master")
    # Start the Spark Master in the foreground
    # The 'exec' command replaces the shell with the Spark process, making it PID 1.
    # 'gosu' is used to run the command as the non-root 'sparkdev' user.
    echo "INFO: Starting Spark Master..."
    exec gosu sparkdev /opt/spark/bin/spark-class org.apache.spark.deploy.master.Master
    ;;

  "worker")
    # The Spark worker is designed to retry connecting to the master on its own.
    # We don't need a complex wait loop; we just start it.
    echo "INFO: Starting Spark Worker, connecting to ${SPARK_MASTER_URL}..."
    exec gosu sparkdev /opt/spark/bin/spark-class org.apache.spark.deploy.worker.Worker "${SPARK_MASTER_URL}"
    ;;

  "")
    echo "ERROR: SPARK_MODE is not set. Please set it to 'master' or 'worker'."
    exit 1
    ;;

  *)
    # Allows running arbitrary commands.
    # For example, running 'bash' to get a shell inside the container.
    echo "INFO: Running custom command: $@"
    exec gosu sparkdev "$@"
    ;;
esac
