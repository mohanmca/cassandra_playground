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



## Cassandra in 50 Words or Less

* “Apache Cassandra is an open source, distributed, decentralized, elastically scalable, highly available, fault-tolerant, tuneably consistent, row-oriented database. Cassandra bases its distribution design on Amazon’s Dynamo and its data model on Google’s Bigtable, with a query language similar to SQL"

## Cassandra features

* It uses gossip protcol (feature of peer-to-peer architecture) to maintain details of other nodes.
* It allows tunable cosistency and client can decide for each write/read (how many RF?)
* You can remove one column value alone in Cassandra

## Cap Theorem (Brewer's theorem)

* CAP - Choose two (as of 2000)
* Network issue would certainly happens, hence network partition failures is un-avoidable, And should be handled. Hence choose between compromise on A or C (Availablity or consistency)
* CA -  MySQL, Postgres, SQL
* CP -  Neo4j, MongoDB, HBase, BigTable
* AP -  DNS, Cassandra, Amazon Dynamo



## Consistencey levels

* Strong consistency (sequential consistency)
  * “Rather than dealing with the uncertainty of the correctness of an answer, the data is made unavailable until it is absolutely certain that it is correct.”
* Casual consistency (Happens before)
* Eventual consisteny (matter of milli-seconds)

## Row-Oriented (Wide column store)

* Partitioned row store - sparse multidimensional hash tables
* Partitioned - means that each row has a unique partition key used to distribute the rows across multiple data stores.
* Sparse - not all rows has same number of columns
* Cassandra stores data in a multidimensional, sorted hash table.
* As data is stored in each column, it is stored as a separate entry in the hash table.
* Column values are stored according to a consistent sort order, omitting columns that are not populated.


## Cassandra - schema free?

* Started as schema free using Thrift API, later CQL was introduced
* No! Till 2.0 CQL and Thrit API co-exist, It was known as "Schema Optional"
* From 3.0, Thrift API is deprecated, and from 4.0 Thrif API is removed
* Additional values for columns can be added using List, Sets and Maps
  * Now-a-days it is considered flexible-schema
* Schema free -> "Optional Schema" -> "Flexible Schema"  

## Cassandra - use-cases?

* Storing user activity updates
* Social network usage, recommendations/reviews, 
* Application statistics
* Inverted index for document searching
* Distributed job priority queue
* Ability to handle application workloads that require high performance at significant write volumes with many concurrent client threads is one of the primary features of Cassandra.



## Cassandra directories

* /opt/cassadra/bin
* /opt/cassadra/bin/cassandra -f --run the process in foreground for debug print and learning..
* /opt/cassadra/conf/cassandra.yaml
* /var/lib/cassandra/hints/
* /var/lib/cassandra/saved_caches/
* /var/lib/cassandra/data/
* /var/lib/cassandra/commitlog/
* /var/log/cassandra/system.log
* /var/log/cassandra/debug.log


## Cassandra run-time properties

* -Dcassandra-foreground=yes
* -Dcassandra.jmx.local.port=7199
* -Dcassandra.libjemalloc=/usr/local/lib/libjemalloc.so
* -Dcassandra.logdir=/opt/cassandra/logs
* -Dcassandra.storagedir=/opt/cassandra/data
* -Dcom.sun.management.jmxremote.authenticate=false
* -Dcom.sun.management.jmxremote.password.file=/etc/cassandra/jmxremote.password
* -Djava.library.path=/opt/cassandra/lib/sigar-bin
* -Djava.net.preferIPv4Stack=true
* -Dlogback.configurationFile=logback.xml
* -XX:GCLogFileSize=10M
* -XX:OnOutOfMemoryError=kill
* -XX:StringTableSize=1000003
* /opt/java/openjdk/bin/java


## Cassandra cqlsh

* Object names are in snake_case. Cassandra converts into lower_case by default, double quote to override
* bin/cqlsh localhost 9042
* ```sql
  show version;
  describe cluster; 
  create keyspace sample_ks with replication = {'class': 'SimpleStrategy', 'replication_factor': 1};
  use sample_ks;
  DESCRIBE KEYSPACES;
  describe keyspace sample_ks;
  describe keyspace system;
  create table user ( first_name text, last_name text, title text, PRIMARY KEY(last_name, first_name) );
  describe table user;
  insert into user(first_name, last_name, title) values  ('Mohan', 'Narayanaswamy', 'Developer');
  select * from user where first_name='Mohan' and last_name = 'Narayanaswamy';
  select * from user where first_name='Mohan';
  --* InvalidRequest: Error from server: code=2200 [Invalid query] message="Cannot execute this query as it might involve data filtering and hus may have unpredictable performance. If you want to execute this query despite the performance unpredictability, use ALLOW FILTERING"
  select count(*) from user; --Aggregation query used without partition key
  delete title from user where last_name='Narayanaswamy' and first_name='Mohan';  --one column alone
  delete from user where last_name='Narayanaswamy' and first_name='Mohan';  --entire row deletion
```


## Via docker

```bash
docker pull cassandra
docker network create cass-network
docker run -d --name my-cassandra --network cass-network cassandra
docker run -d --name my-cassandra-2 --network cass-network cassandra
#docker run --name  my-cassandra -p 9042:9042 -p 7000:7000 --network host -d cassandra:latest
docker exec -it my-cassandra cqlsh
docker stop my-cassandra
```  

## What is anti-entropy repair?

* List of chained security filtered beans

## What are operational mechanics taht affects how you application configuration for data consistency?


## Failure boundaries of Cassandra

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
     DESCRIBE CLUSTER;
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
“Rather than dealing with the uncertainty of the correctness of an answer, the data is made unavailable until it is absolutely certain that it is correct.” (pitfall of strong consistency)
* 

## Building Cassandra

* Cassandra is built using Ant & Maven (Ant in-turn uses Maven)
* [Apache Builds](https://builds.apache.org/)
* [Apache Cassandra Build](https://ci-cassandra.apache.org/view/Cassandra%204.0/job/Cassandra-trunk/lastBuild/)
* [Cassandra source](https://gitbox.apache.org/repos/asf/cassandra.git)
* 'jdk8; ant -f build.xml clean generate-idea-files'
* Ant default target would produce apache-cassandra-x.x.x.jar


## Resources

* https://community.datastax.com/
* user@cassandra.apache.org - provides a general discussion list for users and is frequently used by new users or those needing assistance.
* dev@cassandra.apache.org - is used by developers to discuss changes, prioritize work, and approve releases.
* client-dev@cassandra.apache.org - is used for discussion specific to development of Cassandra clients for various programming languages.
* commits@cassandra.apache.org - tracks Cassandra code commits. This is a fairly high-volume list and is primarily of interest to committers.
* cassandra and cassandra-dev slack channels
* Cassandra blogs
  * [https://thelastpickle.com/blog/](https://thelastpickle.com/blog/)
  * [https://cassandra.apache.org/blog/](https://cassandra.apache.org/blog/)
  * [https://www.instaclustr.com/category/technical/cassandra/](https://www.instaclustr.com/category/technical/cassandra/)
  * [https://www.datastax.com/blog](https://www.datastax.com/blog)


## Reference

* [E.F Codd paper](https://www.seas.upenn.edu/~zives/03f/cis550/codd.pdf)
* [The Case for Shared Nothing - Michael Stonebraker](https://dsf.berkeley.edu/papers/hpts85-nothing.pdf)
* [CAP Theorem](http://www.julianbrowne.com/article/brewers-cap-theorem)
* [CAP Twelve Years Later: How the "Rules" Have Changed](https://www.infoq.com/articles/cap-twelve-years-later-how-the-rules-have-changed/)
* [Cassandra - A Decentralized Structured Storage System](https://www.cs.cornell.edu/projects/ladis2009/papers/lakshman-ladis2009.pdf)
* [Cassandra - A Decentralized Structured Storage System-Updated-Commentry by Johnathan Ellis](https://docs.datastax.com/en/articles/cassandra/cassandrathenandnow.html)
* [Awesome Cassandra](https://github.com/Anant/awesome-cassandra)
* [Cassandra pay-2015](http://marketing.dice.com/pdf/Dice_TechSalarySurvey_2015.pdf)
* [Cassandra pay-2019](http://marketing.dice.com/pdf/Dice_TechSalarySurvey_2019.pdf)
* [Dice pay 2020](https://computing.nova.edu/documents/dice_techsalarysurvey_2020.pdf)
* [CQLSH Introduction](https://gist.github.com/jeffreyscarpenter/761ddcd1c125dfb194dc02d753d31733)
## rough (throw-away)


