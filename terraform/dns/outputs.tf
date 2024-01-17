output "eks_cluster_zone_id" {
  value = aws_route53_zone.cluster_zone.zone_id
}

output "aws_acm_certificate_arn" {
  value = aws_acm_certificate.wildcard_cert.arn
}
