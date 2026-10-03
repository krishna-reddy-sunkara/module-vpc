variable "project" {
    type = string
}

variable "environment" {
    type = string  
}


variable "vpc_cidr" {
    type = string
    default = "10.0.0.0/16"
}

variable "vpc_tags" {
    type = map 
    default = {}
  
}

variable "igw_tags" {
    type = map 
    default = {}  
}

variable "public_cidr_block" {
    type = list 
    default = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "public_subnet_tags" {
    type = map
}