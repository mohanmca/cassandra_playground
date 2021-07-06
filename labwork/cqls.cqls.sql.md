## CQL session using file

```sql
## -- D:\git\cassandra_playground\labwork>docker cp  cqls.cqls.sql cass1:/
## -- cqlsh -f cqls.cqls.sql  > cqls.output.txt
## docker cp cass1:/cqls.output.txt 
select now() from system.local;
select toDate(now()) from system.local;
select ToTimestamp(now()) from system.local;
select ToUnixTimestamp(now()) from system.local;
```

## Warnings and errors

* Warning: schema version mismatch detected; check the schema versions of your nodes in system.local and system.peers.
* 
