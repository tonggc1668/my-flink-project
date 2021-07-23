How to run fink local, please see 
https://ci.apache.org/projects/flink/flink-docs-release-1.12/try-flink/local_installation.html

1 download flink-1.12.3-bin-scala_2.11.tgz

2 tar -xzf flink-1.12.3-bin-scala_2.11.tgz

3 cd flink

4 ./bin/start-cluster.sh

5 ./bin/stop-cluster.sh

How to run fink demo

1 mvn clean package

2 copy my-flink-project-0.1.jar and hello.txt into flink/example dir

3 chmod a+x my-flink-project-0.1.jar

4 cd flink

5 ./bin/flink run -c myflink.StreamWindowWordCount ./examples/my-flink-project-0.1.jar ./examples/hello.txt

To use dependencies in ./lib dir 

make dependencies in pom.xml '<scope>provided</scope>' and copy dependencies from your local repo into lib dir, then
./bin/flink run -c myflink.StreamWindowWordCount -C file://./lib/flink-java-1.12.1.jar,./flink-streaming-java_2.12-1.12.1.jar,./lib/flink-clients_2.12-1.12.1.jar,./lib/log4j-api-2.12.1.jar,./lib/log4j-core-2.12.1.jar,./lib/log4j-slf4j-impl-2.12.1.jar ./examples/my-flink-project-0.1.jar ./examples/hello.txt

To see result

tail -f log/flink-${who am i}-taskexecutor-0-${hostname}.out







