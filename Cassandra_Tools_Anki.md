## (Section: Tools) - How to load json/csv in fastest way into Cassandra:

1. DSKBulk or Apache Spark (faster works for json and CSV)
1. CQL-Copy (slow and only for CSV) 

## (Section: Tools) - What are all DSBulk commands

1. load
2. unload
3. count - statistics

## (Section: Tools) - Load CSV data into Cassandra (using name-to-name mapping):

```sql
dsbulk load -url users.csv       \
            -k killr_video       \
            -t users             \
            -header true         \
            -m "user_id=id,      \
                gender=gender,   \
                age=age"         \
            -logDir /tmp/logs
```


