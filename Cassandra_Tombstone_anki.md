## (Section: Tombstone) -  Read_Repair

1. Read repair does not propagate expired tombstones, nor does it consider expired tombstones when actually repairing data. 
1. If there is tombstoned data that has not been propagated to all replica nodes before gc_grace_seconds has expired, that data may continue to be returned as live data.

## (Section: Tombstone) -  Read_Repair
