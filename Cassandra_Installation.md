## (Section: Installation) - Pre-requisite for this tutorial is docker

* [Docker cheatsheet](https://github.com/mohanmca/MohanLearningGround/blob/master/src/main/md/Tools/docker.md)
* [Dockerfile-3.11.11](https://github.com/docker-library/cassandra/blob/master/3.11/Dockerfile)

## (Section: Installation) -  Use Os-boxes as virtual machine to install cassandra

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

## (Section: Installation) -  Cassandra cluster using apache cassandra (Wait at-least 1 minute between successive container spin-off)

```bash
docker pull cassandra:3.11.11
docker network create cassnet
docker run --name cass1 --network cassnet -d cassandra:3.11.11
docker run --name cass2 --network cassnet -e CASSANDRA_SEEDS=cass1 -d cassandra:3.11.11
docker run --name cass3 --network cassnet -e CASSANDRA_SEEDS=cass1,cass2 -d cassandra:3.11.11
#docker run --name  my-cassandra -p 9042:9042 -p 7000:7000 --network host -d cassandra:latest 
## (Section: Installation) -  Check log
docker logs -f cass1
## (Section: Installation) -  Loging using CQLSH
docker exec -it cass2 cqlsh
docker exec -it cass2 nodetool ring
docker exec -it cass2 nodetool stopdaemon
```


## (Section: Installation) -  Connect to cassandra docker cluster

```bash
docker inspect cass2 | grep IPAddress
docker exec -it cass2 bash
cqlsh 172.18.0.3 9042
use cycling;
```

## (Section: Installation) -  Run commands into cassandra docker node

```bash
docker exec -it cass2 nodetool tpstats
docker exec -it cass2 nodetool repair
```


## (Section: Installation) -  [Via docker for DSE server](https://docs.datastax.com/en/landing_page/doc/landing_page/compatibility.html)

```bash
## (Section: Installation) -  Find Cassandra tag to practice -- choose ops-center and later dse server -- 6.0.16-1
docker pull datastax/dse-server:6.0.16-1
docker network create cassnet # docker network create --driver=bridge cassnet
## (Section: Installation) -  OPS Center can manage cluser, it should run first
docker run -e DS_LICENSE=accept -d -p 8888:8888 -p 61620:61620 --name my-opscenter --network cassnet datastax/dse-opscenter:6.1.10
docker run -e DS_LICENSE=accept -p 9042:9042 -p 7000:7000 -d --name my-cassandra --network cassnet datastax/dse-server:6.0.16-1
docker run -e DS_LICENSE=accept -p 9042:9042 -p 7000:7000 -d --name my-cassandra-2 --network -e CASSANDRA_SEEDS=my-cassandra cassnet datastax/dse-server:6.0.16-1
## (Section: Installation) -  Running dse-studio
docker run -e DS_LICENSE=accept --network cassnet  --link some-cassandra --name my-studio -d datastax/dse-studio
docker exec -it my-cassandra cqlsh
docker exec -it my-cassandra nodetool status

## (Section: Installation) -  #172.19.0.2 #172.19.0.3

docker exec -it my-studio cqlsh ip_address
docker exec -it my-cassandra sh -c "/opt/dse/bin/cqlsh.sh"
"within container" >> cd /opt/dse/bin/cqlsh.sh

docker cp  D:/git/cassandra_playground/labwork/data-files/videos.csv some-cassandra:/videos.csv
```

## (Section: Installation) -  [Setting up application using DSE image -Running Cassandra in Docker](https://www.datastax.com/learn/apache-cassandra-operations-in-kubernetes/running-a-cassandra-application-in-docker#skill-building)

* 
    ```bash
    docker pull cassandra
    docker run -d --name nodeA --network cassnet cassandra
    docker logs -f nodeA
    docker pull datastaxdevs/petclinic-backend
    docker run -d \
        --name backend \
        --network cass-cluster-network \
        -p 9966:9966 \
        -e CASSANDRA_USE_ASTRA=false \
        -e CASSANDRA_USER=cassandra \
        -e CASSANDRA_PASSWORD=cassandra \
        -e CASSANDRA_LOCAL_DC=datacenter1 \
        -e CASSANDRA_CONTACT_POINTS=nodeA:9042 \
        -e CASSANDRA_KEYSPACE_CQL="CREATE KEYSPACE spring_petclinic WITH REPLICATION = {'class':'SimpleStrategy','replication_factor':1};" \
        datastaxdevs/petclinic-backend
    curl -X GET "http://localhost:9966/petclinic/api/pettypes" -H "accept: application/json" | jq
    curl -X POST \
    "http://localhost:9966/petclinic/api/pettypes" \
    -H "accept: application/json" \
    -H "Content-Type: application/json" \
    -d "{ \"id\": \"unicorn\", \"name\": \"unicorn\"}" | jq
    docker exec -it nodeA cqlsh;
    USE spring_petclinic;
    SELECT * FROM petclinic_reference_lists WHERE list_name='pet_type';
    QUIT;
    docker pull datastaxdevs/petclinic-frontend-nodejs
    docker run -d --name frontend -p 8080:8080 -e URL=https://2886795274-9966-jago04.environments.katacoda.com datastaxdevs/petclinic-frontend-nodejs
    clear
    docker ps --format '{{.ID}}\t{{.Names}}\t{{.Image}}'
    docker stop $(docker ps -aq)
    docker rm $(docker ps -aq)
    docker ps --format '{{.ID}}\t{{.Names}}\t{{.Image}}'
    ## Via docker compose
    docker-compose up --scale db=3
    ```

* [Swagger-API](http://localhost:9966/swagger-ui/)


## (Section: Installation) -  Copy files into and out-of containers

```bash
docker cp cass1:/etc/cassandra/cassandra.yaml /tmp
docker cp cass1:/var/log/cassandra/* D:/git/cassandra_playground/log
docker cp cass1:/var/log/cassandra/system.log D:/git/cassandra_playground/log
docker cp cass1:/var/log/cassandra/debug.log D:/git/cassandra_playground/log
```

## (Section: Installation) -  Some Cassandra commands

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

## (Section: Installation) -  Cassandra directory (Apache Cassandra)

* /etc/cassandra
* -Dcom.sun.management.jmxremote.password.file=/etc/cassandra/jmxremote.password
* -Dcassandra.logdir=/var/log/cassandra
* -Dcassandra.storagedir=/var/lib/cassandra
* /usr/share/cassandra/lib/HdrHistogram-2.1.9.jar

## (Section: Installation) -  Cassandra stress-tool

* Creates keyspace1
* Reports maximum possible io-ops, partition-rate and latency mean

## (Section: Installation) -  To start CQLSH

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

## (Section: Installation) -  References
* [Dockerfile-3.11.11](https://github.com/docker-library/cassandra/blob/master/3.11/Dockerfile)
* [Docker DSE](https://docs.datastax.com/en/docker/doc/docker/docker67/dockerDSE.html)
* [Docker Setup](https://docs.datastax.com/en/docker/doc/docker/docker68/dockerReadme.html)
* [DSE Docker setup on windows](https://www.datastax.com/blog/running-dse-microsoft-windows-using-docker)
* [Cassandra Acadamy](https://academy.datastax.com/units/2012-quick-wins-dse-foundations-apache-cassandra?resource=ds201-datastax-enterprise-6-foundations-of-apache-cassandra)
* [Datastax VM](https://s3.amazonaws.com/datastaxtraining/VM/DS201-VM-6.0.ova)
* [Assets for course](https://academy.datastax.com/resources/ds201-datastax-enterprise-6-foundations-of-apache-cassandra)
* [C:\Users\nikia\Dropbox\Certifications\Cassandra](https://academy.datastax.com/#/online-courses/6167eee3-0575-4d88-9f80-f2270587ce23)