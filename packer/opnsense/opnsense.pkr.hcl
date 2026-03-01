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
  qemu_agent = true # Default is true anyway
  node = "kkproxmox"
  vm_id = 1001
  vm_name = "opnsense-template"
  ssh_username = "root"
  ssh_password = "opnsense"
  ssh_timeout = "20m"
  cores = 4
  memory = 4096 # must be more than 3GB, otherwise the boot_command is different
  os = "other"
  cpu_type = "host"
  scsi_controller = "virtio-scsi-single"


  boot_iso {
    # type = "scsi"
    type = "ide"
    iso_file = "local:iso/OPNsense-25.7-dvd-amd64.iso"
    iso_checksum = "sha256:e4c178840ab1017bf80097424da76d896ef4183fe10696e92f288d0641475871"
    unmount = true
  }

  additional_iso_files {
    # cd_files = ["${path.root}/conf/"] # the opnsense config file resides there. the xml must have the name "config.xml"
    # cd_content = {
    # "/conf/config.xml" = file("${path.root}/conf/config.xml")
    # }
    cd_content = {
    "conf/config.xml" = templatefile("${path.root}/conf/config.xml", {
      dynamic_ssh_key = base64encode(file("~/.ssh/id_rsa.pub"))})
    }
    cd_label = "config"
    iso_storage_pool = "local"
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
    # there is already a 10 sec wait for boot, adding another 15
    # start configuration imoprter and select cd1 where the cd_content is stored
    "<wait12s><enter><wait5s>cd1<enter><wait25s>",

    "installer<enter><wait2s>",
    "opnsense<enter><wait10s>",
    
    # Accept default Keymap and ZFS installation
    "<enter><wait2s><enter><wait10s><enter><wait2s><spacebar><wait1s><enter><wait1s>",
    
    # Confirm formatting (Yes) and wait 2 minutes for installation
    "<left><wait1s><enter><wait120s>",
    
    # Do not change password and reboot
    "<down><wait1s><enter><wait1s><enter>",

    # Enable qemu agent service autostart and Update from console to latest version,
    # because qemu requires the latest opnsense version
    "<wait45s>root<enter><wait2s>opnsense<enter><wait5s>",
    "8<enter><wait2s>sysrc qemu_guest_agent_enable='YES'<wait1s><enter><wait1s>exit<enter><wait1s>",
    "12<enter><wait6s>y<enter><wait3s>q"
  ]
}

build {
  sources = ["source.proxmox-iso.opnsense"]
}