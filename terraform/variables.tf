###############################################################################
# VARIABLES
###############################################################################

variable "org_id" {
  type = number
  nullable = false
  description = "The ID of the organization"
  validation {
    condition     = can(regex("^[0-9]+$", var.org_id))
    error_message = "Specify organization id as integer (1 - 10000000..)!"
  }
}

variable "project_id" {
  type = string
  nullable = false
  description = "The project ID for the resources"
  # https://cloud.google.com/resource-manager/docs/creating-managing-projects#before_you_begin
  validation {
    # Must be 6 to 30 characters in length.
    # Can only contain lowercase letters, numbers, and hyphens.
    # Must start with a letter.
    # Cannot end with a hyphen.
    condition     = can(regex("^[a-z][a-z0-9-]{4,28}[a-z0-9]$", var.project_id))
    error_message = "Invalid project ID!"
  }
}

variable "billing_account_id" {
  type = string
  nullable = false
  description = "The alphanumeric ID (for example, 012345-567890-ABCDEF) of the billing account this project belongs to"
  validation {
    condition     = can(regex("^[0-9A-Z]{6}-[0-9A-Z]{6}-[0-9A-Z]{6}$", var.billing_account_id))
    error_message = "Specify billing account as alphanumeric text!"
  }
}

variable "target_amount" {
  type = number
  nullable = false
  description = "Set maximum monthly budget amount (currency as in billing account)"
  default = "1000"
  validation {
    # https://cloud.google.com/billing/docs/reference/budget/rest/v1/billingAccounts.budgets#BudgetAmount
    condition     = can(regex("^1[0-9]+$", var.target_amount))
    error_message = "Specify amount as 64-bit signed integer (1 - 10000000..)!"
  }
}

variable "region" {
  type = string
  nullable = false
  default = "us-central1"
}

variable "zone" {
  type = string
  nullable = false
  default = "us-central1-b"
}