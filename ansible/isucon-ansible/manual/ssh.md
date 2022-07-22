## SSH

1. configファイルを開く
```
open ~/.ssh/config
```

2. EC2のHostNameと自身のGitHubの公開鍵を指定する。(みんなに配る)
```
Host I
    HostName ec2-18-183-160-188.ap-northeast-1.compute.amazonaws.com
    User ubuntu
    IdentityFile /Users/ymktmk/.ssh/ymktmk
    Port 22
```

```
ssh I
```

3. isuconユーザーに切り替えるなら
```
sudo -i -u isucon
```

4. ルートユーザーに切り替える
```
sudo su
```
