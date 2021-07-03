## What is D210 Course about

* Operations for Apache Cassandra™ and DataStax Enterprise

## What are basic parameter required for Cassandra quickstart

* Four parameters
    * cluster-name
    * listen-address (for peer Cassandra nodes to connect to)
    * native-transport-address (for clients)
    * seeds
      * Seeds should be comma seperated inside double quote - "ip1,ip2,ip3"

## What is the location of default Cassandra.yaml?

* /etc/dse/cassandra.yaml (package installer)
* /cassandra-home/resources/cassandra/conf/cassandra.yaml

## What are directories related settings, and level-2 settings (right after quickstart)<default>

* initial_token: <128>
* commitlog_directory
    * /var/lib/cassandra/commitlog
* data_file_directories
    * /var/lib/cassandra/data
* hints_directory
    * /var/lib/cassandra/hints
* saved_caches_directory
* endpoint_snitch

## What are two file-systedm that should be separated

*  /var/lib/cassandra/data and /var/lib/cassandra/commitlog

## Cluster Sizing

* Figure out cluster size parameters
    1. (Write)-Throughput  - How much data per second?
    1. Growth Rate  -   How fast does capacity increase?
    1. Latency (Read) -   How quickly must the cluster respond?

## Cluster Sizing - Writethrough put example

* 2m user commenting 5 comments a day, where a comment is 1000 byte
* # comments per second = (2m * 5)/(24*60*60)  = 10m/86400 = 100 comments per second
* 100 * 1000 bytes = 100KB per-second (multiply into number of replication-factor)

## Cluster Sizing - Read throughput example

* 2m user viewing 10 video summaries a day, where a video has 4 comments
* # comments per second = (2m * 10 * 4)/(24*60*60)  = 80m/86400 = 925 comments per second
* 925 * 1000 bytes = 1MB per-second (should multiply into number of replication-factor?)

## Cluster-sizing - Monthly calculate

* Data should cover only 50% of disk space at any-time to allow repair and compaction to work
* Few they estimate just by doubling the need for 60-seconds and extra-polate to 30 days
* per-second-data-volume * 30*86400 
* 1MB per second into monthly need
    * 1MB * 86400 * 30 = 2.531 TB (here 1MB inclusive of anti-entropy)


## Cluster-sizing - Latency calculate

* Relevant Factors
    * IO Rate
    * Workload shape
    * Access Patterns
    * Table width
    * Node profile (memory/cpu/network)
* What is required SLA
* Do the benchmarking initially before launching


## Cluster Sizing - Probing Questions

1. What is the new/update ratio?
1. What is the replication factor?
1. Additional headroom for operations - Anti-entropy repair?


## [Cassandra stress tool](https://cassandra.apache.org/doc/latest/tools/cassandra_stress.html)

* Define your shcema, and schema performance
* Understand how your database scales
* It could generate graphical output
* Specify any compaction strategy
* Optmize your datamodel and setttings
* Determine production capacity
* Yaml for Schema, Column, Batch and Query descriptions
* columnspec:
```yaml
  - name: name
    size: uniform(5..10) # The names of the staff members are between 5-10 characters
    population: uniform(1..10) # 10 possible staff members to pick from
  - name: when
    cluster: uniform(20..500) # Staff members do between 20 and 500 events
  - name: what
    size: normal(10..100,50)
```
*  Distribution can be any among fom, EXTREME, EXP, GAUSS, UNIFORM, FIXED
* cassandra-stress user profile=/home/cassandra/TestProfile.yaml ops\(insert=10000, user_by_email=100000\) -node node-ds210-node1

ubuntu@ds210-node1:~/labwork$ cassandra-stress user profile=TestProfile.yaml ops\(insert=100000 user_by_email=100000\) -node ds210-node1
There was a problem parsing the table cql: line 0:-1 mismatched input '<EOF>' expecting ')'

## Linux top command

* Comes with every linux distribution - (How much Cassandra is using)
* Brief summary of Linux system resources + Per process details
* Summary
  * CPU Average
    * 1,5,15 (minute) average
    * Spike - will show up in 5 or 15
    * CPU - Wait
      * Too much of wait is problem for Cassandra (should be zero)
      * si/hi (sofwatre/hardware - interrupt) might give clue about waiting
* Memory
  * Res - Physical Memory
  * SHR - Shared Memory
  * VIRT - Virtual memory
  * Buffers are important
    * High read might cause SSTable in buffer
* Process State
  * Zombie, Sleeping, Running  

## Linux top command - Cassandra

* Swap should be zero (Cassandra discourages swap)
  * Disable the swap, zero should be allocated
* Zombie should be zero


## Linux dstat command (alternative to top)

* dstat = cpustat + iostat + vmstat + ifstat (cpy/io/network)
* cpu-core specific information can be listed
* dstate - by defult won't include memory (dstate -am to add memory details output)
* print stat for every 2 seconds, and measure 7 iteration
  ```
  ubuntu@ds210-node1:~$ dstat -am 2 7
  --total-cpu-usage-- -dsk/total- -net/total- ---paging-- ---system-- ------memory-usage-----
  usr sys idl wai stl| read  writ| recv  send|  in   out | int   csw | used  free  buff  cach
    3   6  89   2   0|3412k  112k|   0     0 |   0     0 | 505  1443 | 587M 6286M  100M  935M
    1   1  98   0   0|   0     0 |  66B  722B|   0     0 | 506  1261 | 587M 6286M  100M  935M
    0   0 100   0   0|   0     0 |  66B  418B|   0     0 | 147   403 | 587M 6286M  100M  935M
    0   0 100   0   0|   0     0 |  66B  418B|   0     0 | 161   376 | 587M 6286M  100M  935M
    0   1  99   0   0|   0     0 |  66B  418B|   0     0 | 596  1900 | 587M 6286M  100M  935M
    0   1  98   0   0|   0     0 |  66B  418B|   0     0 | 760  2137 | 587M 6286M  100M  935M
    0   0 100   0   0|   0  8192B|  66B  418B|   0     0 | 111   366 | 587M 6286M  100M  935M
  ubuntu@ds210-node1:~$ 
  ```
* sys is higher - something costly happenning in system space (above 0 is not good)
* disk is weakest link in most system. if wait numbers are higher in user/system space, check disk
* hiq/siq = h/w and s/w interrupt
* HDD can transfer 10s of MBS, while SSDs can transfer hundreds of MBS
* Gigabit is 100MBS usually
* Paging should be usually be near zero (lots of paging is bad to performance)
* System stats can be an indication of process contention (CSW - context switch)



## Lab notes

* 172.18.0.2
* 

## How to create anki from this markdown file

```
mdanki Cassandra_Datastax_210_Anki.md Cassandra_Datastax_210_Anki.apkg --deck "Mohan::Cassandra::DS210::Operations"
```

