variable "prefix" {
  type = string
  description = "prefix string"
}

variable "location" {
  description = "Region"
  default     = "westus2"
}


variable "resource_group_name" {
  type        = string
  description = "Resource group name"
  default     = "bootcamp_Week6-ResourceG"
}

variable "public_vm_size" {
  type        = string
  description = "Vm-Size Config"
  default     = "Standard_B1s"
}

variable "vnet-cidr" {
  type        = string
  description = "Vnet address space(CIDR)"
  default     = "10.0.0.0/16"
}


variable "subnet_name" {
  default = ["Subnet-1", "Private-Subnet-1"]
}

variable "subnet_prefix" {
  default = ["10.0.1.0/24", "10.0.2.0/24"]
}


variable "ubuntu_username" {
  type        = string
  description = "Administrator user name for Ubuntu virtual machine"
  default     = "ubuntu"
}

# variable "access_key_string" {
#   type        = string
#   description = "storage blob access key"
# }

# variable "ubuntu_password" {
#   type        = string
#   description = "Password for Ubuntu virtual machine, Password must meet Azure complexity requirements"
# }

variable "pg_admin" {
  type        = string
  description = "Administrator user name for the database"
  default     = "postgres"
}

variable "pg_admin_password" {
  type        = string
  description = "Password for the database, Password must meet Azure complexity requirements"
}

# variable "okta_url" {
#   type        = string
#   description = "Okta developer URL"
# }
# variable "okta_clientid" {
#   type        = string
#   description = "Okta dev client ID for the application"
# }
#
# variable "okta_secret" {
#   type        = string
#   description = "Okta dev secret for the application"
# }
