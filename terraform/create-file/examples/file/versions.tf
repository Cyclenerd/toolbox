terraform {
  required_version = ">= 1.5.7"

  required_providers {
    random = {
      source  = "hashicorp/random"
      version = ">= 3.6"
    }
  }
}
