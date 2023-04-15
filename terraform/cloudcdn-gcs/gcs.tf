# Webサイト
resource "google_storage_bucket" "admin-web" {
  name     = "kebjob-admin-web-${var.env}"
  location = "ASIA1"
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
