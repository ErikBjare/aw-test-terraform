terraform {
  required_providers {
    docker = {
      source = "kreuzwerker/docker"
    }
  }
}

provider "docker" {
  host = "unix:///var/run/docker.sock"
}

resource "docker_network" "activitywatch_network" {
  name = "activitywatch_network"
  ipam_config {
    subnet = "172.18.0.0/16"
  }
}

resource "docker_image" "activitywatch_vm" {
  name = "erikbjare/aw-test-terraform:latest"
}

resource "docker_container" "activitywatch_vm" {
  count   = var.vm_count
  image   = docker_image.activitywatch_vm.image_id
  name    = "activitywatch-vm-${count.index + 1}"
  restart = "unless-stopped"

  networks_advanced {
      name = docker_network.activitywatch_network.name
      ipv4_address = "172.18.1.${count.index + 1}"
  }

  ports {
    internal = 22
    external = 22020 + count.index + 1
  }
}

resource "null_resource" "provision_activitywatch_vm" {
  count = length(docker_container.activitywatch_vm)

  triggers = {
    container_id = docker_container.activitywatch_vm[count.index].id
  }

  provisioner "local-exec" {
    command = <<-EOT
      SSH_PORT=${docker_container.activitywatch_vm[count.index].ports.*.external[0]}
      CONTAINER_IP=$(docker inspect ${docker_container.activitywatch_vm[count.index].id} --format '{{range .NetworkSettings.Networks}}{{.IPAMConfig.IPv4Address}}{{end}}')
      REMOTE_IPS=$(printf '%s ' ${join(" ", [for i in range(var.vm_count) : docker_container.activitywatch_vm[i].networks_advanced.*.ipv4_address[0] if i != count.index])} | tr ' ' '\n' | grep -v $${CONTAINER_IP} | paste -sd ' ' -)
      echo 
      sshpass -p 'password' ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null desktopuser@localhost -p $${SSH_PORT} 'echo "*/5 * * * * /home/desktopuser/rsync_script.sh $${REMOTE_IPS}" | crontab -'
    EOT
  }
}

output "activitywatch_vm_ips" {
  value = [for i in range(var.vm_count) : docker_container.activitywatch_vm[i].networks_advanced.*.ipv4_address[0]]
}

output "activitywatch_vm_ports" {
  value = [for i in range(var.vm_count) : docker_container.activitywatch_vm[i].ports.*.external[0]]
}
