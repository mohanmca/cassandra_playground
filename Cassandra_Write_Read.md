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


