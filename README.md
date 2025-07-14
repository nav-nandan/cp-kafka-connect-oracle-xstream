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
