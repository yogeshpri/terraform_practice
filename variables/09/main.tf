locals {
 range_one_arg    = range(3)
 range_two_args   = range(1, 3)
 range_three_args = range(1, 13, 3)
}

output "ranges" {
 value = format("Range one arg: %v. Range two args: %v. Range three args: %v", local.range_one_arg, local.range_two_args, local.range_three_args)
}