## Pre-requisite for this tutorial is docker

* [Docker cheatsheet](https://github.com/mohanmca/MohanLearningGround/blob/master/src/main/md/Tools/docker.md)

## Use Os-boxes as virtual machine to install cassandra

* Base installation location - /home/osboxes/node
* Base location for lab - /home/osboxes/Downloads/labwork/data-files
* /home/osboxes/Downloads/labwork/data-files/videos-by-tag.csv

### To start Cassandra  

```bash
cd /home/osboxes/node/
nohup ./bin/dse cassandra 
### Find status Cassandra
osboxes@osboxes:~/node/bin$ ./dsetool status
```

```pre
C: Cassandra       Workload: Cassandra       Graph: no     
======================================================
Status=Up/Down
|/ State=Normal/Leaving/Joining/Moving
--   Address          Load             Effective-Ownership  Token                                        Rack         Health [0,1] 
UN   127.0.0.1        180.95 KiB       100.00%              0                                            rack1        0.70         
```

## Cassandra cluster using apache cassandra (Wait at-least 1 minute between successive container spin-off)

```bash
docker pull cassandra:3.11.10
docker network create cassnet
docker run --name cass1 --network cassnet -d cassandra:3.11.10
docker run --name cass2 --network cassnet -e CASSANDRA_SEEDS=cass1 -d cassandra:3.11.10
docker run --name cass3 --network cassnet -e CASSANDRA_SEEDS=cass1,cass2 -d cassandra:3.11.10
#docker run --name  my-cassandra -p 9042:9042 -p 7000:7000 --network host -d cassandra:latest 
docker exec -it cass2 cqlsh
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


## [Via docker for DSE server](https://docs.datastax.com/en/landing_page/doc/landing_page/compatibility.html)

```bash
## Find Cassandra tag to practice -- choose ops-center and later dse server -- 6.0.16-1
docker pull datastax/dse-server:6.0.16-1
docker network create cassnet # docker network create --driver=bridge cassnet
## OPS Center can manage cluser, it should run first
docker run -e DS_LICENSE=accept -d -p 8888:8888 -p 61620:61620 --name my-opscenter --network cassnet datastax/dse-opscenter:6.1.10
docker run -e DS_LICENSE=accept -p 9042:9042 -p 7000:7000 -d --name my-cassandra --network cassnet datastax/dse-server:6.0.16-1
docker run -e DS_LICENSE=accept -p 9042:9042 -p 7000:7000 -d --name my-cassandra-2 --network -e CASSANDRA_SEEDS=my-cassandra cassnet datastax/dse-server:6.0.16-1
## Running dse-studio
docker run -e DS_LICENSE=accept --network cassnet  --link some-cassandra --name my-studio -d datastax/dse-studio
docker exec -it my-cassandra cqlsh
docker exec -it my-cassandra nodetool status

## #172.19.0.2 #172.19.0.3

docker exec -it my-studio cqlsh ip_address
docker exec -it my-cassandra sh -c "/opt/dse/bin/cqlsh.sh"
"within container" >> cd /opt/dse/bin/cqlsh.sh

docker cp  D:/git/cassandra_playground/labwork/data-files/videos.csv some-cassandra:/videos.csv
```


## Copy files into and out-of containers

```bash
docker cp cass1:/etc/cassandra/cassandra.yaml /tmp
docker cp cass1:/var/log/cassandra/* D:/git/cassandra_playground/log
docker cp cass1:/var/log/cassandra/system.log D:/git/cassandra_playground/log
docker cp cass1:/var/log/cassandra/debug.log D:/git/cassandra_playground/log
```
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

## To start CQLSH

```bash
set PATH=D:\Apps\Python\Python27;%PATH%;
#via Docker
docker exec -it my-cassandra cqlsh
```

```sql
CREATE KEYSPACE "KillrVideo" WITH REPLICATION = { 
 'class' : 'SimpleStrategy', 
 'replication_factor' : 1
};

USE KillrVideo;

create table KillrVideo.videos(
    video_id timeuuid PRIMARY KEY,
    added_date timestamp,
    Title Text
);

insert into videos (video_id, added_date, Title) values (1645ea59-14bd-11e5-a993-8138354b7e31, '2014-01-29', 'Cassandra History');
select * from videos where video_id=1645ea59-14bd-11e5-a993-8138354b7e31;
insert into videos (video_id, added_date, Title) values (245e8024-14bd-11e5-9743-8238356b7e32, '2012-04-03', 'Cassandra & SSDs');
select * from videos;
TRUNCATE videos;
COPY videos(video_id, added_date, title) FROM '/home/osboxes/Downloads/labwork/data-files/videos.csv' WITH HEADER=TRUE;
```

## References
* [Docker DSE](https://docs.datastax.com/en/docker/doc/docker/docker67/dockerDSE.html)
* [Docker Setup](https://docs.datastax.com/en/docker/doc/docker/docker68/dockerReadme.html)
* [DSE Docker setup on windows](https://www.datastax.com/blog/running-dse-microsoft-windows-using-docker)
*[Cassandra Acadamy](https://academy.datastax.com/units/2012-quick-wins-dse-foundations-apache-cassandra?resource=ds201-datastax-enterprise-6-foundations-of-apache-cassandra)
* [Datastax VM](https://s3.amazonaws.com/datastaxtraining/VM/DS201-VM-6.0.ova)
* [Assets for course](https://academy.datastax.com/resources/ds201-datastax-enterprise-6-foundations-of-apache-cassandra)
* [C:\Users\nikia\Dropbox\Certifications\Cassandra](https://academy.datastax.com/#/online-courses/6167eee3-0575-4d88-9f80-f2270587ce23)