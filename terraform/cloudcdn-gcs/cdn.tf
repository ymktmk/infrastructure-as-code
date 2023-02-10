# domainはTerraformで管理しないので
# Aレコードの作成を行うこと

# ロードバランサーのIP
resource "google_compute_global_address" "cdn" {
  name = "cdn-ip"
}

# ロードバランサ
resource "google_compute_global_forwarding_rule" "cdn" {
  name       = "cdn-forwarding-rule"
  target     = google_compute_target_https_proxy.cdn.self_link
  port_range = "443"
  ip_address = google_compute_global_address.cdn.address
}

# HTTPSプロキシ
resource "google_compute_target_https_proxy" "cdn" {
  name             = "cdn-https-proxy"
  url_map          = google_compute_url_map.cdn.self_link
  ssl_certificates = [google_compute_managed_ssl_certificate.cdn.self_link]
  ssl_policy       = google_compute_ssl_policy.ssl_policy.name
}

# URLマップ
resource "google_compute_url_map" "cdn" {
  name            = "cdn-url-map"
  
  default_service = google_compute_backend_bucket.cdn.id
  project         = var.project
}

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

# CDNのバックエンドを定義
resource "google_compute_backend_bucket" "cdn" {
  name        = "cdn-backend-bucket"
  description = "Backend bucket for serving static content through CDN"
  bucket_name = google_storage_bucket.admin-web.name
  enable_cdn  = true
}

# Webサイト
resource "google_storage_bucket" "admin-web" {
  name          = "kebjob-admin-web-${var.env}"
  location      = "ASIA1"
  # 後で消す
  force_destroy = true
  storage_class = "STANDARD"

  versioning {
    enabled = true
  }
  
  website {
    main_page_suffix = "index.html"
    not_found_page   = "404.html"
  }

  cors {
    origin          = ["https://admin.kenjob.jp"]
    method          = ["GET"]
    response_header = ["*"]
    max_age_seconds = 3600
  }

  uniform_bucket_level_access = true
}

resource "google_storage_bucket_iam_binding" "admin-web" {
  bucket = google_storage_bucket.admin-web.name
  role   = "roles/storage.legacyObjectReader"
  members = [
    "allUsers",
  ]
}
