provider "digitalocean" {
  token = var.DO_Token
}

terraform {
  required_providers {
    digitalocean = {
      source = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}

resource "digitalocean_project" "orlando_server_project" {
  name        = "orlando_server_project"
  description = "Un servidor para cositas personales"
  resources   = [digitalocean_droplet.orlando_server_droplet.urn]
}

resource "digitalocean_ssh_key" "orlando_server_ssh_key" {
  name       = "orlando_server_key2"
  public_key = file("./keys/orlando_server.pub")
}

resource "digitalocean_droplet" "orlando_server_droplet" {
  name       = "orlandoserver"
  size       = "s-2vcpu-4gb-120gb-intel"
  image      = "ubuntu-24-04-x64"
  region     = "sfo3"
  ssh_keys   = [digitalocean_ssh_key.orlando_server_ssh_key.id]
  user_data  = file("./docker-install.sh")  # Script para instalar Docker en el servidor

  provisioner "remote-exec" {
    inline = [
      "mkdir -p /projects",
      "mkdir -p /volumes/nginx/html",
      "mkdir -p /volumes/nginx/certs",
      "mkdir -p /volumes/nginx/vhostd",
      "touch /projects/.env",
      "echo \"MONGO_DB=${var.MONGO_DB}\" >> /projects/.env",  # Cambiar MYSQL_DB por MONGO_DB
      "echo \"MONGO_USER=${var.MONGO_USER}\" >> /projects/.env",  # Cambiar MYSQL_USER por MONGO_USER
      "echo \"MONGO_HOST=${var.MONGO_HOST}\" >> /projects/.env",  # Cambiar MYSQL_HOST por MONGO_HOST
      "echo \"MONGO_PASSWORD=${var.MONGO_PASSWORD}\" >> /projects/.env",  # Cambiar MYSQL_PASSWORD por MONGO_PASSWORD
      "echo \"DOMAIN=${var.DOMAIN}\" >> /projects/.env",
      "echo \"USER_EMAIL=${var.USER_EMAIL}\" >> /projects/.env"
    ]
    connection {
      type        = "ssh"
      user        = "root"
      private_key = file("./keys/orlando_server")  # Ruta a tu clave privada
      host        = self.ipv4_address
    }
  }

  provisioner "file" {
    source      = "./containers/docker-compose.yml"  # Archivo docker-compose a copiar
    destination = "/projects/docker-compose.yml"

    connection {
      type        = "ssh"
      user        = "root"
      private_key = file("./keys/orlando_server")  # Ruta a tu clave privada
      host        = self.ipv4_address
    }
  }
}

resource "time_sleep" "wait_docker_install" {
  depends_on      = [digitalocean_droplet.orlando_server_droplet]
  create_duration = "130s" 
}

resource "null_resource" "init_api" {
  depends_on = [time_sleep.wait_docker_install]
  
  provisioner "remote-exec" {
    inline = [
      "cd /projects",
      "docker-compose up -d"  
    ]
    connection {
      type = "ssh"
      user = "root"
      private_key = file("./keys/orlando_server")
      host = digitalocean_droplet.orlando_server_droplet.ipv4_address
    }
  }
}

output "ip" {
  value = digitalocean_droplet.orlando_server_droplet.ipv4_address
}
