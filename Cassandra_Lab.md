```bash
wget http://archive.apache.org/dist/cassandra/4.0-alpha4/apache-cassandra-4.0-alpha4-bin.tar.gz
wget http://archive.apache.org/dist/cassandra/4.0-rc2/apache-cassandra-4.0-rc2-bin.tar.gz 

tar xvfz http://archive.apache.org/dist/cassandra/4.0-rc2/apache-cassandra-4.0-rc2-bin.tar.gz 
cd apache-cassandra-4.0-rc2
bin/cassandra -R
bin/stop-server
$>user=`whoami`;pkill -u $user -f cassandra
```

# How to find the Cassandra and CQL (Native protocol supported versions) version?
1. grep -m 1 -A 2 "Cassandra version" logs/system.log
1. 
    ```pre
        $ grep -m 1 -C 1 "Cassandra version" logs/system.log 
        INFO  [main] 2021-07-16 09:53:21,299 QueryProcessor.java:150 - Preloaded 0 prepared statements
        INFO  [main] 2021-07-16 09:53:21,301 StorageService.java:615 - Cassandra version: 4.0-alpha4
        INFO  [main] 2021-07-16 09:53:21,302 StorageService.java:616 - CQL version: 3.4.5    
    ```

# How to find where Cassandra is initializing internal data structures, such as caches:
1. grep -m 4 "CacheService.java" logs/system.log

## How to search for terms like JMX, gossip, and listening:

* 
    ```bash
        grep -m 1 "JMX" logs/system.log
        grep -m 1 "gossip" logs/system.log
        grep -m 1 "listening" logs/system.log
    ```
## How to confirm Cassandra is running normally?
* 
    ```bash
        grep -m 1 -C 1 "state jump" logs/system.log
        INFO  [main] 2021-07-16 09:53:22,619 StorageService.java:2486 - Node 127.0.0.1:7000 state jump to NORMAL
    ```
## Howt Classify CQL

1. CQL-Shell commands
    1. CAPTURE  CLS          COPY  DESCRIBE  EXPAND  LOGIN   SERIAL  SOURCE   UNICODE 
    1. CLEAR    CONSISTENCY  DESC  EXIT      HELP    PAGING  SHOW    TRACING

1. CQL topics