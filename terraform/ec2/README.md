# terraform-ec2-sample

![Blank diagram - Page 1 (1)](https://user-images.githubusercontent.com/73768462/167977314-b68e5b13-81fa-4f9c-b9c0-4827f8aa036d.png)

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

環境を削除するとき

```
terraform destroy
```
