env                = "dev"
region             = "ap-south-1"
vpc_cidr           = "10.10.0.0/16"
az_count           = 2
single_nat_gateway = true

services = {
  "publishing-api" = {
    instance_type = "t3.small"
    port          = 3000
    min           = 1
    max           = 2
    path          = "/publishing/*"
    health_path   = "/publishing/healthz"
    priority      = 10
  }
  "streaming-api" = {
    instance_type = "t3.small"
    port          = 3001
    min           = 1
    max           = 2
    path          = "/streaming/*"
    health_path   = "/streaming/healthz"
    priority      = 20
  }
}
