## How to create anki from this markdown file

```
mdanki cassandra_repair_anki.md cassandra_repair_anki.apkg --deck "Mohan::Cassandra::Repair::doc"
```

## Developer who maintains/presented about Reaper

* [Alexander Dejanovski](Alexandar Dejanvoski)
* [Real World Tales of Repair (Alexander Dejanovski, The Last Pickle) | Cassandra Summit 2016](https://www.slideshare.net/DataStax/real-world-tales-of-repair-alexander-dejanovski-the-last-pickle-cassandra-summit-2016)

## Repair documentation

* [Cassandra documentation](https://cassandra.apache.org/doc/latest/operating/repair.html)
* [Datastax documentation](https://docs.datastax.com/en/cassandra-oss/3.x/cassandra/tools/toolsRepair.html)
## What is repair?

* Data won't be in sync due to eventual consistency pattern, Merkle-Tree based reconciliation would help to fix the data. It is also called anti-entropy repair. [Cassandra reaper](http://cassandra-reaper.io/) is famous tool for scheduling repair
* reaper and nodetool repair works slightly different
* Reaper Repair mode
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

* nodetool repair -dc DC ## is the command to repair using nodetool
* nodetool -h 1.1.1.1 status
* 

## Reference

* [Repair Improvements in Apache Cassandra 4.0 | DataStax](https://www.youtube.com/watch?v=kl2ea0Cxmi0)
* [Apache Cassandra Maintenance and Repair](http://datastax.com/dev/blog/repair-in-cassandra)
* [DSE 6.8  Architecture Guide, About Repair](https://docs.datastax.com/en/dse/6.8/dse-arch/datastax_enterprise/dbArch/archAboutRepair.html)
* [Real World Tales of Repair (Alexander Dejanovski, The Last Pickle) | Cassandra Summit 2016](https://www.slideshare.net/DataStax/real-world-tales-of-repair-alexander-dejanovski-the-last-pickle-cassandra-summit-2016)
* [Repair](https://cassandra.apache.org/doc/latest/operating/repair.html)