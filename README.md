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

## [Setting up application using DSE image -Running Cassandra in Docker](https://www.datastax.com/learn/apache-cassandra-operations-in-kubernetes/running-a-cassandra-application-in-docker#skill-building)

* ```bash
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
## Cassandra node

* Cassandra designed for JBOD (just a bunch of disk) setup
* If disk is attached to ethernet, it is wrong choice, hence Cassandra not tuned to work with SAN/NAS
* A node can work with
  * 6K to 12K transaction
  * 2-4TB of data on ssd
* Cassandra can lineraly scale with new nodes
*

### nodetool

* help - help
* info - jvm statistics
* status  - all the nodes status (how this node see other nodes in cluster)


## Ring

* Apache cassandra cluster - Collection of nodes
* Node that we connect is co-ordinator node
* Each node is responsible for range of data
  * Token range
* Every node can deduce which node owns the range of token (range of data)
* Co-ordinate sends to acknowledge to client
  * co-ordinator-node !12== data-node
* Range
  * (2^63)-1 to -(2^63)
* Partitioner - Decides how to distribute data within nodes
* Right partitioner would place the data widely
  * Murmur3 as a partitioner
  * MD5 partitioner (random and even)

## When a new node joins the ring

* Gossips out to seed-node (seed-nodes are configured in cassandra.yaml)
* Other node finds where could new node could fit (could be manual or automatic)
* Seed nodes communicate cluster topology to the joining new-node
* State of the nodes
  * Joining, Leaving, UP and Down


## Driver

* Client could intelligently use node status and clutser
* Client would use different policies
  * TokenAwarePolicy
  * RoundRobinPolicy
  * DCAwareRoundRobinPolicy
* Driver knowing token range would make it intelligent, It would directly talk to data node when data is required
* Driver can use the  TokenAwarePolicy and directly deal with the node that is responsbile for the data, internally it would avoid one more hop (co-ordinator-node === data-node)

## Peer-to-Peer

* We should understand the reason by behind peer-to-peer
* Relation databases scales in one of the following way
  * Leader-follower
    * Data is not replicated realtime (hence not consistent)
  * Sharding
    * We need routing if we shard the data
    * No Aggregation support
    * No-joins or group-by
* In peer-to-peer
  * No node is special
  * Everyone is peer
  * Any node can act as co-ordinator (router)
  * No-split-brain Problem
    * Any node that is visible to client might accept the write request
    * Last write wins


## VNode


* If token is distributed in contiguous-range to a physical node, it won't help when new-node joins
  * Hence every node will not get contiguous token range for its capcity
* Bootstraping new node is complex in peer-to-peer without vnodes
* Adding/Removing nodes in distributed system is complex, it can't just rely on the number of physical node
* Vnodes eases the use of heterogeneous machines in a cluster. Better machine can have more vnodes than older.
* We can't move all the data of one-physical node to other node when new-node joins
  * It put strain on the node that transfers the data
  * It won't happen in parallel way
* Each node has 128 VNode (default)
* Vnode automate token range assignment
* num_tokens@cassandra.yaml > 1, enables the vnode (1 means disable vnode)
* If all nodes have equal hardware capability, each node should have the same num_tokens value.

### Why Vnode?

* If we have 30 node (with RF=3), effectively we have 10 nodes of original data, 20 nodes of replicated. If every node holds data for 3 ranges of token, and when a node goes down, logically we have RF=2 for set of data, and we can stream from 6 nodes of data
* If you started your older machines with 64 vnodes per node and the new machines are twice as powerful, simply give them 128 vnodes each and the cluster remains balanced even during transition.
* When using vnodes, Cassandra automatically assigns the token ranges for you. Without vnode, manual assignment is required.


## Gossip protocol

* Gossip is a peer-to-peer communication protocol in which nodes periodically exchange state information about themselves and about other nodes they know about.
* if a first gossips with second node, and later 1st node gossips with 3 other nodes and second nodes gossips with 3 other node, and each node successively gossips with randomly with other node.. information is quickly spread
  * Node information spreads out in polynomial fashion

1. Each node initiates a gossip round every second
1. Picks one to three nodes to gossip with
1. Nodes can gossip with ANY other node in the cluster
1. Probabilistically (slightly favor) seed and downed nodes
1. Nodes do not track which nodes they gossiped with prior
1. Reliably and efficiently spreads node metadata through the cluster
1. Fault tolerant—​continues to spread when nodes fail

### What is gossiped?

* SYN, ACK, ACK2
  * SYN - sender node details
  * ACK - reciever node details + packs additional details that receiver knows extra than sender (not just digest)
  * ACK2 - packs additional details that initiator knows extra then receiver (not just digest)
* Gossip message is tiny, won't cause significant impact to network bandwidth (network spikes won't be caused)
* JSON is only for analogy
```json
## Json analogy
{
  "endPointState": {
    "endPoint": "192.168.0.1",
    "heartBeatState": 515,
    "version": 28
  },
  "applicationState": {
    "STATUS": "NORMAL",
    "DC": "west",
    "RACK": "rack1",
    "SCHEMA": "c2b9ksc",
    "LOAD": 100.0,
    "SEVERITY": 0.75
  }
}
```

## Snitch

* Snitch - means informer (with criminal background or approver)
* Rerports DC, Rack information to each other
* Types of snitch
  * SimpleSnitch hardcodes DC1, RACK1 (useless)
  * PropertyFileSnitch - Every node has to keep, and manualy maintenance
  * GossipingPropertyFileSnitch
  * RackInferingSnitch - Infers from IP address - unreliable (not recommended to use)
  * Cassandra.yaml
    * endpoint_snitch : {"SmpleSnitch" | "PropertyFileSnitch" | "GossipingPropertyFileSnitch" | "DynamicSnitch" }
    * Ec2Snitch, GoogleCloudSnitch, CloudStackSnitch
  * DynamicSnitch - can work on top of snitch that was configured, and in addition knows the high performing node. When node needs to replicate, it can find high-peforming node using DynamicSnitch
* If we need to change the snitch
  * After changing, need to restart all the nodes and run the sequential repair and clean-up on each node.
* All node must use same snitch

### Property File Snitch

* Reads datacenter and rack information for all nodes from a file You must keep files in sync with all nodes in the cluster

```pre
cassandra-topology.properties file
175.56.12.105=DC1:RAC1
175.50.13.200=DC1:RAC1
175.54.35.197=DC1:RAC2
175.54.35.152=DC1:RAC2

120.53.24.101=DC2:RAC1
120.55.16.200=DC2:RAC1
120.57.18.103=DC2:RAC2
120.57.18.177=DC2:RAC2
```

### Gossiping Property File Snitch

* Relieves the pain of the property file snitch
* Declare the current node’s DC/rack information in a file
* You must set each individual node’s settings
* But you don’t have to copy settings as with property file snitch
* Gossip spreads the setting through the cluster

```pre
cassandra-rackdc.properties file
dc=DC1
rack=RAC
```

## Cassandra replication

* When co-ordinator responsible for token range 15-25 receives data to save, it finds its token range and copies data to target node
* Co-ordinator needs to write data to the node where hash-range belongs
  * if RF=2, every node has its data, and it also gets data from its prior node as part of replication
  * if RF=3, every node has its data, and it also gets replicated copies of data from prior node-range (as part of replication)
* We can configure multi-datacenter replication for each keyspace
  * Replication factor could be different for each datacenter
  * When Co-ordinator needs to write data to target-node + 2 other node, where one-of-them belongs to other data-center
  * Data recieved in that target-node of the different data-center takes responsibility to replicate in its data-center
* A replication factor greater than one...
  * Widens the range of token values a single node is responsible for.
  * Causes overlap in the token ranges amongst nodes.
  * Requires more storage in your cluster.


## Consistency

* Cassandra fits into AP system (CAP), Csonsistency is tunable parameter in Cassandra.
* Cassandra by default optimized for Availablity and Partiton, But can be tuned little to accomadate consistency
* Client writes data into Cassandra, it can choose any of the below
  * CL = ONE  === Fastest
  * CL = Quorum
  * CL = ALL (every replica has to write and acknowledge the read) === Slowest
* Client read data into Cassandra, it can choose any of the below
  * CL = ONE  (Write CF = All)
  * CL = Quorum   (Recommeneded if data was written using CF = Quorum)
  * CL = ALL (Write CF = Quorum)
* Read (CF=ONE) and Write (CF=ONE), When is it useful
  * IOT
  * Log-data
  * IOT Timeseries data (where consistency is not that important)
* Consistency across data-center
  * Replica to remote DC could be part of quorum, but it makes write/read slower
  * Choose for local-quorum
* Higher consistency === higher latency  (higher latency -- poor)


### Consistency level in Cassandra

**Consistency Settings In order of weakest to strongest**
1. ANY - Storing a hint at minimum is satisfactory
1. ALL - Every node must participate
1. ONE,TWO,THREE - Checks closest node(s) to coordinator
1. QUORUM - Majority vote, (sum_of_replication_factors / 2) + 1
1. LOCAL_ONE - Closest node to coordinator in same data center
1. LOCAL_QUORUM - Closest quorum of nodes in same data center
1. EACH_QUORUM - Quorum of nodes in each data center, applies to writes only


#### With a replication factor of three, which of the following options guarantee strong consistency?

* [X] - write all, read one
* [X] - write all, read quorum
* [X] - write quorum, read all
* [X] - write quorum, read quorum
* [-] - ~~write one, read all~~


## Hinted hand-off

* Write request can be served, even when nodes are down. Co-ordinator caches using hints file, later handoever the data to target node
* Hints file will be deleted after expiry (default 3 hours), hence data write is not guarantee to the node it was down
* If actual node comes while co-ordinator was down, data won't reach the target node
* When node comes back-online, it receives copy from co-ordinator (not from other 2-replicas when RF=3)
* Hinted-hand-off + Consistency-level-Any means potential data-loss.
  * Even when RF=3 and if three targe nodes for data is down, CONSISTENCY_LEVEL_ANY would successfully return to client
* Consistency-level-Any is not practical due to hinted-hand-off
* We can disable hinted-hand-off

## Read repair (Assume RF=3)

* Nodes goes out-of-sync for many reasons
  * Network partition, node failures, storage failure
* Co-ordinator sometime can answer best available anster (instead of correct answer)
* for read request of CL=ALL, Co-ordinator asks data from fastest node (finds using snitch), and checksum-digest from other two nodes, if they are all consistent, it would reply to client-read
* if checksum-digest doesn't matches
  1. Co-ordinator requests replicated data from other two nodes
  1. Compares the timestamp for the 3 copies
  1. Sends the latest data to client
  1. Replicates the latest data to the nodes that has stale copy

### Read Repair Chance

* Performed when read is at a consistency level less than ALL
* Request reads only a subset of the replicas
* We can’t be sure replicas are in sync
* Generally you are safe, but no guarantees
* Response sent immediately when consistency level is met
* Read repair done asynchronously in the background
* 10% by default


## Node-repai

### Nodetool has a repair tool that can repair entire cluster - Quite expensive operation
* nodetool repair --full
* Extra load on the network, IO also might spike



## Datastax Node-sync

* It uses the same mechnism what read-repair mechnism does
* Datastax Node-sync (should be enabled on per-table-basis)
* Datastax Node-sync - runs in background, continously repairing data
  * Should be enabled per table
  * Create table myTable(...) WITH nodesync = {'enabled': 'true' };
  * Local token ranges as segments, and every segrment progress is saved in data-structure save-points
  * gc_grace_seconds for node-sync is 10 days, it tries to achieve this target.
  * Each segment is about 200MB, can be configured using segment_size_target_bytes
  * Segment is automic, system_distributed.nodesync_status table has segment status
  * Segment outcomes
    * full_in_sync - All replicas were in sync
    * full_repaired - Some repair necessary
    * partial_in_sync
    * partial_repaired
    * uncompleted
    * failed


## Write path

1. Data reaches to node to write
1. Cassandra writes data to mem-table & commit-log
   * In mem-table, it is sorted under partion-key (used for read operation)
   * Commit-log is append-only log (it is like WAL - write ahead log)  (used for recovery operation to reconstruct the mem-table)
1. Upon mem-table is full, Cassandra stores the mem-table to disk as SS-Table
   * Disk format is called ss-table (strig sorted table)
   * SS-Table is of similar format to the mem-table
1. Cassandra drops the commit-log (upon successful SS_TABLE) and destroys old mem-table
1. New mem-table (and commit log) is created
1. Read-path would take care to read data between mem-table and SS-Table
1. **Always ensure commit-log and ss-table are stored in different drive for performance reason**
   * If they are stored in same disk, append only log and read (seek operation), both would slow-down
* When does a client acknowledge a write?
  * Ans: After the commit log and MemTable are written
* SSTable and MemTable are stored sorted by clustering columns

## Read path

* Data could be spread across multiple SS-Table (and in-memory), Hence read is bit more complex than write
* Data is partioned and partion-token is found, if partion-token is available in mem-table then data is returned (Simple)
* SS-Table is sorted and stored based on partion-token
* SS-Table partion-index is stored in a separate file called partition-index
* Partition-index (itself might grow big)
  * Example : If partition index file has 100 partition keys in it: pk001 to pk100. The partition keys are stored in sorted order, so we know that pk027 comes after pk025.
  * pk001: 0 (index offset)
  * pk002: 1170
  * pk...: 999999
  * pk099: 3431170
* Partition-summary (index about partition-index)
  * Incomplete partition index data-structure in-memory
  * Increases the speed to scan the partition-index-file
    * pk001-pk020: 0 (index offset of parition-index)
    * pk021-pk055: 45
    * pk056-pk700: 160
* Key-cache
  * If data was already read, then it directly stores the partition-token-offset of SS-Table in key-cache (cache)
* Bloom-filter
  * Key - possibly there (possible falst positive)
  * It is definitely not there

* Read > Bloom-Filter > Key-Cache > Partition Summary > Partition Index > SSTable

## Data-stax

* No partition-index, instead trie based data-structure used as index
  * SS-Table lookup is much faster than OSS version
* Data-stax can read OSS-Cassandra and migrate to latest format of SS-Table
  * If we know pk0020 location inside the partition-index, it is easier to find the parition-index offset for pk0024 (https://stackoverflow.com/questions/26244456/internals-of-partition-summary-in-cassandra)


## Compaction

### Compacting partition

* Two SS-Table paritions can be merged using merge-sort
  * If keys are matching, take one with latest timestamp
  * Mostly latest paritions will have latest records
  * If two keys are matching, but if there is tombstone, and gc-grace-seconds are elapsed deleted records evicted, not written to new SS-TABLE
  * Despite there could be tombstore, but if gc_grace_seconds not breached, tombstone stored in new partition (for data-resurrection during repair)
* Not all tombstones are discarded during compaction.
* A new partition on disk be larger than either of its input partition segments after a compaction, if later partition segments are made up of mostly INSERT operations.
* Benefits from compactions are
  * More optimal disk usage
  * Faster reads
  * Less memory pressure

### Compacting SSTables

* Two SS-Table merged using merge-sorted
* Merge might reduce the partition as all the stale values inside the parition are evicted
* Once new SS-Table is created, old SS-Table is dropped

### Types of compaction

* SizeTiered Compaction (default for write heavy-load)
* Leveled Compaction (read optimized compaction)
* TimeWindow Compaction (for timeseries data)

* Alter table ks.myTable  WITH compaction = { 'class': 'LeveledCompactionStrategy'}

## Datastax ES6

* Only one core per CPU and Non-blocking-IO
  * Claims to be more performant than OSS version
  * These threads are never block
  * Writes and Reads, both are asynchronous
  * Each thread has its own mem-table
  * Separate management thread for Mem-table-flush, Compaction, Hints, Streaming
* OSS - Executor thread-pool



## Reference

* [Vnodes](https://www.datastax.com/blog/2012/12/virtual-nodes-cassandra-12)
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
* A table always has a partition key, and that if the table has no clustering columns
  * Every partition of that table is only comprised of a single row
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
* Some example of primary key definition are:
    * PRIMARY KEY (a): a is the partition key and there is no clustering columns.
    * PRIMARY KEY (a, b, c) : a is the partition key and b and c are the clustering columns.
    * PRIMARY KEY ((a, b), c) : a and b compose the partition key (this is often called a composite partition key) and c is the clustering column.


## Impact of partition key on query (CQL)

* All equality comparision comes before inequality (<, >)
* Inequality comparision or range queries on clustering columns are allowed (provided partition-key precedes)
* Since data is already sorted on disk
  * Range queries are binary search and followed by a linear read
* If we use datetime or timeuuid and stored them in descending order, later record always contains most recent one.
* ALLOW FILTERING
  * *Scans all partitions in the table*
  * Relaxes querying on parition key constraint
  * allows query on just clustering columns without knowing partition key 
  * Don't use it

## Querying

* Always provide partition key
* Follow the equality similar to the way it is defined
  * Remember that the storage order is based on Clustering key within partition
  * If CQL has more than one equality within clustering column, follow the order of table definition
*   

## CQL

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

## Datastax slides

* (https://www.slideshare.net/planetcassandra/datastax-a-deep-look-at-the-cql-where-clause)[DataStax: A deep look at the CQL WHERE clause ]
## Reference
* [Primary Key, Partition Key and Data Definition](https://cassandra.apache.org/doc/latest/cql/ddl.html#the-partition-key)
* [Cassandra Acadamy](https://academy.datastax.com/units/2012-quick-wins-dse-foundations-apache-cassandra?resource=ds201-datastax-enterprise-6-foundations-of-apache-cassandra)
## CAP Theorem (Consistency)

* CAP Theory and Consistency
* Cassandra fits into AP system, doesn't promise Consistency
  * Cassandra supports partition tolerance and availability
  * Cassandra promises tunable Consistency
  * Consistency can be controlled for each and every read/request independently
* Consistency is harder in distributed systems
* CL = Consistency-Number (Number of replication count for current transaction)
  * CL=1 = A node that stored data in commit-log and memtable
  * CL=ANY = Data is note is not stored in any node, but just handed over to co-ordinator node.
  * CL=Quorum = 51% of the nodes acknowledged that it wrote
  * CL=ALL, Highest consistency and reduce the availability
* CL=Quorum (both read and write) - is considered strongly consistent
* CL=ANY, used only for write (not for read)
* CL=ONE (Quite useful)
  * Log-data
  * TimeSeries data
  * IOT
* CL=ALL
  * Most useless (Entire cluster might stop... should use only after quite thoughtful conversation)
* Cross DC Consistency
  * Strong replication with consistency
  * Remote Coordinator
  * Quorum is heavy (for Cross-DC), It has to consider all the nodes across all the DC's  
  * Local-Quorum (Remote coordinator would not consider for remote Quorum)
    * Not considered remote DC Quorum in Local Quorum
* Any < One/Two/Three < Quorum < Local_One < Local_Quorum < Each_Quorum  < ALL (from weak to strong consistency)
* Each_Quorum - Quorum of nodes in each data-center, applies to write only


## What is Each_Quorum

* Quorum of nodes in each data-center, applies to write only
* Not many application uses it
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

# nodetool gossipinfo
/172.19.0.3
  generation:1573517338
  heartbeat:1729
  STATUS:15:NORMAL,-104443974761627325
  LOAD:1694:6131589.0
  SCHEMA:11:3e2505d7-5286-3090-bc68-d01d101c68db
  DC:7:datacenter1
  RACK:9:rack1
  RELEASE_VERSION:5:3.11.5
  RPC_ADDRESS:4:172.19.0.3
  NET_VERSION:2:11
  HOST_ID:3:2b3576cd-3f5d-4b9c-80bf-9c5a5fce7dc5
  RPC_READY:27:true
  TOKENS:14:<hidden>
/172.19.0.2
  generation:1573517338
  heartbeat:1728
  STATUS:15:NORMAL,-103897790007775916
  LOAD:1694:6974127.0
  SCHEMA:11:3e2505d7-5286-3090-bc68-d01d101c68db
  DC:7:datacenter1
  RACK:9:rack1
  RELEASE_VERSION:5:3.11.5
  RPC_ADDRESS:4:172.19.0.2
  NET_VERSION:2:11
  HOST_ID:3:4936c442-00c7-4242-87cb-4cf265c5ae78
  RPC_READY:27:true
  TOKENS:14:<hidden>

#  nodetool gossipinfo
/172.19.0.3
  generation:1573519222
  heartbeat:17
  STATUS:15:NORMAL,-104443974761627325
  LOAD:19:6396507.0
  SCHEMA:11:3e2505d7-5286-3090-bc68-d01d101c68db
  DC:7:datacenter1
  RACK:9:rack1
  RELEASE_VERSION:5:3.11.5
  RPC_ADDRESS:4:172.19.0.3
  NET_VERSION:2:11
  HOST_ID:3:2b3576cd-3f5d-4b9c-80bf-9c5a5fce7dc5
  TOKENS:14:<hidden>
/172.19.0.2
  generation:1573517338
  heartbeat:1971
  STATUS:15:NORMAL,-103897790007775916
  LOAD:1946:6974127.0
  SCHEMA:11:3e2505d7-5286-3090-bc68-d01d101c68db
  DC:7:datacenter1
  RACK:9:rack1
  RELEASE_VERSION:5:3.11.5
  RPC_ADDRESS:4:172.19.0.2
  NET_VERSION:2:11
  HOST_ID:3:4936c442-00c7-4242-87cb-4cf265c5ae78
  RPC_READY:27:true
  TOKENS:14:<hidden>

#  nodetool gossipinfo
/172.19.0.3
  generation:1573519222
  heartbeat:32
  STATUS:15:NORMAL,-104443974761627325
  LOAD:19:6396507.0
  SCHEMA:11:3e2505d7-5286-3090-bc68-d01d101c68db
  DC:7:datacenter1
  RACK:9:rack1
  RELEASE_VERSION:5:3.11.5
  RPC_ADDRESS:4:172.19.0.3
  NET_VERSION:2:11
  HOST_ID:3:2b3576cd-3f5d-4b9c-80bf-9c5a5fce7dc5
  RPC_READY:27:true
  TOKENS:14:<hidden>
/172.19.0.2
  generation:1573517338
  heartbeat:1982
  STATUS:15:NORMAL,-103897790007775916
  LOAD:1946:6974127.0
  SCHEMA:11:3e2505d7-5286-3090-bc68-d01d101c68db
  DC:7:datacenter1
  RACK:9:rack1
  RELEASE_VERSION:5:3.11.5
  RPC_ADDRESS:4:172.19.0.2
  NET_VERSION:2:11
  HOST_ID:3:4936c442-00c7-4242-87cb-4cf265c5ae78
  RPC_READY:27:true
  TOKENS:14:<hidden>  

#

```  
## Peformance could be degraded for many reasons

* nodetool status  - check all nodes are up
* nodetool tpstats - for dropped messages
  * Usage statistics of thread-pool

### Dropped Mutataions

* Cassandra uses SEDA architecture
  * If messages inside the are not processed with certain timeout under heavy load, they are dropped
  * If cross node is slow, it doesn't receive message fast enough, would be another cause for dropping of messages.
* High number of dropped mutation would cause query timeout
  * This indicates data writes may be lost
* Dropped mutations are automatically recovered by repair/read_repair
* Mutation Drop could happen within same node or cross nodes.
   * INFO  [ScheduledTasks:1] 2019-07-21 11:44:46,150  MessagingService.java:1281 - MUTATION messages were dropped in last 5000 ms: 0 internal and 65 cross node. Mean internal dropped latency: 0 ms and Mean cross-node dropped latency: 4966 ms
*  

### Configuration that affects dropped mutations

* write_request_timeout_in_ms - How long the coordinator waits for write requests to complete with at least one node in the local datacenter. Lowest acceptable value is 10 ms.
* it is milli-seconds, hence every 1000 ms - should be considered as 1 second

* cross_dc_rtt_in_ms - How much to increase the cross-datacenter timeout (write_request_timeout_in_ms + cross_dc_rtt_in_ms) for requests that involve only nodes in a remote datacenter. This setting is intended to reduce hint pressure.

## When does Cassandra end up having useless data

* If we reduce the replication factor, additional un-necessary data may be sitting till the actual compaction happens
* Once we add new node to reduce the token range, Cassandray may contain data from portions of token ranges it no longer owns

## Usage statistics of thread-pool - output

```txt
root@15a092649e23:/# nodetool tpstats
Pool Name                         Active   Pending      Completed   Blocked  All time blocked
ReadStage                              0         0              3         0                 0
MiscStage                              0         0              0         0                 0
CompactionExecutor                     0         0             44         0                 0
MutationStage                          0         0              1         0                 0
MemtableReclaimMemory                  0         0             20         0                 0
PendingRangeCalculator                 0         0              1         0                 0
GossipStage                            0         0              0         0                 0
SecondaryIndexManagement               0         0              0         0                 0
HintsDispatcher                        0         0              0         0                 0
RequestResponseStage                   0         0              0         0                 0
ReadRepairStage                        0         0              0         0                 0
CounterMutationStage                   0         0              0         0                 0
MigrationStage                         0         0              1         0                 0
MemtablePostFlush                      0         0             20         0                 0
PerDiskMemtableFlushWriter_0           0         0             20         0                 0
ValidationExecutor                     0         0              0         0                 0
Sampler                                0         0              0         0                 0
MemtableFlushWriter                    0         0             20         0                 0
InternalResponseStage                  0         0              0         0                 0
ViewMutationStage                      0         0              0         0                 0
AntiEntropyStage                       0         0              0         0                 0
CacheCleanupExecutor                   0         0              0         0                 0

Message type           Dropped
READ                         0
RANGE_SLICE                  0
_TRACE                       0
HINT                         0
MUTATION                     0
COUNTER_MUTATION             0
BATCH_STORE                  0
BATCH_REMOVE                 0
REQUEST_RESPONSE             0
PAGED_RANGE                  0
READ_REPAIR                  0
```
## RDBMS Hitstory

* IBM DB1 - IMS (Hierarchical dbms) - Released in 1968 
* IBM DB2 - 1970 - "A Relational Model of Data for Large Shared Data Banks - Dr. Edgar F. Codd"
* Pros : It works for most of the cases
  * SQL - Support
  * ACID - Transaction (A Transformation of State - Jim Gray)
    * Atomic (State A to State B - no in-between)
    * Consistency
    * Isolated - Force transactions to be serially executed. (If it doesn't require consistency and atomic, it is  possible to have isolated and parallel txns)
    * Durable - Never lost
* Cons : Won't work for massively web scale db

## How RDBMS is tuned

* Introduce Index
* Master(write), Slave (many times only used for read)
  * Introduces replication and transaction issues
  * Introduces consistency issues
* Add more CPU, RAM - Vertical scaling
* Partitioning/Sharding
* Disable journaling  

## Two-phase commit vs Compensation

* Compensation
  * Writing off the transaction if it fails, deciding to discard erroneous transactions and reconciling later. 
  * Retry failed operations later on notification. 
* In a reservation system or a stock sales ticker, these are not likely to meet your requirements. 
* For other kinds of applications, such as billing or ticketing applications, this can be acceptable.
* Starbucks Does Not Use Two-Phase Commit
  * https://www.enterpriseintegrationpatterns.com/ramblings/18_starbucks.html

## Queue anti-pattern

* Cassandra is not suited for Queue
* 

## Sharding (Share nothing)

* Rather keeping all customer in one table, divide up that single customer table so that each database has only some of the records, with their order preserved? Then, when clients execute queries, they put load only on the machine that has the record they’re looking for, with no load on the other machines.
* How to shard?
  * Name-wise sharding issues like customer names that starts with "Q,J" will have less, whereas customer name starts with J, M and S may be busy
  * Shard by DOB, SSN, HASH
* Three basic strategies for determining shard structure  
  * Feature-based shard or functional segmentation
  * Key-based sharding - one-way hash on a key data element and distribute data across machines according to the hash.
  * Lookup Table

# [NoSQL](http://nosql-database.org/)

* Key-Value stores - Oracle Coherence, Redis, and MemcacheD, Amazon’s Dynamo DB, Riak, and Voldemort.
* Column stores - Cassandra, Hypertable, and Apache Hadoop’s HBase.
* Document stores -  MongoDB and CouchDB.
* Graph databases - Blazegraph, FlockDB, Neo4J, and Polyglot
* Object databases -  db4o and InterSystems Caché
* XML databases - Tamino from Software AG and eXist.


## Apache Cassandra

* “Apache Cassandra is distributed, decentralized, elastically scalable, highly available, fault-tolerant, tuneably consistent, row-oriented database that bases its distribution design on Amazon’s Dynamo and its data model on Google’s Bigtable.”
* No SPOF
  * Is not Master/Slave (MongoDB is master/slave)
* Tuneably consistent (not Eventual Consisten as majority believes)

## Cassandra Features

* CQL (moved from Thrift API)
* Secondary indexes
* Materialized views
* Lightweight transactions
* Consistency = Replication factor + consistency level  (delegated to clients)
  * Consistency level <= replication factor
* Cassandra is not column-oriented (it is row oriented)
* Column values are stored according to a consistent sort order, omitting columns that are not populated

## Consistency Forms

* Strict (or Serial) Consistency
  * Works on Single CPU
* Casual Consistency (like Casuation)
  * The cause of events to create some consistency in their order.
  * Writes that are potentially related must be read in sequence. 
  * If two different, unrelated operations suddenly write to the same field, then those writes are inferred not to be causally related.
* Weak (or) Eventual Consistency
  * Rather than dealing with the uncertainty of the correctness of an answer, the data is made unavailable until it is absolutely certain that it is correct

## Row-Oriented

* Cassandra’s data model can be described as a partitioned row store, in which data is stored in sparse multidimensional hashtables.
* “Sparse” means that for any given row you can have one or more columns, but each row doesn’t need to have all the same columns as other rows like it (as in a relational model).
* “Partitioned” means that each row has a unique key which makes its data accessible, and the keys are used to distribute the rows across multiple data stores.

## Always writeable

* A design approach must decide whether to resolve these conflicts at one of two possible times: during reads or during writes. That is, a distributed database designer must choose to make the system either always readable or always writable. Dynamo and Cassandra choose to be always writable, opting to defer the complexity of reconciliation to read operations, and realize tremendous performance gains. The alternative is to reject updates amidst network and server failures.
* CAP Theorem
  * Choose any two (of threee)
  * Cassandra assumes that  network partitioning is unavoidable, hence it lets us deal only with availability and consistency.
  * CAP placement is independent of the orientation of the data storage mechanism
  * CAP theorem database mapping
    * AP - ?
      * To primarily support availability and partition tolerance, your system may return inaccurate data, but the system will always be available, even in the face of network partitioning. DNS is perhaps the most popular example of a system that is massively scalable, highly available, and partition tolerant.
    * CP - ?
      * To primarily support consistency and partition tolerance, you may try to advance your architecture by setting up data shards in order to scale. Your data will be consistent, but you still run the risk of some data becoming unavailable if nodes fail.
    * CA - ?
      * To primarily support consistency and availability means that you’re likely using two-phase commit for distributed transactions. It means that the system will block when a network partition occurs, so it may be that your system is limited to a single data center cluster in an attempt to mitigate this. If your application needs only this level of scale, this is easy to manage and allows you to rely on familiar, simple structures.


## Notable tools

* Sstableloader - Bulk loader
* Leveled compaction strategy - for faster reads
* Atomic batches
* Lightweight transactions were added using the Paxos consensus protocol
* User-defined functions
* Materialized views (sometimes also called global indexes) 

## Few use cases

* Cassandra has been used to create a variety of applications, including a windowed time-series store, an inverted index for document searching, and a distributed job priority queue.

## Updated CAP - Brewer's Theorem

* Brewer now describes the “2 out of 3” axiom as somewhat misleading. 
* He notes that designers only need sacrifice consistency or availability in the presence of partitions. And that advances in partition recovery techniques have made it possible for designers to achieve high levels of both consistency and availability.

## Quotes

* If you can’t split it, you can’t scale it. "Randy Shoup, Distinguished Architect, eBay"
* [“The Case for Shared Nothing” - Michael Stonebreaker](http://db.cs.berkeley.edu/papers/hpts85-nothing.pdf)

## References

* [Cassandra Guide](https://github.com/jeffreyscarpenter/cassandra-guide)
* [Cassandra Paper](http://www.cs.cornell.edu/projects/ladis2009/papers/lakshman-ladis2009.pdf)
* (AWS re:Invent 2018: Amazon DynamoDB Deep Dive: Advanced Design Patterns for DynamoDB (DAT401))[https://www.youtube.com/watch?time_continue=33&v=HaEPXoXVf2k]
* [amazon-dynamodb-deep-dive-advanced-design-patterns-for-dynamodb](https://www.slideshare.net/AmazonWebServices/amazon-dynamodb-deep-dive-advanced-design-patterns-for-dynamodb-dat401-aws-reinvent-2018pdf)
* [Best Practices NOSql](https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/best-practices.html)
* CassandraSummit

## (Server side) - com.datastax.oss.driver.api.core.connection.ConnectionIntiException.. ssl should be configured
* Client side should enable ssl ; true (in spring-boot application.yaml)
  * spring.data.cassandra.ssl: true
## (Client side) - [SSLL SSLV3_ALERT_HANDSHAKE_FAILURE]
* Ensure you configured SSL on cient side
## (Client side) - Since you provided explicit contact points, the local DC must be explicitly set (see basic.load-balancing-policy.local-datacenter)
* spring.data.cassandra.local-datacenter: asiapac
## Cassandra read - query timedout out after PT2S
* 
## Data types

* Text
* timestamp -- we can use in query like added_date > '2013-03-17';

## How to connect to Cassandra from API

1. Create Cluster object
1. Create Session object
1. Execute Query using session and retrieve the result

```java
Cluster cluster = Cluster.builder().addContactPoint("127.0.0.1").build()
Session session = cluster.connect("KillrVideo")
ResultSet result = session.execute("select * from videos_by_tag where tag='cassandra'");

boolean columnExists = result.getColumnDefinitions().asList().stream().anyMatch(cl -> cl.getName().equals("publisher"));

List<Book> books = new ArrayList<Book>();
result.forEach(r -> {
   books.add(new Book(
      r.getUUID("id"), 
      r.getString("title"),  
      r.getString("subject")));
});
return books;
```

## TO setup python

```bash
python -m pip install --upgrade pip
pip install cassandra-driver
``

```python
from cassandra.cluster import Cluster
cluster = Cluster(protocol_version = 3)
session = cluster.connect('Killrvideo')
result = session.execute("select * from videos_by_tag where tag='cassandra'")[0];
print('{0:12} {1:40} {2:5}'.format('Tag', 'ID', 'Title'))
for val in session.execute("select * from videos_by_tag"):
   print('{0:12} {1:40} {2:5}'.format(val[0], val[2], val[3]))
```
## Nodetool usage

* 
```bash
     usage: nodetool [(-pwf <passwordFilePath> | --password-file <passwordFilePath>)]
          [(-u <username> | --username <username>)]
          [(-pw <password> | --password <password>)] [(-h <host> | --host <host>)]
          [(-p <port> | --port <port>)] <command> [<args>]
```

## Nodetool commands

```bash
     The most commonly used nodetool commands are:
     assassinate                  Forcefully remove a dead node without re-replicating any data.  Use as a last resort if you cannot removenode
     bootstrap                    Monitor/manage node-s bootstrap process
     cleanup                      Triggers the immediate cleanup of keys no longer belonging to a node. By default, clean all keyspaces
     clearsnapshot                Remove the snapshot with the given name from the given keyspaces. If no snapshotName is specified we will remove all snapshots
     compact                      Force a (major) compaction on one or more tables or user-defined compaction on given SSTables
     compactionhistory            Print history of compaction
     compactionstats              Print statistics on compactions
     decommission                 Decommission the *node I am connecting to*
     describecluster              Print the name, snitch, partitioner and schema version of a cluster
     describering                 Shows the token ranges info of a given keyspace
     disableautocompaction        Disable autocompaction for the given keyspace and table
     disablebackup                Disable incremental backup
     disablebinary                Disable native transport (binary protocol)
     disablegossip                Disable gossip (effectively marking the node down)
     disablehandoff               Disable storing hinted handoffs
     disablehintsfordc            Disable hints for a data center
     disablethrift                Disable thrift server
     drain                        Drain the node (stop accepting writes and flush all tables)
     enableautocompaction         Enable autocompaction for the given keyspace and table
     enablebackup                 Enable incremental backup
     enablebinary                 Reenable native transport (binary protocol)
     enablegossip                 Reenable gossip
     enablehandoff                Reenable future hints storing on the current node
     enablehintsfordc             Enable hints for a data center that was previsouly disabled
     enablethrift                 Reenable thrift server
     failuredetector              Shows the failure detector information for the cluster
     flush                        Flush one or more tables
     garbagecollect               Remove deleted data from one or more tables
     gcstats                      Print GC Statistics
     getcompactionthreshold       Print min and max compaction thresholds for a given table
     getcompactionthroughput      Print the MB/s throughput cap for compaction in the system
     getconcurrentcompactors      Get the number of concurrent compactors in the system.
     getendpoints                 Print the end points that owns the key
     getinterdcstreamthroughput   Print the Mb/s throughput cap for inter-datacenter streaming in the system
     getlogginglevels             Get the runtime logging levels
     getsstables                  Print the sstable filenames that own the key
     getstreamthroughput          Print the Mb/s throughput cap for streaming in the system
     gettimeout                   Print the timeout of the given type in ms
     gettraceprobability          Print the current trace probability value
     gossipinfo                   Shows the gossip information for the cluster
     help                         Display help information
     info                         Print node information (uptime, load, ...)
     invalidatecountercache       Invalidate the counter cache
     invalidatekeycache           Invalidate the key cache
     invalidaterowcache           Invalidate the row cache
     join                         Join the ring
     listsnapshots                Lists all the snapshots along with the size on disk and true size.
     move                         Move node on the token ring to a new token
     netstats                     Print network information on provided host (connecting node by default)
     pausehandoff                 Pause hints delivery process
     proxyhistograms              Print statistic histograms for network operations
     rangekeysample               Shows the sampled keys held across all keyspaces
     rebuild                      Rebuild data by streaming from other nodes (similarly to bootstrap)
     rebuild_index                A full rebuild of native secondary indexes for a given table
     refresh                      Load newly placed SSTables to the system without restart
     refreshsizeestimates         Refresh system.size_estimates
     reloadlocalschema            Reload local node schema from system tables
     reloadtriggers               Reload trigger classes
     relocatesstables             Relocates sstables to the correct disk
     removenode                   Show status of current node removal, force completion of pending removal or remove provided ID
     repair                       Repair one or more tables
     replaybatchlog               Kick off batchlog replay and wait for finish
     resetlocalschema             Reset node=s local schema and resync
     resumehandoff                Resume hints delivery process
     ring                         Print information about the token ring
     scrub                        Scrub (rebuild sstables for) one or more tables
     setcachecapacity             Set global key, row, and counter cache capacities (in MB units)
     setcachekeystosave           Set number of keys saved by each cache for faster post-restart warmup. 0 to disable
     setcompactionthreshold       Set min and max compaction thresholds for a given table
     setcompactionthroughput      Set the MB/s throughput cap for compaction in the system, or 0 to disable throttling
     setconcurrentcompactors      Set number of concurrent compactors in the system.
     sethintedhandoffthrottlekb   Set hinted handoff throttle in kb per second, per delivery thread.
     setinterdcstreamthroughput   Set the Mb/s throughput cap for inter-datacenter streaming in the system, or 0 to disable throttling
     setlogginglevel              Set the log level threshold for a given class. If both class and level are empty/null, it will reset to the initial configuration
     setstreamthroughput          Set the Mb/s throughput cap for streaming in the system, or 0 to disable throttling
     settimeout                   Set the specified timeout in ms, or 0 to disable timeout
     settraceprobability          Sets the probability for tracing any given request to value. 0 disables, 1 enables for all requests, 0 is the default
     snapshot                     Take a snapshot of specified keyspaces or a snapshot of the specified table
     status                       Print cluster information (state, load, IDs, ...)
     statusbackup                 Status of incremental backup
     statusbinary                 Status of native transport (binary protocol)
     statusgossip                 Status of gossip
     statushandoff                Status of storing future hints on the current node
     statusthrift                 Status of thrift server
     stop                         Stop compaction
     stopdaemon                   Stop cassandra daemon
     tablehistograms              Print statistic histograms for a given table
     tablestats                   Print statistics on tables
     toppartitions                Sample and print the most active partitions for a given column family
     tpstats                      Print usage statistics of thread pools
     truncatehints                Truncate all hints on the local node, or truncate hints for the endpoint(s) specified.
     upgradesstables              Rewrite sstables (for the requested tables) that are not on the current version (thus upgrading them to said current version)
     verify                       Verify (check data checksum for) one or more tables
     version                      Print cassandra version
     viewbuildstatus              Show progress of a materialized view build

     See "nodetool help <command>" for more information on a specific command.
```
## How to create anki from this markdown file

```
mdanki cassandra_repair_anki.md cassandra_repair_anki.apkg --deck "Mohan::Cassandra::Repair::doc"
```

## Developer who maintains/presented about Reaper

* [Alexander Dejanovski](Alexandar Dejanvoski)
* [Real World Tales of Repair (Alexander Dejanovski, The Last Pickle) | Cassandra Summit 2016](https://www.slideshare.net/DataStax/real-world-tales-of-repair-alexander-dejanovski-the-last-pickle-cassandra-summit-2016)

## Repair documentation

* [Cassandra documentation](https://cassandra.apache.org/doc/latest/operating/repair.html)
* [Datastax documentation](https://docs.datastax.com/en/cassandra-oss/3.x/cassandra/tools/toolsRepair.html)
## What is repair?

* Data won't be in sync due to eventual consistency pattern, Merkle-Tree based reconciliation would help to fix the data. It is also called anti-entropy repair. [Cassandra reaper](http://cassandra-reaper.io/) is famous tool for scheduling repair
* reaper and nodetool repair works slightly different
* Reaper Repair mode
  * sequential
  * requiresParallelism  (Building merkle-tree or validation compaction would be parallel)
  * datacenter_aware
    * It is like sequential but one node per each DC

## Some weird facts about repair

* Few reported such that it took 308+ hours to complete repair on 2.1.12 version
* 

## What are Reaper settings

* Segments per node
* Tables
* Blacklist
* Nodes
* Datacenters
* Threads
* Repair intensity

## Reaper is predominantly used for repair tasks

* Reaper uses concept called segments (despite in Cassandra world Segment means CommitLog)
* As per Reaper, you need to use a segment for every 50mb, 20K Segment for every 1 TB
* Smaller the segement, let reaper to repair it faster

## Repair and some number related to time

* With 3 DC with 12 nodes, 4 tb of a keyspace took around 22 hours to repair it.
* 

## Repair related commands

* nodetool repair -dc DC ## is the command to repair using nodetool
* nodetool -h 1.1.1.1 status
* 

## Reference

* [Repair Improvements in Apache Cassandra 4.0 | DataStax](https://www.youtube.com/watch?v=kl2ea0Cxmi0)
* [Apache Cassandra Maintenance and Repair](http://datastax.com/dev/blog/repair-in-cassandra)
* [DSE 6.8  Architecture Guide, About Repair](https://docs.datastax.com/en/dse/6.8/dse-arch/datastax_enterprise/dbArch/archAboutRepair.html)
* [Real World Tales of Repair (Alexander Dejanovski, The Last Pickle) | Cassandra Summit 2016](https://www.slideshare.net/DataStax/real-world-tales-of-repair-alexander-dejanovski-the-last-pickle-cassandra-summit-2016)
* [Repair](https://cassandra.apache.org/doc/latest/operating/repair.html)
## How to create anki from this markdown file

```
mdanki cassandra_definitive_guide_anki.md cassandra_definitive_guide.apkg --deck "Mohan::Cassandra::DefinitiveGuid"
```

## Datbase history

* 1968-IMS (DBI/DB1) 
* 1979-DB2 (E.F Cod 1970s), RDBMS relational model (not working system, just theoratical model)
* Traditionally RDBMS supports locks, locks helps to maintain consistency but reduces access/availability to others
* Journal or WAL log files are used for rollback or atomic-commit in RDBMS, journal sometime switched of to increase performance
* Codd provided a list of 12 rules (0-12, actually 13 :-)) in ComputerWorld Magazine in 1985 (15 years later from original paper)
* ANSI SQL - 1986

## Why RDBMS is successful?

* SQL
* Atomic Transaction with ACID properties
* Two-phase commit was marketted well (Co-ordinated txn)
* Rich schema

## What is the alternative for Two-phase commit

* Compensation or compensatory action
* Writing off the tranaction if it fails, deciding to discard erroneous transactions and reconciling later
  * Won't work on trading or reservation system
* Retry failed operation later on notification
* "Starbucks does not use Two-phase commit" - Gregor Hohpe

## How to horizontally scale RDBMS (shard)

* Shard the database, (key for sharding is important)
* Split the customer based on name (few letter has less load)  or according to phone-number or dob
* Host all the data that begins with certain letter in different database
* Shard users in one database, items in another database

## There are three basic strategies for determining shard structure:

* Feature-based shard or functional segmentation
  * Shard users in one database, items in another database
* Key-based sharding
  * Hash based sharding
  * time-based on numeri-ckeys to hash on
* Lookup table
  * Make one of the noe as "Yellow-pages", look-up for information about where the data stored

## Shared nothing

* Sharding could be termed a kind of shared-nothing architecture that’s specific to databases
* Shared-nothing - no primary or no-secondary
* Every node is independent
* No centralized shared state
* Cassandra (key-based sharding) and MongoDB - Autho sharding database


## New SQL (Scalable ACID transactions)

* Calvin transaction protocol vs Google’s Spanner paper
* FaunaDB is an example of a database that implements the approach on the Calvin paper



## Cassandra in 50 Words or Less

* “Apache Cassandra is an open source, distributed, decentralized, elastically scalable, highly available, fault-tolerant, tuneably consistent, row-oriented database. Cassandra bases its distribution design on Amazon’s Dynamo and its data model on Google’s Bigtable, with a query language similar to SQL"

## Cassandra features

* It uses gossip protcol (feature of peer-to-peer architecture) to maintain details of other nodes.
* It allows tunable cosistency and client can decide for each write/read (how many RF?)
* You can remove one column value alone in Cassandra

## Cap Theorem (Brewer's theorem)

* CAP - Choose two (as of 2000)
* Network issue would certainly happens, hence network partition failures is un-avoidable, And should be handled. Hence choose between compromise on A or C (Availablity or consistency)
* CA -  MySQL, Postgres, SQL
* CP -  Neo4j, MongoDB, HBase, BigTable
* AP -  DNS, Cassandra, Amazon Dynamo

## Cassandra Lightweight transaction (LWT) - Linearizable consistency

* Ensure there are not operation between read and write
* Example: Check if user exist, if not create user (don't overwrite in between)
* Example: Update the value if and only if the value is X (Check-and-set)
* LWT is based on Paxos algorithm (and it is better than two-phase commit)


## Consistencey levels

* Strong consistency (sequential consistency)
  * “Rather than dealing with the uncertainty of the correctness of an answer, the data is made unavailable until it is absolutely certain that it is correct.”
* Casual consistency (Happens before)
* Eventual consisteny (matter of milli-seconds)

## Strong consistency in Cassandra

* R + W > RF = strong consistency
* In this equation, R, W, and RF are the read replica count, the write replica count, and the replication factor, respectively;


## Row-Oriented (Wide column store)

* Partitioned row store - sparse multidimensional hash tables
* Partitioned - means that each row has a unique partition key used to distribute the rows across multiple data stores.
* Sparse - not all rows has same number of columns
* Cassandra stores data in a multidimensional, sorted hash table.
* As data is stored in each column, it is stored as a separate entry in the hash table.
* Column values are stored according to a consistent sort order, omitting columns that are not populated.


## Cassandra - schema free?

* Started as schema free using Thrift API, later CQL was introduced
* No! Till 2.0 CQL and Thrit API co-exist, It was known as "Schema Optional"
* From 3.0, Thrift API is deprecated, and from 4.0 Thrif API is removed
* Additional values for columns can be added using List, Sets and Maps
  * Now-a-days it is considered flexible-schema
* Schema free -> "Optional Schema" -> "Flexible Schema"  

## Cassandra - use-cases?

* Storing user activity updates
* Social network usage, recommendations/reviews, 
* Application statistics
* Inverted index for document searching
* Distributed job priority queue
* Ability to handle application workloads that require high performance at significant write volumes with many concurrent client threads is one of the primary features of Cassandra.



## Cassandra directories

* /opt/cassadra/bin
* /opt/cassadra/bin/cassandra -f --run the process in foreground for debug print and learning..
* /opt/cassadra/conf/cassandra.yaml
* /var/lib/cassandra/hints/
* /var/lib/cassandra/saved_caches/
* /var/lib/cassandra/data/
* /var/lib/cassandra/commitlog/
* /var/log/cassandra/system.log
* /var/log/cassandra/debug.log

## Cassandra directories and files

* $CASSANDRA_HOME/data/commitlog
  * CommitLog-<version><timestamp>.log
  * CommitLog-7-1566780133999.log
* 1-SSTable has multiple files
  * SSTable stored under - $CASSANDRA_HOME/data/data
  * 

## Cassandra run-time properties

* -Dcassandra-foreground=yes
* -Dcassandra.jmx.local.port=7199
* -Dcassandra.libjemalloc=/usr/local/lib/libjemalloc.so
* -Dcassandra.logdir=/opt/cassandra/logs
* -Dcassandra.storagedir=/opt/cassandra/data
* -Dcom.sun.management.jmxremote.authenticate=false
* -Dcom.sun.management.jmxremote.password.file=/etc/cassandra/jmxremote.password
* -Djava.library.path=/opt/cassandra/lib/sigar-bin
* -Djava.net.preferIPv4Stack=true
* -Dlogback.configurationFile=logback.xml
* -XX:GCLogFileSize=10M
* -XX:OnOutOfMemoryError=kill
* -XX:StringTableSize=1000003
* /opt/java/openjdk/bin/java


## Cassandra cqlsh

* Object names are in snake_case. Cassandra converts into lower_case by default, double quote to override
* bin/cqlsh localhost 9042
* ```sql
  show version;
  describe cluster; 
  create keyspace sample_ks with replication = {'class': 'SimpleStrategy', 'replication_factor': 1};
  use sample_ks;
  DESCRIBE KEYSPACES;
  describe keyspace sample_ks;
  describe keyspace system;
  create table user ( first_name text, last_name text, title text, PRIMARY KEY(last_name, first_name) );
  describe table user;
  insert into user(first_name, last_name, title) values  ('Mohan', 'Narayanaswamy', 'Developer');
  select * from user where first_name='Mohan' and last_name = 'Narayanaswamy';
  select * from user where first_name='Mohan';
  --* InvalidRequest: Error from server: code=2200 [Invalid query] message="Cannot execute this query as it might involve data filtering and hus may have unpredictable performance. If you want to execute this query despite the performance unpredictability, use ALLOW FILTERING"
  select count(*) from user; --Aggregation query used without partition key
  delete title from user where last_name='Narayanaswamy' and first_name='Mohan';  --one column alone
  delete from user where last_name='Narayanaswamy' and first_name='Mohan';  --entire row deletion
```


## How to run apache Cassandra using docker

```bash
docker pull cassandra
docker network create cass-network
docker run -d --name apc1 --network cass-network cassandra
docker run -d --name apc2 --network cass-network cassandra
#docker run --name  my-cassandra -p 9042:9042 -p 7000:7000 --network host -d cassandra:latest
docker exec -it apc2 cqlsh
docker stop apc2
```

## Datamodel quick checklist

* All the possible impory query that needs to satisfied should be considered before design
* Minimize the number of partitions that must be searched to satisfy a given query
* Growing number of tombstones begins to degrade read performance. Data-model should account to minmize it
* Partition-size = Nv=Nr(Nc−Npk−Ns)+Ns (hard-limit 2 billion, in-general 100K)
* in Cassandra - everything is distributed hashmap despite they look like relational-model
* Joins are not supported and should be discouraged in Cassandra
* NO REFERENTIAL INTEGRITY - supported in Cassandra (or any nosql)


## THE WIDE PARTITION PATTERN

* group multiple related rows in a partition in order to support fast access to multiple rows within the partition in a single query.
* Cassandra can put tremendous pressure on the java heap and garbage collector, impact read latencies, and can cause issues ranging from load shedding and dropped messages to crashed and downed nodes.

## Cassandra Architecture - logical components (2+4+3+4+1)

* Network topology, Peer-to-peer
* Gossip, repair, hinted handoff, and lightweight transactions
* Reading, writing, and deleting data
* Data-structures of memtable, commit-logs, caches and SSTables
* LWW-Element-Set (Last-Write-Wins-Element-Set) and no-reconciliation


## Cassandra token ring

* Tokens range from -2^63 to 2^63 - 1
* Every node owns multiple token (and it's token ranges)
* TR - Token range of token t is -   x > TR < t
  * x and t are two successive tokens
  * Range of values less than or equal to each token and greater than the last token of the previous node
* The node with the lowest token owns the range less than or equal to its token and the range greater than the highest token, which is also known as the wrapping range
* Early version of Cassandra node has only one token (one TR), nowadays it has 256 token for each node (256 virutal nodes)
* Larger machine can have more than 256 by modifying num_tokens@cassandra.yaml
* Partitioner :: partition_key -> token (clustering key is not used by partitioner)
* Partitioner can’t be changed after initializing a cluster. Cassandra uses MurMurPartitioner since 1.2

## Hinted Handoff

* Acts like JMS MQ, till message is delivered


## Replication Factor vs Consistency Level

9/

## Conflict-free replicated data type


## What is anti-entropy repair?

* Replica synchronization mechanism for ensuring that data on different nodes is updated to the newest version.
* Replica synchronization as well as hinted handoff.
* Project Voldemort also uses read-repair similar to Cassandra (not anti-entropy repair)
* 

## MERKLE TREE usage in Cassandra?

* The advantage MERKLE TREE usage is that it reduces network I/O.
* Used to ensure that the peer-to-peer network of nodes receives data blocks unaltered and unharmed.
* Each table has its own Merkle tree; the tree is created as a snapshot during a validation compaction, 
* MerkleTree is kept only as long as is required to send it to the neighboring nodes on the ring.

## Commit Log

* Only one commit log for entire server
* Commit log shares across multiple table
* All writes to all tables will go into the same commit log
* Ther is a bit for flush_bit for each table in commit log (1 - flush_required, 0 - flush-not-required)
* Throw more memory to reduce false-positives

## Comapaction stragies in Cassandra

* SizeTieredCompactionStrategy (STCS) is the default compaction strategy and is recommended for write-intensive tables.
* LeveledCompactionStrategy (LCS) is recommended for read-intensive tables.
* TimeWindowCompactionStrategy (TWCS) is intended for time series or otherwise date-based data.
* Anticompaction  - Split SSTable with one containing repaied data and other containing unrepaired data


## Cassandra under the hood

* [Refactor and modernize the storage engine](https://issues.apache.org/jira/browse/CASSANDRA-8099)
* [Materialized Views (was: Global Indexes)](https://issues.apache.org/jira/browse/CASSANDRA-6477)
* [Cassandra pluggable storage engine](https://issues.apache.org/jira/browse/CASSANDRA-13474)

## Deletion and Tombstones

* Nodes that was down when records deleted should have mechnism, hence tombstones
* Tombstones can be configured using gc_grace_seconds (garbage collection grace seconds)
* gc_grace_seconds = 864000 seconds ( 10 days)

## Bloom Filter

* Used to reduce disk access
* Used in Hadoop, Bigtable, Squid Proxy Cache (and many big-data systems)
* False-negative is not possible, but falst-positive is possible
* if bloom-filter conveys data is not available, it is not avialble. If available, it may not be available.


## What are operational mechanics that affects how you application configuration for data consistency?


## Failure boundaries of Cassandra

## cluster topology of Cassandra

* Cassandra cluster topology is the arrangement of the nodes (dcs, racs, etc.) and communication network between them.
* Snitch teaches  Cassandra enough about your network topology
* cassandra-topology.properties can be used to configure topology details


## CQL - Primary key and Clustering key

```
PRIMARY KEY (("k1", "k2"), "c1", "c2"), ) WITH CLUSTERING ORDER BY ("c1" DESC, "c2" DESC);
```

## CQLSH - useful
* CQL would use Murmur3 partitioner
* Minimum token is -9223372036854775808 (and maximum token is 9223372036854775808).
* ```sql
     cassandra@cqlsh:system_schema>
     DESCRIBE CLUSTER;
     SELECT * FROM system_schema.keyspaces;
     desc KEYSPACE Keyspace_Name;
     select token(key), key, my_column from mytable where token(key) >= %s limit 10000;```


## How to remove node using nodetool

* Decommission - Streams data from the leaving node (prefered and guaranteed consistency as if it started)
* Removenode -  Streams data from any available node that owns the range

## Cassandra linux limits

* if cassandra has 30 sstables, it would use 30 * 6 - 180 file handles
* XX:MaxDirectMemorySize - we can set off-heap memory (outside JVM on OS)
* 

## Cassandra troubleshoot linux commands

```bash
cat /proc/cass_proc_id/limits | grep files
```


## How does cassandra-topolgoy.properties look alike

```txt
# datacenter One

175.56.12.105=DC1:RAC1
175.50.13.200=DC1:RAC1
175.54.35.197=DC1:RAC1

120.53.24.101=DC1:RAC2
120.55.16.200=DC1:RAC2
120.57.102.103=DC1:RAC2

# datacenter Two

110.56.12.120=DC2:RAC1
110.50.13.201=DC2:RAC1
110.54.35.184=DC2:RAC1

50.33.23.120=DC2:RAC2
50.45.14.220=DC2:RAC2
50.17.10.203=DC2:RAC2

# Analytics Replication Group

172.106.12.120=DC3:RAC1
172.106.12.121=DC3:RAC1
172.106.12.122=DC3:RAC1

# default for unknown nodes 
default=DC3:RAC1
```


## Cassandra Client - features (Datastax Driver 4.9.0)

*   <groupId>com.datastax.oss</groupId>{<artifactId>java-driver-query-builder</artifactId>| <artifactId>java-driver-core</artifactId>| <artifactId>java-driver-mapper-processor</artifactId>|<artifactId>java-driver-mapper-runtime</artifactId>
* CqlSession maintains TCP connections to multiple nodes, it is a heavyweight object. Reuse it
* Prefer file based client side driver configuration
* PreparedStatements also improve security by separating the query logic of CQL from the data.
* Prepared statements were stored in a cache, but beginning with the 3.10 release, each Cassandra node stores prepared statements in a local table so that they are present if the node goes down and comes back up.
* Client side loadbalancing can be configured
  * RoundRobin/Token awareness/Data center awareness
* Driver should deal with node failures, hence we can also configure retry mechnism  
* CQL native protocol is asynchronous
* Compression can be enabled between client and server
* Security can be configured between client and server
* Deifferent profiles can be configured between invocation by the same client

## Client 

## Cassandra Client - Retry Failied Queries (if node failed)

* ExponentialReconnectionPolicy  vs ConstantReconnectionPolicy
* onReadTimeout(), onWriteTimeout(), and onUnavailable()
* The RetryPolicy operations return a RetryDecision
* 

## Cassandra Client side - SPECULATIVE EXECUTION

* The driver can preemptively start an additional execution of the query against a different coordinator node.
* When one of the queries returns, the driver provides that response and cancels any other outstanding queries.
* ConstantSpeculativeExecutionPolicy

## Cassandra Client side - CONNECTION POOLING

* 128 simultaneous requests in protocol - v2
* 32768 simultaneous requests in protocol - v3 
* Default single connection per node
* 1024 -  The maximum number of simultaneous requests per connection (defaults to 1,024).


## Cassandra Client side driver configuration 

```json
datastax-java-driver {
  basic {
    contact-points = [ "127.0.0.1:9042", "127.0.0.2:9042" ]
    session-keyspace = reservation
  }
}
```

## Cassandra Client (Datastax Driver 4.9.0) - Java API

```java
CqlSession cqlSession = CqlSession.builder()
    .addContactPoint(new InetSocketAddress("127.0.0.1", 9042))
    .withKeyspace("reservation")
    .withLocalDatacenter("<data center name>")
    .build()
```
## Cassandra Client Mapper/Entity Annotations

* @Mapper
* @Select
* @Insert
* @Delete
* @Query


## Cassandra Client (Datastax Driver 5.0) - QueryBuilder API API

```java
Select reservationSelect =
  selectFrom("reservation", "reservations_by_confirmation")
  .all()
  .whereColumn("confirm_number").isEqualTo("RS2G0Z");

SimpleStatement reseravationSelectStatement = reservationSelect.build()
```

## Cassandra Client (Datastax Driver 5.0) - Async API
* CQL native protocol is asynchronous
* ```java
      CompletionStage<AsyncResultSet> resultStage =  cqlSession.executeAsync(statement);

      // Load the reservation by confirmation number
      CompletionStage<AsyncResultSet> selectStage = session.executeAsync(
        "SELECT * FROM reservations_by_confirmation WHERE
          confirm_number=RS2G0Z");

      // Use fields of the reservation to delete from other table
      CompletionStage<AsyncResultSet> deleteStage =
        selectStage.thenCompose(
          resultSet -> {
            Row reservationRow = resultSet.one();
            return session.executeAsync(SimpleStatement.newInstance(
              "DELETE FROM reservations_by_hotel_date WHERE hotel_id = ? AND
                start_date = ? AND room_number = ?",
              reservationRow.getString("confirm_number"),
              reservationRow.getLocalDate("start_date"),
              reservationRow.getInt("room_number"));
          });

      // Check results for success
      deleteStage.whenComplete(
          (resultSet, error) -> {
            if (error != null) {
              System.out.printf("Failed to delete: %s\n", error.getMessage());
            } else {
              System.out.println("Delete successful");
            }      
```


## JDK 9 - Reactive style API

* The CqlSession interface extends a new ReactiveSession interface
  * which adds methods such as executeReactive() to process queries expressed as reactive streams.
* ```java
    try (CqlSession session = ...) {
          Flux.from(session.executeReactive("SELECT ..."))
              .doOnNext(System.out::println)
              .blockLast();
    } catch (DriverException e) {
      e.printStackTrace();
    }

try (CqlSession session = ...) {
  Flux.just("INSERT ...", "INSERT ...", "INSERT ...", ...)
      .doOnNext(System.out::println)
      .flatMap(session::executeReactive)
      .blockLast();
} catch (DriverException e) {
  e.printStackTrace();
}    
````

## Cassandra write path

* Performance optimzied for write using append only
* Database commit log and hinted handoff design, the database is always writable, and within a row, writes are always atomic.
* Consistency Level - ANY/ONE/TWO/THREE/LOCAL_ONE/QUORUM/LOCAL_QUORUM/EACH_QUORUM/ALL
  * ANY - Hinted hand-off is counted 
  * ONE (Atleast one commit-log + sstable) is counted as one
* Write-Path
  * Client > Cassandra Cordinator Node > Nodes (replicas)
  * If client uses token-aware cordinator itself replica, if not key is used by partitioner to find node
  * Co-ordinator selects remote co-ordinator fro X-DC replications
* Node that was down will have data using one of the following
  * Anti-entropy mechanisms: 
  * hinted handoff
  * read repair
  * Anti-entropy repair.
* Existing Row-Cache is invalidated during write
* Flush and Compaction might be peformed if necessary
* Memtables are stored as SS-Table to disk

## Cassandra write path - Materialized view

* Partition must be locked while consensus negotiated between replicas
* Logged batches are used to maintain materialized views
* The Cassandra database performs an additional read-before-write operation to update each materialized view
* If a delete on the source table affects two or more contiguous rows, this delete is tagged with one tombstone.
* But one delete in a source table might create multiple tombstones in the materialized view




## Cassandra write/read - consistency CQLS

* ```bash
      cqlsh> CONSISTENCY;
      ## Current consistency level is ONE.
      cqlsh> CONSISTENCY LOCAL_ONE;
      ## Consistency level set to LOCAL_ONE.
      ## statement.setConsistencyLevel(ConsistencyLevel.LOCAL_QUORUM);
  ```

## Cassandra failures and solutions

* java.lang.OutOfMemoryError: Map failed` - Almost always incorrect user limits - check ulimit -a 
  * Check the values of max memory size and virtual memory
* 

## Scaling Quotes

* If you can't split it, you can't scale it.
* No sane pilot would take off in an airplane without the ability to land, and no sane engineer would roll code that they could not pull back off in an emergency
* Management means measurement, and a failure to measure is a failure to manage.

## Performance Quotes

“The recommendation for speeding up .... is to add cache and more cache. And after that add a little more cache just in case.”
“When something becomes slow it's a candidate for caching.”
“LRU policy is perhaps the most popular due to its simplicity, good runtime performance, and a decent hit rate in common workloads.”
“Rather than dealing with the uncertainty of the correctness of an answer, the data is made unavailable until it is absolutely certain that it is correct.” (pitfall of strong consistency)


## Nodetool

* Adminstration tool uses JMX to interact with Cassandra
* TPstats and Tablestats  are subcommands in nodetool
* nodetool help tpstats
* nodetool tpstats --

## Building Cassandra

* Cassandra is built using Ant & Maven (Ant in-turn uses Maven)
* [Apache Builds](https://builds.apache.org/)
* [Apache Cassandra Build](https://ci-cassandra.apache.org/view/Cassandra%204.0/job/Cassandra-trunk/lastBuild/)
* [Cassandra source](https://gitbox.apache.org/repos/asf/cassandra.git)
* 'jdk8; ant -f build.xml clean generate-idea-files'
* 'jdk8; ant -f build.xml test cqltest'
* To test one class in intelli-idea
  * java -Dcassandra.config=file:\\\D:\git\cassandra4\test\conf\cassandra.yaml -Dlogback.configurationFile=file:\\\D:\git\cassandra4\test\conf\logback-test.xml -Dcassandra.logdir=D:/git/cassandra4/build/test/logs -Djava.library.path=D:/git/cassandra4/lib/sigar-bin -ea org.apache.cassandra.db.compaction.LeveledCompactionStrategyTest
* Ant default target would produce apache-cassandra-x.x.x.jar


## Resources

* https://community.datastax.com/
* user@cassandra.apache.org - provides a general discussion list for users and is frequently used by new users or those needing assistance.
* dev@cassandra.apache.org - is used by developers to discuss changes, prioritize work, and approve releases.
* client-dev@cassandra.apache.org - is used for discussion specific to development of Cassandra clients for various programming languages.
* commits@cassandra.apache.org - tracks Cassandra code commits. This is a fairly high-volume list and is primarily of interest to committers.
* cassandra and cassandra-dev slack channels
* Cassandra blogs
  * [https://thelastpickle.com/blog/](https://thelastpickle.com/blog/)
  * [https://cassandra.apache.org/blog/](https://cassandra.apache.org/blog/)
  * [https://www.instaclustr.com/category/technical/cassandra/](https://www.instaclustr.com/category/technical/cassandra/)
  * [https://www.datastax.com/blog](https://www.datastax.com/blog)


## Follow-up questions

* Does mongo-db/kafka supports Cassandra-toplogy/cross-dc kind of configurations?
* How to find node using token in Cassandra?
* Where else "PHI THRESHOLD AND ACCRUAL FAILURE DETECTORS" being used?
* MerkleTree (surprise usage in Cassandra)
* PHI THRESHOLD AND ACCRUAL FAILURE DETECTORS (Surprise)
## Reference

* [E.F Codd paper](https://www.seas.upenn.edu/~zives/03f/cis550/codd.pdf)
* [The Case for Shared Nothing - Michael Stonebraker](https://dsf.berkeley.edu/papers/hpts85-nothing.pdf)
* [CAP Theorem](http://www.julianbrowne.com/article/brewers-cap-theorem)
* [CAP Twelve Years Later: How the "Rules" Have Changed](https://www.infoq.com/articles/cap-twelve-years-later-how-the-rules-have-changed/)
* [Cassandra - A Decentralized Structured Storage System](https://www.cs.cornell.edu/projects/ladis2009/papers/lakshman-ladis2009.pdf)
* [Cassandra - A Decentralized Structured Storage System-Updated-Commentry by Johnathan Ellis](https://docs.datastax.com/en/articles/cassandra/cassandrathenandnow.html)
* [Awesome Cassandra](https://github.com/Anant/awesome-cassandra)
* [Cassandra pay-2015](http://marketing.dice.com/pdf/Dice_TechSalarySurvey_2015.pdf)
* [Cassandra pay-2019](http://marketing.dice.com/pdf/Dice_TechSalarySurvey_2019.pdf)
* [Dice pay 2020](https://computing.nova.edu/documents/dice_techsalarysurvey_2020.pdf)
* [CQLSH Introduction](https://gist.github.com/jeffreyscarpenter/761ddcd1c125dfb194dc02d753d31733)
* [Wide Partitions in Apache Cassandra 3.11](https://thelastpickle.com/blog/2019/01/11/wide-partitions-cassandra-3-11.html)
* [Paxos made simple](https://www.cs.utexas.edu/users/lorenzo/corsi/cs380d/past/03F/notes/paxos-simple.pdf)
* [Datastax driver reference](https://github.com/datastax/java-driver/)
* [Incremental Repair Improvements in Cassandra 4](https://thelastpickle.com/blog/2018/09/10/incremental-repair-improvements-in-cassandra-4.html)
## Code 

* [jeffreyscarpenter/reservation-service](https://github.com/jeffreyscarpenter/reservation-service)
* [Datastax KillrVideo sample java application](https://killrvideo.github.io/docs/languages/java/)
* [Datastax spring pet-clinic](https://github.com/DataStax-Examples/spring-petclinic-reactive#prerequisites)

## rough (throw-away)



## Create Keyspace

```sql
## Only when cluster replication exercise
CREATE KEYSPACE killrvideo WITH replication = {'class': 'NetworkTopologyStrategy','east-side': 1,'west-side': 1};

CREATE KEYSPACE killrvideo WITH replication = {'class': 'SimpleStrategy', 'replication_factor': 1 };
USE killrvideo;

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

SELECT token(tag), tag FROM killrvideo.videos_by_tag;
--output of gossip-info
system.token(tag)    | tag
----------------------+-----------
 -1651127669401031945 |  datastax
 -1651127669401031945 |  datastax
   356242581507269238 | cassandra
   356242581507269238 | cassandra
   356242581507269238 | cassandra

--Export data
COPY vidoes(video_id, added_date, title) TO '/tmp/videos.csv' WITH HEADER=TRUE;
```

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

## Exit cqlsh

* EXIT
* Quit


## Reference

* [A deep look at the CQL WHERE clause](https://www.datastax.com/blog/deep-look-cql-where-clause)

## [What is in All of Those SSTable Files Not Just the Data One but All the Rest Too! (John Schulz, The Pythian Group) | Cassandra Summit 2016 ](https://www.slideshare.net/DataStax/what-is-in-all-of-those-sstable-files-not-just-the-data-one-but-all-the-rest-too-john-schulz-the-pythian-group-cassandra-summit-2016)
## [So you have a broken Cassandra SSTable file?](https://blog.pythian.com/so-you-have-a-broken-cassandra-sstable-file/)
## Time-series presentations

1. (https://www.youtube.com/watch?v=nHes8XW1VHw)
1. (https://www.youtube.com/watch?v=YewOx6En7WM)
1. (https://www.youtube.com/watch?v=3yhd073ad5w)
1. (https://www.youtube.com/watch?v=jSRBCoOaz6I)
1. (https://www.youtube.com/watch?v=QwYH2EyKwNk)
1. (https://www.youtube.com/watch?v=4VBh6UQd6z8)
1. (https://www.youtube.com/watch?v=xVwo9lsrxfg)
1. (https://www.youtube.com/watch?v=AZB5DX9m7Hc)
1. (https://www.youtube.com/watch?v=3pPser3MYEE)
1. (https://www.youtube.com/watch?v=ovMo5pIMj8M)
1. (https://www.youtube.com/watch?v=iQBtkhvaOBM)
## Hinted Handoff

* Simple sticky note on co-ordinator
* Once actual node is available, Co-ordinator would deliver the message
* Previous version used to store hinted-handoff in the table (not nowadays)
* Cassandra is not good fit to design *Queue*, Hence hinted handoff is not stored in table
* There after timeout exceeds hinted-handoff itself dropped
  * By default 2 hours
* How co-ordinator knows node came online?
  * Gossip protocol helps to trigger
* COnsistency level of ANY - Hinted handoff is considered as valid transaction

## How read works?

* Co-ordinator reads data from fastest machine
* Co-ordinator reads checksum form other two machine
* if 1 and 2, matches, then we co-ordinator responds to client queries

## Read Repair (Happens only when CL=All)

* Over-time nodes goes out-of-sync
* Every write chooses between availablity and consistency
* When we choose availablity over consistency
  * We also agree that some inconsistency between server, data becomes out-of-sync
* When Co-ordinator observes data between 3 cluster is not valid, it does the following sequence
    1. Request all nodes to return latest copies of data
    1. Every cell (column) has latest timestamp, Finds the latest timestamp data and latest copy is chosen as valid
    1. It sends latest copies to two other nodes for them to udpate (their obsolete data is repaired)
    1. Responds to client with latest result

## Read Repair Chance (when CL < ALL) (less than ALL consistency read)

* Cassandra does read-repair even for request less than ALL, But not 100% but probablistically
  * Probability is configurable
  * dclocal_read_repair_chance  - (0.1 -- 10%)
  * read_repair_chance
* Client can't be sure if data is latest or replicas are in sync
* Read repair done asynchronously in the background

## Nodetool repair

* It is the last line of defence for us to improve consistency within stored data
* Syncs all data in the cluster
* Expensive
  * Grows with amount of data in cluster
* Use with clusters servicing high writes/deletes
* Must run to synchronize a failed node coming back online
* Run on nodes not read from very often

## Nodetool Sync (only datastax)

* Peforming full-repair is costly
* Full-repair should be run before gc_grace_seconds
* It is default and automatically enabled in datastax
* Repairs in small chunks as we go rather than full repair
  * Create table myTable (...) WITH nodesync = {'enabled': 'true'};

## Nodetool Sync Save points (only datastax)

* Each node splits its local range into segments
  * Small token range of a table
* Each segment makes a save point
  * NodeSync repairs a segment
  * Then NodeSync saves its progress
  * Repeat
  * Save-point is the place where progress is stored
* NodeSync priorities segments to meet deadline target

## Nodetool Sync - Segments Sizes

* Eache segment is less than 200MB
* If a partition is great than 200MB win over segments less than 200MB
* Each segment cannot be less than its partition size, hence if segments are larger .. it means partition was larger

## Nodetool Sync - Segments failures

* Node fails during segment validation, node drops all work for that segment and starts over
* A segment repair is automic operation
* system_distributed.nodesync_status table - has the information and progress
* segment_outcomes
  * full_in_sync : All replicas were in sync
  * full_repaired : Some repair necessary
  * partial_in_sync : all respondent were in sync, but not all replicas responded
  * partial_repaired
  * uncompleted : one node availabled/responded; no validation occurred
  * failed: unexpected error happened; check logs.

## Nodetool Sync - Segments Validation

* NodeSync - simply performs a read repair on the segment
* read-data from all replicas
* Check for inconsistencies
* Repair stale nodes


## Cassandra Write Path (inside the node, and for *a* partition)

* Two atomic operation makes a write successfull (Both commit-log + mem-table)
  * HDD - Commit Log
  * Memory - MemTable
* Commit log
  * It is append only commit log
  * Only retrieved during server restart (for replay)
   * Mem-Table: ![alt text][mem_table]
* Ensure Commit-log and ss-tables are stored in different drive
  * Commit log is append only for peformance
  * When we share same disk, disk seek operation for MM-Table would cause performance degradation
* Once Mem-Table is full, it is written as SS-Table (SSTable is immutable)
* No inplace update performed on SS-Table


## Cassandra Read Path (inside the node, and for particular a partition)

* Read is easy if records are in mem-table
  * Based on token, just to binary-search on mem-table and return the data to client
* Read is bit more complex than write
  * Write path created plenty of SS-Table in disk for a partition
* SSTable has token:byte_off_set index
  * 7:0,13:1120,18:3528,21:4392
  * 7 partition token starts at 0th byte-offset
  * 13 partition token starts at 1120th byte-offset
* Read_Token_58_From_SS_Table: ![alt text][read_token_58]
* There is a file named "partition_index" that has details about token vs  file-byte-offset index. It is used before reading ss-table
* Partition-summary is an another index used by Cassandra
  * Partition-summary resides in memory
  
## Cassandra Read Path workflow

* ReadRequest --> Bloomfilter --> Key Cache --> Partition Summary --> Partition Index --> SS-Table
* Checks in key-cache (if succseeds, data returned directly reading ss-table)
* Checks in partition-index (partition-summary-table)
  * Finds the byte-offset of ss-table from partition-index
  * Reads byte-offset from ss-table for actual data of the primary-key
  * Updates key-cache
    * key-cache contains byte-offsets of the most recently accessed records
    * key-cache is cache for partition-index (it avoids searcing in partition-index about ss-table byte-offset)
* Finally... bloom filter can optimize all the above
  
## Bloom filter

* It might stop the entire process if the data is not present
* It might produce false positives, but never ends in false negative
* If Bloom-filter says "no-data", there is no such partition data in that node
* If Bloom-filter says "possible-data", there may or may not present data in that node

## Datastax

* Trie based partition-summary is being used
* SSTable lookups are extreemly fast
* When migrating from OSS to Datastax
  * Datastax can work with both kinds of ss_table-partition-index
  * It will gradually compact oss version into Trie-based partition-index
  * Tried based partition index is extreemly faster

## Compaction (merging ss-tables)

* Compaction
  * Removes old un-necessary immutable data
  * Deleted data (columns) are removed after gc_grace_seconds
  * Lesser number of ss-table, but during compaction it requires both old and new ss-table
* It merges two set-of partitions into one
  * Common partition data values are merged
  * Last write wins selected
  * Tombstone is marker for deleted record, that won't move into new ss-table (if record passed gc_grace_seconds=10-days)
  * nodetool compact <keyspace> <table>, There is no real offline compaction
* Not all tombstones are discarded
*   
* We never modify ss-table
  * Merge creates new ss-table
  * Stale data removed and compacted (reduced and combined into fewer ss-tables)

## Compaction Strategies (based on use-case)

* Choose proper strategy based on use-case
  * SizeTieredCompaction - For write heavy
  * LeveledCompaction - For read heavy
  * TimeWindowCompaction - For timeseries
* We can change compaction strategy


## Advanced Peformance Gains in (DSE)

* OSS uses thread-pools, might cause thread contention
* DSE - uses only one thread per core
* DSE - Uses asynchronous a lot and non-blocking

## Before and after flush
```
Total number of tables: 47					Total number of tables: 47
----------------						----------------
Keyspace : keyspace1						Keyspace : keyspace1
	Read Count: 0							Read Count: 0
	Read Latency: NaN ms						Read Latency: NaN ms
	Write Count: 574408						Write Count: 574408
	Write Latency: 0.009942241403323074 ms				Write Latency: 0.009942241403323074 ms
	Pending Flushes: 0						Pending Flushes: 0
		Table: standard1						Table: standard1
		SSTable count: 3			      |			SSTable count: 4
		Space used (live): 92.67 MiB		      |			Space used (live): 97.73 MiB
		Space used (total): 92.67 MiB		      |			Space used (total): 97.73 MiB
		Space used by snapshots (total): 0 bytes			Space used by snapshots (total): 0 bytes
		Off heap memory used (total): 497.8 KiB	      |			Off heap memory used (total): 525.04 KiB
		SSTable Compression Ratio: -1.0					SSTable Compression Ratio: -1.0
		Number of partitions (estimate): 426808	      |			Number of partitions (estimate): 427070
		Memtable cell count: 22313		      |			Memtable cell count: 0
		Memtable data size: 5.94 MiB		      |			Memtable data size: 0 bytes
		Memtable off heap memory used: 0 bytes				Memtable off heap memory used: 0 bytes
		Memtable switch count: 18		      |			Memtable switch count: 19
		Local read count: 0						Local read count: 0
		Local read latency: NaN ms					Local read latency: NaN ms
		Local write count: 574408					Local write count: 574408
		Local write latency: 0.009 ms					Local write latency: 0.009 ms
		Pending flushes: 0						Pending flushes: 0
		Percent repaired: 0.0						Percent repaired: 0.0
		Bytes repaired: 0.000KiB					Bytes repaired: 0.000KiB
		Bytes unrepaired: 88.575MiB		      |			Bytes unrepaired: 93.424MiB
		Bytes pending repair: 0.000KiB					Bytes pending repair: 0.000KiB
		Bloom filter false positives: 0					Bloom filter false positives: 0
		Bloom filter false ratio: 0.00000				Bloom filter false ratio: 0.00000
		Bloom filter space used: 497.82 KiB	      |			Bloom filter space used: 525.07 KiB
		Bloom filter off heap memory used: 497.8 KiB  |			Bloom filter off heap memory used: 525.04 KiB
		Index summary off heap memory used: 0 bytes			Index summary off heap memory used: 0 bytes
		Compression metadata off heap memory used: 0 			Compression metadata off heap memory used: 0 
		Compacted partition minimum bytes: 180				Compacted partition minimum bytes: 180
		Compacted partition maximum bytes: 258				Compacted partition maximum bytes: 258
		Compacted partition mean bytes: 258				Compacted partition mean bytes: 258
		Average live cells per slice (last five minut			Average live cells per slice (last five minut
		Maximum live cells per slice (last five minut			Maximum live cells per slice (last five minut
		Average tombstones per slice (last five minut			Average tombstones per slice (last five minut
		Maximum tombstones per slice (last five minut			Maximum tombstones per slice (last five minut
		Dropped Mutations: 0 bytes					Dropped Mutations: 0 bytes
		Failed Replication Count: null					Failed Replication Count: null
```

## Sample data directory wiht WITH bloom_filter_fp_chance = 0.1;

```
ubuntu@ds201-node1:~/node1/data/data/keyspace1/standard1-000692d1cb3811eb8b932752b509e266$ ls -ltar
total 36296
drwxrwxr-x 2 ubuntu ubuntu     4096 Jun 12 04:38 backups
drwxrwxr-x 4 ubuntu ubuntu     4096 Jun 12 04:38 ..
-rw-rw-r-- 1 ubuntu ubuntu        0 Jun 12 04:41 aa-9-bti-Rows.db
-rw-rw-r-- 1 ubuntu ubuntu 35457984 Jun 12 04:41 aa-9-bti-Data.db
-rw-rw-r-- 1 ubuntu ubuntu  1472810 Jun 12 04:41 aa-9-bti-Partitions.db
-rw-rw-r-- 1 ubuntu ubuntu   194656 Jun 12 04:41 aa-9-bti-Filter.db
-rw-rw-r-- 1 ubuntu ubuntu    10271 Jun 12 04:41 aa-9-bti-Statistics.db
-rw-rw-r-- 1 ubuntu ubuntu       10 Jun 12 04:41 aa-9-bti-Digest.crc32
-rw-rw-r-- 1 ubuntu ubuntu     2176 Jun 12 04:41 aa-9-bti-CRC.db
-rw-rw-r-- 1 ubuntu ubuntu       82 Jun 12 04:41 aa-9-bti-TOC.txt
drwxrwxr-x 3 ubuntu ubuntu     4096 Jun 12 04:41 .
```

## Sample data directory wiht WITH bloom_filter_fp_chance = 0.0001;

```
ubuntu@ds201-node1:~/node1/data/data/keyspace1/standard1-000692d1cb3811eb8b932752b509e266$ ls -ltar
total 36488
drwxrwxr-x 2 ubuntu ubuntu     4096 Jun 12 04:38 backups
drwxrwxr-x 4 ubuntu ubuntu     4096 Jun 12 04:38 ..
-rw-rw-r-- 1 ubuntu ubuntu        0 Jun 12 04:47 aa-10-bti-Rows.db
-rw-rw-r-- 1 ubuntu ubuntu 35457984 Jun 12 04:47 aa-10-bti-Data.db
-rw-rw-r-- 1 ubuntu ubuntu  1472810 Jun 12 04:47 aa-10-bti-Partitions.db
-rw-rw-r-- 1 ubuntu ubuntu   389304 Jun 12 04:47 aa-10-bti-Filter.db
-rw-rw-r-- 1 ubuntu ubuntu       10 Jun 12 04:47 aa-10-bti-Digest.crc32
-rw-rw-r-- 1 ubuntu ubuntu     2176 Jun 12 04:47 aa-10-bti-CRC.db
-rw-rw-r-- 1 ubuntu ubuntu       82 Jun 12 04:47 aa-10-bti-TOC.txt
-rw-rw-r-- 1 ubuntu ubuntu    10271 Jun 12 04:47 aa-10-bti-Statistics.db
drwxrwxr-x 3 ubuntu ubuntu     4096 Jun 12 04:47 .
```


## Sample data directory wiht WITH bloom_filter_fp_chance = 1.0; (100% false positive allowed... No filter file)

```
ubuntu@ds201-node1:~/node1/data/data/keyspace1/standard1-000692d1cb3811eb8b932752b509e266$ ls -ltar
total 36104
drwxrwxr-x 2 ubuntu ubuntu     4096 Jun 12 04:38 backups
drwxrwxr-x 4 ubuntu ubuntu     4096 Jun 12 04:38 ..
-rw-rw-r-- 1 ubuntu ubuntu        0 Jun 12 04:53 aa-12-bti-Rows.db
-rw-rw-r-- 1 ubuntu ubuntu 35457984 Jun 12 04:53 aa-12-bti-Data.db
-rw-rw-r-- 1 ubuntu ubuntu  1472810 Jun 12 04:53 aa-12-bti-Partitions.db
-rw-rw-r-- 1 ubuntu ubuntu       10 Jun 12 04:53 aa-12-bti-Digest.crc32
-rw-rw-r-- 1 ubuntu ubuntu     2176 Jun 12 04:53 aa-12-bti-CRC.db
-rw-rw-r-- 1 ubuntu ubuntu    10271 Jun 12 04:53 aa-12-bti-Statistics.db
-rw-rw-r-- 1 ubuntu ubuntu       72 Jun 12 04:53 aa-12-bti-TOC.txt
drwxrwxr-x 3 ubuntu ubuntu     4096 Jun 12 04:53 .
ubuntu@ds201-node1:~/node1/data/data/keyspace1/standard1-0
```


## Nodetool CFStats 

```
ubuntu@ds201-node1:~/node/bin$ ./nodetool cfstats keyspace1
Total number of tables: 47
----------------
Keyspace : keyspace1
	Read Count: 0
	Read Latency: NaN ms
	Write Count: 154846
	Write Latency: 0.011354216447308938 ms
	Pending Flushes: 0
		Table: counter1
		SSTable count: 0
		Space used (live): 0
		Space used (total): 0
		Space used by snapshots (total): 0
		Off heap memory used (total): 0
		SSTable Compression Ratio: -1.0
		Number of partitions (estimate): 0
		Memtable cell count: 0
		Memtable data size: 0
		Memtable off heap memory used: 0
		Memtable switch count: 0
		Local read count: 0
		Local read latency: NaN ms
		Local write count: 0
		Local write latency: NaN ms
		Pending flushes: 0
		Percent repaired: 100.0
		Bytes repaired: 0.000KiB
		Bytes unrepaired: 0.000KiB
		Bytes pending repair: 0.000KiB
		Bloom filter false positives: 0
		Bloom filter false ratio: 0.00000
		Bloom filter space used: 0
		Bloom filter off heap memory used: 0
		Index summary off heap memory used: 0
		Compression metadata off heap memory used: 0
		Compacted partition minimum bytes: 0
		Compacted partition maximum bytes: 0
		Compacted partition mean bytes: 0
		Average live cells per slice (last five minutes): NaN
		Maximum live cells per slice (last five minutes): 0
		Average tombstones per slice (last five minutes): NaN
		Maximum tombstones per slice (last five minutes): 0
		Dropped Mutations: 0
		Failed Replication Count: null

		Table: standard1
		SSTable count: 1
		Space used (live): 36943323
		Space used (total): 36943323
		Space used by snapshots (total): 0
		Off heap memory used (total): 0
		SSTable Compression Ratio: -1.0
		Number of partitions (estimate): 155716
		Memtable cell count: 0
		Memtable data size: 0
		Memtable off heap memory used: 0
		Memtable switch count: 9
		Local read count: 0
		Local read latency: NaN ms
		Local write count: 154846
		Local write latency: 0.010 ms
		Pending flushes: 0
		Percent repaired: 0.0
		Bytes repaired: 0.000KiB
		Bytes unrepaired: 33.815MiB
		Bytes pending repair: 0.000KiB
		Bloom filter false positives: 0
		Bloom filter false ratio: 0.00000
		Bloom filter space used: 0
		Bloom filter off heap memory used: 0
		Index summary off heap memory used: 0
		Compression metadata off heap memory used: 0
		Compacted partition minimum bytes: 180
		Compacted partition maximum bytes: 258
		Compacted partition mean bytes: 258
		Average live cells per slice (last five minutes): NaN
		Maximum live cells per slice (last five minutes): 0
		Average tombstones per slice (last five minutes): NaN
		Maximum tombstones per slice (last five minutes): 0
		Dropped Mutations: 0
		Failed Replication Count: null

----------------
ubuntu@ds201-node1:~/node/bin$ 
```

```
./cassandra-stress read CL=ONE no-warmup n=1000000 -rate threads=1
./nodetool cfstats
```

## Followup questions

* we could not find /var/log/system.log
  * During single-node check console output or nohup.out or terminal output
* What is the difference between partition-summary and partition-index?


[mem_table]: img/mem_table_commitlog.JPG "Commit-Log"
[read_token_58]: img/read_58_token.JPG Read-token"



## What is compaction in Cassandra?

* It is similar to comapaction of file-system
* Multiple SS-Tables are merged (like merge-sort), and deleted removed, tombstones removed, updated records retained.
  * It leads to lean SS-Table


## Pre-requisite for Compaction

* Find table statistics
  * nodetool cfstats
  * nodetool tpstats

## We have problem with two nodes with large number of compaction pending, how to speed up?

* Disable the node act as a co-ordinator? (it can spend its io/cpu in compaction)
  * nodetool disablebinary
* Disable the node accepting write (should be lesser than hinted-handoff period) ?
  * nodetool disablegossip (marking node as down)
  * nodetool disablehandoff (marking node as down)
* Disable the node accepting write (should be lesser than hinted-handoff period) ?
  * nodetool disablegossip
* Increase the compaction througput (there would be consequences for read)
  * nodetool setconcurrentcompactors 2



## Reference
*[Understanding the Nuance of Compaction in Apache Cassandra](https://thelastpickle.com/blog/2017/03/16/compaction-nuance.html)
* [TWCS part 1 - how does it work and when should you use it ?](https://thelastpickle.com/blog/2016/12/08/TWCS-part1.html)
## Important Spring Java project

* [Cassandra Datastax PetClinic](https://github.com/spring-petclinic/spring-petclinic-reactive)
* [Cassandra Datastax Reactive PetClinic](https://github.com/DataStax-Examples/spring-petclinic-reactive)
# Important Cassandra links

* [JIRA](https://issues.apache.org/jira/browse/CASSANDRA-8844)
* [Cassandra Cwiki](https://cwiki.apache.org/confluence/display/CASSANDRA/Home)
* [GIT Cassandra](https://gitbox.apache.org/repos/asf/cassandra.git)
* [CI-Cassandra-Build](https://ci-cassandra.apache.org/job/Cassandra-trunk/531/)
* [CI Console log](https://ci-cassandra.apache.org/job/Cassandra-4.0-artifacts/jdk=jdk_1.8_latest,label=cassandra/59/consoleFull)


## Cassandra Course Videos

* [DS-201 vidoes](https://www.youtube.com/watch?v=69pvhO6mK_o&list=PL2g2h-wyI4Spf5rzSmesewHpXYVnyQ2TS)

## Cassandra index

* [Architecture](https://github.com/mohanmca/cassandra_playground/blob/master/Architecture.md)
* [README](https://github.com/mohanmca/cassandra_playground/blob/master/README.md)
* [cassandra_commands_output](https://github.com/mohanmca/cassandra_playground/blob/master/cassandra_commands_output.md)
* [cassandra_definitive_guide_anki](https://github.com/mohanmca/cassandra_playground/blob/master/cassandra_definitive_guide_anki.md)
* [cassandra_docker](https://github.com/mohanmca/cassandra_playground/blob/master/cassandra_docker.md)
* [cqls_anki](https://github.com/mohanmca/cassandra_playground/blob/master/cqls_anki.md)
* [data_types](https://github.com/mohanmca/cassandra_playground/blob/master/data_types.md)
* [partition](https://github.com/mohanmca/cassandra_playground/blob/master/partition.md)
* [setup](https://github.com/mohanmca/cassandra_playground/blob/master/setup.md)
* [todo](https://github.com/mohanmca/cassandra_playground/blob/master/todo.md)
* [Debug log](https://github.com/mohanmca/cassandra_playground/blob/master/log/debug.log)
* [System Log](https://github.com/mohanmca/cassandra_playground/blob/master/log/system.log)

## Famous Cassandra articles

* [The things I hate about Apache Cassandra - John Schulz](https://blog.pythian.com/the-things-i-hate-about-apache-cassandra/)
## How to generate conf/cassandra_simple.yaml

* grep -v "^#" conf/cassandra.yaml |   sed  '/^$/d' > conf/cassandra_simple.yaml 

## Analyze Cassandra code

```
cat test/unit/org/apache/cassandra/db/compaction/LeveledCompactionStrategyTest.java | tr ' ' '\r\n' | tr A-Z a-z | sort| tr -d '[\\}\\{}]' | sort  
```

## K8ssandra

* [Workshop](https://github.com/datastaxdevs/workshop-k8ssandra)
* [Workshop slides](https://github.com/datastaxdevs/k8ssandra-workshop/raw/main/K8ssandra%20Workshop%20Feb%202021.pdf)
* [Workshop Steps](https://github.com/datastaxdevs/workshop-k8ssandra/wiki)