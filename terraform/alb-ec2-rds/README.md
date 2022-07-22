# terraform-alb-ec2-rds

![alb-ec2-rds](https://user-images.githubusercontent.com/73768462/169782871-a8281a90-dc00-405b-8cea-aeb3b5473a66.png)

鍵を生成する
```
ssh-keygen -t rsa -f example -N ''
```

環境を生成
```
terraform apply
```

SSH接続する
```
ssh -i example ec2-user@<Public IP>
```

RDSに接続する(:3306いらない)
```
mysql –h <RDSエンドポイント> -u admin –p
```

環境を削除するとき
```
terraform destroy
```
