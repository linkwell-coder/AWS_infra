variable "aws_region" {
  description = "The AWS region to create things in."
  default     = "us-east-1"
}

variable "access_key" {
  description = "This is an access key"
  default     = "AKIA5O6ODOOPLNRWHWEO"
}

variable "secret_key" {
  description = "This is an secret key"
  default     = "wi1vkzJpr6U5OxzsKk4NzujDLNA1S5QgG/6HXMnW"
}

variable "vpccidr" {
  description = "This is VPC CIDR block"
  default     = "192.168.0.0/16"
}

variable "vpcname"{
  description = "Name of the VPC"
  default     = "dev-acs-test-vpc"
}
