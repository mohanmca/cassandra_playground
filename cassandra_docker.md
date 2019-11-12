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
docker exec -it cass2 nodetool stopdaemon
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

```bash
# nodetool status
Datacenter: datacenter1
=======================
Status=Up/Down
|/ State=Normal/Leaving/Joining/Moving
--  Address     Load       Tokens       Owns (effective)  Host ID                               Rack
UN  172.19.0.3  5.85 MiB   256          46.7%             2b3576cd-3f5d-4b9c-80bf-9c5a5fce7dc5  rack1
UN  172.19.0.2  6.65 MiB   256          53.3%             4936c442-00c7-4242-87cb-4cf265c5ae78  rack1

# nodetool ring | grep "172.19.0.3" | wc -l
256

# nodetool ring

Datacenter: datacenter1
==========
Address     Rack        Status State   Load            Owns                Token
                                                                           9126432156340756354
172.19.0.2  rack1       Up     Normal  6.65 MiB        53.31%              -9163250791483814686
172.19.0.3  rack1       Up     Normal  5.85 MiB        46.69%              -9137673090615533091
172.19.0.2  rack1       Up     Normal  6.65 MiB        53.31%              -9083337207055421835
172.19.0.2  rack1       Up     Normal  6.65 MiB        53.31%              -8994933303427082675
172.19.0.3  rack1       Up     Normal  5.85 MiB        46.69%              -8931107877434468662
172.19.0.3  rack1       Up     Normal  5.85 MiB        46.69%              -8862098302720005632
172.19.0.2  rack1       Up     Normal  6.65 MiB        53.31%              -8835701033996281573
172.19.0.3  rack1       Up     Normal  5.85 MiB        46.69%              -8779311204712756082
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