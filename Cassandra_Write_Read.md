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
* 

## Read Repair (Happens only when CL=All)

* Over-time nodes goes out-of-sync
* Every write chooses between availablity and consistency
* When we choose availablity over consistency
  * We also agree that some inconsistency between server, they becomes out-of-sync
* When Co-ordinator observes data between 3 cluster is not valid, it does in following sequence
    1. Request all nodes to return latest copies of data
    1. Every cell (column) has latest timestamp, Finds the latest timestamp data and latest copy is chosen as valid
    1. It sends latest copies to two other node for them to udpate
    1. Responds to client with latest result

## Read Repair Chance (when CL < ALL) (less than ALL consistency read)

* Cassandra does read-repair even for request less than ALL, But not 100% but probablistically
  * Probability is configurable
  * dclocal_read_repair_chance  - (0.1 -- 10%)
  * read_repair_chance
* Client can't be sure if data is latest or replicas are in sync
* Read repair done asynchronously in the background

## Nodetool repair

* It is the last line of defence for to improve consistency within stored data
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