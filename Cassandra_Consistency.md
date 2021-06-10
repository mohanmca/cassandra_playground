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