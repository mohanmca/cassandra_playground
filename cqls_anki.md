## Create Keyspace

```sql
CREATE KEYSPACE killrvideo WITH replication = {'class': 'SimpleStrategy', 'replication_factor': 1 };

USE killrvideo;

CREATE TABLE videos (id uuid,added_date timestamp,title text,PRIMARY KEY ((id)));
-- docker cp  D:/git/cassandra_playground/labwork/data-files/videos.csv some-cassandra:/vidoes.csv
COPY videos(id, added_date, title) FROM '/videos.csv' WITH HEADER=TRUE;

CREATE TABLE videos_by_tag (tag text,video_id uuid,added_date timestamp,title text,PRIMARY KEY ((tag), added_date, video_id)) WITH CLUSTERING ORDER BY(added_date DESC);

-- docker cp  D:/git/cassandra_playground/labwork/data-files/videos-by-tag.csv some-cassandra:/videos-by-tag.csv

COPY videos_by_tag(tag, video_id, added_date, title) FROM '/videos-by-tag.csv' WITH HEADER=TRUE;

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

## Gosspinfo

```sql
  SELECT peer, data_center, host_id, preferred_ip, rach, release_version, rpc_address, schema_version FROM system.peers;
```

## nodetool getendpoints killrvideo videos_by_tag cassandra

172.19.0.2


## See how many rows have been written into this table (Warning - row scans are expensive operations on large tables)

SELECT COUNT (*) FROM user;

## Write a couple of rows, populate different columns for each, and view the results

INSERT INTO user (first_name, last_name, title) VALUES ('Bill', 'Nguyen', 'Mr.');
INSERT INTO user (first_name, last_name) VALUES ('Mary', 'Rodriguez');
SELECT * FROM user;

## View the timestamps generated for previous writes

SELECT first_name, last_name, writetime(last_name) FROM user;

## Note that we’re not allowed to ask for the timestamp on primary key columns

SELECT WRITETIME(first_name) FROM user;

## Set the timestamp on a write

UPDATE user USING TIMESTAMP 1434373756626000 SET last_name = 'Boateng' WHERE first_name = 'Mary' ;

## Verify the timestamp used

SELECT first_name, last_name, WRITETIME(last_name) FROM user WHERE first_name = 'Mary';

## View the time to live value for a column

SELECT first_name, last_name, TTL(last_name) FROM user WHERE first_name = 'Mary';

## Set the TTL on the  last name column to one hour

UPDATE user USING TTL 3600 SET last_name = 'McDonald' WHERE first_name = 'Mary' ;

## View the TTL of the last_name - (counting down)

SELECT first_name, last_name, TTL(last_name) FROM user WHERE first_name = 'Mary';


## Find the token

SELECT last_name, first_name, token(last_name) FROM user;

## Clear the screen of output from previous commands

CLEAR

## Exit cqlsh

EXIT