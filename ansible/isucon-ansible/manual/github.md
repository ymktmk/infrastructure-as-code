## GitHub 

rootユーザーに変更
```
sudo su
```

Gitセットアップ
```
git init 
git remote add origin https://github.com/tayzar-tznw/isucon-11-qualify-practice.git
git pull origin main
```

main.goのあるディレクトリに移動してbuild
```
/home/isucon/local/go/bin/go build -o isucholar
```

生成したバイナリファイルをコピーする
```
cp isucholar /home/isucon/webapp/go/
```

```
systemctl stop isucholar.go.service
```

```
systemctl restart isucholar.go.service
```
