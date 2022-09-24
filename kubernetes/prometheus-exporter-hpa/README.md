## Prometheus Sidekiq

* prometheus-operaterはEC2、sidekiq-exporterはFargateで動かす。

kubectl port-forward <Pod名> -n sidekiq 8000:9292

kubectl port-forward prometheus-prometheus-operator-kube-p-prometheus-0 8000:9090
