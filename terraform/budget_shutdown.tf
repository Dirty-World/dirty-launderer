resource "google_cloudfunctions_function" "budget_shutdown" {
  name                  = "budget-shutdown"
  description           = "Shuts down resources if budget is exceeded"
  runtime               = "python311"
  project               = var.project_id
  region                = var.region
  source_archive_bucket = var.GCS_BUCKET_NAME
  source_archive_object = "budget-shutdown.zip"
  entry_point           = "main"
  trigger_http          = true
}