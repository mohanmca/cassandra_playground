## Course DSE installation

```bash
ubuntu@ds201-node1:~$ tar -xf dse-6.0.0-bin.tar.gz
mv dse-6.0.0 node
. labwork/config_node
cd node/bin
./dse cassandra
./dsetool status
```

## Nodetool vs DSEtool

* nodetool -- only Apache Cassandra
* dsetool -- Apache Cassandra™, Apache Spark™, Apache Solr™, Graph

## Nodetool  Gauge the server performance

```SQL
./nodetool describecluster
./nodetool getlogginglevels
./nodetool setlogginglevels org.apache.cassandra TRACE
## Create and populate garbage to stress the cluster
/home/ubuntu/node/resources/cassandra/tools/bin/cassandra-stress write n=50000 no-warmup -rate threads=2
./nodetool flush
./nodetool status
```

## Find all the material view of a keyspace

```bash
SELECT view_name FROM system_schema.views where keyspace_name='myKeyspace';
```

## How to find number of partitions/node-of partition in a table

* ./nodetool tablestats -H keyspace.tablename;
* select token(tag) from killrvideo.videos_by_tag;
  * ./nodetool getendpoints killrvideo videos_by_tag -1651127669401031945
  * ./nodetool getendpoints keyspace table_name #token_number;
  * ./nodetool ring
  * ./nodetool getendpoints killrvideo videos_by_tag 'cassandra'
  * ./nodetool getendpoints killrvideo videos_by_tag 'datastax'

## Cassandra Node (Server/VM/H/W)

* Runs a java process (JVM)
* Only supported on local storage or direct attached storage
* If your disk has ethernet cable, It is wrong choice
  * Don't run it on SAN (not supported)
* Typically 6000-12000 TXN per second / core
* How much data a single Cassandra node can handle? 
  * 2 -to- 4 TB
* How do you manage node?
  * Use nodetool utilitiy  

## Cassandra Ring (The cluster)

* Any node can act as a co-ordinator to incoming data
* How does co-ordinator knows the node that handles the data?
  * Co-ordinator has token-range, Token range is all about paritition key range and node
  * (2^^63)-1 --> (-2^^63) - ranges of tokents are available
  * 20 digit number - 18,446,744,073,709,551,616

## How new nodes join the ring

* Uses seed-nodes configured in new-nodes Cassandra.yaml
  * SeedNode provider could be rest-api
* Node joins by communicating with any seed-nodes
* Seed nodes communicate cluster topology to the joining node
* Once the new-node joins the cluster, all the nodes are peers
  * Node status could be - Leaving/Joining/Up/Running - UN (Up and Normal)

## Peer-to-Peer

* Leader-Follower fails when we do sharding
  * Leader-Follower model is just client-server model on the service side
* Leader follower would fail other leaders are read-replicas, and also supports sharding
* If Leader and follower can't each other due to network glitch, It becomes even more error prone.
* In Cassandra, It is peer-to-peer
  * No node is superior than other
  * Everyone is peer

## Why do we need VNode?

* When adding a new physical node, how to equally distribute data from existing nodes into new node?
* If overloaded node, is distributing data to new node, it would become additional burden for existing overloaded node
* VNode also help distributing data consistently acorss nodes
  * Without vnode, Cluster has to store continuous sequential ranges of data into node
  * VNode automate token range assignment
* It helps making easier to bootstrap new node
* Adding/removing nodes with vnodes helps keep the cluster balanced
* By default each node has 128 vnodes
## How to enable VNode?

* num_tokens value should greather than 1 in Cassandra.yaml
* num_tokens = 1 ## Disable vnode

## Gossip protocol (nodemeta data is the subject)

* No centralized service to spread the information - How do we share information?
* Gossip protocol helps to spread information (despite peer-to-peer)
* Every second a node pick one-to-three other nodes to gossip with
  * It might pick same node successive time, they don't keep track of the node that they gossped with

## What do nodes Gossip about?

* They gossip about node-meta-data
  * Heartbeat, generation, version and load
* What is the difference between generation and version?
  * Generation - timestamp of when the node-bootstraps
  * version - counter incremented every-second

## What is Gossip data structure look like?

* EP: 127.0.0.1, HB:100:20, LOAD:86
* Endpoint, HeartBeat:generation:version, Load
* ```
EndPointState {
  HeartBeatState: {
    Generation: 5,
    Version: 22
  },
  ApplicationState: {
    Status: Normal/Leaving/Left/Joining/Removing,
    DC: CDC1,
    RACK: sg-2a,
    SCHEMA: c2acbn,
    Severity=0.75,
  }
}
```

## What is Gossip protocol?

* Initiator - Sends SYN
* Receiver - Receives SYN and Constructs and replies with ACK message
* Initiator - Gets ACK reponse from receiver  
* Initiator - ACKs the ACK (from receiver) using ACK2 reponse

## How to find more details about Gossip

* project = CASSANDRA AND component = "Cluster/Gossip"
* https://issues.apache.org/jira/browse/CASSANDRA-16588?jql=project%20%3D%20CASSANDRA%20AND%20component%20%3D%20%22Cluster%2FGossip%22


## Node failure detector

* Every node declares their own status.
* Every node detects failure of peer-node
* They don't send their assumptions/evaluations during gossip (nodes don't send their judgement about other nodes)

## Snitch (meaning informer)

* Snitch - toplogy of cluster
* Informs each IP and its physical location
  * DC and Rack
* HttpPropertyFileSnitch
* SimpleSnitch
* Cloud-Based snitches
  * EC2Snitch
  * EC2MultiRegionSnitch
  * RackInferrringSnitch
  * GoogleCloudSnitch
  * CloudStackSnitch
* PropertyFileSnitch
* RackInferingSnitch (don't rely on it)
  * ip=DC1:RACK2
  * ip2=DC2:RACK2
  * 110:100:200:105
    * 110 - Country (ignored by snitcher)
    * 100 - DC octet (second ip octet)
    * 200 - rack octet
    * 105 - node octet
  * cassandra-rackdc.properties can contain the data  

## What is the role of DynamicSnitch

* It uses underlying snitch
* Maintains pulse of each nodes performance
* Determines which node to query based on performance
* Turned on by default for all snitches

## Mandatory operational practice

* All nodes should use same snitch
* Changing network topology requires restarting all the nodes with latest snitch
* Run sequential repair and cleanup on each node

## Reference

* [Datastax videos](https://www.youtube.com/watch?v=69pvhO6mK_o&list=PL2g2h-wyI4Spf5rzSmesewHpXYVnyQ2TS)
* [Datastax Virtual-box VM](https://s3.amazonaws.com/datastaxtraining/VM/DS201-VM-6.0.ova)
