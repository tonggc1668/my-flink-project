CREATE TABLE inputTable (
  id VARCHAR
  ,ts VARCHAR
  ,temp DOUBLE
) WITH (
  'connector' = 'kafka'
  ,'topic' = 'sensor'
  ,'properties.bootstrap.servers' = 'localhost:9092'
  ,'properties.group.id' = 'consumer-group'
  ,'scan.startup.mode' = 'earliest-offset'
  ,'format' = 'csv'
)