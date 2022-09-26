## Prometheus Sidekiq

* prometheus-operaterはEC2、sidekiq-exporterはFargateで動かす。

```
kubectl port-forward <Pod名> -n sidekiq 8000:9292
```

```
kubectl port-forward prometheus-prometheus-operator-kube-p-prometheus-0 8000:9090
```

```
kubectl get --raw /apis/custom.metrics.k8s.io/v1beta1/namespaces/sidekiq/services/sidekiq-exporter-service/sidekiq_processes | jq .
```
