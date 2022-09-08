## ローカルブランチ削除

```
git branch -D [ブランチ名]
```

## リモートブランチ削除

```
git push origin :[ブランチ名]
```

### git commit 取り消し (リモートリポジトリにpushしてしまった場合)
以下のコマンドを実行するとエディタが開いてコミットメッセージを変更する
```
git revert HEAD
git push origin main
```

### 特定のコミットをマージする 
-nをつけるとコミットせずに取り込むことができる
```
git cherry-pick [コミットID]
```

### リモートリポジトリの接続先変更

```
git remote set-url origin <新しい接続先>
```

### リポジトリの履歴を初期化

```
rm -rf .git
```

## コミットをまとめる

```
git rebase -i [まとめたいひとつ前のコミットID]
```

- https://www.sejuku.net/blog/71919
- https://qiita.com/takke/items/3400b55becfd72769214

## 間違えてresetしてしまったとき

```
git reflog
```

```
git reset --hard HEAD@{1}
```

## 作業中に別ブランチの変更を取り入れる(不要なコミットが発生しない)

```
git pull origin main --rebase
```

## 参考文献

- resetとrevertの使い分け

https://tech-blog.rakus.co.jp/entry/20210528/git
