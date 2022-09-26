# encer-infra

### EC2

```
ssh-keygen -t rsa -f encer -N ''
```

```
ssh -i encer ec2-user@<IP>
```

### EC2 userdata

userdataの内容
```
sudo cat /var/lib/cloud/instance/user-data.txt
```

userdataで発生したerrorログ
```
sudo cat /var/log/cloud-init-output.log
```


### CloudFront

```
openssl genrsa -out private_key.pem 2048
```

```
openssl rsa -pubout -in private_key.pem -out public_key.pem
```
