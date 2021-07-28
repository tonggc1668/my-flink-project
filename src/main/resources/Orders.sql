--test sql client
--下面的需要手动输入(发送json消息,注意下面的信息千万不要一次性复制全部内容,必须一条一条手动拷贝)
--
--{"order_id": "1","shop_id": "AF18","member_id": "3410211","trade_amt": "100.00","pay_time": "1556420980000"}
--{"order_id": "2","shop_id": "AF20","member_id": "3410213","trade_amt": "130.00","pay_time": "1556421040000"}
--{"order_id": "3","shop_id": "AF18","member_id": "3410212","trade_amt": "120.00","pay_time": "1556421100000"}
--{"order_id": "4","shop_id": "AF19","member_id": "3410212","trade_amt": "100.00","pay_time": "1556421120000"}
--{"order_id": "5","shop_id": "AF18","member_id": "3410211","trade_amt": "150.00","pay_time": "1556421480000"}
--{"order_id": "6","shop_id": "AF18","member_id": "3410211","trade_amt": "110.00","pay_time": "1556421510000"}
--{"order_id": "7","shop_id": "AF19","member_id": "3410213","trade_amt": "110.00","pay_time": "1556421570000"}
--{"order_id": "8","shop_id": "AF20","member_id": "3410211","trade_amt": "100.00","pay_time": "1556421630000"}
--{"order_id": "9","shop_id": "AF17","member_id": "3410212","trade_amt": "110.00","pay_time": "1556421655000"}

--old format
CREATE TABLE orders (
    order_id BIGINT,
    shop_id VARCHAR,
    trade_amt DOUBLE,
    pay_time BIGINT,
   ts AS TO_TIMESTAMP(FROM_UNIXTIME(pay_time/ 1000, 'yyyy-MM-dd HH:mm:ss')), -- 定义事件时间
   WATERMARK FOR ts AS ts - INTERVAL '5' SECOND   -- 在ts上定义5 秒延迟的 watermark
) WITH (
    'connector.type' = 'kafka',
    'connector.version' = 'universal',
    'connector.topic' = 'order_topic',
    'connector.startup-mode' = 'group-offsets',
    'connector.properties.group.id' = 'testGroup',
    'connector.properties.zookeeper.connect' = 'localhost:2181',
    'connector.properties.bootstrap.servers' = 'localhost:9092',
    'format.type' = 'json'
);

--new format
CREATE TABLE orders (
    order_id BIGINT,
    shop_id VARCHAR,
    trade_amt DOUBLE,
    pay_time BIGINT,
   ts AS TO_TIMESTAMP(FROM_UNIXTIME(pay_time/ 1000, 'yyyy-MM-dd HH:mm:ss')), -- 定义事件时间
   WATERMARK FOR ts AS ts - INTERVAL '5' SECOND   -- 在ts上定义5 秒延迟的 watermark
) WITH (
  'connector' = 'kafka'
  ,'topic' = 'order_topic'
  ,'properties.bootstrap.servers' = 'localhost:9092'
  ,'properties.group.id' = 'testGroup'
  ,'scan.startup.mode' = 'group-offsets'
  ,'format' = 'json'
);

CREATE TABLE order_sink (
    shop_id VARCHAR,
    tumble_start VARCHAR,
    tumble_end VARCHAR,
    amt DOUBLE
) WITH (
  'connector' = 'kafka'
  ,'topic' = 'order_sink_topic'
  ,'properties.bootstrap.servers' = 'localhost:9092'
  ,'format' = 'json'
);

INSERT INTO order_sink
SELECT
  shop_id
  , TUMBLE_START(ts, INTERVAL '1' MINUTE) AS tumble_start
  , TUMBLE_END(ts, INTERVAL '1' MINUTE) AS tumble_end
  , sum(trade_amt) AS amt
FROM orders
GROUP BY shop_id, TUMBLE(ts, INTERVAL '1' MINUTE);