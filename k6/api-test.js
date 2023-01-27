// k6 run api-test.js
import http from 'k6/http'
import { check, sleep } from 'k6'
import {htmlReport} from "https://raw.githubusercontent.com/benc-uk/k6-reporter/main/dist/bundle.js"
import {jUnit, textSummary} from "https://jslib.k6.io/k6-summary/0.0.1/index.js"

export const options = {
  vus: 16,
  duration: '100s',
  rps: 16,
  thresholds: {
    "http_req_duration": ["avg<1"],
    "http_req_waiting": ["avg<1"],
  }
}

export default function () {
  let response = http.get('https://test.k6.io')
  check(response, { "status is 200": (r) => r.status === 200 })
}

// レポート出力設定
export function handleSummary(data) {
  sendSlackMessage(data)
  return {
      stdout: textSummary(data, { indent: " ", enableColors: true }),
      "./result/summary.html": htmlReport(data),
      './result/summary.xml': jUnit(data),
      './result/summary.json': JSON.stringify(data),
  }
}

function sendSlackMessage(data) {

  const slack_token = ""

  var now = new Date()
  var year = now.getFullYear()
  var month = now.getMonth()+1
  var date = now.getDate()
  var hour = now.getHours()
  var min = now.getMinutes()

  const payload = {
    channel: "C04CR5WMSU8",
    attachments: [
      {
        color: "#632eb8",
        blocks: [
          {
            type: "section",
            text: {
              type: "mrkdwn",
              text: `負荷試験結果 ${year}年${month}月${date}日${hour}:${min}`
            }
          },
          {
            type: "section",
            text: {
              type: "mrkdwn",
              text: ""
            },
            accessory: {
              type: "image",
              image_url: "https://k6.io/images/landscape-icon.png",
              alt_text: "k6 thumbnail"
            }
          },
          {
            type: "section",
            text: {
              type: "mrkdwn",
              text: ""
            }
          }
        ]
      }
    ]
  }
  
  let maxThroughput = data.metrics.http_reqs.values['count']
  let failRequest = data.metrics.http_req_failed.values['passes']

  let avgResponseTime = data.metrics.http_req_duration.values['avg']
  let p95ResponseTime = data.metrics.http_req_duration.values['p(95)']
  let vus = data.metrics.vus.values['value']

  let sectionBlocks = payload.attachments.find((attachments) => {
    return attachments.blocks[1].type === "section"
  })

  // sectionBlocks.blocks[1].text.text = 
  //   "*Max Throughput:* " + maxThroughput + " reqs/s" +
  //   "\n*HTTP Failures:* " + failRequest + " reqs" + 
  //   "\n*Avg Response Time:* " + avgResponseTime + " ms" +
  //   "\n*95% Response Time:* " + p95ResponseTime + " ms" +
  //   "\n*Vus:* " + vus + " vus"

  sectionBlocks.blocks[1].text.text = 
    `*秒間リクエスト数:* ${maxThroughput} reqs/s` +
    "\n*同時接続数:* " + vus + " vus" +
    "\n*試験の実行時間:* " + data.state.testRunDurationMs + " ms" +

    "\n*失敗リクエスト数:* " + failRequest + " reqs" + 
    "\n*平均レスポンスタイム:* " + avgResponseTime + " ms" +
    "\n*95%レスポンスタイム:* " + p95ResponseTime + " ms"

  // 閾値
  console.log(data.metrics.http_req_duration.thresholds)
  console.log(data.metrics.http_req_waiting.thresholds)

  if (data.metrics.http_req_duration.thresholds['avg\u003c1']['ok'] === true) {
    sectionBlocks.blocks[2].text.text = "閾値を超えています。"
  } else {
    sectionBlocks.blocks[2].text.text = "基準をクリアしています。"
  }

  const slackRes = http.post('https://slack.com/api/chat.postMessage', JSON.stringify(payload), {
    headers: {
      'Authorization': 'Bearer ' + slack_token,
      'Content-Type': 'application/json'
    }
  })

  console.log(slackRes.body)
  
}
