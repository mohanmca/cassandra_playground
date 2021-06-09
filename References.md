## Important Spring Java project

* [Cassandra Datastax PetClinic](https://github.com/spring-petclinic/spring-petclinic-reactive)
* [Cassandra Datastax Reactive PetClinic](https://github.com/DataStax-Examples/spring-petclinic-reactive)
# Important Cassandra links

* [JIRA](https://issues.apache.org/jira/browse/CASSANDRA-8844)
* [GIT Cassandra](https://gitbox.apache.org/repos/asf/cassandra.git)
* [CI-Cassandra-Build](https://ci-cassandra.apache.org/job/Cassandra-trunk/531/)
* [CI Console log](https://ci-cassandra.apache.org/job/Cassandra-4.0-artifacts/jdk=jdk_1.8_latest,label=cassandra/59/consoleFull)


## Cassandra Course Videos

* [DS-201 vidoes](https://www.youtube.com/watch?v=69pvhO6mK_o&list=PL2g2h-wyI4Spf5rzSmesewHpXYVnyQ2TS)

## Cassandra index

* [Architecture](https://github.com/mohanmca/cassandra_playground/blob/master/Architecture.md)
* [README](https://github.com/mohanmca/cassandra_playground/blob/master/README.md)
* [cassandra_commands_output](https://github.com/mohanmca/cassandra_playground/blob/master/cassandra_commands_output.md)
* [cassandra_definitive_guide_anki](https://github.com/mohanmca/cassandra_playground/blob/master/cassandra_definitive_guide_anki.md)
* [cassandra_docker](https://github.com/mohanmca/cassandra_playground/blob/master/cassandra_docker.md)
* [cqls_anki](https://github.com/mohanmca/cassandra_playground/blob/master/cqls_anki.md)
* [data_types](https://github.com/mohanmca/cassandra_playground/blob/master/data_types.md)
* [partition](https://github.com/mohanmca/cassandra_playground/blob/master/partition.md)
* [setup](https://github.com/mohanmca/cassandra_playground/blob/master/setup.md)
* [todo](https://github.com/mohanmca/cassandra_playground/blob/master/todo.md)
* [Debug log](https://github.com/mohanmca/cassandra_playground/blob/master/log/debug.log)
* [System Log](https://github.com/mohanmca/cassandra_playground/blob/master/log/system.log)

## Famous Cassandra articles

* [The things I hate about Apache Cassandra - John Schulz](https://blog.pythian.com/the-things-i-hate-about-apache-cassandra/)
## How to generate conf/cassandra_simple.yaml

* grep -v "^#" conf/cassandra.yaml |   sed  '/^$/d' > conf/cassandra_simple.yaml 

## Analyze Cassandra code

```
cat test/unit/org/apache/cassandra/db/compaction/LeveledCompactionStrategyTest.java | tr ' ' '\r\n' | tr A-Z a-z | sort| tr -d '[\\}\\{}]' | sort  
```