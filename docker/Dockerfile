# Start from a specific Ubuntu version
FROM ubuntu:22.04

ARG SPARK_VERSION=3.5.0
ARG DELTA_VERSION=3.2.0
ARG ANTLR_VERSION=4.9.3

# Prevent interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC

# Update and install dependencies
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    vim \
    git \
    unzip \
    tar \
    openjdk-17-jdk \
    python3 \
    python3-pip \
    python3-dev \
    gosu \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Set Environment Variables
ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
ENV HADOOP_VERSION=3
ENV SPARK_HOME=/opt/spark
ENV PYSPARK_PYTHON=/usr/bin/python3
ENV PYSPARK_DRIVER_PYTHON=/usr/bin/python3
ENV PATH=$SPARK_HOME/bin:$SPARK_HOME/sbin:$JAVA_HOME/bin:$PATH

# Download and install Apache Spark
RUN wget -q "https://archive.apache.org/dist/spark/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz" -P /tmp && \
    tar -xzf "/tmp/spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz" -C /opt && \
    mv "/opt/spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}" "${SPARK_HOME}" && \
    rm "/tmp/spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz"

# Download JAR files for Delta Lake 3.2.0 (for Spark 3.5.0) from Maven Central
# and place them directly into Spark's main jars directory.
RUN wget -P ${SPARK_HOME}/jars/ https://repo1.maven.org/maven2/io/delta/delta-spark_2.12/${DELTA_VERSION}/delta-spark_2.12-${DELTA_VERSION}.jar && \
    wget -P ${SPARK_HOME}/jars/ https://repo1.maven.org/maven2/io/delta/delta-storage/${DELTA_VERSION}/delta-storage-${DELTA_VERSION}.jar && \
    wget -P ${SPARK_HOME}/jars/ https://repo1.maven.org/maven2/org/antlr/antlr4-runtime/${ANTLR_VERSION}/antlr4-runtime-${ANTLR_VERSION}.jar
# --------------------------------------------------------------------

# Create a non-root user for Spark
RUN useradd -m -s /bin/bash sparkdev

# Create required directories and set permissions
RUN mkdir -p ${SPARK_HOME}/logs && \
    mkdir -p ${SPARK_HOME}/spark-events && \
    mkdir -p ${SPARK_HOME}/work-dir/data/warehouse && \
    chown -R sparkdev:sparkdev ${SPARK_HOME}

# Copy Spark configuration files
COPY docker/spark-defaults.conf ${SPARK_HOME}/conf/spark-defaults.conf
COPY docker/log4j2.properties ${SPARK_HOME}/conf/log4j2.properties

RUN python3 -m pip install --upgrade pip && \
    pip3 install --no-cache-dir \
    pytest \
    pandas \
    numpy \
    pyspark==${SPARK_VERSION} \
    delta-spark \
    jupyterlab

EXPOSE 4040 7077 8080 8081 8888

COPY docker/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
CMD ["tail", "-f", "/dev/null"]
