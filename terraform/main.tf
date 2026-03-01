# resource "proxmox_vm_qemu" "test_server" {
#     name = "terraform-vm-01"
#     target_node = "kkproxmox"

#     clone = "ubuntu-2404-template"

#     agent = 1 #enable QEMU guest agent
    
#     cpu {
#         cores = 2
#         sockets = 1
#         type = "host"
#     }
#     memory = 2048
#     scsihw = "virtio-scsi-pci"
#     # bootdisk = "scsi0"

#     # This is addeded to the default ciuser "ubuntu". ssh-keygen -t rsa to generate the key pair.
#     sshkeys = "${file("~/.ssh/id_rsa.pub")}"

#     disk {
#         slot    = "ide0"
#         type    = "cloudinit"
#         storage = "local-lvm"
#     }

#     disk {
#         slot = "scsi0"
#         size = "20G"
#         type = "disk"
#         storage = "local-lvm"
#         format = "raw"
#     }

#     startup_shutdown {
#         order = -1
#         shutdown_timeout = -1
#         startup_delay = -1
#     }

#     network {
#         id = 0
#         model = "virtio"
#         bridge = "vmbr0"
#     }

#     os_type = "cloud-init"
#     ipconfig0 = "ip=dhcp"
#     skip_ipv6 = true
# }

# resource "proxmox_vm_qemu" "test_server1" {
#     name = "terraform-vm-02"
#     target_node = "kkproxmox"

#     clone = "ubuntu-2404-template"

#     agent = 1 #enable QEMU guest agent
    
#     cpu {
#         cores = 2
#         sockets = 1
#         type = "host"
#     }
#     memory = 2048
#     scsihw = "virtio-scsi-pci"
#     # bootdisk = "scsi0"

#     disk {
#         slot    = "ide0"
#         type    = "cloudinit"
#         storage = "local-lvm"
#     }

#     disk {
#         slot = "scsi0"
#         size = "20G"
#         type = "disk"
#         storage = "local-lvm"
#         format = "raw"
#     }

#     startup_shutdown {
#         order = -1
#         shutdown_timeout = -1
#         startup_delay = -1
#     }

#     network {
#         id = 0
#         model = "virtio"
#         bridge = "vmbrEUZ40"
#     }

#     os_type = "cloud-init"
#     ipconfig0 = "ip=dhcp"
#     skip_ipv6 = true
# }

resource "proxmox_vm_qemu" "c-opnsense" {
    name = "c-opnsense"
    target_node = "kkproxmox"
    clone = "opnsense-template"
    agent = 1 #enable QEMU guest agent
    memory = 4096
    balloon = 4096
    bios = "seabios"
    scsihw = "virtio-scsi-single"
    # bootdisk = "scsi0"    
    os_type = "other"
    # ipconfig0 = "ip=dhcp"
    skip_ipv6 = true

    # pass ssh key somehow
    # sshkeys = "${file("~/.ssh/id_rsa.pub")}"

    cpu {
        cores = 4
        sockets = 1
        type = "host"
    }

    # disk {
    #     slot    = "ide0"
    #     type    = "cloudinit"
    #     storage = "local-lvm"
    # }

    disk {
        slot = "scsi0"
        cache = "none"
        discard = true
        iothread = true
        emulatessd = true
        asyncio = "io_uring"
        size = "20G"
        type = "disk"
        storage = "local-lvm"
        format = "raw"
    }

    startup_shutdown {
        order = -1
        shutdown_timeout = -1
        startup_delay = -1
    }

    network {
        id = 0
        model = "virtio"
        bridge = "vmbr0"
        firewall = true
    }
    
    network {
        id = 1
        model = "virtio"
        bridge = "vmbrDMZ20"
        firewall = true
    }

    network {
        id = 2
        model = "virtio"
        bridge = "vmbrIZ30"
        firewall = true
    }

    network {
        id = 3
        model = "virtio"
        bridge = "vmbrEUZ40"
        firewall = true
    }
}