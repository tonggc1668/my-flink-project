CREATE TABLE user_behavior (
  user_id VARCHAR
  ,item_id VARCHAR
  ,category_id VARCHAR
  ,behavior VARCHAR
  ,ts VARCHAR
  ,myTs AS TO_TIMESTAMP(CONVERT_TZ(REPLACE(ts, 'T', ' '), 'UTC', 'GMT+08:00'));
  ,WATERMARK FOR myTs AS myTs - INTERVAL '5' SECOND
) WITH (
  'connector' = 'kafka'
  ,'topic' = 'user_behavior'
  ,'properties.bootstrap.servers' = 'localhost:9092'
  ,'properties.group.id' = 'user_behavior'
  ,'scan.startup.mode' = 'group-offsets'
  ,'format' = 'json'
);
--SELECT * FROM user_behavior;

SELECT DATE_FORMAT(TUMBLE_START(ts, INTERVAL '10' MINUTE), 'yyyy-MM-dd hh:mm:ss'),
DATE_FORMAT(TUMBLE_END(ts, INTERVAL '10' MINUTE), 'yyyy-MM-dd hh:mm:ss'),
COUNT(*)
FROM user_behavior
WHERE behavior = 'pv'
GROUP BY TUMBLE(ts, INTERVAL '10' MINUTE);