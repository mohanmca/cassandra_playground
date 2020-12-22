## How to create anki from this markdown file

```
mdanki cassandra_definitive_guide_anki.md cassandra_definitive_guide.apkg --deck "Mohan::Cassandra::DefinitiveGuid"
```

## Datbase history

* 1968-IMS (DBI/DB1) 
* 1979-DB2 (E.F Cod 1970s), RDBMS relational model (not working system, just theoratical model)
* Traditionally RDBMS supports locks, locks helps to maintain consistency but reduces access/availability to others
* Journal or WAL log files are used for rollback or atomic-commit in RDBMS, journal sometime switched of to increase performance
* Codd provided a list of 12 rules (0-12, actually 13 :-)) in ComputerWorld Magazine in 1985 (15 years later from original paper)
* ANSI SQL - 1986

## Why RDBMS is successful?

* SQL
* Atomic Transaction with ACID properties
* Two-phase commit was marketted well (Co-ordinated txn)
* Rich schema

## What is the alternative for Two-phase commit

* Compensation or compensatory action
* Writing off the tranaction if it fails, deciding to discard erroneous transactions and reconciling later
  * Won't work on trading or reservation system
* Retry failed operation later on notification
* "Starbucks does not use Two-phase commit" - Gregor Hohpe

## How to horizontally scale RDBMS (shard)

* Shard the database, (key for sharding is important)
* Split the customer based on name (few letter has less load)  or according to phone-number or dob
* Host all the data that begins with certain letter in different database
* Shard users in one database, items in another database

## There are three basic strategies for determining shard structure:

* Feature-based shard or functional segmentation
  * Shard users in one database, items in another database
* Key-based sharding
  * Hash based sharding
  * time-based on numeri-ckeys to hash on
* Lookup table
  * Make one of the noe as "Yellow-pages", look-up for information about where the data stored

## Shared nothing

* Sharding could be termed a kind of shared-nothing architecture that’s specific to databases
* Shared-nothing - no primary or no-secondary
* Every node is independent
* No centralized shared state
* Cassandra (key-based sharding) and MongoDB - Autho sharding database


## New SQL (Scalable ACID transactions)

* Calvin transaction protocol vs Google’s Spanner paper
* FaunaDB is an example of a database that implements the approach on the Calvin paper
* 

## What is anti-entropy repair?

* List of chained security filtered beans

## What are operational mechanics taht affects how you application configuration for data consistency?


## Failure boundaries of Cassandra

*

## cluster topology of Cassandra

* Cassandra cluster topology is the arrangement of the nodes (dcs, racs, etc.) and communication network between them.
* Snitch teaches  Cassandra enough about your network topology
* cassandra-topology.properties can be used to configure topology details


## CQL - Primary key and Clustering key

```
PRIMARY KEY (("k1", "k2"), "c1", "c2"), ) WITH CLUSTERING ORDER BY ("c1" DESC, "c2" DESC);
```

## CQLSH - useful
* CQL would use Murmur3 partitioner
* Minimum token is -9223372036854775808 (and maximum token is 9223372036854775808).
* ```sql
     cassandra@cqlsh:system_schema>
     SELECT * FROM system_schema.keyspaces;
     desc KEYSPACE Keyspace_Name;
     select token(key), key, my_column from mytable where token(key) >= %s limit 10000;```


## How to remove node using nodetool

* Decommission - Streams data from the leaving node (prefered and guaranteed consistency as if it started)
* Removenode -  Streams data from any available node that owns the range

## Cassandra linux limits

* if cassandra has 30 sstables, it would use 30 * 6 - 180 file handles
* XX:MaxDirectMemorySize - we can set off-heap memory (outside JVM on OS)
* 

## Cassandra troubleshoot linux commands

```bash
cat /proc/cass_proc_id/limits | grep files
```


## How does cassandra-topolgoy.properties look alike

```txt
# datacenter One

175.56.12.105=DC1:RAC1
175.50.13.200=DC1:RAC1
175.54.35.197=DC1:RAC1

120.53.24.101=DC1:RAC2
120.55.16.200=DC1:RAC2
120.57.102.103=DC1:RAC2

# datacenter Two

110.56.12.120=DC2:RAC1
110.50.13.201=DC2:RAC1
110.54.35.184=DC2:RAC1

50.33.23.120=DC2:RAC2
50.45.14.220=DC2:RAC2
50.17.10.203=DC2:RAC2

# Analytics Replication Group

172.106.12.120=DC3:RAC1
172.106.12.121=DC3:RAC1
172.106.12.122=DC3:RAC1

# default for unknown nodes 
default=DC3:RAC1
```

## Cassandra failures and solutions

* java.lang.OutOfMemoryError: Map failed` - Almost always incorrect user limits - check ulimit -a 
  * Check the values of max memory size and virtual memory
* 

## Scaling Quotes

* If you can't split it, you can't scale it.
* No sane pilot would take off in an airplane without the ability to land, and no sane engineer would roll code that they could not pull back off in an emergency
* Management means measurement, and a failure to measure is a failure to manage.

## Performance Quotes

“The recommendation for speeding up .... is to add cache and more cache. And after that add a little more cache just in case.”
“When something becomes slow it's a candidate for caching.”
“LRU policy is perhaps the most popular due to its simplicity, good runtime performance, and a decent hit rate in common workloads.”


## Reference

* [E.F Codd paper](https://www.seas.upenn.edu/~zives/03f/cis550/codd.pdf)
* [The Case for Shared Nothing - Michael Stonebraker](https://dsf.berkeley.edu/papers/hpts85-nothing.pdf)

## rough (throw-away)


