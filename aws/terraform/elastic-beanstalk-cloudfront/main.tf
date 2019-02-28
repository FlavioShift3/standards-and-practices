provider "aws" {
  profile = "${var.profile}"
  region  = "${var.region}"
}

data "aws_route53_zone" "zone" {
  name         = "shift3sandbox.com."
  private_zone = false
}

resource "aws_acm_certificate" "cert" {
  domain_name       = "${var.api_domain_name}"
  validation_method = "DNS"
}

resource "aws_route53_record" "cert_validation" {
  name    = "${aws_acm_certificate.cert.domain_validation_options.0.resource_record_name}"
  type    = "${aws_acm_certificate.cert.domain_validation_options.0.resource_record_type}"
  zone_id = "${data.aws_route53_zone.zone.id}"
  records = ["${aws_acm_certificate.cert.domain_validation_options.0.resource_record_value}"]
  ttl     = 60
}

resource "aws_acm_certificate_validation" "cert" {
  certificate_arn         = "${aws_acm_certificate.cert.arn}"
  validation_record_fqdns = ["${aws_route53_record.cert_validation.fqdn}"]
}

resource "aws_s3_bucket" "web_bucket" {
  bucket = "${var.web_domain_name}"
  acl    = "public-read"

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["PUT", "POST"]
    allowed_origins = ["*"]
    expose_headers  = ["ETag"]
    max_age_seconds = 3000
  }

  policy = <<EOF
{
    "Version": "2008-10-17",
    "Statement": [
    {
        "Sid": "PublicReadForGetBucketObjects",
        "Effect": "Allow",
        "Principal": {
            "AWS": "*"
         },
         "Action": "s3:GetObject",
         "Resource": "arn:aws:s3:::listing-alert.shift3sandbox.com/*"
    }, {
        "Sid": "AllowBucketUpdate",
        "Effect": "Allow",
        "Principal": {
            "AWS": "arn:aws:iam::008036621198:user/S3BucketDeployer"
        },
        "Action": "s3:*",
        "Resource": [
            "arn:aws:s3:::listing-alert.shift3sandbox.com",
            "arn:aws:s3:::listing-alert.shift3sandbox.com/*"
        ]
    }]
}
EOF
}

# Create Cloudfront distribution
resource "aws_cloudfront_distribution" "prod_distribution" {
  origin {
    domain_name = "${aws_s3_bucket.web_bucket.bucket_domain_name}"
    origin_id   = "S3-${aws_s3_bucket.web_bucket.bucket}"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "match-viewer"
      origin_ssl_protocols   = ["TLSv1", "TLSv1.1", "TLSv1.2"]
    }
  }

  # By default, show index.html file
  default_root_object = "index.html"
  enabled             = true

  # If there is a 404, return index.html with a HTTP 200 Response
  custom_error_response {
    error_caching_min_ttl = 3000
    error_code            = 404
    response_code         = 200
    response_page_path    = "/index.html"
  }

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3-${aws_s3_bucket.web_bucket.bucket}"

    # Forward all query strings, cookies and headers
    forwarded_values {
      query_string = true

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  # Distributes content to US and Europe
  price_class = "PriceClass_100"

  # Restricts who is able to access this content
  restrictions {
    geo_restriction {
      # type of restriction, blacklist, whitelist or none
      restriction_type = "none"
    }
  }

  # SSL certificate for the service.
  viewer_certificate {
    cloudfront_default_certificate = true
  }
}

# S3 Bucket for storing Elastic Beanstalk task definitions
resource "aws_s3_bucket" "ng_beanstalk_deploys" {
  bucket = "${var.application_name}-deployments"
}

# Elastic Container Repository for Docker images
resource "aws_ecr_repository" "ng_container_repository" {
  name = "${var.application_name}"
}

# Beanstalk Application
resource "aws_elastic_beanstalk_application" "ng_beanstalk_application" {
  name        = "${var.application_name}"
  description = "${var.application_description}"
}

# Beanstalk Environment
resource "aws_elastic_beanstalk_environment" "ng_beanstalk_application_environment" {
  name                = "${var.application_name}-${var.application_environment}"
  application         = "${aws_elastic_beanstalk_application.ng_beanstalk_application.name}"
  solution_stack_name = "${var.solution_stack}"
  tier                = "WebServer"
  setting             = ["${var.environment_variables}"]
  depends_on          = ["aws_acm_certificate_validation.cert"]

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "InstanceType"

    value = "${var.instance_type}"
  }

  setting {
    namespace = "aws:elb:listener:443"
    name      = "ListenerProtocol"
    value     = "HTTPS"
  }

  setting {
    namespace = "aws:elb:listener:443"
    name      = "InstancePort"
    value     = "80"
  }

  setting {
    namespace = "aws:elb:listener:443"
    name      = "SSLCertificateId"
    value     = "${aws_acm_certificate.cert.arn}"
  }

  setting {
    namespace = "aws:autoscaling:asg"
    name      = "MaxSize"

    value = "${var.max_size}"
  }
}
