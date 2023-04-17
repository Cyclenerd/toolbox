# Merge

```shell
terraform plan
```

```text
+ resource "local_file" "foo" {
    + content              = <<-EOT
          eins
          zwei aus B
          drei aus B
      EOT
    + content_base64sha256 = (known after apply)
    + content_base64sha512 = (known after apply)
    + content_md5          = (known after apply)
    + content_sha1         = (known after apply)
    + content_sha256       = (known after apply)
    + content_sha512       = (known after apply)
    + directory_permission = "0777"
    + file_permission      = "0777"
    + filename             = "./merge.txt"
    + id                   = (known after apply)
  }
```