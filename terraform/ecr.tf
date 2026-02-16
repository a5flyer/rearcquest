resource "aws_ecr_repository" "reactf" {
  name                 = "reactf"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = "reactf-ecr"
  }
}
