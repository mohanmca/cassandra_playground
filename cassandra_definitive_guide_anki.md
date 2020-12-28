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

## Cassandra Lightweight transaction (LWT) - Linearizable consistency

* Ensure there are not operation between read and write
* Example: Check if user exist, if not create user (don't overwrite in between)
* Example: Update the value if and only if the value is X (Check-and-set)
* LWT is based on Paxos algorithm (and it is better than two-phase commit)


## Consistencey levels

* Strong consistency (sequential consistency)
  * “Rather than dealing with the uncertainty of the correctness of an answer, the data is made unavailable until it is absolutely certain that it is correct.”
* Casual consistency (Happens before)
* Eventual consisteny (matter of milli-seconds)

## Strong consistency in Cassandra

* R + W > RF = strong consistency
* In this equation, R, W, and RF are the read replica count, the write replica count, and the replication factor, respectively;


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

## Datamodel quick checklist

* All the possible impory query that needs to satisfied should be considered before design
* Minimize the number of partitions that must be searched to satisfy a given query
* Growing number of tombstones begins to degrade read performance. Data-model should account to minmize it
* Partition-size = Nv=Nr(Nc−Npk−Ns)+Ns (hard-limit 2 billion, in-general 100K)
* in Cassandra - everything is distributed hashmap despite they look like relational-model
* Joins are not supported and should be discouraged in Cassandra
* NO REFERENTIAL INTEGRITY - supported in Cassandra (or any nosql)


## THE WIDE PARTITION PATTERN

* group multiple related rows in a partition in order to support fast access to multiple rows within the partition in a single query.
* Cassandra can put tremendous pressure on the java heap and garbage collector, impact read latencies, and can cause issues ranging from load shedding and dropped messages to crashed and downed nodes.

## Cassandra Architecture - logical components (2+4+3+4+1)

* Network topology, Peer-to-peer
* Gossip, repair, hinted handoff, and lightweight transactions
* Reading, writing, and deleting data
* Data-structures of memtable, commit-logs, caches and SSTables
* LWW-Element-Set (Last-Write-Wins-Element-Set) and no-reconciliation


## Cassandra token ring

* Tokens range from -2^63 to 2^63 - 1
* Every node owns multiple token (and it's token ranges)
* TR - Token range of token t is -   x > TR < t
  * x and t are two successive tokens
  * Range of values less than or equal to each token and greater than the last token of the previous node
* The node with the lowest token owns the range less than or equal to its token and the range greater than the highest token, which is also known as the wrapping range
* Early version of Cassandra node has only one token (one TR), nowadays it has 256 token for each node (256 virutal nodes)
* Larger machine can have more than 256 by modifying num_tokens@cassandra.yaml
* Partitioner :: partition_key -> token (clustering key is not used by partitioner)
* Partitioner can’t be changed after initializing a cluster. Cassandra uses MurMurPartitioner since 1.2

## Hinted Handoff

* Acts like JMS MQ, till message is delivered


## Replication Factor vs Consistency Level

9/

## Conflict-free replicated data type


## What is anti-entropy repair?

* Replica synchronization mechanism for ensuring that data on different nodes is updated to the newest version.
* Replica synchronization as well as hinted handoff.
* Project Voldemort also uses read-repair similar to Cassandra (not anti-entropy repair)
* 

## MERKLE TREE usage in Cassandra?

* The advantage MERKLE TREE usage is that it reduces network I/O.
* Used to ensure that the peer-to-peer network of nodes receives data blocks unaltered and unharmed.
* Each table has its own Merkle tree; the tree is created as a snapshot during a validation compaction, 
* MerkleTree is kept only as long as is required to send it to the neighboring nodes on the ring.

## Commit Log

* Only one commit log for entire server
* Commit log shares across multiple table
* All writes to all tables will go into the same commit log
* Ther is a bit for flush_bit for each table in commit log (1 - flush_required, 0 - flush-not-required)
* Throw more memory to reduce false-positives

## Comapaction stragies in Cassandra

* SizeTieredCompactionStrategy (STCS) is the default compaction strategy and is recommended for write-intensive tables.
* LeveledCompactionStrategy (LCS) is recommended for read-intensive tables.
* TimeWindowCompactionStrategy (TWCS) is intended for time series or otherwise date-based data.
* Anticompaction  - Split SSTable with one containing repaied data and other containing unrepaired data


## Cassandra under the hood

* [Refactor and modernize the storage engine](https://issues.apache.org/jira/browse/CASSANDRA-8099)
* [Materialized Views (was: Global Indexes)](https://issues.apache.org/jira/browse/CASSANDRA-6477)
* [Cassandra pluggable storage engine](https://issues.apache.org/jira/browse/CASSANDRA-13474)

## Deletion and Tombstones

* Nodes that was down when records deleted should have mechnism, hence tombstones
* Tombstones can be configured using gc_grace_seconds (garbage collection grace seconds)
* gc_grace_seconds = 864000 seconds ( 10 days)

## Bloom Filter

* Used to reduce disk access
* Used in Hadoop, Bigtable, Squid Proxy Cache (and many big-data systems)
* False-negative is not possible, but falst-positive is possible
* if bloom-filter conveys data is not available, it is not avialble. If available, it may not be available.


## What are operational mechanics that affects how you application configuration for data consistency?


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


## Cassandra Client - features (Datastax Driver 4.9.0)

*   <groupId>com.datastax.oss</groupId>{<artifactId>java-driver-query-builder</artifactId>| <artifactId>java-driver-core</artifactId>| <artifactId>java-driver-mapper-processor</artifactId>|<artifactId>java-driver-mapper-runtime</artifactId>
* CqlSession maintains TCP connections to multiple nodes, it is a heavyweight object. Reuse it
* Prefer file based client side driver configuration
* PreparedStatements also improve security by separating the query logic of CQL from the data.
* Prepared statements were stored in a cache, but beginning with the 3.10 release, each Cassandra node stores prepared statements in a local table so that they are present if the node goes down and comes back up.
* Client side loadbalancing can be configured
  * RoundRobin/Token awareness/Data center awareness
* Driver should deal with node failures, hence we can also configure retry mechnism  
* CQL native protocol is asynchronous
* Compression can be enabled between client and server
* Security can be configured between client and server
* Deifferent profiles can be configured between invocation by the same client

## Cassandra Client - Metadata

* Client can access metadata - CqlSession.getMetadata() 
* Client can react for schema changes using - withSchemaChangeListener()
* Client can deduce dropped nodes and new nodes that were added - com.datastax.oss.driver.api.core.metadata.NodeStateListener
* 

## Cassandra Client - Retry Failied Queries (if node failed)

* ExponentialReconnectionPolicy  vs ConstantReconnectionPolicy
* onReadTimeout(), onWriteTimeout(), and onUnavailable()
* The RetryPolicy operations return a RetryDecision
* 

## Cassandra Client side - SPECULATIVE EXECUTION

* The driver can preemptively start an additional execution of the query against a different coordinator node.
* When one of the queries returns, the driver provides that response and cancels any other outstanding queries.
* ConstantSpeculativeExecutionPolicy

## Cassandra Client side - CONNECTION POOLING

* 128 simultaneous requests in protocol - v2
* 32768 simultaneous requests in protocol - v3 
* Default single connection per node
* 1024 -  The maximum number of simultaneous requests per connection (defaults to 1,024).


## Cassandra Client side driver configuration 

```json
datastax-java-driver {
  basic {
    contact-points = [ "127.0.0.1:9042", "127.0.0.2:9042" ]
    session-keyspace = reservation
  }
}
```

## Cassandra Client (Datastax Driver 4.9.0) - Java API

```java
CqlSession cqlSession = CqlSession.builder()
    .addContactPoint(new InetSocketAddress("127.0.0.1", 9042))
    .withKeyspace("reservation")
    .withLocalDatacenter("<data center name>")
    .build()
```
## Cassandra Client Mapper/Entity Annotations

* @Mapper
* @Select
* @Insert
* @Delete
* @Query


## Cassandra Client (Datastax Driver 5.0) - QueryBuilder API API

```java
Select reservationSelect =
  selectFrom("reservation", "reservations_by_confirmation")
  .all()
  .whereColumn("confirm_number").isEqualTo("RS2G0Z");

SimpleStatement reseravationSelectStatement = reservationSelect.build()
```

## Cassandra Client (Datastax Driver 5.0) - Async API
* CQL native protocol is asynchronous
* ```java
      CompletionStage<AsyncResultSet> resultStage =  cqlSession.executeAsync(statement);

      // Load the reservation by confirmation number
      CompletionStage<AsyncResultSet> selectStage = session.executeAsync(
        "SELECT * FROM reservations_by_confirmation WHERE
          confirm_number=RS2G0Z");

      // Use fields of the reservation to delete from other table
      CompletionStage<AsyncResultSet> deleteStage =
        selectStage.thenCompose(
          resultSet -> {
            Row reservationRow = resultSet.one();
            return session.executeAsync(SimpleStatement.newInstance(
              "DELETE FROM reservations_by_hotel_date WHERE hotel_id = ? AND
                start_date = ? AND room_number = ?",
              reservationRow.getString("confirm_number"),
              reservationRow.getLocalDate("start_date"),
              reservationRow.getInt("room_number"));
          });

      // Check results for success
      deleteStage.whenComplete(
          (resultSet, error) -> {
            if (error != null) {
              System.out.printf("Failed to delete: %s\n", error.getMessage());
            } else {
              System.out.println("Delete successful");
            }      
```


## JDK 9 - Reactive style API

* The CqlSession interface extends a new ReactiveSession interface
  * which adds methods such as executeReactive() to process queries expressed as reactive streams.
* ```java
    try (CqlSession session = ...) {
          Flux.from(session.executeReactive("SELECT ..."))
              .doOnNext(System.out::println)
              .blockLast();
    } catch (DriverException e) {
      e.printStackTrace();
    }

try (CqlSession session = ...) {
  Flux.just("INSERT ...", "INSERT ...", "INSERT ...", ...)
      .doOnNext(System.out::println)
      .flatMap(session::executeReactive)
      .blockLast();
} catch (DriverException e) {
  e.printStackTrace();
}    
````

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


## Follow-up questions

* Does mongo-db/kafka supports Cassandra-toplogy/cross-dc kind of configurations?
* How to find node using token in Cassandra?
* Where else "PHI THRESHOLD AND ACCRUAL FAILURE DETECTORS" being used?
* MerkleTree (surprise usage in Cassandra)
* PHI THRESHOLD AND ACCRUAL FAILURE DETECTORS (Surprise)
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
* [Wide Partitions in Apache Cassandra 3.11](https://thelastpickle.com/blog/2019/01/11/wide-partitions-cassandra-3-11.html)
* [Paxos made simple](https://www.cs.utexas.edu/users/lorenzo/corsi/cs380d/past/03F/notes/paxos-simple.pdf)
* [Datastax driver reference](https://github.com/datastax/java-driver/)

## rough (throw-away)


