## alp

1. template/nginx.confを書き換える

2. playbook/tool.ymlを実行する 

```
ansible-playbook -i hosts playbook/tool.yml --ask-become-pass
```

3. ログを確認する

```
cat /var/log/nginx/access.log | alp ltsv --sort avg
```
