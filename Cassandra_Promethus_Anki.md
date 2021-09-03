## Promethus - Basics

* Instance vector
* Range Vector
* Counter (reset when restart), (use rate)
* Gauge

## Sample Queries

1. cassandra_buffer_pool_misses_total
1. sort(sum(cassandra_node_live_rows_scanned_count{cluterId=~"123|143|176"})) by (cassandra_cluster)

## Grafana Fundamentals

```bash
git clone https://github.com/grafana/tutorial-environment.git
cd tutorial-environment
docker ps
docker-compose up -d
docker-compose ps
curl -O localhost:8081
curl -O localhost:3000 -- Grafana and  http://loki:3100
admin/admin
Configuration > Data_Sources > Add_DS > Promethus > http://promethus:9090 > Save_test
Explore > tns_request_duration_seconds_count > shift_enter
Explore > rate(tns_request_duration_seconds_count[5m]) > shift_enter
Explore > sum(rate(tns_request_duration_seconds_count[5m])) by(route) > shift_enter
```


## Reference

* [Blogs](https://www.robustperception.io/blog/page/6)
* [PromCon EU 2019: PromQL for Mere Mortals](https://www.youtube.com/watch?v=hTjHuoWxsks)
* [Prometheus co-founder Julius Volz](https://www.youtube.com/watch?v=3hKdcFwMozI)
* [Prometheus Monitoring](https://www.youtube.com/c/PrometheusIo/videos)
* [Promethus querying basics](https://prometheus.io/docs/prometheus/latest/querying/basics/)
* [Grafana Labs Videos](https://grafana.com/videos/?plcmt=footer)
* [Powerful graph representations in Grafana](https://grafana.com/go/grafanaconline/2020/powerful-graph-representations-in-grafana/)