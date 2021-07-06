## -- D:\git\cassandra_playground\labwork>docker cp  cqls.cqls.sql cass1:/
## -- cqlsh -f cqls.cqls.sql  > cqls.output.txt
## docker cp cass1:/cqls.output.txt 
select now() from system.local;
select toDate(now()) from system.local;
select ToTimestamp(now()) from system.local;
select ToUnixTimestamp(now()) from system.local;

create keyspace k1 with replication={'class' : 'SimpleStrategy', 'replication_factor':1};
use k1;
create table test(t UUID, v int, PRIMARY KEY (t));
insert into test(t,v) values(now(), 1);
insert into test(t,v) values(uuid(), 1);
update test set v=2 where t=uuid();
update test set v=2 where t=null;
select * from test;

