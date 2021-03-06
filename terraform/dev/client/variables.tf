variable "aws_region" {
  type  = string
  default = "us-east-1"
}

variable "shared_credentials_file" {
  type  = string
  default = "~/.aws/credentials"
}

variable "aws_profile" {
  type  = string
  default = ""
}

variable "stage" {
  type = string
  default = "dev"
}

variable "domain_name" {
  type = string
}

variable "DB_NAME" {
  type = string
}

variable "DB_USERNAME" {
  type = string
  default = "postgres"
}

variable "website_bucket_name" {
  type = string
}

variable "static_path" {
  type = string
  default = "../client"
}

variable "mime_types" {
  default = {
    htm = "text/html"
    html = "text/html"
    css = "text/css"
    js = "application/javascript"
    map = "application/javascript"
    json = "application/json"
    jpeg = "image/jpeg"
    jpg = "image/jpg"
    svg = "image/svg"
    png = "image/png"
    php = "application/x-php"
    webflow = "test/css"
  }
}
