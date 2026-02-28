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
  node = "kkproxmox"
  vm_id = 1001
  vm_name = "opnsense-template"
  ssh_username = "root"
  ssh_password = "opnsense"
  ssh_timeout = "20m"
  cores = 4
  memory = 4096
  os = "other"
  cpu_type = "host"
  scsi_controller = "virtio-scsi-pci"


  boot_iso {
    # type = "scsi"
    type = "ide"
    iso_file = "local:iso/OPNsense-25.7-dvd-amd64.iso"
    iso_checksum = "sha256:e4c178840ab1017bf80097424da76d896ef4183fe10696e92f288d0641475871"
    unmount = true
  }

  additional_iso_files {
    cd_files = ["${path.root}/conf/"] # the opnsense config file resides there. the xml must have the name "config.xml"
    cd_label = "config"
    iso_storage_pool = "local-lvm"
  }

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
    # Wait for the Live CD login prompt
    "<wait45s>",
    "installer<enter><wait3s>",
    "opnsense<enter><wait10s>",
    
    # Accept default Keymap and UFS installation
    "<enter><wait2s><enter><wait10s><enter><wait2s><spacebar><enter>",
    
    # Confirm formatting (Yes)
    "<left><enter><wait180s>",
    
    # Enter the temporary password for the installation phase
    "<down><wait1s><enter><wait1s><enter>",

  ]
}

build {
  sources = ["source.proxmox-iso.opnsense"]
}