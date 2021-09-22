## (Section: Consistency) - CAP Theorem (Consistency)

* CAP Theorm and Consistency
* Cassandra fits into AP system, doesn't promise Consistency
  * Cassandra supports partition tolerance and availability
  * Cassandra promises tunable Consistency
  * Consistency can be controlled for each and every read/request independently
* Consistency is harder in distributed systems

## (Section: Consistency) - Consistency Levels

* CL = Consistency-Number (Number of replication count for current transaction)
  * CL=1 = A node that stored data in commit-log and memtable
  * CL=ANY = Data is note is not stored in any node, but just handed over to co-ordinator node.
  * CL=Quorum = 51% of the nodes acknowledged that it wrote
  * CL=ALL, Highest consistency and reduce the availability
* CL=Quorum (both read and write) - is considered strongly consistent
* CL=ONE (Quite useful)
  * Log-data
  * TimeSeries data
  * IOT
* CL=ALL
  * Most useless (Entire cluster might stop... should use only after quite thoughtful conversation)
  * Transaction would fail and failure rate would directly proportional to number of nodes and its network failures
* Cross DC Consistency
  * Strong replication with consistency
  * Remote Coordinator
  * Quorum is heavy (for Cross-DC), It has to consider all the nodes across all the DC's  
  * Local-Quorum (Remote coordinator would not consider for remote Quorum)
    * Not considered remote DC Quorum in Local Quorum
* Any < One/Two/Three < Local_One < Local_Quorum < Quorum < Each_Quorum  < ALL (from weak to strong consistency)

## Write only consistencies

* Each_Quorum - Quorum of nodes in each data-center, applies to write only
* CL=ANY, used only for write (not for read)


## (Section: Consistency) - What is Each_Quorum

* Quorum of nodes in each data-center, applies to write only
* Not many application uses it

## Consistency Design Thoughts - App infra level layer should handle need to failover

1. If application can't connect to local_dc, it is useless to connect to remote-dc
1. Even if it connects, how come application can ensure local consistency
1. App infrastructure should have redundancies at the front end which would decide when to failover at the app layer
1. 