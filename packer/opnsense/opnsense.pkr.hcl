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
variable "opnsense_pw" {
  type = string
  sensitive = true
}

source "proxmox-iso" "opnsense" { #Resource type and local name
  proxmox_url = var.proxmox_api_url
  username    = var.proxmox_api_token_id
  token       = var.proxmox_api_token_secret

  # Skip TLS Verification for self-signed certificates
  insecure_skip_tls_verify = true
  # qemu_agent = true # Default is true anyway

  node    = "kkproxmox"
  vm_id   = 1001
  vm_name = "opnsense-template"

  boot_iso {
    # type = "scsi"
    type = "ide"
    iso_file = "local:iso/OPNsense-25.7-dvd-amd64.iso"
    iso_checksum = "sha256:e4c178840ab1017bf80097424da76d896ef4183fe10696e92f288d0641475871"
    unmount = true
  }

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

  # provisioner "shell" {
  #   inline = [
  #     "echo 'Waiting for cloud-init to complete...'",
  #     "while [ ! -f /var/lib/cloud/instance/boot-finished ]; do echo 'Still waiting...'; sleep 2; done",
  #     "sudo cloud-init status --wait",
  #     "echo 'Cloud-init completed successfully'"
  #   ]
  # }

  provisioner "shell" {
    # execute_command = "echo ${var.ubuntu_pw}| sudo -S sh -c '{{ .Vars }} {{ .Path }}'"
    execute_command = "echo ${var.ubuntu_pw}| {{.Vars}} sudo -S -E sh -eux '{{.Path}}'"
    inline = [
      "echo 'Waiting for cloud-init to complete...'",
      "while [ ! -f /var/lib/cloud/instance/boot-finished ]; do echo 'Still waiting...'; sleep 2; done",
      # "cloud-init status --wait 2>&1", # could try to do "while cloud-init status == 2; sleep 2; done"
      # "cloud-init status --wait  > /dev/null 2>&1",
      # "[ $? -ne 0 ] && echo 'Cloud-init failed' && exit 1",
      # "echo 'Cloud-init succeeded at ' `date -R`",
      "echo 'Cloud-init completed successfully'",
      "echo 'Cleaning up...'",
      "rm -rf /var/lib/apt/lists/*",
      "rm -rf /tmp/*",
      "rm -rf /var/tmp/*",
      "cloud-init clean --logs --machine-id --seed --configs all"
    ]
  }
}