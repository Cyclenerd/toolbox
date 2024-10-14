# Example
locals {
  new_file_name      = "/tmp/${random_pet.this.id}"
  existing_file_name = "/tmp/test"
}

# Creates new file
module "new_file" {
  source   = "../../"
  filename = local.new_file_name
  content  = "Test"
}

# Does not create a file (file name already exists)
# Note: Terraform state will be updated if necessary (first apply).
module "existing_file" {
  source   = "../../"
  filename = local.existing_file_name
  content  = "Overwrite"
}

# Helper
resource "random_pet" "this" {
  length = 2
}
