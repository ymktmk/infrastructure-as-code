## Nginx

1. template/nginx.confを書き換える

2. playbook/loadbalancing.ymlを実行する 

```
ansible-playbook -i hosts playbook/loadbalancing.yml --ask-become-pass
```
