## Cassandra node

* Cassandra designed for JBOD (just a bunch of disk) setup
* If disk is attached to ethernet, it is wrong choice, hence Cassandra not tuned to work with SAN/NAS
* A node can work with
  * 6K to 12K transaction
  * 2-4TB of data on ssd
  * 2-TB is maximum for data, remaining for compaction
* Cassandra can lineraly scale with new nodes

## (Section: Architecture) -  Ring

* Apache cassandra cluster - Collection of nodes
* Node that we connect is co-ordinator node
* Each node is responsible for range of data
  * Token range
* Every node can deduce which node owns the range of token (range of data)
* Co-ordinator sends acknowledgements to client
  * co-ordinator-node !== data-node
  * co-ordinator-node === data-node (When using TokenAwarePolicy)
* Range
  * (2^63)-1 to -(2^63)
* Partitioner - Decides how to distribute data within nodes
* Right partitioner would place the data widely
  * Murmur3 as a partitioner
  * MD5 partitioner (random and even)

## (Section: Core) What is Wrapping-Range vs Token-Range?

* The vnode with the lowest token owns the range less than or equal to its token and the range greater than the highest token, which is also known as the wrapping range.
* A node claims ownership of the range of values less than or equal to each token and greater than the last token of the previous node, known as a **token range**.

## (Section: Architecture) -  When a new node joins the ring

* Gossips out to seed-node (seed-nodes are configured in cassandra.yaml)
* Other node finds where could new node could fit (could be manual or automatic)
* Seed nodes communicate cluster topology to the joining new-node
* State of the nodes
  * Joining, Leaving, UP and Down


## (Section: Architecture) -  Driver

* Client could intelligently use node status and clutser
* Client would use different policies
  * TokenAwarePolicy
  * RoundRobinPolicy
  * DCAwareRoundRobinPolicy
* Driver knowing token range would make it intelligent, It would directly talk to data node when data is required
* Driver can use the  TokenAwarePolicy and directly deal with the node that is responsbile for the data, internally it would avoid one more hop (co-ordinator-node === data-node)

## (Section: Architecture) -  Peer-to-Peer

* We should understand the reason by behind peer-to-peer
* Relational databases scales in one of the following way
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


## (Section: Architecture) -  VNode

* If token is distributed in contiguous-range to a physical node, it won't help when new-node joins
  * Hence every node will not get contiguous token range for it's capcity
* Bootstraping new node is complex in peer-to-peer without vnodes
* Adding/Removing nodes in distributed system is complex, it can't just rely on the number of physical node
* Vnodes eases the use of heterogeneous machines in a cluster. Better machine can have more vnodes than other.
* We can't move all the data of one-physical node to other node when new-node joins
  * It put strain on the node that transfers the data
  * It won't happen in parallel way
* Each node has 128 VNode (default)
* Vnode automate token range assignment
* num_tokens@cassandra.yaml > 1, enables the vnode (1 means disable vnode)
* If all nodes have equal hardware capability, each node should have the same num_tokens value.

## (Section: Architecture) -  Why Vnode?

* If we have 30 node (with RF=3), effectively we have 10 nodes of original data, 20 nodes of replicated. If every node holds data for 3 ranges of token, and when a node goes down, logically we have RF=2 for set of data, and we can stream from 6 nodes of data
* If you started your older machines with 64 vnodes per node and the new machines are twice as powerful, simply give them 128 vnodes each and the cluster remains balanced even during transition.
* When using vnodes, Cassandra automatically assigns the token ranges for you. Without vnode, manual assignment is required.


## (Section: Architecture) -  Gossip protocol

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

## (Section: Architecture) -  What is gossiped?

* SYN, ACK, ACK2
  * SYN - sender node details
  * ACK - reciever node details + packs additional details that receiver knows extra than sender (not just digest)
  * ACK2 - packs additional details that initiator knows extra then receiver (not just digest)
* Gossip message is tiny, won't cause significant impact to network bandwidth (network spikes won't be caused)
* JSON is only for analogy
```json
## (Section: Architecture) -  Json analogy
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

## (Section: Architecture) -  What is the purpose of Gossip

* Gossip helps to identify fastest node and helps in reading from node with lowest latency

## (Section: Architecture) -  Snitch

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

## (Section: Architecture) -  Property File Snitch

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

## (Section: Architecture) -  Gossiping Property File Snitch

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

## (Section: Architecture) -  How nodes can find if another nodes are doing Compactions?

* DynamicEndpointSnitch - can find other nodes performance and latency, It can find if another nodes is doing Compaction
* DynamicEndpointSnitch implementation uses a modified version of the Phi failure detection mechanism used by gossip.

## (Section: Architecture) -  Cassandra replication

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


## (Section: Architecture) -  Consistency Level

* **Request-Coordinator to Client** Defines how many replicas that are writing or reading data must respond to a **request coordinator** before the coordinator responds to the client. 
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


## (Section: Architecture) -  Consistency level in Cassandra

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


## (Section: Architecture) -  Hinted hand-off

* Write request can be served, even when nodes are down. Co-ordinator caches using hints file, later handoever the data to target node
* Hints file will be deleted after expiry (default 3 hours), hence data write is not guarantee to the node it was down
* If actual node comes while co-ordinator was down, data won't reach the target node
* When node comes back-online, it receives copy from co-ordinator (not from other 2-replicas when RF=3)
* Hinted-hand-off + Consistency-level-Any means potential data-loss.
  * Even when RF=3 and if three targe nodes for data is down, CONSISTENCY_LEVEL_ANY would successfully return to client
* Consistency-level-Any is not practical due to hinted-hand-off
* We can disable hinted-hand-off
* Hints are **best effort**, however, and do not guarantee eventual consistency like anti-entropy repair <repair> does.

## (Section: Architecture) -  Read repair (Assume RF=3)

* Nodes goes out-of-sync for many reasons
  * Network partition, node failures, storage failure
* Co-ordinator sometime can answer best available anster (instead of correct answer)
* for read request of CL=ALL, Co-ordinator asks data from fastest node (finds using snitch), and checksum-digest from other two nodes, if they are all consistent, it would reply to client-read
* if checksum-digest doesn't matches
  1. Co-ordinator requests replicated data from other two nodes
  1. Compares the timestamp for the 3 copies
  1. Sends the latest data to client
  1. Replicates the latest data to the nodes that has stale copy

## (Section: Architecture) -  Read Repair Chance

* Performed when read is at a consistency level less than ALL
* Request reads only a subset of the replicas
* We can’t be sure replicas are in sync
* Generally you are safe, but no guarantees
* Response sent immediately when consistency level is met
* Read repair done asynchronously in the background
* 10% by default


## (Section: Architecture) -  Node-repai

## (Section: Architecture) -  Nodetool has a repair tool that can repair entire cluster - Quite expensive operation
* nodetool repair --full
* Extra load on the network, IO also might spike



## (Section: Architecture) -  Datastax Node-sync

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


## (Section: Architecture) -  Write path

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

## (Section: Architecture) -  Read path

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

## (Section: Architecture) -  Data-stax

* No partition-index, instead trie based data-structure used as index
  * SS-Table lookup is much faster than OSS version
* Data-stax can read OSS-Cassandra and migrate to latest format of SS-Table
  * If we know pk0020 location inside the partition-index, it is easier to find the parition-index offset for pk0024 (https://stackoverflow.com/questions/26244456/internals-of-partition-summary-in-cassandra)

## (Section: Architecture) -  Compacting partition

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

## (Section: Architecture) -  Compacting SSTables

* Two SS-Table merged using merge-sort
* Merge might reduce the partition as all the stale values inside the parition are evicted
* Once new SS-Table is created, old SS-Table is dropped

## (Section: Architecture) -  Types of compaction

* SizeTiered Compaction (default for write heavy-load)
* Leveled Compaction (read optimized compaction)
* TimeWindow Compaction (for timeseries data)

* Alter table ks.myTable  WITH compaction = { 'class': 'LeveledCompactionStrategy'}

## (Section: Architecture) -  Datastax ES6

* Only one core per CPU and Non-blocking-IO
  * Claims to be more performant than OSS version
  * These threads are never block
  * Writes and Reads, both are asynchronous
  * Each thread has its own mem-table
  * Separate management thread for Mem-table-flush, Compaction, Hints, Streaming
* OSS - Executor thread-pool

## Constraints of LightWeight Transaction

* Lightweight transactions are also sometimes referred to as compare-and-set operations. 
* Each lightweight transaction is atomic and always works on a single partition.

## (Section: Architecture) -  Under what circumstances is the use of lightweight transactions justified?

* Race conditions and low data contention