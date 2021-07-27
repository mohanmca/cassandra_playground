## (Section: LWT) -  Why we need Lightweight Transaction/Linearizable Consistency?

1. Strong consistency is not enough to prevent race conditions in cases where clients need to read, then write data.
1. If Cassandra needs to perform read before write (write only if read result matches with certain assumption), Strong consistency won't work
1. Example: In creating a new user account, we’d like to make sure that the user record doesn’t already exist, lest we unintentionally overwrite existing user data. So first we do a read to see if the record exists, and then only perform the create if the record doesn’t exist.

## (Section: LWT) -  What is lightweight transaction (LWT) mechanism?

1. LWT provides linearizable consistency
1. LWT means that transaction like to guarantee that no other client can come in between read and write queries with their own modification.
1. Cassandra’s LWT implementation is based on Paxos.

## (Section: LWT) -  What is lightweight transaction (LWT) Restrictions?
1. Cassandra’s lightweight transactions are limited to a single partition. 
1. Cassandra’s LWT is more expensive than a regular write, think carefully about your use case before using LWTs.


## (Section: LWT) -  What is the purpose of Paxos?

1. Paxos is a consensus algorithm that allows distributed peer nodes to agree on a proposal
1. Paxos can perform transaction without requiring a leader to coordinate a transaction. 
1. Paxos and other consensus algorithms emerged as alternatives to traditional two-phase commit-based approaches to distributed transactions (see the note, The Problem with Two-Phase Commit).

## (Section: LWT) -  How Paxos algorithm works between nodes?

1. The basic Paxos algorithm consists of two stages: prepare/promise and propose/accept. 
1. To modify data, a coordinator node can propose a new value to the replica nodes, taking on the role of leader. \
1. Other replica nodes may act as leaders simultaneously for other modifications. 
1. Each replica node checks the proposal, and if the proposal is the latest it has seen, it promises to not accept proposals associated with any prior proposals. 
1. Each replica node also returns the last proposal it received that is still in progress. 
1. If the proposal is approved by a majority of replicas, the leader commits the proposal, but with the caveat that it must first commit any in-progress proposals that preceded its own proposal.

## (Section: LWT) -  The Cassandra implementation of Paxos algorithm (to support read-before-write semantics) 

1. Prepare/Promise
1. Read/Results
1. Propose/Accept
1. Commit/Ack

## (Section: LWT) -  The Cassandra LOCAL_SERIAL and LWT 

1. A SERIAL consistency level allows reading the current (and possibly uncommitted) state of data without proposing a new addition or update. 
1. If a SERIAL read finds an uncommitted transaction in progress, Cassandra performs a read repair as part of the commit. 
1. We also have a LOCAL_SERIAL, which is like SERIAL for the current data center
1. [Readconsistencylevels](https://docs.datastax.com/en/cassandra-oss/3.0/cassandra/dml/dmlConfigConsistency.html#Readconsistencylevels)
1. [DmlLtwtTransactions](https://docs.datastax.com/en/cassandra-oss/3.0/cassandra/dml/dmlLtwtTransactions.html)
1. [Dynamo](https://cassandra.apache.org/doc/latest/architecture/dynamo.html#tunable-consistency)

## (Section: DS210) -  How to create anki from this markdown file
```
mdanki Cassandra_Transaction_Anki.md Cassandra_Transaction_Anki.apkg --deck "Mohan::Cassandra::Txn::Paxos"
```