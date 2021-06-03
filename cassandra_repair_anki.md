## How to create anki from this markdown file

```
mdanki cassandra_repair_anki.md cassandra_repair_anki.apkg --deck "Mohan::Cassandra::Repair::doc"
```

## What is repair?

* Data won't be in sync due to eventual consistency pattern, Merkle-Tree based reconciliation would help to fix the data. It is also called anti-entropy repair. [Cassandra reper](http://cassandra-reaper.io/) is famous tool for scheduling repair
* reper and nodetool repair works slightly different
* Repair mode
  * sequential
  * requiresParallelism  (Building merkle-tree or validation compaction would be parallel)
  * datacenter_aware
    * It is like sequential but one node per each DC

## Some weird facts about repair

* Few reported such that it took 308+ hours to complete repair on 2.1.12 version
* 

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



## Repair and some number related to time

* With 3 DC with 12 nodes, 4 tb of a keyspace took around 22 hours to repair it.
* 

## Repair related commands

* nodetool -dc DC ## is the command to repair using nodetool
* nodetool -h 1.1.1.1 status
* 

## Reference

* [Apache Cassandra Maintenance and Repair](http://datastax.com/dev/blog/repair-in-cassandra)
* [DSE 6.8  Architecture Guide, About Repair](https://docs.datastax.com/en/dse/6.8/dse-arch/datastax_enterprise/dbArch/archAboutRepair.html)
* [Repair](https://cassandra.apache.org/doc/latest/operating/repair.html)