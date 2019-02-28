profile = "shift3"

application_name = "kids-kare-api"

application_description = "Kids Kare alert api and web"

application_environment = "staging"

region = "us-west-2"

web_domain_name = "kids-kare.shift3sandbox.com"

api_domain_name = "kids-kare-api.shift3sandbox.com"

zone_id = "Z234K2J0M1T89W"

zone_alias_id = "Z38NKT9BP95V3O"

s3_alias = "s3-website-us-west-2.amazonaws.com"

solution_stack = "64bit Amazon Linux 2018.03 v4.8.1 running Node.js"

instance_type = "t2.micro"

max_size = "2"

environment_variables = [
  {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "APP_URL"
    value     = "http://kids-kare.shift3sandbox.com/#/"
  },
]

cnames = ["kids-kare.shift3sandbox.com", "www.kids-kare.shift3sandbox.com"]
