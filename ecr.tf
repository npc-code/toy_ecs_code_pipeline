resource "aws_ecr_repository" "ecr_webapp" {
  #name = "ecr_repo_webapp" # Naming my repository
  name = var.ecr_repo_name
}
