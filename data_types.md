## Data types

* Text
* timestamp -- we can use in query like added_date > '2013-03-17';

## How to connect to Cassandra from API

* Create Cluster object
* Create Session object
* Execute Query using session and retrieve the result

```java
Cluster cluster = Cluster.builder().addContactPoint("127.0.0.1").build()
Session sesssion = cluster.connect("KillrVideo")
ResultSet rset = seesion.execute("select * from videos_by_tag where tag='cassandra'");
```

## TO setup python

```bash
python -m pip install --upgrade pip
pip install cassandra-driver
``

```python
from cassandra.cluster import Cluster
cluster = Cluster(protocol_version = 3)
session = cluster.connect('Killrvideo')
result = session.execute("select * from videos_by_tag where tag='cassandra'")[0];
print('{0:12} {1:40} {2:5}'.format('Tag', 'ID', 'Title'))
for val in session.execute("select * from videos_by_tag"):
   print('{0:12} {1:40} {2:5}'.format(val[0], val[2], val[3]))
```