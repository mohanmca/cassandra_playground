# cassandra_playground
cassandra learning

## Important Cassandra links

* [JIRA](https://issues.apache.org/jira/browse/CASSANDRA-8844)
* [GIT Cassandra](https://gitbox.apache.org/repos/asf/cassandra.git)
* [CI-Cassandra-Build](https://ci-cassandra.apache.org/job/Cassandra-trunk/531/)
* [CI Console log](https://ci-cassandra.apache.org/job/Cassandra-4.0-artifacts/jdk=jdk_1.8_latest,label=cassandra/59/consoleFull)

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

## How to generate conf/cassandra_simple.yaml

* grep -v "^#" conf/cassandra.yaml |   sed  '/^$/d' > conf/cassandra_simple.yaml 

## Analyze Cassandra code

```
cat test/unit/org/apache/cassandra/db/compaction/LeveledCompactionStrategyTest.java | tr ' ' '\r\n' | tr A-Z a-z | sort| tr -d '[\\}\\{}]' | sort  
```