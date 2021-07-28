-- kafka source
CREATE TABLE user_log (
  user_id VARCHAR
  ,item_id VARCHAR
  ,category_id VARCHAR
  ,behavior VARCHAR
  ,ts BIGINT
  ,myTs AS TO_TIMESTAMP(FROM_UNIXTIME(ts))
  ,WATERMARK FOR myTs AS myTs - INTERVAL '5' SECOND
) WITH (
  'connector' = 'kafka'
  ,'topic' = 'user_behavior'
  ,'properties.bootstrap.servers' = 'localhost:9092'
  ,'properties.group.id' = 'user_log'
  ,'scan.startup.mode' = 'group-offsets'
  ,'format' = 'csv'
);

-- kafka sink
CREATE TABLE user_log_sink (
  user_id varchar
  ,max_tx bigint
  ,primary key (user_id) not enforced
) WITH (
  'connector' = 'upsert-kafka'
  ,'topic' = 'user_behavior_sink'
  ,'properties.bootstrap.servers' = 'localhost:9092'
  ,'properties.group.id' = 'user_log'
  ,'key.format' = 'json'
  ,'key.json.ignore-parse-errors' = 'true'
  ,'value.format' = 'json'
  ,'value.json.fail-on-missing-field' = 'false'
  ,'value.fields-include' = 'ALL'
);

-- SET 'pipeline.name' = 'SqlJob';

-- insert
insert into user_log_sink
select user_id, count(user_id)
from user_log
group by user_id;