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
```

```SQL
## Gosspinfo
SELECT peer, data_center, host_id, preferred_ip, rach, release_version, rpc_address, schema_version FROM system.peers;
``` 

```pre
 system.token(tag)    | tag
----------------------+-----------
 -1651127669401031945 |  datastax
 -1651127669401031945 |  datastax
   356242581507269238 | cassandra
   356242581507269238 | cassandra
   356242581507269238 | cassandra
 

# nodetool getendpoints killrvideo videos_by_tag cassandra
172.19.0.2
# nodetool getendpoints killrvideo videos_by_tag datastax
172.19.0.2
```