https://ci.apache.org/projects/flink/flink-docs-release-1.12/try-flink/local_installation.html

download flink-1.12.3-bin-scala_2.11.tgz

tar -xzf flink-1.12.3-bin-scala_2.11.tgz
cd flink
./bin/start-cluster.sh

mvn clean package
chmod a+x my-flink-project-0.1.jar

copy my-flink-project-0.1.jar and hello.txt into example dir
./bin/flink run -c myflink.StreamWindowWordCount ./examples/my-flink-project-0.1.jar ./examples/hello.txt

or make dependencies <scope>provided</scope> and copy dependencies from your local repo into lib dir, then
./bin/flink run -c myflink.StreamWindowWordCount -C file://./lib/flink-java-1.12.1.jar,./flink-streaming-java_2.12-1.12.1.jar,./lib/flink-clients_2.12-1.12.1.jar,./lib/log4j-api-2.12.1.jar,./lib/log4j-core-2.12.1.jar,./lib/log4j-slf4j-impl-2.12.1.jar ./examples/my-flink-project-0.1.jar ./examples/hello.txt

to see result
tail -f log/flink-${who am i }-taskexecutor-0-${hostname}.out

./bin/stop-cluster.sh






