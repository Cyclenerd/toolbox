# Creates a local file

Creates a single file if the file name does **not** exist.

If the file already exists or has been modified, the Terraform state is only updated during `terraform apply`.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.7 |
| <a name="requirement_local"></a> [local](#requirement\_local) | >= 2.4.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_local"></a> [local](#provider\_local) | >= 2.4.1 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [local_file.this](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_content"></a> [content](#input\_content) | Content to store in the file, expected to be a UTF-8 encoded string. | `string` | n/a | yes |
| <a name="input_directory_permission"></a> [directory\_permission](#input\_directory\_permission) | Permissions to set for directories created (before umask), expressed as string in numeric notation. Default value is 0755. | `string` | `"0755"` | no |
| <a name="input_file_permission"></a> [file\_permission](#input\_file\_permission) | Permissions to set for the output file (before umask), expressed as string in numeric notation. Default value is 0644. | `string` | `"0644"` | no |
| <a name="input_filename"></a> [filename](#input\_filename) | The path to the file that will be created. Missing parent directories will be created. If the file already exists, it will NOT be overridden. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_file_id"></a> [file\_id](#output\_file\_id) | The hexadecimal encoding of the SHA1 checksum of the file content. |
<!-- END_TF_DOCS -->
