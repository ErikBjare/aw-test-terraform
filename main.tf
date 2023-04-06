terraform {
  required_providers {
    docker = {
      source = "kreuzwerker/docker"
    }
  }
}

provider "docker" {
  host = "tcp://localhost:2376"
}

resource "docker_image" "activitywatch_vm" {
  name = "your-docker-image-name"
}

resource "docker_container" "activitywatch_vms" {
  count   = var.vm_count
  image   = docker_image.activitywatch_vm.latest
  name    = "activitywatch-vm-${count.index}"
  restart = "unless-stopped"

  ports {
    internal = 5600
    external = 5600 + count.index
  }

  env = [
    "RSYNC_USERNAME=${var.rsync_username}",
    "RSYNC_PASSWORD=${var.rsync_password}"
  ]

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install -y lxde",
      "wget https://github.com/ActivityWatch/activitywatch/releases/download/v0.11.0/activitywatch-v0.11.0-linux-x86_64.zip",
      "unzip activitywatch-v0.11.0-linux-x86_64.zip",
      "chmod +x activitywatch/aw-qt",
      "mkdir ~/ActivityWatchSync",
      "echo '@activitywatch/aw-qt' >> ~/.config/lxsession/LXDE/autostart",
      "echo '@rsync -avz --delete --password-file=/etc/rsyncd.secrets /home/${var.rsync_username}/ActivityWatchSync rsync://${var.rsync_username}@activitywatch-vm-0:873/ActivityWatchSync' >> ~/.config/lxsession/LXDE/autostart",
      "sudo apt-get install -y rsync",
      "echo 'uid = ${var.rsync_username}' | sudo tee -a /etc/rsyncd.conf",
      "echo 'gid = ${var.rsync_username}' | sudo tee -a /etc/rsyncd.conf",
      "echo 'use chroot = yes' | sudo tee -a /etc/rsyncd.conf",
      "echo 'max connections = 4' | sudo tee -a /etc/rsyncd.conf",
      "echo 'pid file = /var/run/rsyncd.pid' | sudo tee -a /etc/rsyncd.conf",
      "echo 'lock file = /var/run/rsync.lock' | sudo tee -a /etc/rsyncd.conf",
      "echo 'log file = /var/log/rsyncd.log' | sudo tee -a /etc/rsyncd.conf",
      "echo '[ActivityWatchSync]' | sudo tee -a /etc/rsyncd.conf",
      "echo 'path = /home/${var.rsync_username}/ActivityWatchSync' | sudo tee -a /etc/rsyncd.conf",
      "echo 'comment = ActivityWatch Sync folder' | sudo tee -a /etc/rsyncd.conf",
      "echo 'read only = no' | sudo tee -a /etc/rsyncd.conf",
      "echo 'list = yes' | sudo tee -a /etc/rsyncd.conf",
      "echo 'uid = ${var.rsync_username}' | sudo tee -a /etc/rsyncd.conf",
      "echo 'gid = ${var.rsync_username}' | sudo tee -a /etc/rsyncd.conf",
      "echo 'auth users = ${var.rsync_username}' | sudo tee -a /etc/rsyncd.conf",
      "echo 'secrets file = /etc/rsyncd.secrets' | sudo tee -a /etc/rsyncd.conf",
      "echo '${var.rsync_username}:${var.rsync_password}' | sudo tee /etc/rsyncd.secrets",
      "sudo chmod 600 /etc/rsyncd.secrets",
      "sudo systemctl enable rsync",
      "sudo systemctl start rsync"
    ]
  }
}
