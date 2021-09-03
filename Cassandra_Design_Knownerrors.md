## Cassandra Design - Hot spot keys

* Another way you could reduce the hot spot for an object in Cassandra is to make additional copies of it by inserting it into additional rows of a table. 
* The rows are accessed on nodes by the compound partition key, so one field of the partition key could be a "copy_number" value, and when you go to read the object, you randomly set a copy_number value (from 0 to the number of copy rows you have) so that the load of reading the object will likely hit a different node for each read (since rows are hashed across the cluster based on the partition key). 
* This approach would give you more granularity at the object level compared to changing the replication factor for the whole table, at the cost of more programming work to manage randomly reading different rows.
* [Hot object](https://stackoverflow.com/questions/27879617/change-replication-factor-of-selected-objects)

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
