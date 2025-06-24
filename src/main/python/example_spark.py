from pyspark.sql import SparkSession
from pyspark.sql.functions import col, count, avg, sum, max, min, stddev
import tempfile
import os

spark = SparkSession.builder \
    .appName("SimpleExample") \
    .getOrCreate()

spark.sparkContext.setLogLevel("WARN")

dummy_data = [
    ("Alice", "Engineering", 75000, 28),
    ("Bob", "Sales", 60000, 32),
    ("Charlie", "Engineering", 80000, 25),
    ("Diana", "Marketing", 55000, 29),
    ("Eve", "Sales", 65000, 31),
    ("Frank", "Engineering", 90000, 35),
    ("Grace", "Marketing", 58000, 27),
    ("Henry", "Sales", 70000, 30)
]

df = spark.createDataFrame(dummy_data, ["name", "department", "salary", "age"])
csv_path = "/opt/spark/work-dir/data/dummy.csv"
df.coalesce(1).write.mode("overwrite").option("header", "true").csv(csv_path)

df_from_csv = spark.read.option("header", "true").option("inferSchema", "true").csv(csv_path)

agg_results = df_from_csv.groupBy("department").agg(
    count("name").alias("employee_count"),
    avg("salary").alias("avg_salary"),
    max("salary").alias("max_salary"),
    min("age").alias("min_age"),
    sum("salary").alias("total_salary")
).orderBy(col("avg_salary").desc())

agg_results.show()

spark.stop()
