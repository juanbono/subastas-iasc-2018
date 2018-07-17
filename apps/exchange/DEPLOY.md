# Pasos para hacer un deployment

1. Crear release de la exchange.
```
$ env MIX_ENV=docker mix release --env=docker
```

(OPCIONAL) Probar la release
```
$ REPLACE_OS_VARS=true PORT=4000 ./_build/prod/rel/exchange/bin/exchange foreground
```

2. Crear la imagen de docker
```
$ eval $(minikube docker-env)
$ docker build -t exchange:release .
```

(OPCIONAL) Probar el contenedor y enviarle una request
```
$ docker run -it -p 4000:4000 -e “PORT=4000” — rm exchange:release console
$ curl -H "Content-Type: application/json" -d '{"name": "B", "ip":"127.0.0.1:5001", "tags":["zapatos"]}' http://localhost:4000/buyers
```

3. Levantar minikube
```
$ minikube start --vm-driver=virtualbox
$ kubectl config set-context minikube
$ kubectl create -f k8s/exchange-deployment.yaml
```

4. Ver si se estan pulleando la imagen de la exchange.
```
$ kubectl get pods
```

5. Ver en el dashboard
```
$ minikube dashboard --logtostderr --v=2
```