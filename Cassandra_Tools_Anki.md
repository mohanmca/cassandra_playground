## (Section: Cqls) - Exit cqlsh

* EXIT
* Quit

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
