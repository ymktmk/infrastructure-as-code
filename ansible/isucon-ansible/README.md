# isucon-ansible

## インフラとしてやること

- 必要なツールのインストール
- デプロイ
- インフラ構成の変更
- 外形監視

## 他にやること

- SSL HTTP2
- DBのCPU追加する
- index貼る
- Nginx(Chapter6)
- 高速化(Chapter8)
- OS(Chapter9)

## 各種コマンド

```
brew install ansible
```

```
ansible-playbook -i hosts playbook/tool.yml --syntax-check
````

ツールのインストール
```
ansible-playbook -i hosts playbook/tool.yml
```

LoadBalancing構成へ変更
```
ansible-playbook -i hosts playbook/loadbalancing.yml
```

Goをデプロイする
```
ansible-playbook -i hosts playbook/tool.yml
```

root以外でログインし、su/sudoでrootになる
```
ansible-playbook -i hosts playbook/tool.yml --ask-become-pass
```

Prometheus・Grafana起動
```
docker-compose up -d
```
