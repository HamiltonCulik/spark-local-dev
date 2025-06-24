from pyspark.sql import SparkSession
from pyspark.sql.functions import col, upper

spark = SparkSession.builder.appName("LocalDeltaTest").getOrCreate()

print("Spark Session created successfully with Delta Lake support!")
print(f"Using Spark version: {spark.version}")

print("\nCreating bronze table...")
data = [("Alice", 28), ("Bob", 35), ("Charlie", 42)]
columns = ["name", "age"]
df_bronze = spark.createDataFrame(data).toDF(*columns)

df_bronze.write.format("delta").mode("overwrite").saveAsTable("bronze_users")
print("Bronze table 'bronze_users' created.")

print("\nCreating silver table from bronze...")
df_silver = spark.read.table("bronze_users").withColumn("name_upper", upper(col("name")))

df_silver.write.format("delta").mode("overwrite").saveAsTable("silver_users_transformed")
print("Silver table 'silver_users_transformed' created.")

print("\nVerifying final silver table:")
spark.read.table("silver_users_transformed").show()

# You can also see the tables in your warehouse directory inside the container at
# /opt/spark/work-dir/warehouse/

spark.stop()
