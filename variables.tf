variable "region_aws" {
  description = "aws region"
  type        = string
}

variable "supernet" {
  description = "cidr for wan supernet"
  type        = string
}

variable "net_name" {
  description = "prepended to all resource name tags"
  type        = string
}

variable "vpc_params" {
  description = "inputs for vpc's"
  type = map(object({
    type = string
    cidr = string
  }))
}

variable "subnet_params" {
  description = "inputs for subnets"
  type = map(object({
    vpc       = string
    cidr_mask = number
    public    = bool
  }))
}