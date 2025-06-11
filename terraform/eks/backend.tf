terraform {
  # Using local backend for now
  # To use S3 backend, first create the S3 bucket:
  # aws s3 mb s3://wole-devs-eks --region us-east-1
  # and then uncomment the following:
  /*
  backend "s3" {
    bucket  = "wole-devs-eks"
    key     = "eks/terraform.state"
    region  = "us-east-1"
    encrypt = true
  }
  */
}