## OperrationTimeout

1. https://docs.datastax.com/en/drivers/java/3.9/com/datastax/driver/core/SocketOptions.html
1. An 'OperationTimedOut' exception comes about when the driver read timeout is hit.  This is driven by SocketOptions.getReadTimeoutMillis()
1. Defaults to 12 seconds.  In the general case, you want this value to be greater than your timeouts in cassandra.yaml. 
1. This is meant to handle cases where cassandra doesn't respond even after its self imposed timeouts, which could indicate something wrong with the connection or the cassandra node you are communicating with in general (i.e. high GC activity).
1.  
    ```java
            Cluster cluster = Cluster.builder().addContactPoint("host1")
                    .withSocketOptions(new SocketOptions().setReadTimeoutMillis(13000))
                    .build();
    ```


## com.datastax.oss.driver.api.core.DriverTimeoutException: Query timed out after PT2S

```json
datastax-java-driver {
  profiles {
    slow {
      basic.request.timeout = 10 seconds
    }
  }
}
```

## Cassandra when not to use batch?

1. Batch do not yield any noticeable performance gain. The following articles should give you a good picture of their pros and cons:
  1. https://docs.datastax.com/en/cql-oss/3.3/cql/cql_using/useBatchGoodExample.html
  1. https://inoio.de/blog/2016/01/13/cassandra-to-batch-or-not-to-batch/
  1. https://www.batey.info/cassandra-anti-pattern-cassandra-logged.html
  1. https://www.batey.info/cassandra-anti-pattern-misuse-of.html
1. https://groups.google.com/a/lists.datastax.com/g/java-driver-user/c/8WHkWJ4j9I8/m/ZmS8gYg9BwAJ
  