## infrastructure-as-code

### ディレクトリ

- ansible
- docker
- kubernetes
- serverless
- terraform

### GitHub Acrionsの使い方

1. API経由でJobを非同期に実行する。
```
curl -X POST -H "Accespt: application/vnd.github.v3+json" \
  -H "Authorization: token ${TOKEN}"
  https://api.github.com/repos/ymktmk/infrastructure-as-code/actions/workflows/api.yaml/dispatches \
  -d '{"ref":"main","inputs":{"name": "tomoki", "email": "ymktmk.tt@gmail.com"}}'
```

2. Cronを実行できる
```
name: cron job

on:
  schedule:
    - cron: '0 0 * * *'

jobs:
  cron-job:
    runs-on: ubuntu-latest
    steps:
        - name: Get the last execution time
          run: |
            echo Hello Kubernetes !
```
