git elasticsearch_69999
git clone --branch elasticsearch_69999 https://github.com/elastic/built-docs.git
git clone --branch elasticsearch_69999 https://github.com/elastic/built-docs.git

```bash
docker pull docker.elastic.co/elasticsearch/elasticsearch:6.8.14
docker run --memory 4096m --cpus 2  -p 9200:9200 -p 9300:9300 -e "discovery.type=single-node" docker.elastic.co/elasticsearch/elasticsearch:6.8.14
```