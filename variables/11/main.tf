locals {
 a_jsondecode = jsondecode("{\"hello\": \"world\"}")
}


output "a_jsondecode" {
 value = local.a_jsondecode
}