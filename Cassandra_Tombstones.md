## What are Tombstones?

* Dead cells (columns/rows) are kept it memory and disk, for other other nodes to aware about dead cells for 10-days.
* When rows are queried, query has to scan over multiple expired cells/rows to get to the live cells


## What are all the majore issues due to Tombstones

* Often query read ends up in timesout
* Memory is occupied by dead-cells
* Rarely TombstoneOverwhelmException happens


## How to agressively collect tombstones (to resolve few of the query timeout tactical solution)

1. tombstone_threshold ratio to 0.1
1. unchecked_tombstone_compaction: true
1. min_threshold: 2 (Compaction would be triggered for just 2 similar sized SSTables)


## Where is Tombstones are handled?

* Tombstones are handled part of Compaction
* [AbstractCompactionStrategy](https://github.com/apache/cassandra/blob/cassandra-3.11/src/java/org/apache/cassandra/db/compaction/AbstractCompactionStrategy.java)
    *  protected boolean worthDroppingTombstones(SSTableReader sstable, int gcBefore)
    *
        ```java
            System.currentTimeMillis() > sstable.getCreationTimeFor(Component.DATA) + tombstoneCompactionInterval * 1000
            AND
            double droppableRatio = sstable.getEstimatedDroppableTombstoneRatio(gcBefore);
            if (droppableRatio > tombstoneThreshold=0.2f) 
        ``` 