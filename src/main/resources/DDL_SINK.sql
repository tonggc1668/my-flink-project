CREATE TABLE outputTable (
    id VARCHAR
    ,cnt BIGINT
    ,avgTemp DOUBLE
    ,primary key (id) not enforced
) WITH (
  'connector' = 'upsert-kafka'
  ,'topic' = 'sinktest'
  ,'properties.bootstrap.servers' = 'localhost:9092'
  ,'key.format' = 'json'
  ,'key.json.ignore-parse-errors' = 'true'
  ,'value.format' = 'json'
  ,'value.json.fail-on-missing-field' = 'false'
  ,'value.fields-include' = 'ALL'
)