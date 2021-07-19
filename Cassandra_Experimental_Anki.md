
## (Section: Experimental) - MV - Limitations?

1. A view and a base table must belong to the same keyspace;
1. No base table static column can be included in a view;
1. All base table primary key columns must become materialized view primary key columns;
1. At most one base table non-primary key column can become a materialized view primary key column;
1. All view primary key columns must be restricted to not allow nulls.
1. It is possible that a materialized view and a base table become out-of-sync. Cassandra does not provide a way to automatically detect and fix such inconsistencies
   1. Applications can drop and recreate the materialized view, which is not an ideal solution in production
1. Even though writes to base tables and views are asynchronous
    1. Each materialized view slows down writes to its base table by approximately 10%. 
    1, Cassandra community recommends to not create more than two materialized views per table.
1.     
    ```sql
    cqlsh:killr_video> CREATE MATERIALIZED VIEW IF NOT EXISTS 
                 users_by_name_age AS SELECT * FROM users
                 WHERE name IS NOT NULL AND email IS NOT NULL AND age  IS NOT NULL
                 PRIMARY KEY ((name, age), email);
    InvalidRequest: Error from server: code=2200 [Invalid query] message="Cannot include more than one non-primary key column in materialized view primary key (got name, age)"
    ```

## (Section: Experimental) - How to mitigate the risk of base-view inconsistency?

1. Use consistency levels LOCAL_QUORUM and higher for base table writes.
1. Standard recommended repair procedures should be performed on both tables and views regularly or whenever a node is removed, replaced or started back up.

## (Section: Experimental) - Example of MVs.

1.
    ```sql 
        CREATE TABLE users (
            email TEXT, name TEXT,
            age INT,date_joined DATE,
            PRIMARY KEY ((email))
        );

        CREATE MATERIALIZED VIEW IF NOT EXISTS users_by_name AS SELECT * FROM users    WHERE name IS NOT NULL AND email IS NOT NULL PRIMARY KEY ((name), email);
        CREATE MATERIALIZED VIEW IF NOT EXISTS users_by_date_joined AS SELECT * FROM users WHERE date_joined IS NOT NULL AND email IS NOT NULL PRIMARY KEY ((date_joined), email);
    ```


## (Section: Experimental) - What are all types of secondary index.

1. Regular secondary index (2i): a secondary index that uses hash tables to index data and supports equality (=) predicates.
1. SSTable-attached secondary index (SASI): an experimental and more efficient secondary index that uses B+ trees to index data and can support equality (=), inequality (<, <=, >, >=) and even text pattern matching (LIKE).

## (Section: Experimental) - Use cases for indexes in Cassandra production (specific cases):

1. Real-time transactional query: retrieving rows from a large multi-row partition, when both a partition key and an indexed column are used in a query.
1. Expensive analytical query: retrieving a large number of rows from potentially all partitions, when only an indexed low-cardinality column is used in a query. 
    1. A low-cardinality column is characterized by a large number of duplicates stored in it and a limited data range for its possible values.
1.
    ```sql
    Retrieve rows based on a rating value:
    -- Real-time transactional query
    SELECT * FROM ratings_by_movie WHERE title  = 'Alice in Wonderland' AND year = 2010 AND rating = 9;
    -- Expensive analytical query
    SELECT * FROM ratings_by_movie WHERE rating = 9;

    --Create the SASI:
    CREATE CUSTOM INDEX IF NOT EXISTS rating_ratings_by_movie_sasi ON ratings_by_movie (rating)USING 'org.apache.cassandra.index.sasi.SASIIndex';
    --Retrieve rows based on a rating range:
    -- Real-time transactional query
    SELECT * FROM ratings_by_movie    WHERE title  = 'Alice in Wonderland'    AND year   = 2010    AND rating >= 8 AND rating <= 10;
    -- Expensive analytical query
    SELECT * FROM ratings_by_movie    WHERE rating >= 8 AND rating <= 10;
    ```    
## (Section: Experimental) - What is the main real-time transactional use case for a secondary index?

1. Retrieving rows from a large multi-row partition

## (Section: Experimental) - Limitations of indexes in Cassandra:

1. For all other use cases, which usually involve high-cardinality columns, you should always prefer **tables and materialized views** to secondary indexes.
1. The general recommendation is to have at most one secondary index per table.


## (Section: Experimental) - Secondary index limitations

1. To understand secondary index limitations, let's take a closer look at how they work in comparison to Cassandra tables and materialized views.
1. Tables and materialized views are examples of distributed indexing. A table or view data structure is distributed across all nodes in a cluster based on a partition key. When retrieving data using a partition key, Cassandra knows exactly which replica nodes may contain the result. For example, given a 100-node cluster with the replication factor of 5, at most 5 replica nodes and 1 coordinator node need to participate in a query.
1. In contrast, secondary indexes are examples of local indexing. A secondary index is represented by many independent data structures that index data stored on each node. When retrieving data using only an indexed column, Cassandra has no way to determine which nodes may have necessary data and has to query all nodes in a cluster. For example, given a 100-node cluster with any replication factor, all 100 nodes have to search their local index data structures. This does not scale well.
1. Therefore, for real-time transactional queries, you should only use a secondary index when a partition key is also known, such that your query retrieves rows from a known partition based on an indexed column. In this case, Cassandra takes advantage of both distributed and local indexing.
1. Secondary indexes can also be beneficial to distribute processing across all nodes in a cluster for expensive analytical queries that retrieve a large subset of table rows based on a low-cardinality column. Such queries are generally run via Spark-Cassandra Connector, where retrieved data is further processed using Apache Spark™. Note, however, that Apache Solr™-based search indexes can do substantially better than secondary indexes in this use case.