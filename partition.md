* Base installation location - /home/osboxes/node
* Base location for lab - /home/osboxes/Downloads/labwork/data-files
*  /home/osboxes/Downloads/labwork/data-files/videos-by-tag.csv

### To start Cassandra  

```bash
cqlsh:killrvideo> desc table video;

CREATE TABLE killrvideo.videos (
    video_id timeuuid PRIMARY KEY,
    added_date timestamp,
    title text
) WITH bloom_filter_fp_chance = 0.01
    AND caching = {'keys': 'ALL', 'rows_per_partition': 'NONE'}
    AND comment = ''
    AND compaction = {'class': 'org.apache.cassandra.db.compaction.SizeTieredCompactionStrategy', 'max_threshold': '32', 'min_threshold': '4'}
    AND compression = {'chunk_length_in_kb': '64', 'class': 'org.apache.cassandra.io.compress.LZ4Compressor'}
    AND crc_check_chance = 1.0
    AND default_time_to_live = 0
    AND gc_grace_seconds = 864000
    AND max_index_interval = 2048
    AND memtable_flush_period_in_ms = 0
    AND min_index_interval = 128
    AND speculative_retry = '99PERCENTILE';

COPY video(video_id, added_date, title) TO '/home/osboxes/node/labwork/video.csv' WITH HEADER=TRUE;
cqlsh:killrvideo> COPY video(video_id, added_date, title) TO '/home/osboxes/node/labwork/video.csv' WITH HEADER=TRUE;
Using 1 child processes

Starting copy of killrvideo.video with columns [video_id, added_date, title].
Processed: 5 rows; Rate:      21 rows/s; Avg. rate:      21 rows/s
5 rows exported to 1 files in 0.234 seconds.

create table KillrVideo.videos(
    video_id timeuuid PRIMARY KEY,
    added_date timestamp,
    Title Text
);
COPY videos(video_id, added_date, title) FROM '/home/osboxes/node/labwork/video.csv' WITH HEADER=TRUE;
drop table video;

create table KillrVideo.videos_by_tag(
    tag Text,
    video_id timeuuid PRIMARY KEY,
    added_date timestamp,
    Title Text
);
COPY videos_by_tag(tag, video_id, added_date, title) FROM '/home/osboxes/Downloads/labwork/data-files/videos-by-tag.csv' WITH HEADER=TRUE;
select token(video_id), video_id from videos_by_tag where tag='cassandra' allow FILTERING;
select token(video_id), video_id from videos_by_tag where title='Cassandra Intro' allow FILTERING;
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

CREATE KEYSPACE KillrVideo WITH REPLICATION = { 
 'class' : 'SimpleStrategy', 
 'replication_factor' : 1
};

USE KillrVideo;

create table KillrVideo.video(
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

### Known errors
```
#Typo in your command
cqlsh:killrvideo> TRUCATE TABLE "video";
SyntaxException: line 1:0 no viable alternative at input 'TRUCATE' ([TRUCATE]...)
```





## Reference
*[Cassandra Acadamy](https://academy.datastax.com/units/2012-quick-wins-dse-foundations-apache-cassandra?resource=ds201-datastax-enterprise-6-foundations-of-apache-cassandra)