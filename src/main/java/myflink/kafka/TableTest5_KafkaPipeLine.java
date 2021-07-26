package myflink.kafka;

import org.apache.commons.io.FileUtils;
import org.apache.flink.streaming.api.environment.StreamExecutionEnvironment;
import org.apache.flink.table.api.EnvironmentSettings;
import org.apache.flink.table.api.bridge.java.StreamTableEnvironment;

import java.io.File;
import java.io.IOException;

public class TableTest5_KafkaPipeLine {

    static String DDL_SOURCE = "";
    static String DDL_SINK = "";
    static String DML = "";
    static final String FILE_DDL_SOURCE = "src/main/resources/DDL_SOURCE.sql";
    static final String FILE_DDL_SINK = "src/main/resources/DDL_SINK.sql";
    static final String FILE_DML = "src/main/resources/DML.sql";


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