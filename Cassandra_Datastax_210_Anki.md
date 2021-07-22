## (Section: DS210) - What is D210 Course about

* Operations for Apache Cassandra™ and DataStax Enterprise
* Installation
  * echo "deb https://debian.datastax.com/enterprise stable main" | sudo tee -a /etc/apt/sources.list.d/datastax.sources.list
  * curl -L https://debian.datastax.com/debian/repo_key | sudo apt-key add -
  * sudo apt-get update
  * sudo apt-get install dse-full

## (Section: DS210) -  What are basic parameter required for Cassandra quickstart

* Four parameters
    * cluster-name
    * listen-address (for peer Cassandra nodes to connect to)
    * native-transport-address (for clients)
    * seeds
      * Seeds should be comma seperated inside double quote - "ip1,ip2,ip3"

## (Section: DS210) -  What is the location of default Cassandra.yaml?

* /etc/dse/cassandra.yaml (package installer)
* /cassandra-home/resources/cassandra/conf/cassandra.yaml

## (Section: DS210) -  What are directories related settings, and level-2 settings (right after quickstart)<default>

* initial_token: <128>
* commitlog_directory
    * /var/lib/cassandra/commitlog
* data_file_directories
    * /var/lib/cassandra/data
* hints_directory
    * /var/lib/cassandra/hints
* saved_caches_directory
* endpoint_snitch

## (Section: DS210) -  What are two file-systedm that should be separated

*  /var/lib/cassandra/data and /var/lib/cassandra/commitlog

## (Section: DS210) -  Cluster Sizing

* Figure out cluster size parameters
    1. (Write)-Throughput  - How much data per second?
    1. Growth Rate  -   How fast does capacity increase?
    1. Latency (Read) -   How quickly must the cluster respond?

## (Section: DS210) -  Cluster Sizing - Writethrough put example

* 2m user commenting 5 comments a day, where a comment is 1000 byte
* # comments per second = (2m * 5)/(24*60*60)  = 10m/86400 = 100 comments per second
* 100 * 1000 bytes = 100KB per-second (multiply into number of replication-factor)

## (Section: DS210) -  Cluster Sizing - Read throughput example

* 2m user viewing 10 video summaries a day, where a video has 4 comments
* # comments per second = (2m * 10 * 4)/(24*60*60)  = 80m/86400 = 925 comments per second
* 925 * 1000 bytes = 1MB per-second (should multiply into number of replication-factor?)

## (Section: DS210) -  Cluster-sizing - Monthly calculate

* Data should cover only 50% of disk space at any-time to allow repair and compaction to work
* Few they estimate just by doubling the need for 60-seconds and extra-polate to 30 days
* per-second-data-volume * 30*86400 
* 1MB per second into monthly need
    * 1MB * 86400 * 30 = 2.531 TB (here 1MB inclusive of anti-entropy)


## (Section: DS210) -  Cluster-sizing - Latency calculate

* Relevant Factors
    * IO Rate
    * Workload shape
    * Access Patterns
    * Table width
    * Node profile (memory/cpu/network)
* What is required SLA
* Do the benchmarking initially before launching


## (Section: DS210) -  Cluster Sizing - Probing Questions

1. What is the new/update ratio?
1. What is the replication factor?
1. Additional headroom for operations - Anti-entropy repair?


## (Section: DS210) -  [Cassandra stress tool](https://cassandra.apache.org/doc/latest/tools/cassandra_stress.html)

* Define your shcema, and schema performance
* Understand how your database scales
* It could generate graphical output
* Specify any compaction strategy
* Optmize your datamodel and setttings
* Determine production capacity
* Yaml for Schema, Column, Batch and Query descriptions
* columnspec:
```yaml
  - name: name
    size: uniform(5..10) # The names of the staff members are between 5-10 characters
    population: uniform(1..10) # 10 possible staff members to pick from
  - name: when
    cluster: uniform(20..500) # Staff members do between 20 and 500 events
  - name: what
    size: normal(10..100,50)
```
*  Distribution can be any among fom, EXTREME, EXP, GAUSS, UNIFORM, FIXED
* cassandra-stress user profile=/home/cassandra/TestProfile.yaml ops\(insert=10000, user_by_email=100000\) -node node-ds210-node1
* cassandra-stress user profile=TestProfile.yml ops\(insert=2,user_by_email=2\) no-warmup -rate threads<=54
* cassandra-stress user profile=TestProfile.yml ops\(insert=2000,user_by_email=2\) no-warmup -rate threads'<=32'

ubuntu@ds210-node1:~/labwork$ cassandra-stress user profile=TestProfile.yaml ops\(insert=100000,user_by_email=100000\) -node ds210-node1
There was a problem parsing the table cql: line 0:-1 mismatched input '<EOF>' expecting ')'

## (Section: DS210) -  Linux top command

* Comes with every linux distribution - (How much Cassandra is using)
* Brief summary of Linux system resources + Per process details
* Summary
  * CPU Average
    * 1,5,15 (minute) average
    * Spike - will show up in 5 or 15
    * CPU - Wait
      * Too much of wait is problem for Cassandra (should be zero)
      * si/hi (sofwatre/hardware - interrupt) might give clue about waiting
* Memory
  * Res - Physical Memory
  * SHR - Shared Memory
  * VIRT - Virtual memory
  * Buffers are important
    * High read might cause SSTable in buffer
* Process State
  * Zombie, Sleeping, Running  

## (Section: DS210) -  Linux top command - Cassandra

* Swap should be zero (Cassandra discourages swap)
  * Disable the swap, zero should be allocated
* Zombie should be zero


## (Section: DS210) -  Linux dstat command (alternative to top)

* dstat = cpustat + iostat + vmstat + ifstat (cpy/io/network)
* cpu-core specific information can be listed
* dstate - by defult won't include memory (dstate -am to add memory details output)
* print stat for every 2 seconds, and measure 7 iteration
  ```
  ubuntu@ds210-node1:~$ dstat -am 2 7
  --total-cpu-usage-- -dsk/total- -net/total- ---paging-- ---system-- ------memory-usage-----
  usr sys idl wai stl| read  writ| recv  send|  in   out | int   csw | used  free  buff  cach
    3   6  89   2   0|3412k  112k|   0     0 |   0     0 | 505  1443 | 587M 6286M  100M  935M
    1   1  98   0   0|   0     0 |  66B  722B|   0     0 | 506  1261 | 587M 6286M  100M  935M
    0   0 100   0   0|   0     0 |  66B  418B|   0     0 | 147   403 | 587M 6286M  100M  935M
    0   0 100   0   0|   0     0 |  66B  418B|   0     0 | 161   376 | 587M 6286M  100M  935M
    0   1  99   0   0|   0     0 |  66B  418B|   0     0 | 596  1900 | 587M 6286M  100M  935M
    0   1  98   0   0|   0     0 |  66B  418B|   0     0 | 760  2137 | 587M 6286M  100M  935M
    0   0 100   0   0|   0  8192B|  66B  418B|   0     0 | 111   366 | 587M 6286M  100M  935M
  ubuntu@ds210-node1:~$ 
  ```
* sys is higher - something costly happenning in system space (above 0 is not good)
* disk is weakest link in most system. if wait numbers are higher in user/system space, check disk
* hiq/siq = h/w and s/w interrupt
* HDD can transfer 10s of MBS, while SSDs can transfer hundreds of MBS
* Gigabit is 100MBS usually
* Paging should be usually be near zero (lots of paging is bad to performance)
* System stats can be an indication of process contention (CSW - context switch)

## (Section: DS210) -  Nodetool (Performance Analysis inside cluster node)

* dstat, top - can investigate inside linux
* nodetool - can investigate inside Cassandra JVM
* Every Cache size hit ratio should be higher (should be above 80%)
* Load - How much data is stored inside node

```
cqlsh:killr_video> exit
root@c1bf4c2d5378:/# nodetool info
ID                     : 020b9ef3-ae33-4c9f-902a-33eb7f9a753d
Gossip active          : true
Thrift active          : false
Native Transport active: true
Load                   : 571.88 KiB
Generation No          : 1625291106
Uptime (seconds)       : 35986
Heap Memory (MB)       : 209.83 / 998.44
Off Heap Memory (MB)   : 0.01
Data Center            : datacenter1
Rack                   : rack1
Exceptions             : 0
Key Cache              : entries 3721, size 323.3 KiB, capacity 49 MiB, 6138479 hits, 6142208 requests, 0.999 recent hit rate, 14400 save period in seconds
Row Cache              : entries 0, size 0 bytes, capacity 0 bytes, 0 hits, 0 requests, NaN recent hit rate, 0 save period in seconds
Counter Cache          : entries 0, size 0 bytes, capacity 24 MiB, 0 hits, 0 requests, NaN recent hit rate, 7200 save period in seconds
Chunk Cache            : entries 27, size 1.69 MiB, capacity 217 MiB, 120 misses, 6150101 requests, 1.000 recent hit rate, NaN microseconds miss latency
Percent Repaired       : 100.0%
Token                  : (invoke with -T/--tokens to see all 256 tokens)
```

## (Section: DS210) -  Nodetool compaction-history - what are all the fields and output?

```
root@c1bf4c2d5378:/# nodetool compactionhistory
Compaction History:
id                                   keyspace_name columnfamily_name compacted_at            bytes_in bytes_out rows_merged
e01933a0-dc04-11eb-bef5-537733e6a124 system        size_estimates    2021-07-03T13:45:06.266 169066   41854     {4:4}
e0175ee0-dc04-11eb-bef5-537733e6a124 system        sstable_activity  2021-07-03T13:45:06.254 1102     224       {1:12, 4:4}
bacb1140-dbeb-11eb-bef5-537733e6a124 system        size_estimates    2021-07-03T10:45:06.260 169604   41922     {4:4}
bac8ee60-dbeb-11eb-bef5-537733e6a124 system        sstable_activity  2021-07-03T10:45:06.246 968      224       {1:8, 3:1, 4:3}
```


## (Section: DS210) -  To figure out the name of a node’s datacenter and rack, which nodetool sub-command should you use? 

* Nodetool info

## (Section: DS210) -  Nodetool gcstats

* Higher the GC Elapsed time is worst performance of the cluster
* Higher StdDev, cluster performance would be erratic

```bash
root@c1bf4c2d5378:/# nodetool gcstats
       Interval (ms) Max GC Elapsed (ms)Total GC Elapsed (ms)Stdev GC Elapsed (ms)   GC Reclaimed (MB)         Collections      Direct Memory Bytes
                 334                   0                   0                 NaN                   0                   0                       -1
root@c1bf4c2d5378:/# nodetool gcstats
       Interval (ms) Max GC Elapsed (ms)Total GC Elapsed (ms)Stdev GC Elapsed (ms)   GC Reclaimed (MB)         Collections      Direct Memory Bytes
                2057                   0                   0                 NaN                   0                   0                       -1
root@c1bf4c2d5378:/# nodetool gcstats
       Interval (ms) Max GC Elapsed (ms)Total GC Elapsed (ms)Stdev GC Elapsed (ms)   GC Reclaimed (MB)         Collections      Direct Memory Bytes
                1307                   0                   0                 NaN                   0                   0                       -1
```

## (Section: DS210) -  Nodetool Gossipinfo

* What is the status of the node according its peer node
* Peer node knows the detaila about another node using 'gossipe-info'
* Schema-Version mismatch can be noted from this output. Rare but crucial information.

## (Section: DS210) -  Nodetool Ring command

* "nodetool ring" is used to output all the tokens of a node.
* nodetool ring -- ks_killr_vide -- for specific keyspace
* 
  ```bash
      root@c1bf4c2d5378:/# nodetool ring -- killr_video | head

      Datacenter: datacenter1
      ==========
      Address     Rack        Status State   Load            Owns                Token
                                                                                9187745666723249887
      172.19.0.3  rack1       Up     Normal  624.25 KiB      100.00%             -9143401694522716388
      172.19.0.3  rack1       Up     Normal  624.25 KiB      100.00%             -9002139349711660790
      172.19.0.3  rack1       Up     Normal  624.25 KiB      100.00%             -8851720287326751527
      172.19.0.3  rack1       Up     Normal  624.25 KiB      100.00%             -8617136159627124213
      172.19.0.3  rack1       Up     Normal  624.25 KiB      100.00%             -8578864381590385349
  ```
* 

## (Section: DS210) -  Nodetool Tableinfo (tablestats) - Quite useful for data-modelling information

* nodetool tablestats -- ks_killr_video
* nodetool tablestats -- ks_killr_video user_by_email
*    ```bash
    root@c1bf4c2d5378:/# nodetool tablestats -- killr_video
    Total number of tables: 37
    ----------------
    Keyspace : killr_video
            Read Count: 3952653
            Read Latency: 2.332187202873614 ms
            Write Count: 12577242
            Write Latency: 0.026214161419490855 ms
            Pending Flushes: 0
                    Table: user_by_email
                    SSTable count: 3
                    Space used (live): 321599
                    Space used (total): 321599
                    Space used by snapshots (total): 0
                    Off heap memory used (total): 5745
                    SSTable Compression Ratio: 0.6803828095486517
                    Number of partitions (estimate): 2468
                    Memtable cell count: 1809586
                    Memtable data size: 103656
                    Memtable off heap memory used: 0
                    Memtable switch count: 3
                    Local read count: 3952653
                    Local read latency: 0.030 ms
                    Local write count: 12577242
                    Local write latency: 0.003 ms
                    Pending flushes: 0
                    Percent repaired: 0.0
                    Bloom filter false positives: 0
                    Bloom filter false ratio: 0.00000
                    Bloom filter space used: 4680
                    Bloom filter off heap memory used: 4656
                    Index summary off heap memory used: 1041
                    Compression metadata off heap memory used: 48
                    Compacted partition minimum bytes: 61
                    Compacted partition maximum bytes: 86
                    Compacted partition mean bytes: 84
                    Average live cells per slice (last five minutes): 1.0
                    Maximum live cells per slice (last five minutes): 1
                    Average tombstones per slice (last five minutes): 1.0
                    Maximum tombstones per slice (last five minutes): 1
                    Dropped Mutations: 6
    ```
*  Table histogram helps to find how much time taken for read/vs/write
```bash    
killr_video/user_by_email histograms
Percentile  SSTables     Write Latency      Read Latency    Partition Size        Cell Count
                              (micros)          (micros)           (bytes)
50%             0.00              0.00              0.00                86                 2
75%             0.00              0.00              0.00                86                 2
95%             0.00              0.00              0.00                86                 2
98%             0.00              0.00              0.00                86                 2
99%             0.00              0.00              0.00                86                 2
Min             0.00              0.00              0.00                61                 2
Max             0.00              0.00              0.00                86                 2
```
## (Section: DS210) -  How to find large partition?

* nodetool tablehistograms ks_killr_video  table -- would give multi-millions cell-count
* nodetool tablehistograms ks_killr_video  table -- would give large partition-size


## (Section: DS210) -  Nodetool Threadpoolinfo (tpstats)

* Early versions of Cassandra were designed using SEDA architectures (now it actually moved away from it)
* If queue is blocked, the request is blocked
* if MemtableFlushWriter is blocked, Cassandra unable to write to disk
  * If blocked, lots of data is sitting in memory, sooner Long-GC might kick-in


## (Section: DS210) -  Cassandra logging

* It is ususally known as system.log (and debug.log only if enabled in logback.xml or using nodetool setlogginglevel )
* java gc.log is also available to investigate gc (garbage collection)
* /var/log/cassandra/system.log
* syste.log (INFO and above)
* logging location can be changed in /etc/dse/cassandra/jvm.options or -DCassandra.logdir=<LOG_DIR>
* default configurations are in /etc/cassandra/logback.xml
* Change logging level for live systems
  * nodetool setlogginglevel org.apache.cassandra.service.StorageProxy DEBUG
  * nodetool getlogginglevel

## (Section: DS210) -  Cassandra JVM GC logging

* GC logging answeres 3 questions
  * When GC occured
  * How much memory reclaimed
  * What is the heap memory before an after reclaim (on the heap)
* GC logging details are configured /etc/cassandra/jvm.options
* Cassandra doesn't use G1 garbage collection

## (Section: DS210) -  How Cassandra JVM GC logging can be configured

* How it was turn it on
  * -Xloggc:/var/log/cassandra/gc.log  (in the cassandra start script)
* -XX:+PrintGC   (refer jvm.options for mroe documentation and options)
* Dynamically alter JVM process GC.log
  * info -flag +PrintGC <process-id>

## (Section: DS210) -  How to read GC.log?

* GC pause in a second or two is big trouble, it should have been in sub-milli-seconds
* Ensure after GC, heap consumption is reduced (number should reduce)

## (Section: DS210) -  Adding a node

* Why to add node? 
  * To increase capacity for operational head-room
  * Reached maxmum h/w capcity
  * Reached maxmum traffic capcity
    * To decrease latency of the application
* How to add nodes for single-token nodes?
  * Always double to capcity of your cluster
  * Token ranges has to bisect each of the existing clutser ranges
* How to add nodes for Vnodes cluster?
  * Add single node in incremental fashion
* Can we add multiple node at the same time?
  * Not recommended, but possible
* What is the impact of adding single node?
  * Lots of data movement into the new-node
  * We may need to remove excess copy for old nodes
  * Will have gradual impact on performance of the cluster
  * Will take longer to grow the cluster
* VNodes make it simple to add node
* Seed - nodes, Any node that is running while adding other nodes. They are not special in any way


## (Section: DS210) -  Bootstrapping (Adding a note)

* We need any existing running nodes as seed-nodes (they are not special nodes)
* (Adding cluster) Topology changes (adding/removing nodes) are not recommended when there is a repair process alive in your cluster
* Cluster-name has to match to join existing cluster


## (Section: DS210) -  What are the steps followed by a boostrapping node when joining?

1. Contact the seed nodes to learn about gossip state.
1. Transition to Up and Joining state (to indicate it is joining the cluster; represented by UJ in the nodetool status).
1. Contact the seed nodes to ensure schema agreement.
1. Calculate the tokens that it will become responsible for.
1. Stream replica data associated with the tokens it is responsible for from the former owners.
1. Transition to Up and Normal state once streaming is complete (to indicate it is now part of the cluster; represented by UN in the nodetool status).

## (Section: DS210) -  What are the help rendered by a existing node to a joining?

* Cluster nodes has to prepare to stream necessary SSTables
* Existing Cluster nodes continue to satisfy read and write, but also forward write to joining node
* Monitor the bootstrap process using 'nodetool netstas'

## (Section: DS210) -  Issues during bootstrap

* New node will certainly have a lot of compactions to deal with(especially  if it is LCS).
* New node should compact as much as before accepting read requests
  * nodetool disablebinary && nodetool disablethrift && nodetooldisablegossip*
    * Above will disconnect Cassandra from the cluster, but not stop Cassandra itself. At this point you can unthrottle compactions and let it compact away.
* We should unthrottle during bootstrap as the node won't receive read queries until it finishes streaming and joins the cluster.

## (Section: DS210) -  If Bootstrap fails

* Read the log and find the reason
* If it Up and failed with 50% data, try to restart.. mostly it would fix itself
* if it further doesn't work, investigate further


## (Section: DS210) -  After Boostrap (Cleanup)

* Nodetool cleanup should be peformed to the other cluster nodes (not to the node that joined)
* Cleans up keyspaces and partition keys no longer belonging to a node. (bootstrapped node would have taken some keys and reduced burden on this node)
* Cleanup just reads all ss-table and throws-away all the keys not belong to the node, worst-case it just copies the sstable as is
* It is almost like Compaction
* nodetool [options] cleanup -- keyspace <table>


## (Section: DS210) -  Removing node

* Why to remove a node?
  * For some event, we ramped-up, need to scale down for legitimate reason
  * Replacing h/w, or faulty node
* We can't just shutdown and leave
* 3 ways to remove the node
  1. Inform the leaving node that, this node would be taken away, so it would redistribute its data to the rest of the cluster
     * nodetool decommission
        * It was properly redistributed
        * Shutting down the port and shutting down process
        * Data still on the disk, but should be deleted if we plan to bring the node back
  1. Inform to the rest of the cluster nodes, that a node was removed/lost
     * nodetool removenode
  1. Inform the node to just leave immediately without replicating any of its data
     * nodetool assasinate  (like kill -9) && nodetool repair (on the rest of the ndoes to fix)
     * Try when it is not trying to go away

## (Section: DS210) -  Where is the data coming from when a node is removed?

* Decommision - Data comes from the node leaving
* RemoveNode - Data comes from the rest of the cluster nodes

## (Section: DS210) -  How to replace a down-node

* Replace vs Remove-and-Add
* Backup for a node will work a replaced node, because same tokens are used to bring replaced node into cluster
* Best option is replace instead of remove-and-add
* -Dcassandra.replace_address=<IP_ADDRESS_OF_DEAD_NODE> // has to change in JVM.options
  * Above line informs cluster that node will have same range of tokens as existing dead node
* Once replaced, we should remove  -Dcassandra.replace_address=<IP_ADDRESS_OF_DEAD_NODE>
* We should update seed-node (remove old node, and update with latest IP), to fix GossipInfo


## (Section: DS210) -  Why replace a node than removing-and-adding?

1. Don't need to move data twice
1. Backup would work for th replaced node (if the token range is same)
1. It is faster and lesser impact on the cluster

## (Section: DS210) -  STCS - Size Tieres Compaction Strategy

* STCS Organizes SSTables into Tiers based on sizes
  * On an exponential scale
* Multiple SSTables would become (larger or smaller)
  * Smaller - when plenty of deltes
  * Largers - Sum of size of smaller SSTables (when there is no delete in smaller sstable)
* Lower-tier means smaller SStables
* Higher-tier means larger SStables
* min_threshold and max_thrshold (number of files within the tier)

## (Section: DS210) -  STCS Pros and Disadvantage

* STCS doesn't compact 1 GB and 1MB file together
  * Avoids write amplification
  * Handles write heavy system very well
* STCS requires of at least twice the data size (Space amplification)
* How do we combine 4 * 128MB file, we require 512MB additional space to combine them (at-least 50%)
* Stale records in Larger SSTables take unnecessary space (old file would take time to catchup)
* Concurrent_Compactors - Failed more often than helping.
* STCS - Major compaction was not recommended for producton (one big large compacted file) - Never do 'nodetool compact'
## (Section: DS210) -  STCS Hotness

* STCS compaction chooses hottest tier first to compact
* SSTable hotness determined by number of reads per second per partition key
## (Section: DS210) -  Wht STCS is slower for read

* If new write is in lower tier, and old values are in higher tier, they can't be compacted together (immediately)

## (Section: DS210) -  What triggers a STCS Compaction

* More write --> More Compaction
* Compaction starts every time a memtable flushes to an SSTable
* MemTable too large, commit log too large or manual flush (Triggering events)
* When the cluster streams SSTable segments to the node
  * Bootstrap, rebuild, repair
* Compaction continues until there are no more tiers with at least min_threshold tables in it  

## (Section: DS210) -  STCS - Tombstones

* If no eligible buckets, STCS compacts a single SSTable
* tombstone_compaction_interval - At-least one day old before considered for Tombstone compaction
* Compaction ensures that tombstones donot overlap old records in other SSTables
* The number of expired tombstones must be above 20%

## (Section: DS210) -  LCS - Leveled Compaction Strategy

* sstable_size_in_mb - Max size of SSTable
  * 'Max SSTable Size' - would be considered like unit size for compaction to trigger
* When there are more than 10 SSTables, they are combined and level is promoted
* Every higher level would be 10times bigger than their lower levels
* LCS - limits space amplification, but it ends in higher write amplification
* L0 - is landing place

## (Section: DS210) -  LCS Pros and Cons

* LCS is best for reads
  * 90% of the data resides in the lowest level
  * Each partition resides in only one table
* LCS is not suitable for more writes than reads, but suits occasional writes but high reads
* Reads are handled only by few SSTable make it faster
* LCS - doesn't require 50% space, it wastes less disk space  

## (Section: DS210) -  LCS - Lagging behind

* If lower levels are two big, LCS falls back to STCS for L0 compaction
* Falling to STCS would helps to create larger SSTable, and compacting two larger SSTable is optimum


## (Section: DS210) -  LeveledCompactionStrategy

* [LCS Cassandra](https://issues.apache.org/jira/browse/CASSANDRA-14605?jql=labels%20%3D%20lcs%20AND%20project%20in%20(Cassandra))

## (Section: DS210) -  TWCS - Time-window compaction strategies

* Best suited for Time-series data
* Windowf of time can be chosen while creating Table
* STCS is used within the timewindow
* Any SSTable that spans two window will be considered for next window
* Not suited for data that is being updated

## (Section: DS210) -  Nodesync (Datastax Enterprise 6.0)

* Continuous background repair
  * only for DSE-6.0 and above
  * Repair - doesn't mean something broken, rather preventing anti-entropy
* Low overhead, Consistency performance, Doesn't use Merkel tree
* Predicatable synchronization overhead, and easier than repair
* 
  ```sql 
    create table mytable (k int primary key) with nodesync = {'enabled': 'true', 'deadline_target_sec: 'true'}; 
    nodetool nodesyncservice setrate <value_in_kb_per_sec>
    nodetool nodesyncservice getrate
  ```
* Parameters
  * Rate -- how much bandwidth could be used (between rate and target --- rate always wins)
  * Target -- (lesser than gc_grace_seconds)
* nodetool nodesync vs dse/bin/nodesync (second binary is cluster-wide tool)

## (Section: DS210) -  What are all the possible reason for large SSTable

* nodetool compact (somebody run it)
  * Major compaction using STCS would create large SSTable
* LCS (over period of time created large SSTable)
* We need to split the file sometime (anti-compaction)
* Warning before using SSTablesplit (don't run on live system)
* 
  ```bash
  sudo service cassandra stop
  sstablesplit -s 40 /user/share/data/cssandra/killr_video/users/*
  ```

## (Section: DS210) -  Multi-Datacenter

* We can add datacenter using `alter keyspace` even before datacenter is available
* Cassandra allows to add datacenter to live system
* conf/cassandra-rackdc.properties
* Snitch is control where the data is.
* NetworkTopologyStrategy - is the one that achieves the distribution (among DC, controlled by Snitch)
* Replication values can be per-datacenter
* DC level information are per keyspace level (not table level)
* 
  ```sql
    alter keyspace killr_video with replication = {'class': 'NetworkTopologyStrategy', 'DC1': 2, 'DC2': 2}
  ```
* nodetool reubuild -- name-of-existing-datacenter
* Run 'nodetool rebuild' specifying the existing datacenter on all the nodes in the new DC
* Without above, request with LOCAL_ONE or ONE consistency level may fail if the existing DC are not completely in sync

## (Section: DS210) -  Multi-Datacenter Consistency Level

* Local_Quorum - TO reduce latency
* Each - Very heavy operation
* Snitch should be specified

## (Section: DS210) -  What if one datacenter goes down?

* Gossip will find that DC is down
* Reocvery can be accomplished with a rolling repair to all nodes in failed datacenter
* Hints would be piling up in other datacenters (that is receiving updates)
* We should run-repair if we go beyond GC_Grace_seconds

## (Section: DS210) -  Why we need additional DC?

* Live Backup
* Improved Performance
* Analytics vs Transaction workload 

## (Section: DS210) -  SSTableDump

1. Old tool, quite useful
1. Only way to dump SSTable into json (for investigation purpose)
1. Useful to diagnose SSTable ttl and tombostone
1. Usage
   1. tools/bin/sstable data/ks/table/sstable-data.db
   1. -d to view as key-value (withtout JSON)

## (Section: DS210) -  SSTableloader

1. sstableloader -d co-ordinator-ip /var/lib/cassandra/data/killrvideo/users/
1. Load existing data in SSTable format into another cluster (production to test)
1. Useful to upgrade data from one enviroment to another environment (migrating to new DC)
1. It adheres to replication factor of target cluster
1. Tables are repaired in target cluster after being loaded
1. Fastest way to load the data
1. Source should be a running node with proper Cassandra.yaml file
1. Atleast one node in the cluster is configured as SEED
1. sample dump
    ```json
    [
      {
        "partition" : {
          "key" : [ "36111c91-4744-47ad-9874-79c2ecb36ea7" ],
          "position" : 0
        },
        "rows" : [
          {
            "type" : "row",
            "position" : 30,
            "liveness_info" : { "tstamp" : "2021-07-06T03:38:20.642757Z" },
            "cells" : [
              { "name" : "v", "value" : 1 }
            ]
          }
        ]
      },
      {
        "partition" : {
          "key" : [ "ec07b617-1348-42b8-afb1-913ff531a24c" ],
          "position" : 43
        },
        "rows" : [
          {
            "type" : "row",
            "position" : 73,
            "cells" : [
              { "name" : "v", "value" : 2, "tstamp" : "2021-07-06T03:39:12.173004Z" }
            ]
          }
        ]
      },
      {
        "partition" : {
          "key" : [ "91d7d620-de0b-11eb-ad2f-537733e6a124" ],
          "position" : 86
        },
        "rows" : [
          {
            "type" : "row",
            "position" : 116,
            "liveness_info" : { "tstamp" : "2021-07-06T03:38:03.777666Z" },
            "cells" : [
              { "name" : "v", "deletion_info" : { "local_delete_time" : "2021-07-06T09:06:57Z" },
                "tstamp" : "2021-07-06T09:06:57.504609Z"
              }
            ]
          }
        ]
      },
      {
        "partition" : {
          "key" : [ "7164f397-f1cb-4341-bc83-ac10088d5bfd" ],
          "position" : 128
        },
        "rows" : [
          {
            "type" : "row",
            "position" : 158,
            "cells" : [
              { "name" : "v", "value" : 2, "tstamp" : "2021-07-06T03:38:56.888661Z" }
            ]
          }
        ]
      }
    ]
    ```

## (Section: DS210) -  Loading different formats of data into Cassandra

1. Apache Spark for Dataloading
1. 
    ```python
    from pyspark import SparkConf
    import pyspark_cassandra
    from pyspark_cassandra import CassandraSparkContext

    conf = SparkConf().set("spark.cassandra.connection.host", <IP1>).set("spark.cassandra.connection.native.port",<IP2>)

    sparkContext = CassandraSparkContext(conf = conf)
    rdd = sparkContext.parallelize([{"validated":False, "sampleId":"323112121", "id":"121224235-11e5-9023-23789786ess" }])
    rdd.saveToCassandra("ks", "test", {"validated", "sample_id", "id"} )
    ```
1. Loading a CSV file into a Cassandra table with validation:
```scala
import com.datastax.spark.connector._
import com.datastax.spark.connector.cql._
import org.apache.spark.SparkContext

//Preparing SparkContext to work with Cassandra
val conf = new SparkConf(true).set("spark.cassandra.connection.host", "192.168.123.10")
        .set("spark.cassandra.auth.username", "cassandra")            
        .set("spark.cassandra.auth.password", "cassandra")
val sc = new SparkContext("spark://192.168.123.10:7077", "test", conf)
val beforeCount = sc.cassandraTable("killrvideo", "users").count
val users = sc.textFile("file:///home/student/users.csv").repartition(2 * sc.defaultParallelism).cache // The RDD is used in two actions
val loadCount = users.count
users.map(line => line.split(",") match {
      case Array(id, firstname, lastname, email, created_date)    => User(java.util.UUID.fromString(id), firstname, lastname, email, new java.text.SimpleDateFormat("yyyy-mm-dd").parse(created_date))
  }
).saveToCassandra("killrvideo", "users")
val afterCount = sc.cassandraTable("killrvideo", "users").count
if (loadCount - (afterCount - beforeCount) > 0)
  println ("Errors or upserts - further validation required")
```

## (Section: DS210) -  Datstax - DSE Bulk (configuration should be in HOCON format)

1. CLI import tool (from csv or json)
1. Can move to and from files in the file-system
1. Why DSE Bulk?
  1. Casandra-loader is not formally supported, SSTableLoader data should be in SSTable format
  1. CQLSH Copy is not performant
  1. Can be used as format for backup
  1. Unload and reformat as different data-model
1. Usage: dsbulk -f dsbulk.conf -c csv/json -k keyspace -t tablename

## (Section: DS210) -  Backup and Snapshots

1. Why do we need your backup for distributed data?
  1. Human error caused data wipe
  1. Somebody thought they are dropping data in UAT, but it was production
  1. Programmatic accidental deletion or overwriting data
  1. Wrong procedure followed and lost data
1. SSTables are immutable, we can just copy them for backup purpose
1. usage - nodetool -h localhost -p 7199 snapshot mykeyspace


## (Section: DS210) -  What is Cassandra snapshots?
1. The DDL to create the table is stored as well.
1. A snapshot is a copy of a table’s SSTable files at a given time, created via hard links.
1. Hardlink snapshots are acting as Point-in-Time backup 
## (Section: DS210) -  Why Snapshots are fast in Cassandra? How to snapshot at the same time?

* It just creates hard-links to underlying SSTable (immutable files)
* Actual files are not copied, hence less (zero) data-movement
* A parallel SSH tool can be used to snapshot at the same time.

## (Section: DS210) -  How do incrementa backup works

* Every flush to disk should be added to snapshots
  * incremental_backup: true --##cassandra.yaml
* Snapshot is required (before incremental backups) in-order for incremental backup to work (pre-requisite)
* Snapshot informations are stored under "snapshots/directory"
* incremental backups  are stored under "backups/directory"
* incremental backups - are not automatically removed (warning would pile-up)
  * These should be manually removed before creating new snapshot

## (Section: DS210) -  Where to store snapshots?

* Snapshots and incremental backups are stored on each cassandra-node
* Files should be copied to remote place (not on node)
  * [tablesnap can store to AWS S3](https://github.com/JeremyGrosser/tablesnap)

## (Section: DS210) -  How Truncate works?

* auto_snapshot is critical, don't disable it
* Helps to take Snapshots, just before table truncation.

## (Section: DS210) -  How to snapshot?

* bin/nodetool snapshot -cf table - t <tag> -- keyspace keyspace2
* [How to snapshot and restore](https://docs.rackspace.com/blog/apache-casandra-backup-and-recovery/)

## (Section: DS210) -  Restore (We get 1 point for backup, 99 point for restore)

* Backup that doesn't help to restore is useless
* Restore should be tested many times and documented properly

## (Section: DS210) -  [Steps to restore from snapshots](https://community.datastax.com/questions/2345/how-to-restore-cassandra-snapshot-to-a-different-k.html)

1. Delete the current data files 
1. Copy the snapshot and incremental files to the appropriate data directories
1. The table schema must already be present in order to use this method
1. If using incremental backups
   1. Copy the contents of the backups/ directory to each table directory
1. Restart and repair the node after the file copying is done
Honorable mention – tablesnap and tablerestore
• Used when backing up Cassandra to AWS S3
## (Section: DS210) -  How to remove snapshots?

* nodetool clearsnapshot <snapshot_name>
  * Not specifying a snapshot name removes all snapshots
* Remember to remove old snapshots before taking new ones, not automatic

## (Section: DS210) -  JVM settings

1. jvm.options can be used to modify jvm settings
1. cassandra-env.sh is a shell that launches cassandra server, that uses jvm.options
1. MAX_HEAP_SIZE : -Xmx8G
1. HEAP_NEW_SIZE : -XX:NewSize=100m
1. Java 9 by default uses G1 Collector


## (Section: DS210) -  Garbage Collections (Apache Cassandra)

* Cassandra on JDK-8 was using CMS
* Decrease Pause-Time, But increase Through-Put
* Eden, S-1, S-2 space
* GC Process - Eden -> Survivor -> S2/S1 (Always one of the survivor space is empty)
* GC Process - Step2 - Eden + Survivor -> S2/S1 (Always one of the survivor space is empty)
* After many young gc, S1/S2 -> Old GC
* CMS kicks in when OldGen is 75% full

## (Section: DS210) -  Why does full GC runs?

* If the old gen fills up before the CMS collector can finish
* Full GC, stop the world collctor checks new-gen, old-gen and perm-gen

## (Section: DS210) -  How to troubleshoot OutOfMemoryError issues in Casssandra?

* -XX:+HeapDumpOnOutOfMemoryError - would dump the entire memory
* Use Eclipse Memory Analyzer tool to analyze the content of memory
* Cassandra puts the file in a subdirectory of the working, root directory when running as a service
* Ensure Cassandra has access to the directory where dump directory was configured, disk should have space to hold this file

## (Section: DS210) -  What is TSC?

* It is a register inside CPU
* Time Stamp Counter (counts the number of cycles), but won't match between processors

## (Section: DS210) -  Tuning the Linux Kernel

* NTP should be in place for Cassandra to agree time within the clusters
  * NTP would adjust from hierarchy of time servers every 1-20 minutes
* Cassandra service requires unfettered access to all resources
* ulimit -a would display all the limits or limits.conf file
* What are all the limits
  1.  -t: cpu time (seconds)              unlimited
  1.  -f: file size (blocks)              unlimited
  1.  -d: data seg size (kbytes)          unlimited
  1.  -s: stack size (kbytes)             8176
  1.  -c: core file size (blocks)         0
  1.  -v: address space (kbytes)          unlimited
  1.  -l: locked-in-memory size (kbytes)  unlimited
  1.  -u: processes                       2666
  1.  -n: file descriptors                256
  1.  -msgqueue  unlimited
  1.  -sigpending unlimited

## (Section: DS210) -  What should be removed/disabled from Linux for Cassandra to work? How to remove

* swapping should be removed in linux from two places
* swapoff -a (not permanently)
* /etc/fstab should be edited to disable swapping
* edit /etc/sysctl.conf and set vm.swappines=0
  * sysctl -p should reload /etc/sysctl.conf
* Refer datastax for other recommended linux settings  

## (Section: DS210) -  Hardware resources to consider

1. Parameters
  * Peristent type
  * Memory (16GB to 32GB)
  * CPU (16 Core is best for value)
  * Network (OS should use separate NIC, shouldn't share with Cassandra)
    * Cassandra.yaml supports different NIC for CQL and inter-node
  * Number of nodes
1. Don't allow
  * SAN/NAS/NFS
1. SSDs are prefered
  * 0.50 USD/GB vs 0.05 USD/GB
  * TWCS - can use HDD
  * HDD should be backed with more memory

## (Section: DS210) -  Datastax on Cloud

* Templates and scripts to install DSE on cloud
* OPSCenter LCM 6.0+ (Lifecycle manager)
  1. Provisioning (installation and config)
  1. Configuration management
  1. Chef, Ansible, Recipes playbook out there for DSE OPSCenter
* Always prefer locally attached SSD
* If Elastic storage is the only option (on cloud)
  1. When ephemeral volume fails, terminate and get a fresh box
* AWS
  1. GP2 or IO2 EBS (if you can't affort ephemerals)
  1. Get big ones, IO latencies are better for larger disk volumes
* Google
  1. Elastic volume always have the same tight latencies
  1. pd-ssd seems faster than local-ssd  

## (Section: DS210) -  Cassandra on Cloud Challenges

* Hyeperthreads - you don't get a real CPU
* Noisy neighbors - if you see CPU steal, terminate your box and get a new one
* Networking
  * AWS VPN - Setup cross region network
    * Prefer Enhanced networking, supported only for few instance
  * Azure - Do not use VPN gateways, use public IPs, Vnet2Vnet is slow but works for small workloads
  * Google - Flat network - No config, it's great

## (Section: DS210) -  Cassandra on cloud security

* AWS - volume encryption for EBS
* Google - largely secure by default. Should go through multifactor auth

## (Section: DS210) -  Cassandra Security Considerations

* Authentication and Authorization (Covered in DS410)
* Authentication in disabled by default
  * Enable the authentication in dse.yaml
  * DSEAuthenticator (supports 3 schemes)
    * Kerberos
    * Ldap
    * Internal
  * Default superuser comes with datastax - user-id and password (cassandra/cassandra)
  * ALTER change cassandra WITH PASSWORD 'newpassword'
* Cassandra stores all the credentials in the sys_auth keyspace

## (Section: DS210) -  What is the default security configuration

```yaml
authentication_options:
  enabled: false
  default_scheme: internal
  allow_digest_with_krb: true
  plain_text_without_ssl: warn
```

## (Section: DS210) -  Where is roles are stored in internal-scheme? (in default scheme)

* ALTER keyspace system_auth with replication {'class' : 'NetworkTopologyStrategy', 'dc': 1 , 'dc': 3} 
* All the roles are stored in system_auth.roles table

## (Section: DS210) -  Cassandra Authentication table (system_auth.roles - in default scheme)

* 
  ```sql
    CREATE table system_auth.roles (role text primary key, can_login boolean, is_superuser boolean, number_of set<text>, salted_hash text)
    CREATE ROLE fred with PASSWORD = 'Yababdadfdfd' and LOGIN = true;
    if LOGIN=TRUE --- user
    if LOGIN=FALSE --- role
    LIST roles;
    DROP role fred;
  ```
* salted_hash is password

## (Section: DS210) -  What are best practices for Cassandra security

1. Create one more superuer_role and delete the default cassandra super-user
  1. At least change the password for default super-user 'cassandra'
  1. ALTER USER cassandra WITH password 'newpassword'
1. Ensure system_auth keyspace should be replicated to multiple datacenter

## (Section: DS210) -  Cassandra Role/Authorization management

```sql
    Grant Select ON killr_video.user_by_email TO user/role;
    Grant Select ON killr_video.user_by_email TO fred;
    Create Role DB_Accessors;
    Grant Select ON killr_video.user_by_email to db_accessors;
    Grant db_accessors to fred;
    REVOKE SELECT FROM db_accessors;
    Permissions 
    * Create Keyspace, Create Table, 
    * DDROP - Drop..
    * MODIFY - 
    * Alter -
    * Authorize - 
```

## (Section: DS210) -  Cassandra encryption SSL

* node-to-node
* client-to-node
* SSL
  * client-symmeteric key would be used to communicate, client-key is encrypted by server public key (typical SSL)
  * Keystore - signed key-pair (private/public key pair)
  * Truststore - RCA (root certificate authority) for signed certificate validation
* Inter node communiation
  * Nodes present their certificate from keystore to other nodes
  * Other nodes validate the certicate using their trust-store RCA details

## (Section: DS210) -  What are two artifacts required for Cassandra to enable SSL

1. TrustStore (all the trusted certificate- ROOT CA)
   1. This is common among all the Cassandra nodes
1. Keystore (key-pair, its own signed certificate)


## (Section: DS210) -  8 Steps for SSL setup (node-to-node)

1. Create Root Cert  (Root of entire SSL communication)
   1. Root Cert = "CA_KEY" + "Root Cert"
1. Create keyStore w/Key pair (for each node)
   1. KeyStore
1. Export Signing Req (Each nodes certificate sign request)
1. Sign the certificate using Root-CA
   1. To Sign new certificate using root-CA, we need both CA-KEY + Root-Cert
1. Import RootCert into keyStore
1. Import Singed Certificate into keyStore
7. Create Turst Store
   1. Use RootCA to authenticate incoming Connections.
*  Credit-Datastax ![SSL](img/SSL_STEPS_Datastax.png) "Credit-Datastax-SSL"
* [Cassandra Security Configuration](./cassandra_security_configuration.pdf)
   1. [Credit: SSL Configuration](https://www.slideshare.net/BrajaDas/cassandra-security-configuration?from_action=save)

## (Section: DS210) -  How to harden Cassandra security

1. Secure the keystore - since this contains private key
1. Setup firewasll so that only nodes can talk to each other on the listen_port
1. Protect the root CA private key - this Not be disbuted to the nodes
1. Enable require_client_auth, otherwise program could spoof being a node

## (Section: DS210) -  Datastax OpsCenter

1. Two Products
1. Configure and deploy cluster
1. Configure Security
1. Perform software upgrades
1. Load Certificate

## (Section: DS210) -  Datastax OpsCenter (Cluster Monitoring/Alert)
1. Monitoring and management (Operation)
1. Broswer -> OpsCenter Service -> Agent running inside DataStax Cassandra JVM (exposed via JMX)
1. UI features
   1. Dashboard
   1. Metrics
   1. Alerts
   1. Trend/Capacity analysis
   1. Performance service
1. Comprehensive Grafana like dashboard

## (Section: DS210) -  Datastax OpsCenter (Management Service)

1. Backup & Restore Service
1. NodeSync Service
1. Repair Service
1. Best Practices Service
1. Capacity Service

## (Section: DS210) -  Datastax OpsCenter (Backup and restore Service)

1. Visual backup management
1. Backup & Restore on distributed system is hard
1. Support for multi-cloud backup and restore option
1. Enterprise-class visual backup service guards against data loss on managed database clusters
1. Backup Destination
    1. Local server
    1. Amazon S3
    1. Custom Location
1. Compresses data
1. Configurable retention polcies
1. Includes alerts and reporting


## (Section: DS210) -  Datastax OpsCenter LifeCycle Manager (Provisioning)

1. Configuration and deployment (Onboarding)
1. UI Menu has option for
  1. SSH Credentials
  1. Repositories (download software from datastax)
  1. Config Profiles
  1. Add DC/Nodes/Clusters
1. Point in time backup & restore

## (Section: DS210) -  Datastax OpsCenter NodeSync

1. Prefered over repair service
1. Low intensity continuous repair

## (Section: DS210) -  Datastax OpsCenter other features

1. Best Practice service - periodically audits, alerts and suggests solution
1. Capacity service - Used to forecast metrics, configurable for multiple parameters
1. Performance Service - Diagnose table performance, query performance, ThreadPool stats
1. Datastax DSE uses one thread per core (and tries to avoid ThreadPools)
1. Alerts - Integreated into Enterprise Monitoriing system
    1. Post request
    1. Mail
    1. SNMP - to an enterprise monitoring system

## (Section: DS210) -  Follow-up course

1. DS-220 - Practical application modelling with Apache Casssandra
1. DS-310 - DataStax Enterprise Search
1. DS-320 - DataStax Enterprise Apache Sparx
1. DS-330 - DataStax Enterprise Graph

## (Section: DS210) -  Lab notes

* 172.18.0.2
* /usr/share/dse/data
* /var/lib/cassandra/data
* DS-220 


## (Section: DS210) -  Cassandra people

* [Jamie King](https://twitter.com/mrcompscience)
* [Jonathan Ellis](https://twitter.com/spyced)
* [Patrick McFadin](https://twitter.com/patrickmcfadin?lang=en)
* 
## (Section: DS210) -  How to create anki from this markdown file

```
mdanki Cassandra_Datastax_210_Anki.md Cassandra_Datastax_210_Anki.apkg --deck "Mohan::Cassandra::DS210::Operations"
```



