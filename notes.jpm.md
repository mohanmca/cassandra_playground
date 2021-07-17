## Notes from Jonathan Koppenhofer about WebUI

* 5 years back, Cassandra web ui had unlimited access to everything, later they introduced roles
* Initial metrics dashboard was using Cassandra itself, nowadays it uses Promethus 

## New cluster checklist with 3 recommendation (mandated).

1. Same number of node in every dc
1. More than one node per dc
1. Exist at-least in 2 dc

## You should have Snapshot 

1. Snapshot currently stored locally
2. CEPAS and above, copy the snapshot to neptune
3. Cohesity (backup to any application from 3rd quarter by Cass team)

## Policy about daily backups

* Daily backups
* 2 hours backups


## Backup retention period

* 30 days
* 70
* 100
* 452 days

## Archiving service

* Cassandra S3 - Neptune integration can be used for archiving
* Universal archive service
* Select lcoation (export) - external backup mechanism in Cassandra web can be used for archival needs

## Snapshop Schedules (cluster-level)

* Cassweb > Schedules > Snapshots > Create
* Every schedule has
    * Name
    * Reocurring frequency
    * Keyspaces
    * Datacenters
    * Include-All-Nodes Or Nodes (we can select few nodes alone)
    * Schedule Expression
    * Timezone
    * Expire in Days (retention-period)
 

## What are Snapshots?

* hard-links to SS_Tables, it is full backup without additional space
* primary pointer to iNodes


## Snapshots roles

* Cluster-Amin role
    * Repair can be performed
* Controlled by IDAnyhwere and RSAM is required to get role

## Repave impact

* Hygene repave - detaches data disk and reinstalls the OS and Cassandra binary, attaches the disk
  * We would retain the data
* Cyber repave - Cassandra will lose the data
* IWP app alone will get the Neptune

## What are all the tools to recover

* Self service tools are available to restore the data


## Repairs

* Cluster_Admin alone can schedule repair
* What are not on scope for repair?
    * Timeseries data
    * System.tables data

## What is recommended repair?

* One complete repair between before every GC_GRACE_SECONDS
* Otherwise, we might endup with resurrected data, that are not required would endup within the cluster


## What is recommended GC_GRACE_SECONDS?

* 7 days is generally recommended (weekly)
* 1 day - few teams are quite aggressive
  * Can they complete full-repair within 24hrs?
* For first repair, repair process would take lots of time initially
  * Subsequent reapairs would be fast once clusters are in sync

## Repairs in Cassandra 4.0

* 5 fold increase for full-repair
* 6 fold increase for inc-repair
* More repairs than Cassandra 3.0
* 4.0 would repair only tables that was not repaired


## When is adhoc repairs suggested?

* Dropped mutation requires repair
* Dropped mutation clearly shows that data is not able to replicate
* It requires repair to fix the dropped mutation

## What is repair?

* Effectively reconcilling and fixing consistency
* This process is mandatory
* 2 days 19 hours is not uncommon time for a repair

## Repair (tunable thing)

* Repair intensity is .9 (90%), but we can bring down if there are plenty of compaction
    * While repair running - we can reduce intensity
* 90% is intensity, that means 10% of the time Cassandra would pause for compaction to kick-in and to completed
  * If too much of compaction requests piling up, reduce the intensity during repair process

## When could we run Repairs?

* It is okay to run during week-days
* Revisit data-model
* Too big intensity might cause Full GC (when MVs are there)
* We witnesses crashes during repair with full intensity
* We can actually pause the repairs anytime without issue

## Would repairs pause/stop in between cause any issue?

* No, whatever repair it had done is better than nothing
* Pausing/Stopping repair won't cause any issue


## Repair Paralellism

* Repair thread-count can't be altered, It is for reaper
* We use reaper as a repair tool, as default repair in Cassandra is a bit dangerous
* We support 3 parallelism
  * Sequential - individual token range in sequential order, longer time to complete
  * Parallel - multiple segement across DC all at once, highest speed.
  * DC-Aware - Parallel but within single DC (safer than Parallel, less resource intensive)

## BAU Repair

* Schedule at keyspace level
* Select required table, if you suspect table has lesser consistency than it supposed to be repaired.
* We can't exclude table.. 
  * we can include. We have choice for allow-list, but no choice for reject-list


## If you stuck with a segment

* Check logfiles
* Nodetool repair service check /clusterId/repair/{repairId}/segments
* Search for running segments
* Find how long it is running
* With above details, check the log files
* Materilaized view will not show few details
* No co-relation between size and repairs
  * Size is not a big problem for repair
  * There are repairs, that took 2 weeks, and few took 45 minutes
  * It depends on multiple factor, but no correlation

## Alerts

* Ensure required alerts are set using Cassweb-UI
* Setup READ SLA alerts
* Example: Write_latency_histogram's 99thPercentile > 2000
* APP mon used to have metrics data
* AlertHub - prefered
  * Alerthub pulls from Promethus
  * Has event router
  * Dynamic Reaction supported
* We have access to Grafana dashboard inside Cassandra web


## PLM and maintenance

* Cluster owner can decide when hygene repave has to be scheduled
* Cassandra team doesn't have any additional tools than what we have for cluster owner
* Legacy Dashboard comes from Cassandra data (using agent)
* Latest Dashboard comes from Promethus
* Some ball-park number for disk usage, but all depends on model and application
    * Disk usage should be below 55% (if you are on STCS)
    * Disk usage should be below 60% (if you are on LCS)
    * Disk usage should be below 60% (if you are on TWCS)
* Read/Write latency is for co-ordinator level node

## For node level metrics details, select table

* Table level graph would show latency for host-level
* Hintend-handoff can give details about network partition issues
* If high latency only one DC, network might be the reason
* HW/NW might not be your problem, but developer should understand and issue
* "Client Native Transport Requests"
  * Client level
* If Compaction is growing (100 or more)
  * Repairs might be running behind


## Dropped Mutation

* If only one machine has plenty of dropped mutation, but Qurum used for read and write, we are generally it is fine

## Garbage Collection

* Full GC Count and Full GC Duration - both are bad when they go high (count > 2 is bad)
* If young GC Duration is more than 300ms -- Cluster is not in good shape


## Partition size should be less than 100MB

## full GC ends up triggered cluster failure

* Cycle of death
* Restart might work
* Full-repair with MV might create Full-GC

## We can launch nodetool for each node and query data using it
