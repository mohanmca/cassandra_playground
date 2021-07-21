## (Section: TDG) - RDBMS history

* IBM DB1 - IMS Hierarchical dbms - DBI/DB1 - Released in 1968 
* IBM DB2 - 1970 - "A Relational Model of Data for Large Shared Data Banks - Dr. Edgar F. Codd"
* 1979-DB2 (E.F Cod 1970s), RDBMS relational model (not working system, just theoratical model)
* Traditionally RDBMS supports locks, locks helps to maintain consistency but reduces access/availability to others
* Journal or WAL log files are used for rollback or atomic-commit in RDBMS, journal sometime switched of to increase performance
* Codd provided a list of 12 rules (0-12, actually 13 :-)) in ComputerWorld Magazine in 1985 (15 years later from original paper)
* ANSI SQL - 1986

## (Section: TDG) -  RDBMS Pros and cons

* Pros : It works for most of the cases
  * SQL - Support
  * ACID - Transaction (A Transformation of State - Jim Gray)
    * Atomic (State A to State B - no in-between)
    * Consistency
    * Isolated - Force transactions to be serially executed. (If it doesn't require consistency and atomic, it is  possible to have isolated and parallel txns)
    * Durable - Never lost
* Cons : Won't work for massively web scale db

## (Section: TDG) -  Why RDBMS is successful?

* SQL
* Atomic Transaction with ACID properties
* Two-phase commit was marketted well (Co-ordinated txn)
* Rich schema

## (Section: TDG) -  How RDBMS is tuned

* Introduce Index
* Master(write), Slave (many times only used for read)
  * Introduces replication and transaction issues
  * Introduces consistency issues
* Add more CPU, RAM - Vertical scaling
* Partitioning/Sharding
* Disable journaling  

## (Section: TDG) -  Two-phase commit vs Compensation

* Compensation
  * Writing off the transaction if it fails, deciding to discard erroneous transactions and reconciling later. 
  * Retry failed operations later on notification.
* In a reservation system or a stock sales ticker, these are not likely to meet your requirements. 
* For other kinds of applications, such as billing or ticketing applications, this can be acceptable.
* Starbucks Does Not Use Two-Phase Commit
  * https://www.enterpriseintegrationpatterns.com/ramblings/18_starbucks.html


## (Section: TDG) -  Sharding (Share nothing)

* Rather keeping all customer in one table, divide up that single customer table so that each database has only some of the records, with their order preserved? Then, when clients execute queries, they put load only on the machine that has the record they’re looking for, with no load on the other machines.
* How to shard?
  * Name-wise sharding issues like customer names that starts with "Q,J" will have less, whereas customer name starts with J, M and S may be busy
  * Shard by DOB, SSN, HASH
* Three basic strategies for determining shard structure  
  * Feature-based shard or functional segmentation
  * Key-based sharding - one-way hash on a key data element and distribute data across machines according to the hash.
  * Lookup Table

## (Section: TDG) -  [List of NoSQL databases](http://nosql-database.org/)

* Key-Value stores - Oracle Coherence, Redis, and MemcacheD, Amazon’s Dynamo DB, Riak, and Voldemort.
* Column stores - Cassandra, Hypertable, and Apache Hadoop’s HBase.
* Document stores -  MongoDB and CouchDB.
* Graph databases - Blazegraph, FlockDB, Neo4J, and Polyglot
* Object databases -  db4o and InterSystems Caché
* XML databases - Tamino from Software AG and eXist.


## (Section: TDG) -  Apache Cassandra - Official definition

* “Apache Cassandra is an open source, distributed, decentralized, elastically scalable, highly available, fault-tolerant, tuneably consistent, row-oriented database. Cassandra bases its distribution design on Amazon’s Dynamo and its data model on Google’s Bigtable, with a query language similar to SQL"
* Tuneably consistent (not Eventual Consisten as majority believes)


## (Section: TDG) -  Cassandra Features

* CQL (Thrift API is completely removed in 3.x)
  * CQL also known as native-transport
* Secondary indexes
* Materialized views
* Lightweight transactions
* Consistency = Replication factor + consistency level  (delegated to clients)
  * Consistency level <= replication factor
* Cassandra is not column-oriented (it is row oriented)
* Column values are stored according to a consistent sort order, omitting columns that are not populated

## (Section: TDG) -  What are all Consistency Forms?

* Strict (or Serial) Consistency or Strong (sequential consistency)
  * Works on Single CPU
  * “Rather than dealing with the uncertainty of the correctness of an answer, the data is made unavailable until it is absolutely certain that it is correct.”
* Casual Consistency (like Casuation)
  * Happens before
  * The cause of events to create some consistency in their order.
  * Writes that are potentially related must be read in sequence. 
  * If two different, unrelated operations suddenly write to the same field, then those writes are inferred not to be causally related.
* Weak (or) Eventual Consistency
  * Rather than dealing with the uncertainty of the correctness of an answer, the data is made unavailable until it is absolutely certain that it is correct
  * Eventual consisteny (matter of milli-seconds)

## (Section: TDG) -  Strong consistency in Cassandra

* R + W > RF = Strong consistency
* In this equation, R, W, and RF are the read replica count, the write replica count, and the replication factor, respectively;

## (Section: TDG) -  Row-Oriented data store

* Cassandra’s data model can be described as a partitioned row store, in which data is stored in sparse multidimensional hashtables.
* “Sparse” means that for any given row you can have one or more columns, but each row doesn’t need to have all the same columns as other rows like it (as in a relational model).
* “Partitioned” means that each row has a unique key which makes its data accessible, and the keys are used to distribute the rows across multiple data stores.

## (Section: TDG) -  Always writeable

* A design approach must decide whether to resolve these conflicts at one of two possible times: during reads or during writes. That is, a distributed database designer must choose to make the system either always readable or always writable. Dynamo and Cassandra choose to be always writable, opting to defer the complexity of reconciliation to read operations, and realize tremendous performance gains. The alternative is to reject updates amidst network and server failures.
* CAP Theorem
  * Choose any two (of threee)
  * Cassandra assumes that  network partitioning is unavoidable, hence it lets us deal only with availability and consistency.
  * CAP placement is independent of the orientation of the data storage mechanism
  * CAP theorem database mapping
    * AP - ?
      * To primarily support availability and partition tolerance, your system may return inaccurate data, but the system will always be available, even in the face of network partitioning. DNS is perhaps the most popular example of a system that is massively scalable, highly available, and partition tolerant.
    * CP - ?
      * To primarily support consistency and partition tolerance, you may try to advance your architecture by setting up data shards in order to scale. Your data will be consistent, but you still run the risk of some data becoming unavailable if nodes fail.
    * CA - ?
      * To primarily support consistency and availability means that you’re likely using two-phase commit for distributed transactions. It means that the system will block when a network partition occurs, so it may be that your system is limited to a single data center cluster in an attempt to mitigate this. If your application needs only this level of scale, this is easy to manage and allows you to rely on familiar, simple structures.


## (Section: TDG) -  Notable tools

* Sstableloader - Bulk loader
* Leveled compaction strategy - for faster reads
* Atomic batches
* Lightweight transactions were added using the Paxos consensus protocol
* User-defined functions
* Materialized views (sometimes also called global indexes) 

## (Section: TDG) -  Few use cases

* Cassandra has been used to create a variety of applications, including a windowed time-series store, an inverted index for document searching, and a distributed job priority queue.

## (Section: TDG) -  Updated CAP - Brewer's Theorem

* Brewer now describes the “2 out of 3” axiom as somewhat misleading. 
* He notes that designers only need sacrifice consistency or availability in the presence of partitions. And that advances in partition recovery techniques have made it possible for designers to achieve high levels of both consistency and availability.

## (Section: TDG) -  What is the alternative for Two-phase commit

* Compensation or compensatory action
* Writing off the tranaction if it fails, deciding to discard erroneous transactions and reconciling later
  * Won't work on trading or reservation system
* Retry failed operation later on notification
* "Starbucks does not use Two-phase commit" - Gregor Hohpe

## (Section: TDG) -  How to horizontally scale RDBMS (shard)

* Shard the database, (key for sharding is important)
* Split the customer based on name (few letter has less load)  or according to phone-number or dob
* Host all the data that begins with certain letter in different database
* Shard users in one database, items in another database

## (Section: TDG) -  There are three basic strategies for determining shard structure:

* Feature-based shard or functional segmentation
  * Shard users in one database, items in another database
* Key-based sharding
  * Hash based sharding
  * time-based on numeri-ckeys to hash on
* Lookup table
  * Make one of the node as "Yellow-pages", look-up for information about where the data stored

## (Section: TDG) -  Shared nothing

* Sharding could be termed a kind of shared-nothing architecture that’s specific to databases
* Shared-nothing - no primary or no-secondary
* Every node is independent
* No centralized shared state
* Cassandra (key-based sharding) and MongoDB - Autn o sharding database


## (Section: TDG) -  New SQL (Scalable ACID transactions)

* Calvin transaction protocol vs Google’s Spanner paper
* FaunaDB is an example of a database that implements the approach on the Calvin paper


## (Section: TDG) -  Cassandra features

* It uses gossip protcol (feature of peer-to-peer architecture) to maintain details of other nodes.
* It allows tunable cosistency and client can decide for each write/read (how many RF?)
* It is possible to remove one column value alone in Cassandra

## (Section: TDG) -  Cap Theorem (Brewer's theorem)

* CAP - Choose two (as of 2000)
* Network issue would certainly happens, hence network partition failures is un-avoidable, And should be handled. Hence choose between compromise on A or C (Availablity or consistency)
* CA -  MySQL, Postgres, SQL
* CP -  Neo4j, MongoDB, HBase, BigTable
* AP -  DNS, Cassandra, Amazon Dynamo

## (Section: TDG) -  Cassandra Lightweight transaction (LWT) - Linearizable consistency

* Ensure there are not operation between read and write
* Example: Check if user exist, if not create user (don't overwrite in between)
* Example: Update the value if and only if the value is X (Check-and-set)
* LWT is based on Paxos algorithm (and it is better than two-phase commit)


## (Section: TDG) -  Row-Oriented (Wide column store)

* Partitioned row store - sparse multidimensional hash tables
* Partitioned - means that each row has a unique partition key used to distribute the rows across multiple data stores.
* Sparse - not all rows has same number of columns
* Cassandra stores data in a multidimensional, sorted hash table.
* As data is stored in each column, it is stored as a separate entry in the hash table.
* Column values are stored according to a consistent sort order, omitting columns that are not populated.


## (Section: TDG) -  Cassandra - schema free?

* Started as schema free using Thrift API, later CQL was introduced
* No! Till 2.0 CQL and Thrit API co-exist, It was known as "Schema Optional"
* From 3.0, Thrift API is deprecated, and from 4.0 Thrif API is removed
* Additional values for columns can be added using List, Sets and Maps
  * Now-a-days it is considered flexible-schema
* Schema free -> "Optional Schema" -> "Flexible Schema"  

## (Section: TDG) -  Cassandra - use-cases?

* Storing user activity updates
* Social network usage, recommendations/reviews, 
* Application statistics
* Inverted index for document searching
* ~~Distributed job priority queue~~ (queues are not recommended anymore)
* Ability to handle application workloads that require high performance at significant write volumes with many concurrent client threads is one of the primary features of Cassandra.



## (Section: TDG) -  Cassandra directories

* /opt/cassadra/bin
* /opt/cassadra/bin/cassandra -f --run the process in foreground for debug print and learning..
* /opt/cassadra/conf/cassandra.yaml
* /var/lib/cassandra/hints/
* /var/lib/cassandra/saved_caches/
* /var/lib/cassandra/data/
* /var/lib/cassandra/commitlog/
* /var/log/cassandra/system.log
* /var/log/cassandra/debug.log

## (Section: TDG) -  Cassandra directories and files

* $CASSANDRA_HOME/data/commitlog
  * CommitLog-<version><timestamp>.log
  * CommitLog-7-1566780133999.log
* 1-SSTable has multiple files
  * SSTable stored under - $CASSANDRA_HOME/data/data

## (Section: TDG) -  Cassandra run-time properties

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


## (Section: TDG) -  Cassandra cqlsh

* Object names are in snake_case. Cassandra converts into lower_case by default, double quote to override
* bin/cqlsh localhost 9042
* 
  ```sql
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

## (Section: TDG) -  How to run apache Cassandra using docker

```bash
docker pull cassandra
docker network create cass-network
docker run -d --name apc1 --network cass-network cassandra
docker run -d --name apc2 --network cass-network cassandra
#docker run --name  my-cassandra -p 9042:9042 -p 7000:7000 --network host -d cassandra:latest
docker exec -it apc2 cqlsh
docker stop apc2
```

## (Section: TDG) -  Datamodel quick checklist

* All the possible important query that needs to satisfied should be considered before design
* Minimize the number of partitions that must be searched to satisfy a given query
* Growing number of tombstones begins to degrade read performance. Data-model should account to minmize it
* Partition-size = Nv=Nr(Nc−Npk−Ns)+Ns (hard-limit 2 billion, in-general 100K)
  * Partition Size can have maximum of 2 billion cells
  * Nv (Number of cells) = Nr * Nc (Number of rows * number of columns)
  * Ns - Number of static columns (static columns stored once per partition)
* in Cassandra - everything is distributed hashmap despite they look like relational-model
* Joins are not supported and should be discouraged in Cassandra
* NO REFERENTIAL INTEGRITY - supported in Cassandra (or any nosql)


## (Section: TDG) -  THE WIDE PARTITION PATTERN

* group multiple related rows in a partition in order to support fast access to multiple rows within the partition in a single query.
* Cassandra can put tremendous pressure on the java heap and garbage collector, impact read latencies, and can cause issues ranging from load shedding and dropped messages to crashed and downed nodes.

## (Section: TDG) -  Cassandra Architecture - What is the role of reconciliation?

* LWW-Element-Set (Last-Write-Wins-Element-Set) and no-reconciliation


## (Section: TDG) -  Cassandra token ring

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

## (Section: TDG) -  Hinted Handoff

* Acts like JMS MQ, till message is delivered
* But message is deleted after 3 hours (should be consumed within that)


## (Section: TDG) -  Conflict-free replicated data type

* To resolve conflicts, system can use the Last-Writer-Wins Register
* Which keeps only the last updated value when merging diverged data sets. 
* Cassandra uses this strategy to resolve conflicts.
* We need to be very cautious when using this strategy because it drops changes that occurred in the meantime.


## (Section: TDG) -  What is anti-entropy repair?

* Replica synchronization mechanism for ensuring that data on different nodes is updated to the newest version.
* Replica synchronization as well as hinted handoff.
* Project Voldemort also uses read-repair similar to Cassandra (not anti-entropy repair)


## (Section: TDG) -  MERKLE TREE usage in Cassandra?

* The advantage MERKLE TREE usage is that it reduces network I/O.
* Used to ensure that the peer-to-peer network of nodes receives data blocks unaltered and unharmed.
* Each table has its own Merkle tree; the tree is created as a snapshot during a validation compaction, 
* MerkleTree is kept only as long as is required to send it to the neighboring nodes on the ring.

## (Section: TDG) -  Commit Log

* Only one commit log for entire server
* Commit log shares across multiple table
* All writes to all tables will go into the same commit log
* Ther is a bit for flush_bit for each table in commit log (1 - flush_required, 0 - flush-not-required)
* Throw more memory to reduce false-positives

## (Section: TDG) -  Comapaction stragies in Cassandra

* SizeTieredCompactionStrategy (STCS) is the default compaction strategy and is recommended for write-intensive tables.
* LeveledCompactionStrategy (LCS) is recommended for read-intensive tables.
* TimeWindowCompactionStrategy (TWCS) is intended for time series or otherwise date-based data.
* Anticompaction  - Split SSTable with one containing repaied data and other containing unrepaired data


## (Section: TDG) -  Cassandra under the hood

* [Refactor and modernize the storage engine](https://issues.apache.org/jira/browse/CASSANDRA-8099)
* [Materialized Views (was: Global Indexes)](https://issues.apache.org/jira/browse/CASSANDRA-6477)
* [Cassandra pluggable storage engine](https://issues.apache.org/jira/browse/CASSANDRA-13474)

## (Section: TDG) -  Deletion and Tombstones

* Nodes that was down when records deleted should have mechanism, hence tombstones
* Tombstones can be configured using gc_grace_seconds (garbage collection grace seconds)
* gc_grace_seconds = 864000 seconds ( 10 days)

## (Section: TDG) -  Bloom Filter

* SSTable is not good when key that is not available in a table is queried
* Without bloomfilter, Cassandra read-path would query multiple files (sgements) to confirm a key is absent. It queries latest to oldest before confirming lack of key.
* Used to reduce disk access
* Used in Hadoop, Bigtable, Squid Proxy Cache (and many big-data systems)
* False-negative is not possible, but falst-positive is possible
* if bloom-filter conveys data is not available, if it is not avialble. But it might return 'may be available', it may not be available.

## (Section: TDG) -  cluster topology of Cassandra

* Cassandra cluster topology is the arrangement of the nodes (dcs, racs, etc.) and communication network between them.
* Snitch teaches  Cassandra enough about your network topology
* cassandra-topology.properties can be used to configure topology details


## (Section: TDG) -  CQL - Primary key and Clustering key

```
PRIMARY KEY (("k1", "k2"), "c1", "c2"), ) WITH CLUSTERING ORDER BY ("c1" DESC, "c2" DESC);
```

## (Section: TDG) -  CQLSH - useful

* CQL would use Murmur3 partitioner
* Minimum token is -9223372036854775808 (and maximum token is 9223372036854775808).
* ```sql
     cassandra@cqlsh:system_schema>
     DESCRIBE CLUSTER;
     DESCRIBE KEYSPACES;
     DESCRIBE TABLES;
     SELECT * FROM system_schema.keyspaces;
     desc KEYSPACE Keyspace_Name;
     select token(key), key, my_column from mytable where token(key) >= %s limit 10000;
```

## (Section: TDG) -  How to remove node using nodetool

* Decommission - Streams data from the leaving node (prefered and guaranteed consistency as if it started)
* Removenode -  Streams data from any available node that owns the range
* assassinate - Forcefully remove a dead node without re-replicating any data. Use as a last resort if you cannot removenode

## (Section: TDG) -  Cassandra linux limits

* if cassandra has 30 sstables, it would use 30 * 6 - 180 file handles
* XX:MaxDirectMemorySize - we can set off-heap memory (outside JVM on OS)
 

## (Section: TDG) -  Cassandra troubleshoot linux commands

```bash
cat /proc/cass_proc_id/limits | grep files
```


## (Section: TDG) -  How does cassandra-topolgoy.properties look alike

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


## (Section: TDG) -  Cassandra Client - features (Datastax Driver 4.9.0)

*  
    ```xml
        <dependency>
          <groupId>com.datastax.oss</groupId>
          <artifactId>java-driver-query-builder</artifactId>
          <artifactId>java-driver-core</artifactId>
          <artifactId>java-driver-mapper-processor</artifactId>
          <artifactId>java-driver-mapper-runtime</artifactId>
        </dependency>
    ```
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

## (Section: TDG) -  Cassandra Client - Retry Failied Queries (if node failed)

* ExponentialReconnectionPolicy  vs ConstantReconnectionPolicy
* onReadTimeout(), onWriteTimeout(), and onUnavailable()
* The RetryPolicy operations return a RetryDecision


## (Section: TDG) -  Cassandra Client side - SPECULATIVE EXECUTION

* The driver can preemptively start an additional execution of the query against a different coordinator node.
* When one of the queries returns, the driver provides that response and cancels any other outstanding queries.
* ConstantSpeculativeExecutionPolicy

## (Section: TDG) -  Cassandra Client side - CONNECTION POOLING

* Default single connection per node
* 128 simultaneous requests in protocol - v2
* 32768 simultaneous requests in protocol - v3 
* 1024 -  Default maximum number of simultaneous requests per connection.


## (Section: TDG) -  Cassandra Client side driver configuration 

```json
datastax-java-driver {
  basic {
    contact-points = [ "127.0.0.1:9042", "127.0.0.2:9042" ]
    session-keyspace = reservation
  }
}
```

## (Section: TDG) - How to connect to Cassandra using Java API

1. Create Cluster object
1. Create Session object
1. Execute Query using session and retrieve the result
1. 
    ```java
    Cluster cluster = Cluster.builder().addContactPoint("127.0.0.1").build()
    Session session = cluster.connect("KillrVideo")
    ResultSet result = session.execute("select * from videos_by_tag where tag='cassandra'");

    boolean columnExists = result.getColumnDefinitions().asList().stream().anyMatch(cl -> cl.getName().equals("publisher"));

    List<Book> books = new ArrayList<Book>();
    result.forEach(r -> {
      books.add(new Book(
          r.getUUID("id"), 
          r.getString("title"),  
          r.getString("subject")));
    });
    return books;
    ```

## (Section: TDG) -  How to connect to Cassandra using Python API
*
  ```bash
  python -m pip install --upgrade pip
  pip install cassandra-driver
  ```

* 
  ```python
    from cassandra.cluster import Cluster
    cluster = Cluster(['192.168.0.1', '192.168.0.2'], protocol_version = 3, port=..., ssl_context=...)
    session = cluster.connect('Killrvideo')
    result = session.execute("select * from videos_by_tag where tag='cassandra'")[0];
    print('{0:12} {1:40} {2:5}'.format('Tag', 'ID', 'Title'))
    for val in session.execute("select * from videos_by_tag"):
      print('{0:12} {1:40} {2:5}'.format(val[0], val[2], val[3]))
  ```

## (Section: TDG) - Cassandra Client (Datastax Driver 4.9.0) - Java API
* 
  ```java
  CqlSession cqlSession = CqlSession.builder()
      .addContactPoint(new InetSocketAddress("127.0.0.1", 9042))
      .withKeyspace("reservation")
      .withLocalDatacenter("<data center name>")
      .build()
  ```

## (Section: TDG) -  Cassandra Client Mapper/Entity Annotations

* @Mapper
* @Select
* @Insert
* @Delete
* @Query


## (Section: TDG) -  Cassandra Client (Datastax Driver 5.0) - QueryBuilder API API

```java
  Select reservationSelect =  selectFrom("reservation", "reservations_by_confirmation")
    .all()
    .whereColumn("confirm_number").isEqualTo("RS2G0Z");

  SimpleStatement reseravationSelectStatement = reservationSelect.build()
```

## (Section: TDG) -  Cassandra Client (Datastax Driver 5.0) - Async API
* CQL native protocol is asynchronous
* 
```java
      CompletionStage<AsyncResultSet> resultStage =  cqlSession.executeAsync(statement);

      // Load the reservation by confirmation number
      CompletionStage<AsyncResultSet> selectStage = session.executeAsync("SELECT * FROM reservations_by_confirmation WHERE confirm_number=RS2G0Z");

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

## (Section: TDG) -  JDK 9 - Reactive style API
* The CqlSession interface extends a new ReactiveSession interface. Which adds methods such as executeReactive() to process queries expressed as reactive streams.
* 
  ```java
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
  ```

## (Section: TDG) -  Cassandra write path

* Performance optimzied for write using append only
* Database commit log and hinted handoff design, the database is always writable, and within a row, writes are always atomic.
* Consistency Level - ANY/ONE/TWO/THREE/LOCAL_ONE/QUORUM/LOCAL_QUORUM/EACH_QUORUM/ALL
  * ANY - Hinted hand-off is counted 
  * ONE (Atleast one commit-log + sstable) is counted as one
* Write-Path
  * Client > Cassandra Cordinator Node > Nodes (replicas)
  * If client uses token-aware cordinator itself replica, if not key is used by partitioner to find node
  * Co-ordinator selects remote co-ordinator for X-DC replications
* Node that was down will have data using one of the following
  * hinted handoff
  * read repair
  * Anti-entropy repair.
* Existing Row-Cache is invalidated during write
* Flush and Compaction might be peformed if necessary
* Memtables are stored as SS-Table to disk


## (Section: TDG) -  Cassandra write path - Materialized view

* Partition must be locked while consensus negotiated between replicas
* Logged batches are used to maintain materialized views
* The Cassandra database performs an additional read-before-write operation to update each materialized view
* If a delete on the source table affects two or more contiguous rows, this delete is tagged with one tombstone.
* But one delete in a source table might create multiple tombstones in the materialized view


## (Section: TDG) -  Cassandra write/read - consistency CQLS

* ```bash
      cqlsh> CONSISTENCY;
      ## Current consistency level is ONE.
      cqlsh> CONSISTENCY LOCAL_ONE;
      ## Consistency level set to LOCAL_ONE.
      ## statement.setConsistencyLevel(ConsistencyLevel.LOCAL_QUORUM);
  ```

## (Section: TDG) -  Cassandra failures and solutions

* java.lang.OutOfMemoryError: Map failed` - Almost always incorrect user limits - check ulimit -a 
  * Check the values of max memory size and virtual memory

## (Section: TDG) -  Scaling Quotes

* If you can’t split it, you can’t scale it. "Randy Shoup, Distinguished Architect, eBay"
* [“The Case for Shared Nothing” - Michael Stonebreaker](http://db.cs.berkeley.edu/papers/hpts85-nothing.pdf)
* No sane pilot would take off in an airplane without the ability to land, and no sane engineer would roll code that they could not pull back off in an emergency
* Management means measurement, and a failure to measure is a failure to manage.

## (Section: TDG) -  Performance Quotes

1. “The recommendation for speeding up .... is to add cache and more cache. And after that add a little more cache just in case.”
1. “When something becomes slow it's a candidate for caching.”
1. “LRU policy is perhaps the most popular due to its simplicity, good runtime performance, and a decent hit rate in common workloads.”
1. “Rather than dealing with the uncertainty of the correctness of an answer, the data is made unavailable until it is absolutely certain that it is correct.” (pitfall of strong consistency)


## (Section: TDG) -  Nodetool

* Adminstration tool uses JMX to interact with Cassandra
* TPstats (threadpoolstatus) and Tablestats  are subcommands in nodetool
* nodetool help tpstats
* nodetool tpstats --

## (Section: TDG) -  Building Cassandra

* Cassandra is built using Ant & Maven (Ant in-turn uses Maven)
* [Apache Builds](https://builds.apache.org/)
* [Apache Cassandra Build](https://ci-cassandra.apache.org/view/Cassandra%204.0/job/Cassandra-trunk/lastBuild/)
* [Cassandra source](https://gitbox.apache.org/repos/asf/cassandra.git)
* 'jdk8; ant -f build.xml clean generate-idea-files'
* 'jdk8; ant -f build.xml test cqltest'
* To test one class in intelli-idea
  * java -Dcassandra.config=file:\\\D:\git\cassandra4\test\conf\cassandra.yaml -Dlogback.configurationFile=file:\\\D:\git\cassandra4\test\conf\logback-test.xml -Dcassandra.logdir=D:/git/cassandra4/build/test/logs -Djava.library.path=D:/git/cassandra4/lib/sigar-bin -ea org.apache.cassandra.db.compaction.LeveledCompactionStrategyTest
* Ant default target would produce apache-cassandra-x.x.x.jar


## (Section: TDG) -  Resources

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


## (Section: TDG) -  Follow-up questions for Cassandra

* What are the other peer-to-peer databases?
  * How clients are connecting to them?  
* Does mongo-db/kafka supports Cassandra-toplogy/cross-dc kind of configurations?
* How to find node using token in Cassandra?
* Where else "PHI THRESHOLD AND ACCRUAL FAILURE DETECTORS" being used?
* MerkleTree (surprise usage in Cassandra)
* PHI THRESHOLD AND ACCRUAL FAILURE DETECTORS (Surprise)


## (Section: TDG) -  Definitive Guide References

* [Cassandra Guide](https://github.com/jeffreyscarpenter/cassandra-guide)
* [Cassandra Paper](http://www.cs.cornell.edu/projects/ladis2009/papers/lakshman-ladis2009.pdf)
* [AWS re:Invent 2018: Amazon DynamoDB Deep Dive: Advanced Design Patterns for DynamoDB (DAT401)](https://www.youtube.com/watch?time_continue=33&v=HaEPXoXVf2k)
* [amazon-dynamodb-deep-dive-advanced-design-patterns-for-dynamodb](https://www.slideshare.net/AmazonWebServices/amazon-dynamodb-deep-dive-advanced-design-patterns-for-dynamodb-dat401-aws-reinvent-2018pdf)
* [Best Practices NOSql](https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/best-practices.html)
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
* [Incremental Repair Improvements in Cassandra 4](https://thelastpickle.com/blog/2018/09/10/incremental-repair-improvements-in-cassandra-4.html)
* CassandraSummit

## (Section: TDG) -  Code 

* [jeffreyscarpenter/reservation-service](https://github.com/jeffreyscarpenter/reservation-service)
* [Datastax KillrVideo sample java application](https://killrvideo.github.io/docs/languages/java/)
* [Datastax spring pet-clinic](https://github.com/DataStax-Examples/spring-petclinic-reactive#prerequisites)


## (Section: TDG) -  How to create anki from this markdown file

```
mdanki Cassandra_Definitive_Guide_Anki.md Cassandra_Definitive_Guide.apkg --deck "Mohan::Cassandra::DefinitiveGuide"
```