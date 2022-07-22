## EKS

EKS Cluster on Public Subnet

### Setup ArgoCD

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
