## What are basic requirements for MultiDC Configurations?

* Proper snitch that understands racks (AWSSnitch, GCPSnitch)
 * SimpleStrategy doesn't understand racks or DCs. 
* NetworkStrategyToplogy
* Use either LOCAL_QUORUM or QUORUM.

## Multi-DC Presentations

* [Multi-Datacenter Essentials (Julien Anguenot) | C* Summit 2016](https://www.slideshare.net/DataStax/apache-cassandra-multidatacenter-essentials-julien-anguenot-iland-internet-solutions-c-summit-2016)


## Multi-DC Performance

* Reading and writing with local_quorum should not be a problem in terms of performance if all data centers are healthy. 
* But Quorum queries will take hit due to network latency
* Larger number of DCs - Read performance latency issue
    * Global quorum queries (and queries with cross-dc probabilistic read repair) may touch more DCs and be slower, and read-repairs during those queries get more expensive.
    * Your write consistency and network quality matters a ton for read repairs. 
    * During the read, the coordinator will track which replicas are mismatching, and build mutations to make them in sync - that buildup will accumulate more data if you're very out of sync. 
* Larger number of DCs - Repair memory performance issue
    * The anti-entropy repairs do pair-wise merkle trees. 
    * If you imagine 6, 8, 12 datacenters of 3 copies each, you've got 18, 24, 36 copies of data, each of those holds a merkle tree.
    * Repair coordinator will have a lot more data in memory (adjusting the tree depth in newer versions, or using the offheap option in 4.0) starts removing the GC pressure on the coordinator in those types of topologies.
    * In older versions, using subrange repair and lots of smaller ranges will avoid very deep trees and keep memory tolerable.
* Larger number of DCs - Repair streaming performance latency issue
    * ALSO, when you do have a mismatch, you're going to stream a LOT of data.  
    * in 12x3, if one replica goes down beyond the hint window, when it comes up it's getting 35 copies of data,
    * Abovew would overwhelm node that has resurrected when it streams and compacts.


## Multi-DC failover

* Repairs only after a node/DC/connection is down for more then max_hint_window_in_ms
* 

## Is 1PB data managable using Cassandra, What is the problem with larger ndoes (beyond 4 TB)

* Yes! Add as many nodes as possible rather adding larger nodes (don't cross 4TB)
* The main problems (for larger nodes) tend to be streaming, compaction, and repairs when it comes to dense nodes.


## Can we add multiple nodes in different DC (or same DC) at the same time

* Discouraged to add multiple nodes at the same time
* Theoratically possible! Not recommended

## Is it recommended to logically split DC (one and only DC) into logical DC and gain performance to reduce ACK?

* No! Reduce the number of nodes within DC to reduce ACK.

## data centers / DCS / " DC "

