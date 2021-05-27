## New model
* IBM DB1 - IMS (Hierarchical dbms) - Released in 1968 
* IBM DB2 - 1970 - "A Relational Model of Data for Large Shared Data Banks - Dr. Edgar F. Codd"
* Pros : It works for most of the cases
  * SQL - Support
  * ACID - Transaction (A Transformation of State - Jim Gray)
    * Atomic (State A to State B - no in-between)
    * Consistency
    * Isolated - Force transactions to be serially executed. (If it doesn't require consistency and atomic, it is  possible to have isolated and parallel txns)
    * Durable - Never lost
* Cons : Won't work for massively web scale db

## How RDBMS is tuned

* Introduce Index
* Master(write), Slave (many times only used for read)
  * Introduces replication and transaction issues
  * Introduces consistency issues
* Add more CPU, RAM - Vertical scaling
* Partitioning/Sharding
* Disable journaling  

## Two-phase commit vs Compensation

* Compensation
  * Writing off the transaction if it fails, deciding to discard erroneous transactions and reconciling later. 
  * Retry failed operations later on notification. 
* In a reservation system or a stock sales ticker, these are not likely to meet your requirements. 
* For other kinds of applications, such as billing or ticketing applications, this can be acceptable.
* Starbucks Does Not Use Two-Phase Commit
  * https://www.enterpriseintegrationpatterns.com/ramblings/18_starbucks.html

## Sharding (Share nothing)

* Rather keeping all customer in one table, divide up that single customer table so that each database has only some of the records, with their order preserved? Then, when clients execute queries, they put load only on the machine that has the record they’re looking for, with no load on the other machines.
* How to shard?
  * Name-wise sharding issues like customer names that starts with "Q,J" will have less, whereas customer name starts with J, M and S may be busy
  * Shard by DOB, SSN, HASH
* Three basic strategies for determining shard structure  
  * Feature-based shard or functional segmentation
  * Key-based sharding - one-way hash on a key data element and distribute data across machines according to the hash.
  * Lookup Table

# [NoSQL](http://nosql-database.org/)

* Key-Value stores - Oracle Coherence, Redis, and MemcacheD, Amazon’s Dynamo DB, Riak, and Voldemort.
* Column stores - Cassandra, Hypertable, and Apache Hadoop’s HBase.
* Document stores -  MongoDB and CouchDB.
* Graph databases - Blazegraph, FlockDB, Neo4J, and Polyglot
* Object databases -  db4o and InterSystems Caché
* XML databases - Tamino from Software AG and eXist.


## Apache Cassandra

* “Apache Cassandra is distributed, decentralized, elastically scalable, highly available, fault-tolerant, tuneably consistent, row-oriented database that bases its distribution design on Amazon’s Dynamo and its data model on Google’s Bigtable.”
* No SPOF
  * Is not Master/Slave (MongoDB is master/slave)
* Tuneably consistent (not Eventual Consisten as majority believes)

## Cassandra Features

* CQL (moved from Thrift API)
* Secondary indexes
* Materialized views
* Lightweight transactions
* Consistency = Replication factor + consistency level  (delegated to clients)
  * Consistency level <= replication factor
* Cassandra is not column-oriented (it is row oriented)
* Column values are stored according to a consistent sort order, omitting columns that are not populated

## Consistency Forms

* Strict (or Serial) Consistency
  * Works on Single CPU
* Casual Consistency (like Casuation)
  * The cause of events to create some consistency in their order.
  * Writes that are potentially related must be read in sequence. 
  * If two different, unrelated operations suddenly write to the same field, then those writes are inferred not to be causally related.
* Weak (or) Eventual Consistency
  * Rather than dealing with the uncertainty of the correctness of an answer, the data is made unavailable until it is absolutely certain that it is correct


## Row-Oriented

* Cassandra’s data model can be described as a partitioned row store, in which data is stored in sparse multidimensional hashtables. 
* “Sparse” means that for any given row you can have one or more columns, but each row doesn’t need to have all the same columns as other rows like it (as in a relational model). 
* “Partitioned” means that each row has a unique key which makes its data accessible, and the keys are used to distribute the rows across multiple data stores.

## Always writeable

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


## Notable tools
* Sstableloader - Bulk loader
* Leveled compaction strategy - for faster reads
* Atomic batches
* Lightweight transactions were added using the Paxos consensus protocol
* User-defined functions
* Materialized views (sometimes also called global indexes) 

## Few use cases

* Cassandra has been used to create a variety of applications, including a windowed time-series store, an inverted index for document searching, and a distributed job priority queue.

## Updated CAP - Brewer's Theorem

* Brewer now describes the “2 out of 3” axiom as somewhat misleading. He notes that designers only need sacrifice consistency or availability in the presence of partitions, and that advances in partition recovery techniques have made it possible for designers to achieve high levels of both consistency and availability.


## Quotes
* If you can’t split it, you can’t scale it. "Randy Shoup, Distinguished Architect, eBay"
* [“The Case for Shared Nothing” - Michael Stonebreaker](http://db.cs.berkeley.edu/papers/hpts85-nothing.pdf)

## References
* [Cassandra Guide](https://github.com/jeffreyscarpenter/cassandra-guide)
* [Cassandra Paper](http://www.cs.cornell.edu/projects/ladis2009/papers/lakshman-ladis2009.pdf)
* (AWS re:Invent 2018: Amazon DynamoDB Deep Dive: Advanced Design Patterns for DynamoDB (DAT401))[https://www.youtube.com/watch?time_continue=33&v=HaEPXoXVf2k]
* [amazon-dynamodb-deep-dive-advanced-design-patterns-for-dynamodb](https://www.slideshare.net/AmazonWebServices/amazon-dynamodb-deep-dive-advanced-design-patterns-for-dynamodb-dat401-aws-reinvent-2018pdf)
* [Best Practices NOSql](https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/best-practices.html)
* CassandraSummit
