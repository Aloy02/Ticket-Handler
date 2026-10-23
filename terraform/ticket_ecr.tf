# ------------------------------------------------------------------------------
# Data Sources
# ------------------------------------------------------------------------------

resource "aws_ecr_repository" "report_generator_repo" {
  name                 = "${var.PREFIX}-ticket-handler"
  image_tag_mutability = "MUTABLE"
  force_delete         = true

  image_scanning_configuration {
    scan_on_push = true
  }
}