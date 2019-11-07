## Cassandra node

* Cassandra designed for JBOD (just a bunch of disk) setup
* If disk is attached to ethernet, it is wrong choice, hence Cassandra not tuned to work with SAN/NAS
* A node can work with
  * 6K to 12K transaction
  * 2-4TB of data on ssd

### nodetool

* info - jvm statistics
* status  - all the nodes status (how this node see other nodes in cluster)


## Ring

* Apache cassandra cluster - Collection of nodes
* Node that we connect is co-ordinator node
* Each node is responsible for range of data
  * Token range
* Every node can deduce which node owns the range of token (range of data)
* Co-ordinate sends to acknowledge to client
  * co-ordinator-node !== data-node
* Range
  * -(2^63)-1 to 2^63
* Right partitioner would place the data widely
  * MD5 partitioner (random and even)


## Driver

* Client could intelligently use node status and clutser
* Client would use different policies
  * TokenAwarePolicy
  * RoundRobinPolicy
  * DCAwareRoundRobinPolicy
* Driver can use the  TokenAwarePolicy and directly deal with the node that is responsbile for the data, internally it would avoid one more hop (co-ordinator-node === data-node) 

## When a new node joins the ring

* Gossips out to seed-node (seed-nodes are configured in cassandra.yaml)
* Other node finds where could new node could fit (could be manual or automatic)
* Seed nodes communicate cluster topology to the joining new-node
* Joining, Leaving, UP and Down are the state of the nodes
*  