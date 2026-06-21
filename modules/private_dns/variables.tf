variable "resource_group_name" { type = string }
variable "vnet_ids" { type = list(string) }
variable "tags" {
  type    = map(string)
  default = {}
}
