variable "resource_group_name" { type = string }
variable "location" { type = string }
variable "name" { type = string }
variable "throughput" { type = number }
variable "subnet_id" { type = string }
variable "dns_zone_id" { type = string }
variable "secondary_location" { type = string }
variable "dr_subnet_id" { type = string }
variable "dr_resource_group_name" { type = string }
variable "tags" {
  type    = map(string)
  default = {}
}
