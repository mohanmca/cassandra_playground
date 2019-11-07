* Base installation location - /home/osboxes/node
* Base location for lab - /home/osboxes/Downloads/labwork/data-files
* /home/osboxes/Downloads/labwork/data-files/videos-by-tag.csv


## Partition

* The most important concept in Cassandra is patition.
* Primary Key (state, (id))
  * First part of the primary is always partition keys, in the above primary key state is used as partition key
  * In 1000 node ring, state is used to find the ring-number using consistent hashing algorithm
  * It's complexity is - o(1)
* Partition key should be analogus to "GROUP BY" related column in typical rdbms table, Here we pre-compute whereas in RDBMS it might do full-table-scan
* Group rows physically together on disk based on the partition key.
* It hashes the partition key values to create a partition token.
* We can choose partition after table were constructed and data inserted


## Clustering Columns

* This constitutes part of Primary Key along with partition key
* We can have one or more clustering column
* Rows are sorted within the partition based on clustering column
* PRIMARY KEY ((state), city, name)
  * By default they are sorted in Ascending order
* Example
  * (PRIMARY KEY((state), city, name, id) WITH CLUSTERING ORDER BY (city DESC, name ASC))  
  * "CREATE TABLE videos_by_tag (
      tag text,
      video_id uuid,
      added_date timestamp,
      title text,
      PRIMARY KEY(tag, added_date) 
    ) WITH CLUSTERING ORDER BY (added_date DESC);"

## Primary Key

* Primary Key = Partition Key + Clustering Column
* Decides uniqueness and date order (sorted and stored)


## Impact of partition key on query (CQL)

* All equality comparision comes before inequality (<, >)
* Inequality comparision or range queries on clustering columns are allowed
* Since data is already sorted on disk
  * Range queries are binary search and followed by a linear read
* If we use datetime or timeuuid and stored them in descending order, later record always contains most recent one.
* ALLOW FILTERING
  * *Scans all partitions in the table*
  * Relaxes querying on parition key constraint
  * allows query on just clustering columns without knowing partition key 
  * Don't use it


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
    video_id timeuuid,
    added_date timestamp,
    Title Text,
    PRIMARY KEY (tag, video_id)
);
COPY videos_by_tag(tag, video_id, added_date, title) FROM '/home/osboxes/Downloads/labwork/data-files/videos-by-tag.csv' WITH HEADER=TRUE;
select token(video_id), video_id from videos_by_tag where tag='cassandra';
select token(video_id), video_id from videos_by_tag where title='Cassandra Intro' allow FILTERING;
select * from videos_by_tag where tag='cassandra' and added_date > '2013-03-17';
drop table videos_by_tag;

CREATE TABLE videos_by_tag (
     tag text,
     video_id uuid,
     added_date timestamp,
     title text,
     PRIMARY KEY(tag, added_date) 
 ) WITH CLUSTERING ORDER BY (added_date DESC); 

COPY videos_by_tag(tag, video_id, added_date, title) FROM '/home/videos-by-tag.csv' WITH HEADER = TRUE; 
select * from videos_by_tag where tag='cassandra' and added_date > '2013-03-17';
```  

```





## Reference
*[Cassandra Acadamy](https://academy.datastax.com/units/2012-quick-wins-dse-foundations-apache-cassandra?resource=ds201-datastax-enterprise-6-foundations-of-apache-cassandra)