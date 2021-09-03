## What is the process in changing replication factor?

1. Generate old keyspace CQL
1. Repeat next two steps for each count of RF changes
    1. Update Keyspace with one-more or one-less replication factor and execute
    1. Run nodetool repair on all the impacted nodes
1. Replication factor should be incremented one at a time (Never go from 3 to 5, Always go from 3->4->5)
1. Always change all the keyspace whose 'class' : 'NetworkTopologyStrategy', such as  system_auth

## Concrete steps

1. Use CQL
1. Decribe Keyspace
1. Alter keyspace seragent WITH replication = {'class': 'NetworkTopologyStrategy', 'dc1' : 3, 'dc2' : 2};
1. On each affected node, run nodetool repair with the -full option. - Run nodetool repair --full
1. Describe Keyspace and validate changes are reflected
1. Connect to any node and query the data

## Reference

* [Updatring Replication Factor](https://docs.datastax.com/en/cql-oss/3.x/cql/cql_using/useUpdateKeyspaceRF.html?hl=updating%2Creplication%2Cfactor)
* [How to modify replication factor in Cassandra cluster](https://kb.juniper.net/InfoCenter/index?page=content&id=KB34477&cat=CONTRAIL&actp=LIST)