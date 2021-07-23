package myflink.kafka;

import org.apache.commons.io.FileUtils;
import org.apache.flink.streaming.api.environment.StreamExecutionEnvironment;
import org.apache.flink.table.api.EnvironmentSettings;
import org.apache.flink.table.api.bridge.java.StreamTableEnvironment;

import java.io.File;
import java.io.IOException;


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
public class TableTest5_KafkaPipeLine {

    static String DDL_SOURCE = "";
    static String DDL_SINK = "";
    static String DML = "";
    static final String FILE_DDL_SOURCE = "src/main/resources/DDL_SOURCE";
    static final String FILE_DDL_SINK = "src/main/resources/DDL_SINK";
    static final String FILE_DML = "src/main/resources/DML";


static {
    try {
        DDL_SOURCE =
                FileUtils.readFileToString(new File(FILE_DDL_SOURCE), "UTF-8");
        DDL_SINK =
                FileUtils.readFileToString(new File(FILE_DDL_SINK), "UTF-8");
        DML =
                FileUtils.readFileToString(new File(FILE_DML), "UTF-8");
    } catch (IOException e) {
        e.printStackTrace();
    }
}
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

        tableEnv.sqlUpdate(DDL_SOURCE);
        tableEnv.sqlUpdate(DDL_SINK);
        tableEnv.sqlUpdate(DML);

        tableEnv.execute("");
    }
}