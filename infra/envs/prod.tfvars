env                = "prod"
region             = "ap-south-1"
vpc_cidr           = "10.30.0.0/16"
az_count           = 3
single_nat_gateway = false # one NAT per AZ, so an AZ failure does not cut egress

services = {
  "publishing-api" = {
    instance_type = "t3.medium"
    port          = 3000
    min           = 3
    max           = 6
    path          = "/publishing/*"
    health_path   = "/publishing/healthz"
    priority      = 10
  }
  "streaming-api" = {
    instance_type = "t3.medium"
    port          = 3001
    min           = 3
    max           = 9
    path          = "/streaming/*"
    health_path   = "/streaming/healthz"
    priority      = 20
  }
}
