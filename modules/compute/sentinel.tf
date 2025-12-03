resource "null_resource" "force_recreate_sentinel" {
  triggers = {
    force = var.force_recreate ? uuid() : 0
  }
}
