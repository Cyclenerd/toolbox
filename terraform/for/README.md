# For

```shell
terraform plan
```

```text
Terraform will perform the following actions:

  # local_file.foo["drei"] will be created
  + resource "local_file" "foo" {
      + content              = "3"
      + content_base64sha256 = (known after apply)
      + content_base64sha512 = (known after apply)
      + content_md5          = (known after apply)
      + content_sha1         = (known after apply)
      + content_sha256       = (known after apply)
      + content_sha512       = (known after apply)
      + directory_permission = "0777"
      + file_permission      = "0777"
      + filename             = "./drei.value"
      + id                   = (known after apply)
    }

  # local_file.foo["eins"] will be created
  + resource "local_file" "foo" {
      + content              = "EINS"
      + content_base64sha256 = (known after apply)
      + content_base64sha512 = (known after apply)
      + content_md5          = (known after apply)
      + content_sha1         = (known after apply)
      + content_sha256       = (known after apply)
      + content_sha512       = (known after apply)
      + directory_permission = "0777"
      + file_permission      = "0777"
      + filename             = "./eins.value"
      + id                   = (known after apply)
    }

  # local_file.foo["zwei"] will be created
  + resource "local_file" "foo" {
      + content              = "ZWEI"
      + content_base64sha256 = (known after apply)
      + content_base64sha512 = (known after apply)
      + content_md5          = (known after apply)
      + content_sha1         = (known after apply)
      + content_sha256       = (known after apply)
      + content_sha512       = (known after apply)
      + directory_permission = "0777"
      + file_permission      = "0777"
      + filename             = "./zwei.value"
      + id                   = (known after apply)
    }

  # local_file.foo2["eins"] will be created
  + resource "local_file" "foo2" {
      + content              = <<-EOT
            drei
            eins
            zwei
        EOT
      + content_base64sha256 = (known after apply)
      + content_base64sha512 = (known after apply)
      + content_md5          = (known after apply)
      + content_sha1         = (known after apply)
      + content_sha256       = (known after apply)
      + content_sha512       = (known after apply)
      + directory_permission = "0777"
      + file_permission      = "0777"
      + filename             = "./eins.key"
      + id                   = (known after apply)
    }

Plan: 4 to add, 0 to change, 0 to destroy.
```