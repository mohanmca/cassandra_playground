## (Section: Performance) -  Performance could be degraded for many reasons

* nodetool status  - check all nodes are up
* nodetool tpstats - for dropped messages
  * Usage statistics of thread-pool

## (Section: Performance) -  Dropped Mutataions

* Cassandra uses SEDA architecture
  * If messages inside the are not processed with certain timeout under heavy load, they are dropped
  * If cross node is slow, it doesn't receive message fast enough, would be another cause for dropping of messages.
  * Mutations are also dropped when a node's commitlog disk cannot keep up with the write requests being sent to it. The write operation in this case is "missed" and considered a failure by the coordinator node.
* High number of dropped mutation would cause query timeout
  * This indicates data writes may be lost
* Dropped mutations are automatically recovered by repair/read_repair
* Mutation Drop could happen within same node or cross nodes.
   * INFO  [ScheduledTasks:1] 2019-07-21 11:44:46,150  MessagingService.java:1281 - MUTATION messages were dropped in last 5000 ms: 0 internal and 65 cross node. Mean internal dropped latency: 0 ms and Mean cross-node dropped latency: 4966 ms
* Monitor the iostat and write request for over a period to confirm if traffic is increasing

## (Section: Performance) -  Configuration that affects dropped mutations

* write_request_timeout_in_ms - How long the coordinator waits for write requests to complete with at least one node in the local datacenter. Lowest acceptable value is 10 ms.
* it is milli-seconds, hence every 1000 ms - should be considered as 1 second

* cross_dc_rtt_in_ms - How much to increase the cross-datacenter timeout (write_request_timeout_in_ms + cross_dc_rtt_in_ms) for requests that involve only nodes in a remote datacenter. This setting is intended to reduce hint pressure.

## (Section: Performance) -  When does Cassandra end up having useless data

* If we reduce the replication factor, additional un-necessary data may be sitting till the actual compaction happens
* Once we add new node to reduce the token range, Cassandray may contain data from portions of token ranges it no longer owns

## (Section: Performance) -  How to find the largest SSTable (or largest partition) in the cluster

* nodetool tablehistograms keyspaces.table
* find the max value


## (Section: Performance) -  Usage statistics of thread-pool - output

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