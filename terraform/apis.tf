###############################################################################
# ENABLE APIs
###############################################################################

locals {
  google_apis = toset([
    # Service Usage API
    "serviceusage.googleapis.com",
    # Cloud Resource Manager API
    "cloudresourcemanager.googleapis.com",
    # Identity and Access Management (IAM) API
    "iam.googleapis.com",
    # Cloud Billing API
    "cloudbilling.googleapis.com",
    # Cloud Billing Budget API
    "billingbudgets.googleapis.com",
    # Cloud Pub/Sub API
    "pubsub.googleapis.com",
    # Cloud Storage API
    "storage.googleapis.com",
    # Cloud Logging API
    "logging.googleapis.com",
    # Cloud Build API
    "cloudbuild.googleapis.com",
    # Cloud Function API
    "cloudfunctions.googleapis.com",
  ])
}

# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_project_service

# Enable API
resource "google_project_service" "google-apis" {
  for_each = local.google_apis
  service  = each.value
}