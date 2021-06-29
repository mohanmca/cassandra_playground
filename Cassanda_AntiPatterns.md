* [Anti-patterns in Cassandra - 2.2](https://docs.datastax.com/en/cassandra-oss/2.2/cassandra/planning/planPlanningAntiPatterns.html)
* [Anti-patterns-Planning and testing DataStax Enterprise deployments](https://docs.datastax.com/en/dse-planning/doc/planning/planningAntiPatterns.html)
* [Anti-patterns which all Cassandra users must know](https://morioh.com/p/9e872f2fcd88)
* [Anti-patterns which all Cassandra users must know](https://medium.com/analytics-vidhya/anti-patterns-which-all-cassandra-users-must-know-1e54c60ff1fa)
* [Cassandra nice use cases and worst anti patterns](https://www.slideshare.net/doanduyhai/cassandra-nice-use-cases-and-worst-anti-patterns)
* [Apache Cassandra Anti Patterns-2012](https://www.infoq.com/presentations/Apache-Cassandra-Anti-Patterns/)
* [Cassandra anti-patterns: Queues and queue-like datasets](https://irrlab.com/2016/04/14/cassandra-anti-patterns-queues-and-queue-like-datasets/)
* [Cassandra Anti-Patterns](https://www.tomaz.me/slides/2014-24-03-cassandra-anti-patterns/#/)
* Building a queue, Frequently updated data, Query flexibility, Incorrect use of BATCH, Querying an entire table
*
```pre
            Using Apache Cassandra as a backend for a queue or queue-like structure is never going to end well. We have discussed at length that, due to Cassandra's log-based storage engine, inserts, updates, and deletes are all treated as writes. Well, what does a queue do? It does the following:

                Data gets written to a queue.
                Data gets updated while it's in the queue (example: status). Sometimes several times.
                When the data is no longer required, it gets deleted.

            Given what we have covered about how Cassandra handles things, such as in-place updates (obsoleted data) and deletes (tombstones), it should be obvious that this is not a good idea. Remember, a data model built to accommodate a small amount of in-place updates or deletes is fine. A data model that relies on in-place updates and deletes isn’t going to make anyone happy in the end.
```
