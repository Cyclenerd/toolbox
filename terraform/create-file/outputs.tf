output "file_id" {
  description = "The hexadecimal encoding of the SHA1 checksum of the file content."
  value       = try(local_file.this.id, null)
}
