## What is compaction in Cassandra?

* It is similar to comapaction of file-system
* Multiple SS-Tables are merged (like merge-sort), and deleted removed, tombstones removed, updated records retained.
  * It leads to lean SS-Table


## Pre-requisite for Compaction

* Find table statistics
  * nodetool cfstats
  * nodetool tpstats

## We have problem with two nodes with large number of compaction pending, how to speed up?

* Disable the node act as a co-ordinator? (it can spend its io/cpu in compaction)
  * nodetool disablebinary
* Disable the node accepting write (should be lesser than hinted-handoff period) ?
  * nodetool disablegossip (marking node as down)
  * nodetool disablehandoff (marking node as down)
* Disable the node accepting write (should be lesser than hinted-handoff period) ?
  * nodetool disablegossip
* Increase the compaction througput (there would be consequences for read)
  * nodetool setconcurrentcompactors 2



## Reference
*[Understanding the Nuance of Compaction in Apache Cassandra](https://thelastpickle.com/blog/2017/03/16/compaction-nuance.html)
* [TWCS part 1 - how does it work and when should you use it ?](https://thelastpickle.com/blog/2016/12/08/TWCS-part1.html)