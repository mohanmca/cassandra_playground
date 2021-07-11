## Storage Architecture

* Only one commit log per cluster
* Commit-logs are flused to (via MemTable) sstables
* When memtables are flushed to disk, they are written as SSTables (fast compression used by default)
* Memtable and SSTable is sorted by primary-key and clustering-key
   * A partition-key would be exist within SSTable only one page
* SSTable very poor to find absence of key (hence we need bloom-filter)


## SStable - settings in cassandra.yaml

1. flush_compression: fast
1. file_cache_enabled: false 
    * The chunk cache will store recently accessed sections of the sstable in-memory as uncompressed buffers. - 32MB
1. Memtable    
   1. memtable_heap_space_in_mb: 2048
   1. memtable_offheap_space_in_mb: 2048
1. index_summary_capacity_in_mb (SSTable index summary)
1. index_summary_resize_interval_in_minutes 
   * How frequently index summaries should be resampled
1. compaction_throughput_mb_per_sec: 64
1. stream_entire_sstables: true
1. max_value_size_in_mb: 256

## What are the files part of SSTable

* mb-1-big-Summary.db
* mb-1-big-Index.db
* mb-1-big-Filter.db
* mb-1-big-Data.db
* SSTable metata files
  * mb-1-big-Digest.crc32
  * mb-1-big-Statistics.db
  * mb-1-big-CRC.db
  * mb-1-big-Toc.txt -- list of the above files

## What is the role of index file

* It lists the partition-keys/cluster-keys that are available inside the SSTable with offset information. Disk seek can directly locate few keys

## What is the role of statitics file

* It has the column definition
* It has almost all the details about DDL of a table


## Why SQLite4 didn't use LSM?

* Every insert needs to check constraint, and it requires reads. In simple, every write operation also ends up with read operation.
* LSM is great for blind writes, but doesn't work work as well when constraints must be checked prior to each write


## LSM Pros and Cons

* Pros
   * Faster writes
   * Reduced write amplification
   * Linear Writes
   * Less SSD Wear
* Cons
  * Slower Reads
  * Background Merge process
  * More space on disk
  * Greater Complexity


## SSTable references

* [What is in All of Those SSTable Files Not Just the Data One but All the Rest Too! (John Schulz, The Pythian Group) | Cassandra Summit 2016 ](https://www.slideshare.net/DataStax/what-is-in-all-of-those-sstable-files-not-just-the-data-one-but-all-the-rest-too-john-schulz-the-pythian-group-cassandra-summit-2016)
* [So you have a broken Cassandra SSTable file?](https://blog.pythian.com/so-you-have-a-broken-cassandra-sstable-file/)
* [C23: Lessons from SQLite4 by SQLite.org - Richard Hipp ](https://www.slideshare.net/InsightTechnology/dbtstky2017-c23-sqlite?from_action=save)