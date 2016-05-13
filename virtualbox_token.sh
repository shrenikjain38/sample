unset http_proxy https_proxy all_proxy
docker-machine create -d virtualbox manager
docker-machine regenerate-certs manager -f
docker-machine create -d virtualbox agent1
docker-machine regenerate-certs agent1 -f
eval $(docker-machine env manager)
token=$(docker run --rm swarm create)
docker run -d -p 3376:3376 -t -v /var/lib/boot2docker:/certs:ro swarm manage -H 0.0.0.0:3376 --tlsverify --tlscacert=/certs/ca.pem --tlscert=/certs/server.pem --tlskey=/certs/server-key.pem token://$token
eval $(docker-machine env agent1)
docker run -d swarm join --addr=$(docker-machine ip agent1):2376 token://$token
