variable "resource_group_name" { type = string }
variable "location" { type = string }
variable "env" { type = string }
variable "retention_days" { type = number }
variable "project_name" { type = string }
variable "tags" {
  type    = map(string)
  default = {}
}
