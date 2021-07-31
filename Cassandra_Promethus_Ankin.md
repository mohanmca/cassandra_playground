## Promethus - Basics

* Instance vector
* Range Vector
* Counter (reset when restart), (use rate)
* Gauge

## Sample Queries

1. cassandra_buffer_pool_misses_total
1. sort(sum(cassandra_node_live_rows_scanned_count{cluterId=~"123|143|176"})) by (cassandra_cluster)

## Reference

* [Blogs](https://www.robustperception.io/blog/page/6)
* [PromCon EU 2019: PromQL for Mere Mortals](https://www.youtube.com/watch?v=hTjHuoWxsks)
* [Prometheus co-founder Julius Volz](https://www.youtube.com/watch?v=3hKdcFwMozI)