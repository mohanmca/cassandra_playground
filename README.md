# cassandra_playground
cassandra learning


## How to generate conf/cassandra_simple.yaml

* grep -v "^#" conf/cassandra.yaml |   sed  '/^$/d' > conf/cassandra_simple.yaml 