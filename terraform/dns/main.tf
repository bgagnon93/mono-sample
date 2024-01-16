# Route53 Hosted Zone & Certificate Management

# Get Parent Domain Route53 Zone
data "aws_route53_zone" "parent_zone" {
  name = var.parent_domain
}

resource "aws_route53_zone" "cluster_zone" {
  name = var.cluster_subdomain
  tags = {
    cluster           = var.cluster_name
    contact           = "bgagnon93@gmail.com"
    "user:CostCenter" = "core"
    terraform         = true
    client            = "internal"
  }
}

resource "aws_route53_record" "ns" {
  zone_id = data.aws_route53_zone.parent_zone.zone_id # PARENT ZONE id
  name    = var.cluster_subdomain
  type    = "NS"
  ttl     = "30"
  records = aws_route53_zone.cluster_zone.name_servers
}

resource "aws_acm_certificate" "wildcard_cert" {
  domain_name       = "*.${var.cluster_subdomain}"
  validation_method = "DNS"
  lifecycle {
    create_before_destroy = true
  }
  tags = var.tags
}

resource "aws_route53_record" "cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.wildcard_cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = aws_route53_zone.cluster_zone.zone_id
}

resource "aws_acm_certificate_validation" "wildcard_cert" {
  certificate_arn         = aws_acm_certificate.wildcard_cert.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
}
