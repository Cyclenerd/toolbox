locals {
  content = fileexists(var.filename) ? file(var.filename) : var.content
}

resource "local_file" "this" {
  # Create file only if file does not exists
  file_permission      = var.file_permission
  directory_permission = var.directory_permission
  filename             = var.filename
  content              = local.content
}
