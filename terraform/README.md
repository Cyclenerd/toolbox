# Terraform

Terraform plans, mostly for Google Cloud.

Google provider: <https://registry.terraform.io/providers/hashicorp/google/latest/docs>

## Login

1. To initiate authorization, enter the following command:

    ```bash
    gcloud auth login --no-launch-browser
    ```

1. Copy the long URL that begins with `https://accounts.google.com/o/oauth2/auth...`
1. Paste this URL into the browser with which you are currently logged in with your admin account.
1. Copy the authorization code from the web browser.
1. Paste the authorization code back to the prompt,
   "Enter authorization code", and press Enter to complete the authorization.

### Application Default Credential

Perform the same steps again, this time for "Application Default Credentials":

```bash
gcloud auth application-default login --no-launch-browser
```

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
