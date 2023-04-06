variable "vm_count" {
  description = "The number of virtual machines/containers to create"
  type        = number
  default     = 3
}

variable "rsync_username" {
  description = "Username for the rsync user"
  type        = string
  default     = "rsyncuser"
}

variable "rsync_password" {
  description = "Password for the rsync user"
  type        = string
  default     = "rsyncpassword"
}
