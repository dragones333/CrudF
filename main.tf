provider "digitalocean" {
  token = var.do_token
}

resource "digitalocean_droplet" "web" {
  image  = "ubuntu-20-04-x64"
  name   = "api-server"
  region = "nyc3"
  size   = "s-1vcpu-1gb"

  provisioner "remote-exec" {
    inline = [
      "sudo apt update",
      "sudo apt install -y docker.io docker-compose",
    ]
  }
}

variable "do_token" {}

terraform {
  backend "s3" {
    bucket = "mi-terraform-state"
    endpoint = "nyc3.digitaloceanspaces.com"
    access_key = "YOUR_ACCESS_KEY"
    secret_key = "YOUR_SECRET_KEY"
    region     = "us-east-1"
  }
}
