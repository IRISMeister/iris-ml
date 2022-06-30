# iris-ml

## テストデータ
[NYCのTAXYに関するオープンデータ](https://www1.nyc.gov/site/tlc/about/tlc-trip-record-data.page)の中の[2016/1月分のデータ](https://s3.amazonaws.com/nyc-tlc/trip+data/green_tripdata_2016-01.parquet)を使用。

IRISにロードするには、[nyc.py](nyc.py)にてCSV化したものをext/green_tripdata_2016-01.csvとして配置する。

## IntegratedML
[オンラインドキュメント](https://docs.intersystems.com/iris20221/csp/docbookj/DocBook.UI.Page.cls?KEY=GIML_Basics)

実行するSQL文。

```sql
LOAD DATA FROM FILE '/home/irisowner/ext/green_tripdata_2016-01.csv' INTO green_tripdata

DROP VIEW green_tripdata_view

CREATE VIEW green_tripdata_view AS 
SELECT 
ID,HourOfTheDay,DayOfTheWeek,PULocationID,Payment_type,Passenger_count,
CASE 
  WHEN TipRatio<0.10 THEN 'LOW'
  WHEN TipRatio<0.20 THEN 'REGULAR'
  ELSE 'HIGH'
END as TipType
FROM 
(
  SELECT ID,
	PULocationID,Payment_type,
    DATEPART('hh',lpep_pickup_datetime) as HourOfTheDay, 
    DATEPART('dw',lpep_pickup_datetime) as DayOfTheWeek, 
    Trip_distance/DATEDIFF('ss',lpep_pickup_datetime,Lpep_dropoff_datetime)*3600 as Speed,
    Trip_distance as Distance,
    tip_amount / total_amount as TipRatio,
    lpep_pickup_datetime as PickupTime,
    DATEDIFF('ss',lpep_pickup_datetime,Lpep_dropoff_datetime) as Duration,Passenger_count
  FROM green_tripdata where total_amount>0 
)
WHERE Duration > 1 and Distance>1

DROP MODEL green_tripdata_model

CREATE MODEL green_tripdata_model PREDICTING(TipType) from green_tripdata_view 

TRAIN MODEL green_tripdata_model from green_tripdata_view where ID<1+10000

SELECT PREDICT(green_tripdata_model) As PredictTipType,TipType from green_tripdata_view where ID>1+10000 AND id<1+10500

VALIDATE MODEL green_tripdata_model as r1 from green_tripdata_view where ID>1+10000 AND id<1+10500

SELECT * FROM INFORMATION_SCHEMA.ML_VALIDATION_METRICS where VALIDATION_RUN_NAME='r1'
```

## 埋め込みpython

[オンラインドキュメント](https://docs.intersystems.com/iris20221/csp/docbookj/DocBook.UI.Page.cls?KEY=AEPYTHON)

[【はじめてのInterSystems IRIS】Embedded Python セルフラーニングビデオシリーズ公開！](https://jp.community.intersystems.com/node/520751)

[Embedded Pythonを簡単にご紹介します](https://jp.community.intersystems.com/node/511336)

```python
import iris
df = iris.sql.exec('select * from green_tripdata').dataframe()
# データフレームを表示
print(df)
# lpep_pickup_datetimeフィールドの統計的数値を表示
print(df['lpep_pickup_datetime'].describe())
```
