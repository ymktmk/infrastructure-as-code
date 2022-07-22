## MySQL
* sudoをつける

```
mysql --version
```

```
mysql -uisucon -pisucon
```

```
systemctl status mysql
```

```
systemctl start mysql
```

```
systemctl restart mysql
```

### 外部からMySQLに接続

1. データベース・テーブルへのアクセス権限設定

ユーザー作成(後者はmysql8?)
```
CREATE USER 'isucon'@'%' IDENTIFIED BY 'isucon';
CREATE USER 'isucon'@'%' IDENTIFIED WITH mysql_native_password BY 'isucon';
```

権限を付与する
```
GRANT ALL PRIVILEGES ON *.* TO 'isucon'@'%' WITH GRANT OPTION;
```

```
FLUSH PRIVILEGES;
```

* コマンドメモ
```
drop user 'isucon'@'%';
select user,host from mysql.user;
```

2. MySQLへのアクセス制限設定

```
vi /etc/mysql/mysql.conf.d/mysqld.cnf
```

bind-addressをコメントアウトする or 0.0.0.0としてすべてのネットワークインターフェイスでlisten
```
# bind-address = 127.0.0.1
```

```
systemctl restart mysql
```

3. MySQLが利用するポートの開放設定

Listen Portの確認
```
sudo apt install net-tools
```

```
netstat -atn
```

4. ファイアウォールの制限設定

セキュリティグループで3306ポートを解放する


5. 接続

```
mysql -h 133.242.221.148 -uisucon -pisucon
```
