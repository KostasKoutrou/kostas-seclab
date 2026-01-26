packer {
  required_plugins {
    name = {
      version = "~> 1"
      source  = "github.com/hashicorp/proxmox"
    }
  }
}

# Declare variables, we will pull them later in the packer build command
variable "proxmox_api_url" { type = string }
variable "proxmox_api_token_id" { type = string }
variable "proxmox_api_token_secret" {
  type      = string
  sensitive = true
}
variable "ubuntu_pw" {
  type = string
  sensitive = true
}

source "proxmox-iso" "ubuntu-server" { #Resource type and local name
  proxmox_url = var.proxmox_api_url
  username    = var.proxmox_api_token_id
  token       = var.proxmox_api_token_secret

  # Skip TLS Verification for self-signed certificates
  insecure_skip_tls_verify = true
  # qemu_agent = true

  node    = "kkproxmox"
  vm_id   = 1000
  vm_name = "ubuntu-2404-template"

  iso_file = "local:iso/ubuntu-24.04.3-live-server-amd64.iso"

  cores = 4
  memory = 4096

  network_adapters {
    model  = "virtio"
    bridge = "vmbr0" # Will probably change it in the Terraform script, this is only for packer.
  }

  disks {
    disk_size    = "20G"
    storage_pool = "local-lvm"
    type         = "scsi"
    ssd          = true
  }

  boot_command = [
    "<esc><wait>", "e<wait>",
    "<down><down><down><end>",
    # " autoinstall ds=nocloud-net;s=http://{{.HTTPIP}}:{{.HTTPPort}}/",
    " autoinstall cloud-config-url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/user-data ds='nocloud-net;s=http://{{.HTTPIP}}:{{.HTTPPort}}/'",
    #" ip=dhcp cloud-config-url=http://{{.HTTPIP}}:{{.HTTPPort}}/user-data autoinstall ds=nocloud-net;s=http://{{.HTTPIP}}:{{.HTTPPort}}/",
    "<f10>"
  ]

  http_directory = "http"
  ssh_username   = "lab-admin"
  ssh_password = "${var.ubuntu_pw}"
  ssh_timeout    = "20m"
}

build {
  sources = ["source.proxmox-iso.ubuntu-server"]
}