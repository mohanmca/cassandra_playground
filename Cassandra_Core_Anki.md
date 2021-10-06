## (Section: Core) - Number of stages on Cassandra

1. AntiEntropyStage            
1. CacheCleanupExecutor      
1. CompactionExecutor          
1. CounterMutationStage        
1. GossipStage                 
1. HintsDispatcher             
1. InternalResponseStage       
1. MemtableFlushWriter         
1. MemtablePostFlush           
1. MemtableReclaimMemory       
1. MigrationStage              
1. MiscStage                   
1. MutationStage               
1. PendingRangeCalculator      
1. PerDiskMemtableFlushWriter_0
1. ReadRepairStage             
1. ReadStage                   
1. RequestResponseStage        
1. Sampler                     
1. SecondaryIndexManagement    
1. ValidationExecutor          
1. ViewMutationStage             


## (Section: Core) Status of Table (SSTable tablestats)

1. Average live cells per slice (last five minutes): 1.0
1. Average tombstones per slice (last five minutes): 1.0
1. Bloom filter false positives: 0
1. Bloom filter false ratio: 0.00000
1. Bloom filter off heap memory used: 4656
1. Bloom filter space used: 4680
1. Compacted partition maximum bytes: 86
1. Compacted partition mean bytes: 84
1. Compacted partition minimum bytes: 61
1. Compression metadata off heap memory used: 48
1. Dropped Mutations: 6
1. Index summary off heap memory used: 1041
1. Local read count: 3952653
1. Local read latency: 0.030 ms
1. Local write count: 12577242
1. Local write latency: 0.003 ms
1. Maximum live cells per slice (last five minutes): 1
1. Maximum tombstones per slice (last five minutes): 1
1. Memtable cell count: 1809586
1. Memtable data size: 103656
1. Memtable off heap memory used: 0
1. Memtable switch count: 3
1. Number of partitions (estimate): 2468
1. Off heap memory used (total): 5745
1. Pending flushes: 0
1. Percent repaired: 0.0
1. Space used (live): 321599
1. Space used (total): 321599
1. Space used by snapshots (total): 0
1. SSTable Compression Ratio: 0.6803828095486517
1. SSTable count: 3
1. Table: user_by_email

## (Section: Core) Status of Nodetool Info (node info)

1. Chunk Cache            : entries 27, size 1.69 MiB, capacity 217 MiB, 120 misses, 6150101 requests, 1.000 recent hit rate, NaN microseconds miss latency
1. Counter Cache          : entries 0, size 0 bytes, capacity 24 MiB, 0 hits, 0 requests, NaN recent hit rate, 7200 save period in seconds
1. Data Center            : datacenter1
1. Exceptions             : 0
1. Generation No          : 1625291106
1. Gossip active          : true
1. Heap Memory (MB)       : 209.83 / 998.44
1. ID                     : 020b9ef3-ae33-4c9f-902a-33eb7f9a753d
1. Key Cache              : entries 3721, size 323.3 KiB, capacity 49 MiB, 6138479 hits, 6142208 requests, 0.999 recent hit rate, 14400 save period in seconds
1. Load                   : 571.88 KiB
1. Native Transport active: true
1. Off Heap Memory (MB)   : 0.01
1. Percent Repaired       : 100.0%
1. Rack                   : rack1
1. Row Cache              : entries 0, size 0 bytes, capacity 0 bytes, 0 hits, 0 requests, NaN recent hit rate, 0 save period in seconds
1. Thrift active          : false
1. Token                  : (invoke with -T/--tokens to see all 256 tokens)
1. Uptime (seconds)       : 35986

## (Section: DS210) -  How to create anki from this markdown file

```
mdanki Cassandra_Core_Anki.md Cassandra_Core_Anki.apkg --deck "Mohan::Cassandra::Core::Fields"
```

