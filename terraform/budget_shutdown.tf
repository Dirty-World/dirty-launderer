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

# Define a Pub/Sub topic for budget alerts
resource "google_pubsub_topic" "budget_alert_topic_shutdown" {
  name = "budget-alert-topic-shutdown"
}

# Define a Pub/Sub subscription for the budget alert topic
resource "google_pubsub_subscription" "budget_alert_subscription_shutdown" {
  name  = "budget-alert-subscription-shutdown"
  topic = google_pubsub_topic.budget_alert_topic_shutdown.name
}

# Define a Cloud Function to handle budget alerts
resource "google_cloudfunctions_function" "budget_shutdown_function" {
  name        = "budget-shutdown-function"
  runtime     = "python310"
  entry_point = "main"
  source_archive_bucket = var.GCS_BUCKET_NAME
  source_archive_object = var.source_archive
  trigger_http          = false

  event_trigger {
    event_type = "google.pubsub.topic.publish"
    resource   = google_pubsub_topic.budget_alert_topic_shutdown.id
  }

  environment_variables = {
    TELEGRAM_BOT_TOKEN = var.telegram_bot_token
    ADMIN_CHAT_ID      = var.admin_chat_id
  }
}

# Grant the Cloud Function permission to consume Pub/Sub messages
resource "google_project_iam_member" "function_pubsub_invoker" {
  project = var.project_id
  role    = "roles/pubsub.subscriber"
  member  = "serviceAccount:${google_cloudfunctions_function.budget_shutdown_function.service_account_email}"
}