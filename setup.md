* Base installation location - /home/osboxes/node
* Base location for lab - /home/osboxes/Downloads/labwork/data-files


### To start Cassandra  

```bash
cd /home/osboxes/node/
nohup ./bin/dse cassandra 

## Via docker
docker run --name some-cassandra -p 9042:9042 -p 7000:7000 --network host -d cassandra:latest
docker exec -it some-cassandra cqlsh
```  

### Find status Cassandra  

```bash
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

```SQL
## CQL

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

insert into video (video_id, added_date, Title) values (1645ea59-14bd-11e5-a993-8138354b7e31, '2014-01-29', 'Cassandra History');
select * from video where video_id=1645ea59-14bd-11e5-a993-8138354b7e31;
insert into video (video_id, added_date, Title) values (245e8024-14bd-11e5-9743-8238356b7e32, '2012-04-03', 'Cassandra & SSDs');
select * from video;
TRUNCATE video;
COPY video(video_id, added_date, title) FROM '/home/osboxes/Downloads/labwork/data-files/videos.csv' WITH HEADER=TRUE;
```


## To start CQLSH

```bash
set PATH=D:\Apps\Python\Python27;%PATH%;

#via Docker
docker exec -it some-cassandra cqlsh
```





## Reference
*[Cassandra Acadamy](https://academy.datastax.com/units/2012-quick-wins-dse-foundations-apache-cassandra?resource=ds201-datastax-enterprise-6-foundations-of-apache-cassandra)