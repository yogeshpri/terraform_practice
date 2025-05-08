locals {
  a_file = file("~/abc.txt")
}

output "a_file" {
  value = local.a_file
}