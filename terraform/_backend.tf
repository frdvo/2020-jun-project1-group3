terraform {
  backend "s3" {
    key            = "da/project3"
    region         = "ap-southeast-2"
    dynamodb_table = "da-project3-terraform-lock"
  }
}