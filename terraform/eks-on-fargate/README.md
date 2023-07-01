## EKS

### Create EKS Cluster

- クラスターのバージョンやアドオンのバージョンが正しいことを確認してください
- Public SubnetかPrivate Subnetかを選択してください(FargateはPublic Subnetで動作しません)

### Setup ArgoCD

```
rm ~/.kube/config
```

```
aws eks update-kubeconfig --region ap-northeast-1 --name eks
```

ArgoCD用のnamespace作成
```
kubectl create namespace argocd
```

ArgoCDをデプロイする
```
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/v2.3.3/manifests/ha/install.yaml
```

ArgoCDのパスワードをpasswordに変更
```
kubectl -n argocd patch secret argocd-secret \
  -p '{"stringData": {
    "admin.password": "$2a$10$rRyBsGSHK6.uc8fntPwVIuLVHgsAhAX7TcdrqW/RADU0uh7CaChLa",
    "admin.passwordMtime": "'$(date +%FT%T%Z)'"
  }}'
```

ポートフォワードを行う。admin, passwordでログインできる
```
kubectl port-forward svc/argocd-server -n argocd 8080:443
```

## Set up to be able use SecurityGroupPolicy

```
curl -o aws-k8s-cni.yaml https://raw.githubusercontent.com/aws/amazon-vpc-cni-k8s/v1.7.7/config/v1.7/aws-k8s-cni.yaml
```

```
kubectl apply -f aws-k8s-cni.yaml
```

1.7.7以上ならOK
```
kubectl describe daemonset aws-node --namespace kube-system | grep Image | cut -d "/" -f 2
```

CNI プラグインを有効にする
```
kubectl set env daemonset aws-node -n kube-system ENABLE_POD_ENI=true
```

liveness probesやreadiness probesを使用している場合は、以下コマンドも必要らしい。
```
kubectl patch daemonset aws-node \
  -n kube-system \
  -p '{"spec": {"template": {"spec": {"initContainers": [{"env":[{"name":"DISABLE_TCP_EARLY_DEMUX","value":"true"}],"name":"aws-vpc-cni-init"}]}}}}'
```

* https://zenn.dev/karamaru/articles/97d7c6b79b7251
* https://docs.aws.amazon.com/ja_jp/eks/latest/userguide/security-groups-for-pods.html
