unset http_proxy https_proxy all_proxy
docker-machine create -d virtualbox manager
docker-machine regenerate-certs manager -f
docker-machine create -d virtualbox consul
docker-machine regenerate-certs consul -f
docker-machine create -d virtualbox agent1
docker-machine regenerate-certs agent1 -f
docker-machine create -d virtualbox agent2
docker-machine regenerate-certs agent2 -f
eval $(docker-machine env consul)
docker run -d -p 8500:8500 --name=consul progrium/consul -server -bootstrap
eval $(docker-machine env manager)
docker run -d -p 3376:3376 -t -v /var/lib/boot2docker:/certs:ro swarm manage -H 0.0.0.0:3376 --strategy=random --tlsverify --tlscacert=/certs/ca.pem --tlscert=/certs/server.pem --tlskey=/certs/server-key.pem consul://$(docker-machine ip consul):8500
eval $(docker-machine env agent1)
docker run -d swarm join --addr=$(docker-machine ip agent1):2376 consul://$(docker-machine ip consul):8500
eval $(docker-machine env agent2)
docker run -d swarm join --addr=$(docker-machine ip agent2):2376 consul://$(docker-machine ip consul):8500