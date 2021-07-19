## Cassandra production error

* RANGE SLICE Messages were dropped
* StorageProxy.readRegular(group, consistencyLevel, queryStartNanoTime);
* SinglePartitionCommand.java[1176]/StorageProxy.read(this, consistency, clientState, queryStartNanoTime);


## (Server side) - com.datastax.oss.driver.api.core.connection.ConnectionIntiException.. ssl should be configured
* Client side should enable ssl ; true (in spring-boot application.yaml)
  * spring.data.cassandra.ssl: true

## (Client side) - [SSLL SSLV3_ALERT_HANDSHAKE_FAILURE]
* Ensure you configured SSL on cient side

## (Client side) - Since you provided explicit contact points, the local DC must be explicitly set (see basic.load-balancing-policy.local-datacenter)
* spring.data.cassandra.local-datacenter: asiapac
