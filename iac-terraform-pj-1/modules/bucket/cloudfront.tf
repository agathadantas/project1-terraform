resource "aws_cloudfront_origin_access_control" "frontend" {
  name                              = "pj-cd-acloud-${var.project}-${var.environment}-OAI"
  description                       = "pj-cd-acloud-${var.project}-${var.environment}-OAI"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_origin_access_identity" "oai" {
  comment = "pj-cd-acloud-${var.project}-${var.environment} website OAI"
}

resource "aws_cloudfront_distribution" "frontend_distribution" {
  origin {
    domain_name = aws_s3_bucket.bucket_s3.bucket_regional_domain_name
    origin_id   = "pj-cd-acloud-${var.project}-${var.environment}-frontend-origin"

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.oai.cloudfront_access_identity_path
    }
  }

    aliases = ["www.${var.domain}", var.domain]

  enabled         = true
  is_ipv6_enabled = true

  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "pj-cd-acloud-${var.project}-${var.environment}-frontend-origin"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 86400
    default_ttl            = 31536000
    max_ttl                = 31536000
    compress               = true
  }

  ordered_cache_behavior {
    path_pattern     = "/index.html"
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = "pj-cd-acloud-${var.project}-${var.environment}-frontend-origin"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    min_ttl                = 86400
    default_ttl            = 31536000
    max_ttl                = 31536000
    compress               = true
    viewer_protocol_policy = "redirect-to-https"
  }

  price_class = "PriceClass_100"

  viewer_certificate {
    cloudfront_default_certificate = false
    acm_certificate_arn = var.us-east-1_certificate
    ssl_support_method = "sni-only"
  }

  retain_on_delete = true

  custom_error_response {
    error_caching_min_ttl = 300
    error_code            = 403
    response_code         = 200
    response_page_path    = "/index.html"
  }

  custom_error_response {
    error_caching_min_ttl = 300
    error_code            = 404
    response_code         = 200
    response_page_path    = "/index.html"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  tags = {
    Name        = "pj-cd-acloud-${var.project}-${var.environment}-cloudfront"
    Entity      = "pj"
    Unit        = "cd"
    Team        = "ACloud"
    Project     = var.project
    Environment = var.environment
    Region      = var.region
    Repository  = var.repository
  }
}

#CDN

resource "aws_cloudfront_distribution" "cdn_distribution" {
  origin {
    domain_name = aws_s3_bucket.cdn.bucket_regional_domain_name
    origin_id   = "pj-cd-acloud-${var.project}-${var.environment}-cdn-origin"

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.oai.cloudfront_access_identity_path
    }
  }

  aliases = ["cdn.${var.domain}"]

  enabled         = true
  is_ipv6_enabled = true

  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "pj-cd-acloud-${var.project}-${var.environment}-cdn-origin"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
    compress               = true
  }

  ordered_cache_behavior {
    path_pattern     = "/index.html"
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = "pj-cd-acloud-${var.project}-${var.environment}-cdn-origin"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    min_ttl                = 0
    default_ttl            = 0
    max_ttl                = 0
    compress               = true
    viewer_protocol_policy = "redirect-to-https"
  }

  price_class = "PriceClass_100"

  viewer_certificate {
    cloudfront_default_certificate = false
    acm_certificate_arn = var.us-east-1_certificate
    ssl_support_method = "sni-only"
  }

  retain_on_delete = true

  custom_error_response {
    error_caching_min_ttl = 300
    error_code            = 403
    response_code         = 200
    response_page_path    = "/index.html"
  }

  custom_error_response {
    error_caching_min_ttl = 300
    error_code            = 404
    response_code         = 200
    response_page_path    = "/index.html"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  tags = {
    Name        = "pj-cd-acloud-${var.project}-${var.environment}-cloudfront"
    Entity      = "pj"
    Unit        = "cd"
    Team        = "ACloud"
    Project     = var.project
    Environment = var.environment
    Region      = var.region
    Repository  = var.repository
  }
}