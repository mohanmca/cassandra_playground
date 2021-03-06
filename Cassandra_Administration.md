## (Section: Administration) -  DSE Cassandra Course topics

1. Install and Start Apache Cassandra™
1. CQL
1. Partitions
1. Clustering Columns
1. Application Connectivity and Drivers
1. Node
1. Ring
1. VNodes
1. Gossip
1. Snitches
1. Replication
1. Consistency Levels
1. Hinted Handoff
1. Read Repair
1. Node Sync
1. Write Path
1. Read Path
1. Compaction
1. Advanced Performance

## (Section: Administration) -  Course DSE installation

```bash
ubuntu@ds201-node1:~$ tar -xf dse-6.0.0-bin.tar.gz
mv dse-6.0.0 node
. labwork/config_node
cd node/bin
./dse cassandra
./dsetool status
```

## (Section: Administration) -  Nodetool vs DSEtool

* nodetool -- only Apache Cassandra
* dsetool -- Apache Cassandra™, Apache Spark™, Apache Solr™, Graph

## (Section: Administration) -  Nodetool  Gauge the server performance

```SQL
./nodetool describecluster
./nodetool getlogginglevels
./nodetool setlogginglevels org.apache.cassandra TRACE
## (Section: Administration) -  Create and populate garbage to stress the cluster
/home/ubuntu/node/resources/cassandra/tools/bin/cassandra-stress write n=50000 no-warmup -rate threads=2
./nodetool flush
./nodetool status
```

## (Section: Administration) -  Find all the material view of a keyspace

```bash
SELECT view_name FROM system_schema.views where keyspace_name='myKeyspace';
```

## (Section: Administration) -  How to find number of partitions/node-of partition in a table

* ./nodetool tablestats -H keyspace.tablename;
* select token(tag) from killrvideo.videos_by_tag;
  * ./nodetool getendpoints killrvideo videos_by_tag -1651127669401031945
  * ./nodetool getendpoints keyspace table_name #token_number;
  * ./nodetool ring
  * ./nodetool getendpoints killrvideo videos_by_tag 'cassandra'
  * ./nodetool getendpoints killrvideo videos_by_tag 'datastax'

## (Section: Administration) -  Cassandra Node (Server/VM/H/W)

* Runs a java process (JVM)
* Only supported on local storage or direct attached storage
* If your disk has ethernet cable, It is wrong choice
  * Don't run it on SAN (not supported)
* Typically 6000-12000 TXN per second / core
* How much data a single Cassandra node can handle? 
  * 2 -to- 4 TB
* How do you manage node?
  * Use nodetool utilitiy  

## (Section: Administration) -  Cassandra Ring (The cluster)

* Any node can act as a co-ordinator to incoming data
* How does co-ordinator knows the node that handles the data?
  * Co-ordinator has token-range, Token range is all about paritition key range and node
  * (2^^63)-1 --> (-2^^63) - ranges of tokents are available
  * 20 digit number - 18,446,744,073,709,551,616

## (Section: Administration) -  How new nodes join the ring

* Uses seed-nodes configured in new-nodes Cassandra.yaml
  * SeedNode provider could be rest-api
* Node joins by communicating with any seed-nodes
* Seed nodes communicate cluster topology to the joining node
* Once the new-node joins the cluster, all the nodes are peers
  * Node status could be - Leaving/Joining/Up/Running - UN (Up and Normal)

## (Section: Administration) -  Peer-to-Peer

* Leader-Follower fails when we do sharding
  * Leader-Follower model is just client-server model on the service side
* Leader follower would fail other leaders are read-replicas, and also supports sharding
* If Leader and follower can't each other due to network glitch, It becomes even more error prone.
* In Cassandra, It is peer-to-peer
  * No node is superior than other
  * Everyone is peer

## (Section: Administration) -  Why do we need VNode?

* When adding a new physical node, how to equally distribute data from existing nodes into new node?
* If overloaded node, is distributing data to new node, it would become additional burden for existing overloaded node
* VNode also help distributing data consistently acorss nodes
  * Without vnode, Cluster has to store continuous sequential ranges of data into node
  * VNode automate token range assignment
* It helps making easier to bootstrap new node
* Adding/removing nodes with vnodes helps keep the cluster balanced
* By default each node has 128 vnodes


## (Section: Administration) -  How to enable VNode?

* num_tokens value should greather than 1 in Cassandra.yaml
* num_tokens = 1 ## Disable vnode

## (Section: Administration) -  Gossip protocol (nodemeta data is the subject)

* No centralized service to spread the information - How do we share information?
* Gossip protocol helps to spread information (despite peer-to-peer)
* Every second a node pick one-to-three other nodes to gossip with
  * It might pick same node successive time, they don't keep track of the node that they gossped with

## (Section: Administration) -  What do nodes Gossip about?

* They gossip about node-meta-data
  * Heartbeat, generation, version and load
* What is the difference between generation and version?
  * Generation - timestamp of when the node-bootstraps
  * version - counter incremented every-second

## (Section: Administration) -  What is Gossip data structure look like?

* EP: 127.0.0.1, HB:100:20, LOAD:86
* Endpoint, HeartBeat:generation:version, Load
* 
  ```json
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

## (Section: Administration) -  What is Gossip protocol?

* Initiator - Sends SYN
* Receiver - Receives SYN and Constructs and replies with ACK message
* Initiator - Gets ACK reponse from receiver  
* Initiator - ACKs the ACK (from receiver) using ACK2 reponse

## (Section: Administration) -  How to find more details about Gossip

* project = CASSANDRA AND component = "Cluster/Gossip"
* https://issues.apache.org/jira/browse/CASSANDRA-16588?jql=project%20%3D%20CASSANDRA%20AND%20component%20%3D%20%22Cluster%2FGossip%22


## (Section: Administration) -  Sample Gossipinfo

```json
ubuntu@ds201-node1:~/node1/bin$ ./nodetool gossipinfo
/127.0.0.1
  generation:1623251077
  heartbeat:732
  STATUS:32:NORMAL,-117951217631614635
  LOAD:717:6930897.0
  SCHEMA:322:08e0aca4-d15e-3357-8876-0e7cc6cc60ba
  DC:50:Cassandra
  RACK:18:rack1
  RELEASE_VERSION:4:4.0.0.2284
  NATIVE_TRANSPORT_ADDRESS:3:127.0.0.1
  X_11_PADDING:677:{"dse_version":"6.0.0","workloads":"Cassandra","workload":"Cassandra","active":"true","server_id":"08-00-27-32-1E-DD","graph":false,"health":0.1}
  NET_VERSION:1:256
  HOST_ID:2:d8e387df-71c3-4584-b911-bb8867f66b8b
  NATIVE_TRANSPORT_READY:86:true
  NATIVE_TRANSPORT_PORT:6:9041
  NATIVE_TRANSPORT_PORT_SSL:7:9041
  STORAGE_PORT:8:7000
  STORAGE_PORT_SSL:9:7001
  JMX_PORT:10:7199
  TOKENS:31:<hidden>
/127.0.0.2
  generation:1623251055
  heartbeat:736
  STATUS:61:NORMAL,-1182052107726675062
  LOAD:699:7303102.0
  SCHEMA:328:08e0aca4-d15e-3357-8876-0e7cc6cc60ba
  DC:65:Cassandra
  RACK:18:rack1
  RELEASE_VERSION:4:4.0.0.2284
  NATIVE_TRANSPORT_ADDRESS:3:127.0.0.1
  X_11_PADDING:680:{"dse_version":"6.0.0","workloads":"Cassandra","workload":"Cassandra","active":"true","server_id":"08-00-27-32-1E-DD","graph":false,"health":0.1}
  NET_VERSION:1:256
  HOST_ID:2:55c76577-e187-4948-807f-a95026a7c4dd
  NATIVE_TRANSPORT_READY:95:true
  NATIVE_TRANSPORT_PORT:6:9042
  NATIVE_TRANSPORT_PORT_SSL:7:9042
  STORAGE_PORT:8:7000
  STORAGE_PORT_SSL:9:7001
  JMX_PORT:10:7299
  TOKENS:60:<hidden>
```


## (Section: Administration) -  Node failure detector

* Every node declares their own status.
* Every node detects failure of peer-node
* They don't send their assumptions/evaluations during gossip (nodes don't send their judgement about other nodes)

## (Section: Administration) -  Snitch (meaning informer)

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

## (Section: Administration) -  What is the role of DynamicSnitch

* It uses underlying snitch
* Maintains pulse of each nodes performance
* Determines which node to query based on performance
* Turned on by default for all snitches

## (Section: Administration) -  Mandatory operational practice

* All nodes should use same snitch
* Changing network topology requires restarting all the nodes with latest snitch
* Run sequential repair and cleanup on each node

## (Section: Administration) -  Replication with RF=1

* Every node is responsible for certain token range
* Partitioner finds the token from the data (MurMurPartitioner)
* RF=1 - Only one copy of the data (source alone)
* Let us say we have token range or 0, 13, 25, 38, 50, 63, 75, 88, 100
* If we try to insert data with token value of 59. 
  * Node that owns token higher than 59 is (here 63 is choosen)
  * Node that owns 50 and above.. but below 63 would store the data

## (Section: Administration) -  Replication with RF>=2

* Data would be stored in node that supposed to own token range
* For every RF>1, Node who is neighbour (token range higher) also gets copy of the data
* Let us say if we try to store token()==59 and RF=2
  * Node that owns 50-63 would get a copy
  * Node that owns 63-75 would also get a copy


## (Section: Administration) -  Replication with RF>=2 and Cross DataCenter

* Cross DC replication is hard
* We can have different RF for each DC
* Country specific replication can be controlled at the keyspace level
* Remote Co-ordinator would act as a local-cordinator to replicate data within remote DC

## (Section: Administration) -  Consistency in CQL

```sql
consistency ANY;
##Consistency level set to ANY.

select * from videos_by_tag;
##InvalidRequest: Error from server: code=2200 [Invalid query] message="ANY ConsistencyLevel is only supported for writes"

INSERT INTO videos_by_tag(tag, added_date, video_id, title)  VALUES ('cassandra', '2016-2-11', uuid(), 'Cassandra, Take Me Home');

select * from videos_by_tag;InvalidRequest: Error from server: code=2200 [Invalid query] message="ANY ConsistencyLevel is only supported for writes"
```

## (Section: Administration) -  Reference

* [Datastax videos](https://www.youtube.com/watch?v=69pvhO6mK_o&list=PL2g2h-wyI4Spf5rzSmesewHpXYVnyQ2TS)
* [Datastax Virtual-box VM](https://s3.amazonaws.com/datastaxtraining/VM/DS201-VM-6.0.ova)
