## ElasticSearch

### Relational Database vs ElasticSearch 

index    = database
type     = table
document = row
field    = column

/customer/_doc/1
インデックス/タイプ/ドキュメントID

* バージョン7.0以降では、「Type」は廃止された。

### インデックス

同様の特性を持つドキュメントのコレクションです。

### ドキュメント

インデックスを付けられる情報の基本単位です。JSON形式で表現されます。
```
{
   "doc": {
      "name": "Jane Doe",
      "age": 20
   }
}
```

### フィールド

ドキュメント(JSON)のkeyとvalueの組み合わせを指します。

### シャード & レプリカ

インデックスを小さな単位に分割したものをシャードといいます。コンテンツ量を均一に分割することで検索のパフォーマンスを上げることができます。
データが損失しないためにレプリカシャードを作成します。同一のノードにプライマリーシャードとレプリカシャードは存在しないようになっています。

* デフォルトでは、各インデックスは5つのプライマリシャードと1つのレプリカを割り当てられます。

- ElasticSearch超入門
https://qiita.com/bbbks9/items/7695262be0befb94897f

- ElasticSearchの概念
https://www.elastic.co/guide/jp/elasticsearch/reference/current/gs-basic-concepts.html
https://dev.classmethod.jp/articles/elasticsearch-getting-started-06
https://hogetech.info/bigdata/elasticsearch

- ElasticSearchの設計
https://dev.classmethod.jp/articles/elasticsearch-getting-started-01/

### Index API

`?pretty`をつけるとResponseが見やすくなる

- indexの作成
```
curl -X PUT "localhost:9200/customer?pretty"
```

- indexing
idを指定しないと適当なidが付与される。
```
curl -X PUT -H "Content-Type: application/json" "localhost:9200/customer/_doc/1?pretty" -d '{"name": "John Doe"}'
```

- indexの一覧
```
curl "localhost:9200/_cat/indices?v"
```

- indexの削除
```
curl -X DELETE "localhost:9200/customer?pretty"
```

- documentの更新
```
curl -X POST -H "Content-Type: application/json" "localhost:9200/customer/_doc/1/_update?pretty" -d '{"doc": {"name": "Jane Doe", "age": 20}}'
```

### Serach API

`?pretty`をつけるとResponseが見やすくなる

```
curl 'localhost:9200/customer/_search?q=*&pretty'
```

- 全てのデータを取得
```
curl -X POST -H "Content-Type: application/json" 'localhost:9200/customer/_search?pretty' -d '{"query": { "match_all": {} }}'
```

- キーワード検索
```
curl -X POST -H "Content-Type: application/json" 'localhost:9200/customer/_search?pretty' -d '{"query": { "match": {"name": "John"} }}'
```
