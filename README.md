# cp-kafka-connect-oracle-xstream
cp-kafka-connect build for oracle xstream to run on M1 host

## Download Oracle XStream CDC Source Connector
```
wget https://hub-downloads.confluent.io/api/plugins/confluentinc/kafka-connect-oracle-xstream-cdc-source/versions/1.1.0/confluentinc-kafka-connect-oracle-xstream-cdc-source-1.1.0.zip

unzip confluentinc-kafka-connect-oracle-xstream-cdc-source-1.1.0.zip
```

## Download Oracle Instant Client (aarch64) Bundle
- Consolidated bundle with necessary files - https://drive.google.com/file/d/10VR_xBGDoFB0uSFbpdmbb0zgodbg6zUh/view
- Move ojdbc8.jar and xstreams.jar to the above connector directory (```confluentinc-kafka-connect-oracle-xstream-cdc-source-1.1.0/lib```)

## Steps to Build cp-kafka-connect Docker Image for Oracle XStream CDC Source Connector
Rebuild cp-kafka-connect image with required libs and jars from Oracle Instant Client (aarch64) for Oracle XStream CDC Source Connector to successfully connect to remote Oracle 19c using Oracle JDBC OCI Driver.

```
git clone https://github.com/nav-nandan/cp-kafka-connect-oracle-xstream.git
cd cp-kafka-connect-oracle-xstream
docker build -t navnandan/cp-kafka-connect-oracle-oci-client:7.9.2 .
docker push navnandan/cp-kafka-connect-oracle-oci-client:7.9.2
```

## Run docker-compose to spin up Oracle 19c CDB with TNS listeners and Instant Client on Connect Worker

```
docker-compose up -d
```

## Test Connector Plugin Installation

```
curl -X GET http://localhost:8083/connector-plugins | jq
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100   803  100   803    0     0  22655      0 --:--:-- --:--:-- --:--:-- 22305
[
  {
    "class": "io.confluent.connect.oracle.xstream.cdc.OracleXStreamSourceConnector",
    "type": "source",
    "version": "1.1.0"
  }
]
```

## Test OCI Driver Connection

```
docker cp OCIConnectionTest.java connect:/opt/oracle
Successfully copied 4.61kB to connect:/opt/oracle

docker exec -it connect bash

[appuser@connect oracle]$ javac -cp /usr/share/connectors/confluentinc-kafka-connect-oracle-xstream-cdc-source-1.1.0/lib/ojdbc8.jar OCIConnectionTest.java
[appuser@connect oracle]$ java -cp /usr/share/connectors/confluentinc-kafka-connect-oracle-xstream-cdc-source-1.1.0/lib/ojdbc8.jar: OCIConnectionTest
Oracle JDBC Driver Registered!
Attempting to connect to database...
Connection successful!
ID: 1
Value: abc
Connection closed.
```

## Deploy Oracle XStream CDC Source Connector

```
curl -X POST http://localhost:8083/connectors \
  -H "Content-Type: application/json" \
  -d '{
  "name": "oracle-connector",
  "config": {
    "connector.class": "io.confluent.connect.oracle.xstream.cdc.OracleXStreamSourceConnector",
    "confluent.topic.bootstrap.servers": "broker-0:19092",
    "tasks.max": "1",
    "database.hostname": "oracle19c",
    "database.port": "1521",
    "database.user": "C##CFLTUSER",
    "database.password": "password",
    "database.dbname": "ORCLCDB",
    "database.service.name": "ORCLCDB",
    "database.pdb.name": "ORCLPDB1",
    "database.out.server.name": "XOUT",
    "topic.prefix": "cflt",
    "table.include.list": "C##CFLTUSER.TEST",
    "key.converter": "io.confluent.connect.avro.AvroConverter",
    "value.converter": "io.confluent.connect.avro.AvroConverter",
    "key.converter.schema.registry.url": "http://schema-registry:8081",
    "value.converter.schema.registry.url": "http://schema-registry:8081",
    "schema.history.internal.kafka.topic": "__orcl-schema-changes.cflt",
    "schema.history.internal.kafka.bootstrap.servers": "broker-0:19092"
  }
}' | jq
```

## Verify Connector Deployment

```
curl -X GET http://localhost:8083/connectors | jq
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100    20  100    20    0     0   2617      0 --:--:-- --:--:-- --:--:--  2857
[
  "oracle-connector"
]

curl -X GET http://localhost:8083/connectors/oracle-connector | jq
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100   981  100   981    0     0  22145      0 --:--:-- --:--:-- --:--:-- 22295
{
  "name": "oracle-connector",
  "config": {
    "connector.class": "io.confluent.connect.oracle.xstream.cdc.OracleXStreamSourceConnector",
    "database.service.name": "ORCLCDB",
    "database.user": "C##CFLTUSER",
    "database.dbname": "ORCLCDB",
    "confluent.topic.bootstrap.servers": "broker-0:19092",
    "tasks.max": "1",
    "database.pdb.name": "ORCLPDB1",
    "schema.history.internal.kafka.bootstrap.servers": "broker-0:19092",
    "database.port": "1521",
    "value.converter.schema.registry.url": "http://schema-registry:8081",
    "topic.prefix": "cflt",
    "schema.history.internal.kafka.topic": "__orcl-schema-changes.cflt",
    "database.hostname": "oracle19c",
    "database.password": "password",
    "name": "oracle-connector",
    "database.out.server.name": "XOUT",
    "table.include.list": "C##CFLTUSER.TEST",
    "value.converter": "io.confluent.connect.avro.AvroConverter",
    "key.converter": "io.confluent.connect.avro.AvroConverter",
    "key.converter.schema.registry.url": "http://schema-registry:8081"
  },
  "tasks": [
    {
      "connector": "oracle-connector",
      "task": 0
    }
  ],
  "type": "source"
}
```

## Verify Kafka Topics

```
kcat -L -b localhost:19092 | grep cflt
  topic "__orcl-schema-changes.cflt" with 1 partitions:
  topic "cflt.C__CFLTUSER.TEST" with 1 partitions:

kcat -C -t cflt.C__CFLTUSER.TEST -b localhost:19092                         
abc
1.1.0$Oracle XStream CDcflt????e
firstORCLPDB1????????????0C##CFLTUSETEST1391636r????e?????????????0
def
1.1.0$Oracle XStream CDcflt????lastORCLPDB1????????????0C##CFLTUSETEST1391636r????e???????????0
% Reached end of topic cflt.C__CFLTUSER.TEST [0] at offset 2
```
