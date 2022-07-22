# terraform-sample

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
ssh -i ./example ec2-user@<Public IP>
```

環境を削除するとき

```
terraform destroy
```