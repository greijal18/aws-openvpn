variable "access_key" {
  default = "greijal"
}

variable "region" {
  #default = "eu-west-2" # Europe (London)
  default = "sa-east-1" # South America (São Paulo)
}

variable "az_count" {
  default = "1"
}

variable "instanceTenancy" {
  default = "default"
}

variable "dnsHostNames" {
  default = true  
}

variable "vpcCIDRblock" {
  default = "10.0.0.0/16"
}

variable "ingressCIDRblock" {
  type = list
  default = [ "0.0.0.0/0" ]
}

variable "egressCIDRblock" {
  type = list
  default = [ "0.0.0.0/0" ]
}   
