DROP TABLE IF EXISTS user_behavior;

CREATE TABLE user_behavior (
    user_id BIGINT,
    item_id BIGINT,
    category_id BIGINT,
    behavior STRING,
    ts TIMESTAMP(3),
    proctime as PROCTIME(),   -- 处理时间列
    WATERMARK FOR ts as ts - INTERVAL '30' SECOND  -- 在ts上定义watermark，ts成为事件时间列
) WITH (
    'connector.type' = 'kafka',  -- kafka connector
    'connector.version' = 'universal',  -- universal 支持 0.11 以上的版本
    'connector.topic' = 'user_behavior',  -- kafka topic
    'connector.startup-mode' = 'earliest-offset',  -- 从起始 offset 开始读取
    'connector.properties.zookeeper.connect' = 'localhost:2181',  -- zk 地址
    'connector.properties.bootstrap.servers' = 'localhost:9092',  -- broker 地址
    'format.type' = 'json'  -- 数据源格式为 json
);

SELECT * FROM user_behavior;

SELECT user_id FROM user_behavior;

SELECT DATE_FORMAT(TUMBLE_START(ts, INTERVAL '1' MINUTE), 'yyyy-MM-dd hh:mm:ss'),
DATE_FORMAT(TUMBLE_END(ts, INTERVAL '10' MINUTE), 'yyyy-MM-dd hh:mm:ss'),
COUNT(*)
FROM user_behavior
WHERE behavior = 'pv'
GROUP BY TUMBLE(ts, INTERVAL '10' MINUTE);