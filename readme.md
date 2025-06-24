# Spark-Dev: Local Spark & Databricks-Style Development

This repository provides a fully local solution for developing and testing Apache Spark applications. It supports both standard Spark and Databricks-style workflows by pulling the Delta Spark package from Maven. No cloud resources required, everything runs on your machine, and it includes a Jupyter instance connected to the Spark cluster for seamless development.

## Project Structure

- `src/main/python/` — Place your Spark scripts here (e.g., `example_spark.py`, `example_dbx.py`)
- `src/test/` — (Reserved for tests)
- `notebooks/python/` — Jupyter notebooks for Python (e.g., `template.ipynb`, `template_dbx.ipynb`)
- `notebooks/sql/` — Jupyter notebooks for SQL (empty by default)
- `data/` — Your local datasets (empty by default)
- `docker/` — Dockerfiles and configs for the Spark cluster
- `scripts/` — Helper scripts (`start-cluster.sh`, `stop-cluster.sh`)
- `docker-compose.yml` — Compose file to spin up the Spark cluster
- `.env` — General configuration for customizing your local Spark environment (edit this file to adjust ports, cluster size, and other settings)

## Purpose

- Develop and test Spark jobs locally
- Optionally use Databricks syntax and Delta Lake
- No cloud or Databricks account needed

## Requirements

- Docker
- Docker Compose

## Usage
### Mounted Directories for containers
- src/main/ (place your scripts here)
- notebooks/ (always copy the first cell from your desired template)
- data/ (mounted as a volume to ease data sharing)

### URLs
- Spark Master UI: http://localhost:8080 (Shows all workers and jobs)
- Spark Worker UIs: http://localhost:8081, 8082, etc. (One for each worker)
- Application UI: http://localhost:4040 (Visible only when a Spark job is running)
- Jupyter interface: http://localhost:8888

### Sample Usage
Currently, the scripts are written in .sh which make it incompatible with Windows. To run the scripts on Windows, you can use WSL or Docker Desktop.

1. `./scripts/start-cluster.sh` (starts cluster, this will build the Docker image if needed)
2. Run spark:
  - Using `spark-submit`:
    1. Write your script: `src/main/python/my_script.py`
    2. Run it: `docker-compose exec -T -u sparkdev spark-master /opt/spark/bin/spark-submit --master spark://spark-dev-master:7077 /opt/spark/work-dir/src/main/python/my_script.py`
  - Using Jupyter notebooks:
    1. Open the Jupyter interface at [http://localhost:8888](http://localhost:8888)
    2. Connect to the Spark Cluster by using the master_url `spark://spark-master:7077` when creating the Spark Session (check `template.ipynb` for an example)
    3. Create your own notebook in the `notebooks/` folder and start developing
    4. Always remember to run `spark.stop()` in a cell after you're done, otherwise resources are not released properly.
