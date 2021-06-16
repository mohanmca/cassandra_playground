echo "deb https://debian.datastax.com/enterprise stable main" | sudo tee –a /etc/apt/sources.list.d/datastax.sources.list
curl -L https://debian.datastax.com/debian/repo_key | sudo apt-key add -
sudo apt-get update
sudo apt-get install dse-full
/home/ubuntu/labwork/TestProfile.yaml