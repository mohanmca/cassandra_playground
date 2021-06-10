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


## Followup questions

* What is the difference between partition-summary and partition-index?


[mem_table]: img/mem_table_commitlog.JPG "Commit-Log"
[read_token_58]: img/read_58_token.JPG Read-token"


