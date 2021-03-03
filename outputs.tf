output "ecr_webapp_repository_url" {
    value = aws_ecr_repository.ecr_webapp.repository_url
}

output "ecr_webapp_repository_name" {
    value = aws_ecr_repository.ecr_webapp.name
}

output "alb_endpoint" {
    value = aws_alb.app_alb.dns_name
}

output "url" {
    value = aws_route53_record.alb_endpoint[0].name
}