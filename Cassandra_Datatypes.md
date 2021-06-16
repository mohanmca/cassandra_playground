## Data types

* Text
* timestamp -- we can use in query like added_date > '2013-03-17';

## How to connect to Cassandra from API

1. Create Cluster object
1. Create Session object
1. Execute Query using session and retrieve the result

```java
Cluster cluster = Cluster.builder().addContactPoint("127.0.0.1").build()
Session session = cluster.connect("KillrVideo")
ResultSet result = session.execute("select * from videos_by_tag where tag='cassandra'");

boolean columnExists = result.getColumnDefinitions().asList().stream().anyMatch(cl -> cl.getName().equals("publisher"));

List<Book> books = new ArrayList<Book>();
result.forEach(r -> {
   books.add(new Book(
      r.getUUID("id"), 
      r.getString("title"),  
      r.getString("subject")));
});
return books;
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