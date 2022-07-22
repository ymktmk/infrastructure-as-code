## prometheus

```
wget https://github.com/prometheus/node_exporter/releases/download/v1.1.2/node_exporter-1.1.2.linux-amd64.tar.gz
```

```
tar xfz node_exporter-1.1.2.linux-amd64.tar.gz;
```

```
node_exporter-1.1.2.linux-amd64/node_exporter &
```

* Ansibleで実行するにはどれか?
```
 - name: prometheus agent install
   shell: >
      wget https://github.com/prometheus/node_exporter/releases/download/v1.1.2/node_exporter-1.1.2.linux-amd64.tar.gz;
      tar xfz node_exporter-1.1.2.linux-amd64.tar.gz;
- name: prometheus agent up
  shell: node_exporter-1.1.2.linux-amd64/node_exporter &
  async: 5
  poll: 0
```

./node_exporter-1.1.2.linux-amd64/node_exporter &
/bin/sh -lc node_exporter-1.1.2.linux-amd64/node_exporter &
/bin/sh -lc ./node_exporter-1.1.2.linux-amd64/node_exporter &
