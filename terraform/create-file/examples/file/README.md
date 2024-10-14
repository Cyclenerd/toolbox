# Creates a local file

Creates a single file.

Run:

```bash
echo "Test" > /tmp/test
chmod 644 /tmp/test
terraform init
terraform plan
terraform apply
```

## Example

<!-- BEGIN_TF_DOCS -->

```hcl
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
```

## Providers

| Name | Version |
|------|---------|
| <a name="provider_random"></a> [random](#provider\_random) | 3.6.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_existing_file"></a> [existing\_file](#module\_existing\_file) | ../../ | n/a |
| <a name="module_new_file"></a> [new\_file](#module\_new\_file) | ../../ | n/a |

## Resources

| Name | Type |
|------|------|
| [random_pet.this](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/pet) | resource |

## Inputs

No inputs.

## Outputs

No outputs.
<!-- END_TF_DOCS -->
