## Kustomize

Kubernetesのマニフェストを環境差分だけどこかに切り出したい。そういったときに使えるのがKustomize

https://qiita.com/Morix1500/items/d08a09b6c6e43efa191d

各環境で共通設定となる記述をする → bases
個環境で差分となる設定を記述する → overlays

https://qiita.com/oguogura/items/af3860ca32cd0264ca93

## Command

```
brew install Kustomize
```

```
Kustomize build .
```
