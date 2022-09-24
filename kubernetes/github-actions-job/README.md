## GitHub Actionsでkubernetesのjobを実行する

GitHub Actions ・・・ .github/workflows/db-migration.yaml
IAM Role ・・・ terraform/eks-on-fargate/oidc.tf
Job Manifest ・・・ kubernetes/github-actions-job/job.yaml
RBAC ・・・ kubernetes/github-actions-job/rbac.yaml
aws-auth ・・・ terraform/eks-on-fargate/eks.tf

* https://qiita.com/sonots/items/96984e349debc33057c5
* https://qiita.com/taishin/items/dfb9a5620f37ffb74fe9
* https://kubernetes.io/ja/docs/reference/access-authn-authz/rbac/
* https://github.com/h3poteto/kube-job
