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
  # qemu_agent = true # Default is true anyway

  node    = "kkproxmox"
  vm_id   = 1000
  vm_name = "ubuntu-2404-template"

  # iso_file = "local:iso/ubuntu-24.04.3-live-server-amd64.iso"

  boot_iso {
    # type = "scsi"
    type = "ide"
    iso_file = "local:iso/ubuntu-24.04.3-live-server-amd64.iso"
    iso_checksum = "sha256:c3514bf0056180d09376462a7a1b4f213c1d6e8ea67fae5c25099c6fd3d8274b"
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

  cloud_init = true # add an empty Cloud-Init CDROM driver after the VM has been converted to a template.
  cloud_init_storage_pool = "local-lvm" # Name of the Proxmox storage pool to store the Cloud-Init CDROM on.

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