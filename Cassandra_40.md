## What is new with Apache Cassandra 4.0

1. No new features in core-engine
1. Improve efficiency, faster, reliable and easier to use.
1. New features
   1. Virtual table - Access to metadata about node
        1. Virtual table doesn't eliminate JMX (still available)
   1. Query logger (full query logger and audit logger)
   1. Improvements in internode communication
        1. Scalability, Reliablity and Improved Performance
   1. When new nodes are joining, zero copy helps to copy from disk to node (via network)
   1. Improvements to incremental repair
   1. Support for java-11 (New GC)


## Reference

* [New Features Cassandra 4.0](https://www.datastax.com/learn/whats-new-for-cassandra-4/introduction)