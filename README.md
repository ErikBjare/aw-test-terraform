aw-test-terraform
=================

A multi-device ActivityWatch setup with sync (using rsync), for testing purposes, using Docker & Terraform.

NOTE: I've used GPT4 quite a lot while doing this. I don't really know what I'm doing, and it has been a great debug help. (it also wrote basically the entire first commit)


## Usage

Before running `terraform init` and `terraform apply`, ensure that you have the Docker provider installed, your Docker daemon is running.

 - [x] The `Dockerfile` builds an Ubuntu image with LXDE, ActivityWatch, VNC, and SSH installed and ran with `supervisord`.
 - [x] The `main.tf` file creates a specified number of containers on the same network. 
 - [ ] It sets up rsync and the `~/ActivityWatchSync` folders, configuring the rsync service to sync data between the containers' folders.

Note that this configuration assumes that the first container (`activitywatch-vm-0`) will act as the central hub for syncing the `ActivityWatchSync` folders. You can modify this behavior as needed (as we should as part of testing).
