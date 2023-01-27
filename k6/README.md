## k6-sample

負荷試験ツールk6を使ったのでサンプルのソースコードを置いておく

## セットアップ

```
brew install k6
```

## 実行

```
k6 run api-token.js \
-e URL="http://example.com" \
-e GRANT_TYPE="" \
-e SCOPE="" \
-e CLIENT_ID="" \
-e CLIENT_SECRET="" 
```
* -e URL="http://example.com" で環境変数を渡して実行
* influxDBに蓄積する場合は`--out influxdb=http://localhost:8086/k6db`

## 試験レポート確認

resultディレクトリ以下にHTMLが生成されるので、それを確認

## influxDBと連携し、Grafanaで可視化

1. コンテナ起動(influxDB, Grafana)

```
docker-compose up
```

2. Grafanaにログイン

admin:adminでログイン可能

3. data sourceを設定

url: http://k6-sample_influxdb_1:8086
db_name: k6db
username: root
password: root

4. ダッシュボードで可視化

以下のテンプレートをダウンロードして活用
https://k6.io/docs/results-visualization/influxdb-+-grafana/#custom-grafana-dashboard

## 詳細

急激なトラフィックを想定した試験も可能
```
export const options = {
    stages: [
        { target: 10, duration: '1s' },
        { target: 20, duration: '1s' },
        { target: 30, duration: '1s' }
    ]
}
```

|メトリック名                 |内容                                |
|---                      |---                                |
|data_received            |受信データ量（左：Total, 右：/秒）         |
|data_sent                |送信データ量（左：Total, 右：/秒）         |
|http_req_blocked         |TCP接続の待ち時間（平均）              |
|http_req_connecting      |TCP接続にかかった時間(平均)           |
|http_req_duration        |リクエストにかかった総時間<br> （http_req_sending + http_req_waiting + http_req_receiving） |
|expected_response:true   |成功したリクエストのみの総時間            |
|http_req_failed          |リクエストが失敗した割合                 |
|http_req_receiving       |リモートホストからのリクエスト応答時間        |
|http_req_sending         |リモートホストへリクエストを送るのにかかった時間|
|http_req_tls_handshaking |TLSセッションのハンドシェイクにかかった時間   |
|http_req_waiting         |リクエストしてから応答があるまでの待機時間（“time to first byte”, or “TTFB”）|
|http_reqs                |k6が生成したリクエスト数（総数, /秒）       |
|iteration_duration|1回のJS実行にかかった時間(準備と終了処理も含む)    |
|iterations               |VUがJSを実行した合計回数               |
|vus                      |アクティブ仮想ユーザー数                 |
|vus_max                  |最大アクティブ仮想ユーザー数              |

### 参考文献

* k6
https://k6.io/

* grafana
https://www.macnica.co.jp/business/semiconductor/articles/basic/140341/

* template
https://grafana.com/grafana/dashboards/?search=k6

* other blog
https://qiita.com/chroju/items/355f3c6da9f8c4867ba5
https://qiita.com/ryotaro76/items/f4bbcc1bec3fbae0e4b4
https://zenn.dev/toshiro3/articles/05493fb36d8656
https://qiita.com/itatibs/items/57a05cc8680cf17fd43f
