import pyarrow.csv as csv
import pyarrow.parquet as pq

trips = pq.read_table('green_tripdata_2016-01.parquet')
csv.write_csv(trips,"ext/green_tripdata_2016-01.csv")

