###############################################################################
# SET ORGANIZATION POLICIES
###############################################################################

# https://cloud.google.com/architecture/security-foundations/using-example-terraform#organization-policy-setup
# https://cloud.google.com/resource-manager/docs/organization-policy/org-policy-constraints

locals {
  google_boolean_organization_policies = toset([
    # COMPUTE
    # Disables hardware-accelerated nested virtualization for all Compute Engine VMs
    "compute.disableNestedVirtualization",
    # Disables serial port access to Compute Engine VMs
    "compute.disableSerialPortAccess",
    # Disables Compute Engine API access to the guest attributes of Compute Engine VMs
    "compute.disableGuestAttributesAccess",
    # Skip the creation of the default network and related resources during Google Cloud project resource creation
    "compute.skipDefaultNetworkCreation",
    # SQL
    # Restricts public IP addresses on Cloud SQL instances
    "constraints/sql.restrictPublicIp",
    # IAM
    # Disables the creation of service account external keys
    "constraints/iam.disableServiceAccountKeyCreation",
    # Disable Service Account Key Upload
    "constraints/iam.disableServiceAccountKeyUpload",
    # STORAGE
    # Requires buckets to use uniform IAM-based bucket-level access
    "constraints/storage.uniformBucketLevelAccess",
    # Enforce Public Access Prevention on Google Storage Buckets
    "constraints/storage.publicAccessPrevention",
  ])
}

# Organization
# google_organization_policy
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_organization_policy

# Folder
# google_folder_organization_policy
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_folder_organization_policy

# Project
# google_project_organization_policy
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_project_organization_policy

# Enforce boolean policies
resource "google_project_organization_policy" "my-organization-policies" {
  for_each   = local.google_boolean_organization_policies
  project    = "${google_project.my-project.number}"
  constraint = each.value
  boolean_policy {
    enforced = true
  }
}

# Disables Compute Engine VM instances external IP addresses
resource "google_project_organization_policy" "my-disable-gce-external-ip-policy" {
  project    = "${google_project.my-project.number}"
  constraint = "compute.vmExternalIpAccess"
  list_policy {
    deny {
      all = true
    }
  }
}