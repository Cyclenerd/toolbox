# Terraform

Terraform plans, mostly for Google Cloud.

Google provider: <https://registry.terraform.io/providers/hashicorp/google/latest/docs>

## Deploying

1. Run `terraform init`.
1. Run `terraform plan` and review the output.
1. Run `terraform apply`. (`-auto-approve`)

## Destroying

```shell
terraform plan -destroy
terraform apply -destroy
```

## Style Conventions

<https://www.terraform.io/language/syntax/style>

```shell
terraform fmt
```

## Variable

File `terraform.tfvars`:
```
image_id=ami-abc123
```

Or via command:
```shell
terraform apply -var-file="testing.tfvars"
terraform apply -var="image_id=ami-abc123"
terraform apply -var="project_id=$GOOGLE_CLOUD_PROJECT"
```

## Debug

```shell
export TF_LOG="DEBUG"
export TF_LOG_PATH="/tmp/terraform.log"
```
