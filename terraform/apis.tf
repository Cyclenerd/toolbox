###############################################################################
# ENABLE APIs
###############################################################################

locals {
  google_apis = toset([
    # Compute Engine API
    "compute.googleapis.com",
    # Cloud DNS API
    "dns.googleapis.com",
    # Cloud Pub/Sub API
    "pubsub.googleapis.com",
    # Cloud Build API
    "cloudbuild.googleapis.com",
    # Cloud Source Repositories API
    "sourcerepo.googleapis.com",
    # Cloud Scheduler API
    "cloudscheduler.googleapis.com",
    # Service Usage API
    "serviceusage.googleapis.com",
    # Cloud Resource Manager API
    "cloudresourcemanager.googleapis.com",
    # Identity and Access Management (IAM) API
    "iam.googleapis.com",
    # IAM Service Account Credentials API
    "iamcredentials.googleapis.com",
    # Cloud Storage API
    "storage.googleapis.com",
    # Cloud Logging API
    "logging.googleapis.com",
    # Cloud Monitoring API
    "monitoring.googleapis.com",
    # Cloud Function API
    "cloudfunctions.googleapis.com",
    # Secret Manager
    "secretmanager.googleapis.com",
    # Essential Contacts
    "essentialcontacts.googleapis.com",
    # Cloud Billing API
    "cloudbilling.googleapis.com",
    # Cloud Billing Budget API
    "billingbudgets.googleapis.com",
    # Kubernetes Engine API
    "container.googleapis.com",
    # Container Security API
    "containersecurity.googleapis.com",
    # Artifact Registry
    "artifactregistry.googleapis.com",
    # Container Scanning API
    "containerscanning.googleapis.com",
    # Cloud SQL
    "sql-component.googleapis.com",
    # Google Cloud Firestore API
    "firestore.googleapis.com",
    # Cloud Datastore API
    "datastore.googleapis.com",
    # Organization Policy API
    "orgpolicy.googleapis.com",
    # Cloud Deployment Manager V2 API
    "deploymentmanager.googleapis.com",
    # Cloud Deploy API
    "clouddeploy.googleapis.com",
    # Cloud Data Loss Prevention (DLP) API
    "dlp.googleapis.com",
    # Web Security Scanner API
    "websecurityscanner.googleapis.com",
    # Certificate Authority Service API
    "privateca.googleapis.com",
    # Certificate Manager API
    "certificatemanager.googleapis.com",
    # Cloud Key Management Service (KMS) API
    "cloudkms.googleapis.com",
    # Identity-Aware Proxy API
    "iap.googleapis.com",
    # Binary Authorization API
    "binaryauthorization.googleapis.com",
    # Managed Service for Microsoft Active Directory API
    "managedidentities.googleapis.com",
    # reCAPTCHA Enterprise API
    "recaptchaenterprise.googleapis.com",
    # Google Cloud Memorystore for Redis API
    "redis.googleapis.com",
    # Cloud Memorystore for Memcached API
    "memcache.googleapis.com",
    # Batch API
    "batch.googleapis.com",
    # API Gateway API
    "apigateway.googleapis.com",
    # Service Control API
    "servicecontrol.googleapis.com",
    # Service Management API
    "servicemanagement.googleapis.com",
    # Transfer Appliance API
    "transferappliance.googleapis.com",
    # Cloud Tasks API
    "cloudtasks.googleapis.com",
    # Workflows API
    "workflows.googleapis.com",
    "workflowexecutions.googleapis.com",
    # Connector Platform API
    "connectors.googleapis.com",
    # Application Integration API
    "integrations.googleapis.com",
    # Cloud IDS API
    "ids.googleapis.com",
    # Backup and DR Service API
    "backupdr.googleapis.com",
    # Cloud Composer API
    "composer.googleapis.com",
    # Cloud Dataproc API
    "dataproc.googleapis.com",
    # Datastream API
    "datastream.googleapis.com",
    # Google Cloud Data Catalog API
    "datacatalog.googleapis.com",
    # Cloud Data Fusion API
    "datafusion.googleapis.com",
    # Vertex AI API
    "aiplatform.googleapis.com",
    # Notebooks API
    "notebooks.googleapis.com",
    # Dataflow API
    "dataflow.googleapis.com",
    # Bare Metal Solution API
    "baremetalsolution.googleapis.com",
    # Eventarc
    "eventarc.googleapis.com",
    "eventarcpublishing.googleapis.com",
    # Cloud Runtime Configuration API
    "runtimeconfig.googleapis.com",
  ])
}

# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_project_service

# Enable API
resource "google_project_service" "google-apis" {
  for_each = local.google_apis
  service  = each.value
}