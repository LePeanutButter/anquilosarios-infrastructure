resource "null_resource" "force_recreate_sentinel" {
  triggers = {
    value = var.force_recreate ? uuid() : "no-recreate"
  }
}
