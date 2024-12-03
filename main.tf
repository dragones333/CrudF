provider "digitalocean" {
  token = var.do_token
}

resource "digitalocean_droplet" "app_server" {
  image  = "ubuntu-20-04-x64"
  name   = "api-server"
  region = "nyc3" 
  size   = "s-1vcpu-1gb"
  ssh_keys = [var.ssh_key_id] 
}
