import http from 'k6/http'
import { check, sleep } from 'k6'
import {htmlReport} from "https://raw.githubusercontent.com/benc-uk/k6-reporter/main/dist/bundle.js"
import {jUnit, textSummary} from "https://jslib.k6.io/k6-summary/0.0.1/index.js"

export const options = {
  vus: 16,
  duration: '100s',
  rps: 400,
  thresholds: {
    "http_req_duration": ["avg<100"]
  }
}

export default function () {
  const url = "http://localhost:3000"
  let response = http.get(url)
  check(response, { "status is 200": (r) => r.status === 200 })
}

// レポート出力設定
export function handleSummary(data) {
    return {
        stdout: textSummary(data, { indent: " ", enableColors: true }),
        "./result/summary.html": htmlReport(data),
        './result/summary.xml': jUnit(data),
        './result/summary.json': JSON.stringify(data),
    }
}
