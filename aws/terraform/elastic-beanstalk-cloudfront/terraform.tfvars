profile = "shift3"

application_name = "listing-alert-api"

application_description = "Listing alert api and web"

application_environment = "staging"

region = "us-west-2"

web_domain_name = "listing-alert.shift3sandbox.com"

api_domain_name = "listing-alert-api.shift3sandbox.com"

zone_id = "Z234K2J0M1T89W"

zone_alias_id = "Z38NKT9BP95V3O"

s3_alias = "s3-website-us-west-2.amazonaws.com"

solution_stack = "64bit Amazon Linux 2018.03 v2.12.9 running Docker 18.06.1-ce"

instance_type = "t2.micro"

max_size = "2"

environment_variables = [
  {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "APP_URL"
    value     = "http://text-a-truck.shift3sandbox.com/#/"
  },
]
