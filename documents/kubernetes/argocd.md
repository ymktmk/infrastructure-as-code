## tool

## ArgoCDのメリット

アプリケーションとしてリソースを1つのまとまりとして考えることができる。ロールバックなどが非常にやりやすい。app of appsということも実現可能。

## ArgoCDを使ったGitOps
1. mainブランチへmerge
2. GitHub Actions によりDockerコンテナビルド、ECRへのPush & Kustomize によりコンテナイメージタグが更新
3. ArgoCDがGitHub上のManifest ファイルの更新をトリガに EKS へローリングデプロイ開始
4. ArgoCD によって新たに指定されたイメージを ECR から Pull しデプロイ完了

https://blog.recruit.co.jp/rmp/infrastructure/gitops-cd-by-using-argo-cd-at-eks/

https://tech.readyfor.jp/entry/2021/01/08/095708

https://sreake.com/blog/argocd/

### Sync Option

https://argo-cd.readthedocs.io/en/stable/user-guide/sync-options/

https://argo-cd.readthedocs.io/en/stable/user-guide/auto_sync/

## Command

```
brew tap argoproj/tap
brew install argoproj/tap/argocd
```
