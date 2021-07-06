## Create Keyspace (and use it)

```sql
## Only when cluster replication exercise
CREATE KEYSPACE killrvideo WITH replication = {'class': 'NetworkTopologyStrategy','east-side': 1,'west-side': 1};

CREATE KEYSPACE killrvideo WITH replication = {'class': 'SimpleStrategy', 'replication_factor': 1 };
USE killrvideo;
```

## Create TABLE and load/export data in and out-of-tables

```sql
CREATE TABLE videos (video_id uuid,added_date timestamp,title text,PRIMARY KEY ((video_id)));
insert into videos (video_id, added_date, title) values (5645f8bd-14bd-11e5-af1a-8638355b8e3a, '2014-02-28','Cassndra History')

-- docker cp  D:/git/cassandra_playground/labwork/data-files/videos.csv some-cassandra:/vidoes.csv
-- COPY videos(video_id, added_date, title) FROM '~/labwork/data-files/videos.csv' WITH HEADER=TRUE;
COPY videos(video_id, added_date, title) FROM '/videos.csv' WITH HEADER=TRUE;

CREATE TABLE videos_by_tag (tag text,video_id uuid,added_date timestamp,title text,PRIMARY KEY ((tag), added_date, video_id)) WITH CLUSTERING ORDER BY(added_date DESC);
-- docker cp  D:/git/cassandra_playground/labwork/data-files/videos-by-tag.csv some-cassandra:/videos-by-tag.csv
-- COPY videos_by_tag(tag, video_id, added_date, title) FROM '~/labwork/data-files/videos-by-tag.csv' WITH HEADER=TRUE;
COPY videos_by_tag(tag, video_id, added_date, title) FROM '/videos-by-tag.csv' WITH HEADER=TRUE;
INSERT INTO killrvideo.videos_by_tag (tag, added_date, video_id, title) VALUES ('cassandra', '2016-2-8', uuid(), 'Me Lava Cassandra');
UPDATE killrvideo.videos_by_tag SET title = 'Me LovEEEEEEEE Cassandra' WHERE tag = 'cassandra' AND added_date = '2016-02-08' AND video_id = paste_your_video_id;

--Export data
COPY vidoes(video_id, added_date, title) TO '/tmp/videos.csv' WITH HEADER=TRUE;
```
## How to select token values of primary-key

```sql
SELECT token(tag), tag FROM killrvideo.videos_by_tag;
--output of gossip-info
system.token(tag)    | tag
----------------------+-----------
 -1651127669401031945 |  datastax
 -1651127669401031945 |  datastax
   356242581507269238 | cassandra
   356242581507269238 | cassandra
   356242581507269238 | cassandra
```

## CQL Copy and rules

* Cassandra expects same number of columns in every row (in delimited file)
* Number of columns should match the table
* Empty data in column is assumed by default as NULL value
* COPY from should not be used to dump entire data (could be in TB or PB)
* For importing larger datasets, use DSBulk
* Can be piped with standar-input and standrd-outpu

## CQL Copy options

1. DELIMITER
1. HEADER
1. CHUNKSIZE - 1000 (default)
1. SKIPROW - number of rows to skip (for testing)



## How to list partition_key (or the actual token) along with other columns

* USe token fucntion and pass all the parameter of the partition_key
* select tag, title, video_added_date, token(tag) from videos_by_tag;
* "InvalidRequest: code=2200 [Invalid query] message="Invalid number of arguments in call to function token: 1 required but 2 provided"
  * When you pass clustering column that are not part of partition_key, CQL throws this error

## Gosspinfo

```sql
  SELECT peer, data_center, host_id, preferred_ip, rach, release_version, rpc_address, schema_version FROM system.peers;
```

## nodetool getendpoints killrvideo videos_by_tag cassandra

172.19.0.2

## What are all the System Schema

```bash
system
system_auth
system_distributed
system_schema
system_traces
```


## See how many rows have been written into this table (Warning - row scans are expensive operations on large tables)

* SELECT COUNT (*) FROM user;

## Write a couple of rows, populate different columns for each, and view the results

1. INSERT INTO user (first_name, last_name, title) VALUES ('Bill', 'Nguyen', 'Mr.');
1. INSERT INTO user (first_name, last_name) VALUES ('Mary', 'Rodriguez');
1. SELECT * FROM user;

## View the timestamps generated for previous writes

* SELECT first_name, last_name, writetime(last_name) FROM user;

## Note that we’re not allowed to ask for the timestamp on primary key columns

* SELECT WRITETIME(first_name) FROM user;

## Set the timestamp on a write

* UPDATE user USING TIMESTAMP 1434373756626000 SET last_name = 'Boateng' WHERE first_name = 'Mary' ;

## Verify the timestamp used

* SELECT first_name, last_name, WRITETIME(last_name) FROM user WHERE first_name = 'Mary';

## View the time to live value for a column

* SELECT first_name, last_name, TTL(last_name) FROM user WHERE first_name = 'Mary';

## Set the TTL on the  last name column to one hour

* UPDATE user USING TTL 3600 SET last_name = 'McDonald' WHERE first_name = 'Mary' ;

## View the TTL of the last_name - (counting down)

* SELECT first_name, last_name, TTL(last_name) FROM user WHERE first_name = 'Mary';


## Find the token

* SELECT last_name, first_name, token(last_name) FROM user;

## Clear the screen of output from previous commands

* CLEAR

## Cassandra Dual equivalent table and SQL

```sql
1. select now() from system.local;
```

## Exit cqlsh

* EXIT
* Quit


## Reference

* [A deep look at the CQL WHERE clause](https://www.datastax.com/blog/deep-look-cql-where-clause)
