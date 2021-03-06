## What is repair?

* Repair ensures that all replicas have identical copies of a given partition
* Data won't be in sync due to eventual consistency pattern, Merkel-Tree based reconciliation would help to fix the data.
* It is also called anti-entropy repair.
* [Cassandra reaper](http://cassandra-reaper.io/) is famous tool for scheduling repair
* Reaper and nodetool repair works slightly different
* Reaper repair mode
  * sequential
  * requiresParallelism  (Building merkle-tree or validation compaction would be parallel)
  * datacenter_aware
    * It is like sequential but one node per each DC

## Repair Service (on OpsCenter)

1. Runs in the background
1. Works on small chunks to limit performance impact
1. Continuously cycles within a specified time period
1. Can run in parallel
1. Can work on sub-ranges or incremental

## Repair command

* 
  ```bash
  nodetool <options> repair
  --dc <dc_name> identify data centers
  --pr <partitioner-range> repair only primary range
  --st <start_token> used when repairing a subrange
  --et <end_token> used when repairing a subrange
  ```

## Why repairs are necessary?

* Nodes may go down for a period of time and miss writes
  * Especially if down for more than max_hint_window_in_ms
* If nodes become overloaded and drop writes
* if dropped mutation is high repair was missing in its place

## Repair guideline

* Make sure repair completes within gc_grace_seconds window
* Repair should be scheduled once before every gc_grace_seconds

## What is Primary Range Repair?

* The primary range is the set of tokens the node is assigned
* Repairing only the node's primary range will make sure that data is synchronized for that range
* Repairing only the node's primary range will eliminate reduandant repairs

## How does repair work?

1. Nodes build merkel-trees from partitions to represent how current data values are
1. Nodes exchange merkel trees
1. Nodes compare the merkel trees to identify specific values that need synchronization
1. Nodes exchange data values and update their data

## Events that trigger Repair

* 'CL=Quorum' - Read would trigger the repair
* Random repair (even for non-quorum read)
  * read_repair_chance
  * dclocal_read-repair_chance
* Nodetool repair - externally triggered

## Dropped Mutation vs Repair


## If 10 nodes equally sharing data with RF=3, if we try to repair 'nodetool repair on node-3', How many node will be involved in repair?

* 5 nodes.
* Node-3 will replicate its data to 2 other nodes (N3 (primary) + N4 (copy-1)  + N5 (copy-2) )
* Node-1 would use N3 for copy-2
* Node-2 would use N3 for copy-1

## How to specifically use only one node to repair itself

* nodetool -pr node-3 --But we have to run in all the nodes immediately
* runing nodetool -pr on only one node is **not-recommended**

## If we run full repair on a 'n' node cluster with RF=3, How many times we are repairing the data?

* We repair thrice.


## Developer who maintains/presented about Reaper

* [Alexander Dejanovski](Alexandar Dejanvoski)
* [Real World Tales of Repair (Alexander Dejanovski, The Last Pickle) | Cassandra Summit 2016](https://www.slideshare.net/DataStax/real-world-tales-of-repair-alexander-dejanovski-the-last-pickle-cassandra-summit-2016)

## Repair documentation

* [All the options of nodetool-repair](https://cassandra.apache.org/doc/latest/tools/nodetool/repair.html#nodetool-repair)
* [Cassandra documentation](https://cassandra.apache.org/doc/latest/operating/repair.html)
* [Datastax documentation](https://docs.datastax.com/en/cassandra-oss/3.x/cassandra/tools/toolsRepair.html)

## Repair and some number related to time

* First scheduled repair would always take more time
* Repair scheduled often generally completes faster, since there are less data to repair
* Few reported - it took 308+ hours to complete repair on 2.1.12 version
* With 3 DC with 12 nodes, 4 tb of a keyspace took around 22 hours to repair it.

## What are Reaper settings

* Segments per node
* Tables
* Blacklist
* Nodes
* Datacenters
* Threads
* Repair intensity

## Reaper is predominantly used for repair tasks

* Reaper uses concept called segments (despite in Cassandra world Segment means CommitLog)
* As per Reaper, you need to use a segment for every 50mb, 20K Segment for every 1 TB
* Smaller the segement, let reaper to repair it faster

## Repair related commands

```bash
nodetool repair -dc DC ## is the command to repair using nodetool
nodetool -h 1.1.1.1 status
```

## Reference

* [Repair Improvements in Apache Cassandra 4.0 | DataStax](https://www.youtube.com/watch?v=kl2ea0Cxmi0)
* [Apache Cassandra Maintenance and Repair](http://datastax.com/dev/blog/repair-in-cassandra)
* [DSE 6.8  Architecture Guide, About Repair](https://docs.datastax.com/en/dse/6.8/dse-arch/datastax_enterprise/dbArch/archAboutRepair.html)
* [Real World Tales of Repair (Alexander Dejanovski, The Last Pickle) | Cassandra Summit 2016](https://www.slideshare.net/DataStax/real-world-tales-of-repair-alexander-dejanovski-the-last-pickle-cassandra-summit-2016)
* [Repair](https://cassandra.apache.org/doc/latest/operating/repair.html)

## How to create anki from this markdown file

```
mdanki cassandra_repair_anki.md cassandra_repair_anki.apkg --deck "Mohan::Cassandra::Repair::doc"
```
