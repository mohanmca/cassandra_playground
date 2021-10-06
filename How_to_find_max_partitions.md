## How to find number of rows in each partition?

```python
[keyspace_name...] = select keyspace_name, table_name, column_name from system_schema.columns where keyspace_name='ks_name' and table_name='tname' and kind='partition_key';
[tables...] = select keyspace_name, table_name from system_schema.tables where keyspace_name in [keyspaces];
[keyspace_name..., table_name..., column_name...] = select keyspace_name, table_name, column_name from system_schema.tables where keyspace_name in [keyspace_name..., table_name..., column_names...] and table_name in [tables] allow filtering;--since we skip column_name
for each keyspace_name:
    for each table_name:
```

```python
[keyspace_name...] = select keyspace_name from system_schema.keyspaces;
[tables...] = select keyspace_name, table_name from system_schema.tables where keyspace_name in [keyspaces];
[keyspace_name..., table_name..., column_name...] = select keyspace_name, table_name, column_name from system_schema.tables where keyspace_name in [keyspace_name..., table_name..., column_names...] and table_name in [tables] allow filtering;--since we skip column_name
for each keyspace_name:
    for each table_name:
```