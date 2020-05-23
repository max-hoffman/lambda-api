resource "aws_route53_zone" "main" {
  name = "${var.stage}.${var.domain_name}"

  tags = {
    Environment = var.stage
  }
}

resource "aws_route53_record" "main" {
  zone_id = aws_route53_zone.dev.zone_id
  name    = "${var.stage}.${var.domain_name}"
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.s3_distribution.domain_name
    zone_id                = aws_cloudfront_distribution.s3_distribution.hosted_zone_id
    evaluate_target_health = true
  }
}
