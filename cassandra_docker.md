## Cassandra cluster using dse

```bash
docker network create --driver=bridge cassnet
docker run -e DS_LICENSE=accept --name some-cassandra --network cassnet -d datastax/dse-server
docker run -e DS_LICENSE=accept --name some-cassandra2 --network cassnet  -e CASSANDRA_SEEDS=some-cassandra -d datastax/dse-server
docker inspect --format '{{ .NetworkSettings.IPAddress }}' some-cassandra
docker inspect --format '{{ .NetworkSettings.IPAddress }}' some-cassandra2

docker exec -it some-cassandra nodetool status
docker exec -it some-cassandra cqlsh

## #172.19.0.2 #172.19.0.3
docker run -e DS_LICENSE=accept --network cassnet  --link some-cassandra --name my-studio -d datastax/dse-studio
docker exec -it my-studio cqlsh ip_address
docker exec -it some-cassandra sh -c "/opt/dse/bin/cqlsh.sh"
"within container" >> cd /opt/dse/bin/cqlsh.sh

docker cp  D:/git/cassandra_playground/labwork/data-files/videos.csv some-cassandra:/videos.csv
```

## Cassandra cluster using apache cassandra

```bash
docker run --name cass1 --network cassnet -d cassandra
docker run --name cass2 --network cassnet -e CASSANDRA_SEEDS=cass1 -d cassandra
docker run --name cass3 --network cassnet -e CASSANDRA_SEEDS=cass1,cass2 -d cassandra
 
docker exec -it cass2 nodetool stopdaemon
```

## Connect to cassandra docker cluster

```bash
docker inspect cass2 | grep IPAddress
docker exec -it cass2 bash
cqlsh 172.18.0.3 9042
use cycling;
```
## Run commands into cassandra docker node

```bash
docker exec -it cass2 bash
docker exec -it cass2 nodetool tpstats
docker exec -it cass2 nodetool repair
```


docker cp cass1:/etc/cassandra/cassandra.yaml /tmp
docker cp cass1:/var/log/cassandra/* D:/git/cassandra_playground/log
docker cp cass1:/var/log/cassandra/system.log D:/git/cassandra_playground/log
docker cp cass1:/var/log/cassandra/debug.log D:/git/cassandra_playground/log

## Some Cassandra commands

```bash
nodetool status
nodetool info
nodetool describecluster
nodetool getlogginglevels
nodetool setlogginglevel org.apache.cassandra TRACE
nodetool settraceprobability 0.1
nodetool drain
nodetool stopdaemon
nodtool flush
cassandra-stress write n=50000 no-warmup -rate threads=1
```

## Cassandra directory (Apache Cassandra)

* /etc/cassandra
* -Dcom.sun.management.jmxremote.password.file=/etc/cassandra/jmxremote.password
* -Dcassandra.logdir=/var/log/cassandra
* -Dcassandra.storagedir=/var/lib/cassandra
* /usr/share/cassandra/lib/HdrHistogram-2.1.9.jar

## Cassandra stress-tool

* Creates keyspace1
* Reports maximum possible io-ops, partition-rate and latency mean

## Reference
* [Docker DSE](https://docs.datastax.com/en/docker/doc/docker/docker67/dockerDSE.html)
