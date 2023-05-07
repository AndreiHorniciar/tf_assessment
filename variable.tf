variable "vm_count" {
  description = "Number of VMs to create"
  type        = number
  default     = 2
}

variable "vm_size" {
  description = "Size of the VMs"
  default     = "Standard_B2ms"
}

variable "admin_username" {
  description = "Admin username for the VMs"
  default     = "adminuser"
}

variable "publisher" {
    default = "Canonical"
}

variable "image" {
    default = "UbuntuServer"
}

variable "sku" {
    default =  "16.04-LTS"
}     