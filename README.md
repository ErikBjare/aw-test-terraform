aw-test-terraform
=================

A multi-device ActivityWatch setup with sync, for testing purposes, using Terraform.

NOTE: This was almost entirely generated using GPT4 (at least initial commit)


## Usage

Before running `terraform init` and `terraform apply`, ensure that you have the Docker provider installed, your Docker daemon is running, and your SSH key is in place. You may need to adjust the path of the private SSH key if it is located elsewhere.

The `main.tf` file creates a specified number of containers with ActivityWatch and LXDE installed. It sets up rsync and the `~/ActivityWatchSync` folders, configuring the rsync service to sync data between the containers' folders.

Note that this configuration assumes that the first container (`activitywatch-vm-0`) will act as the central hub for syncing the `ActivityWatchSync` folders. You can modify this behavior as needed.
