variable "filename" {
  description = "The path to the file that will be created. Missing parent directories will be created. If the file already exists, it will NOT be overridden."
  type        = string
}

variable "content" {
  description = "Content to store in the file, expected to be a UTF-8 encoded string."
  type        = string
}

variable "directory_permission" {
  description = "Permissions to set for directories created (before umask), expressed as string in numeric notation. Default value is 0755."
  type        = string
  default     = "0755"
}

variable "file_permission" {
  description = "Permissions to set for the output file (before umask), expressed as string in numeric notation. Default value is 0644."
  type        = string
  default     = "0644"
}
