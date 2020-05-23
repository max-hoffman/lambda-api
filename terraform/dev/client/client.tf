# https://gist.github.com/nagelflorian/67060ffaf0e8c6016fa1050b6a4e767a

data "aws_iam_policy_document" "s3_public" {
  statement {
    sid    = "PublicReadForGetBucketObjects"
    effect = "Allow"

    actions = ["s3:GetObject"]
    resources = [aws_s3_bucket.bucket.arn]
  }
}

resource "aws_iam_policy" "s3_public" {
    name = "s3-public"
    path = "/"
    description = "public reading from s3 bucket"
    policy = data.aws_iam_policy_document.s3_public.json
}

resource "aws_s3_bucket" "bucket" {
  bucket = var.website_bucket_name
  acl = "public-read"
  # website_redirect = var.domain_name

  website {
    index_document = "index.html"
    error_document= "404.html"
  }
}

resource "aws_s3_bucket_object" "web" {
  for_each = fileset(path.module, "${var.static_path}/**/*.html")

  bucket = aws_s3_bucket.bucket.id
  acl = "public-read"

  key = replace(each.value, "${var.static_path}/", "")
  source = each.value
  content_type = lookup(var.mime_types, element(split(".", basename(each.value)), 1), "text/plain")
  etag = filemd5(each.value)

}

locals {
  s3_origin_id = "myS3Origin"
}

resource "aws_cloudfront_origin_access_identity" "origin_access_identity" {
  comment = "Some comment"
}

resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name = aws_s3_bucket.bucket.bucket_regional_domain_name
    origin_id   = local.s3_origin_id

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.origin_access_identity.cloudfront_access_identity_path
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "Quarantoned S3 CDN dev"
  default_root_object = "index.html"

  # aliases = ["mysite.example.com", "yoursite.example.com"]

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.s3_origin_id

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  # Cache behavior with precedence 0
  ordered_cache_behavior {
    path_pattern     = "/content/immutable/*"
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = local.s3_origin_id

    forwarded_values {
      query_string = false
      headers      = ["Origin"]

      cookies {
        forward = "none"
      }
    }

    min_ttl                = 0
    default_ttl            = 86400
    max_ttl                = 31536000
    compress               = true
    viewer_protocol_policy = "redirect-to-https"
  }

  # Cache behavior with precedence 1
  ordered_cache_behavior {
    path_pattern     = "/content/*"
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.s3_origin_id

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
    compress               = true
    viewer_protocol_policy = "redirect-to-https"
  }

  restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations        = ["US", "CA", "GB", "DE"]
    }
  }

  tags = {
    Environment = "dev"
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}
