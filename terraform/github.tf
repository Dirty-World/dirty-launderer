resource "google_cloudfunctions2_function" "github_proxy_sync" {
  name     = "github-proxy-sync"
  location = var.region
  project  = var.project_id

  build_config {
    runtime     = "python311"
    entry_point = "main"
    source {
      storage_source {
        bucket = var.GCS_BUCKET_NAME
        object = "github-proxy-sync.zip"
      }
    }
  }

  service_config {
    environment_variables = {
      PROJECT_ID            = var.project_id
      BUCKET_NAME           = var.GCS_BUCKET_NAME
    }
  }
}