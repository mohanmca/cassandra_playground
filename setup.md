* Base location - /home/osboxes/node


### To start Cassandra  

```bash
cd /home/osboxes/node/
nohup ./bin/dse cassandra 
```  

### Find status Cassandra  

```bash
osboxes@osboxes:~/node/bin$ ./dsetool status
```

```pre
C: Cassandra       Workload: Cassandra       Graph: no     
======================================================
Status=Up/Down
|/ State=Normal/Leaving/Joining/Moving
--   Address          Load             Effective-Ownership  Token                                        Rack         Health [0,1] 
UN   127.0.0.1        180.95 KiB       100.00%              0                                            rack1        0.70         
```