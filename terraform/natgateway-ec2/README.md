# terraform-natgateway-ec2

![Blank diagram - Page 1](https://user-images.githubusercontent.com/73768462/167905997-ee509b6f-b10f-445f-8f18-7f44b6d6edaa.png)

鍵を生成する
```
ssh-keygen -t rsa -f example -N ''
```

環境を生成
```
terraform apply
```

環境を削除するとき
```
terraform destroy
```

1. パブリックサブネットのEC2にSSH接続

```
ssh -i example ec2-user@<Public IP>
```

2. パブリックサブネットのEC2に鍵を送信する & プライベートサブネットのEC2にSSH接続

```
scp -i example example ec2-user@<パブリックサブネットのEC2のPublic IP>:/tmp/
```

```
ssh -i example ec2-user@<パブリックサブネットのEC2のPublic IP>
```

```
cd /tmp
```

```
ssh -i example ec2-user@<プライベートサブネットのEC2のPrivate IP>
```
