package myflink.kafka;

import org.apache.flink.streaming.api.environment.StreamExecutionEnvironment;
import org.apache.flink.table.api.DataTypes;
import org.apache.flink.table.api.EnvironmentSettings;
import org.apache.flink.table.api.Table;
import org.apache.flink.table.api.bridge.java.StreamTableEnvironment;
import org.apache.flink.table.descriptors.Csv;
import org.apache.flink.table.descriptors.Kafka;
import org.apache.flink.table.descriptors.Schema;


/*下载kafka解压 http://kafka.apache.org/downloads

        启动zookeeper

        $ bin/zookeeper-server-start.sh config/zookeeper.properties

        启动kafka服务

        $ bin/kafka-server-start.sh config/server.properties

        启动kafka生产者

        $ bin/kafka-console-producer.sh --broker-list localhost:9092  --topic sensor

        启动kafka消费者
        $ bin/kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic sinktest

sensor_1,1547718199,35.8
sensor_6,1547718201,15.4
sensor_7,1547718202,6.7
sensor_10,1547718205,38.1
sensor_1,1547718207,36.3
sensor_1,1547718209,32.8
sensor_1,1547718212,37.1
*/
public class TableTest4_KafkaPipeLine {
    public static void main(String[] args) throws Exception {
        // 1. 创建环境
        StreamExecutionEnvironment env = StreamExecutionEnvironment.getExecutionEnvironment();
        env.setParallelism(1);

        EnvironmentSettings settings = EnvironmentSettings.newInstance()
                .useBlinkPlanner()
                .inStreamingMode()
                .build();

        StreamTableEnvironment tableEnv = StreamTableEnvironment.create(env,settings);

        // 2. 连接Kafka，读取数据
        tableEnv.connect(new Kafka()
                .version("universal")
                .topic("sensor")
                .property("zookeeper.connect", "localhost:2181")
                .property("bootstrap.servers", "localhost:9092")
        )
                .withFormat(new Csv())
                .withSchema(new Schema()
                        .field("id", DataTypes.STRING())
                        .field("timestamp", DataTypes.BIGINT())
                        .field("temp", DataTypes.DOUBLE())
                )
                .createTemporaryTable("inputTable");

        // 3. 查询转换
        // 简单转换
        Table sensorTable = tableEnv.from("inputTable");
        Table resultTable = sensorTable.select("id, temp")
                .filter("id === 'sensor_6'");

        // 聚合统计
        /*Table aggTable = sensorTable.groupBy("id")
                .select("id, id.count as count, temp.avg as avgTemp");

        tableEnv.sqlQuery("select id, temp from inputTable where id = 'senosr_6'");
        Table sqlAggTable = tableEnv.sqlQuery("select id, count(id) as cnt, avg(temp) as avgTemp from inputTable group by id");

        // 打印输出
        tableEnv.toAppendStream(resultTable, Row.class).print("result");
        tableEnv.toRetractStream(aggTable, Row.class).print("agg");
        tableEnv.toRetractStream(sqlAggTable, Row.class).print("sqlagg");
        env.execute();*/

        // 4. 建立kafka连接，输出到不同的topic下
        tableEnv.connect(new Kafka()
                .version("universal") // kafka 版本，universal 支持 0.11 以上的版本
                .topic("sinktest")
                .property("zookeeper.connect", "localhost:2181")
                .property("bootstrap.servers", "localhost:9092")
        )
                .withFormat(new Csv())
                .withSchema(new Schema()
                        .field("id", DataTypes.STRING())
                        .field("temp", DataTypes.DOUBLE())
                )
                .createTemporaryTable("outputTable");

        resultTable.insertInto("outputTable");

        tableEnv.execute("");
    }
}