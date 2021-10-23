
variable "location" {
  description = "Region"
  default     = "westus2"
}


variable "resource_group_name" {
  type        = string
  description = "Resource group name"
  default     = "bootcamp_Week5-ResourceG"
}

variable "vm_name" {
  type = string
}

variable "public_vm_size" {
  type        = string
  description = "Vm-Size Config"
  default     = "Standard_B1s"
}

variable "availability_set_id" {
  type = string
}

variable "network_interface_ids" {
  type = list(any)
}

variable "storage_os_disk_name" {
  type = string
}

variable "computer_name" {
  type = string
}

variable "ubuntu_username" {
  type = string
}

variable "admin_password" {
  type = string
}
