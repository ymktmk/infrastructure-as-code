# 証明書
resource "google_compute_managed_ssl_certificate" "cdn" {
  name = "cdn-certificate"

  managed {
    domains = ["admin.kenjob.jp"]
  }
}

resource "google_compute_ssl_policy" "ssl_policy" {
  name            = "streets-ssl-policy"
  profile         = "MODERN"
  min_tls_version = "TLS_1_2"
}
