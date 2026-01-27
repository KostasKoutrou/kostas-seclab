resource "proxmox_vm_qemu" "test_server" {
    name = "terraform-vm-01"
    target_node = "kkproxmox"

    clone = "ubuntu-2404-template"

    agent = 1 #enable QEMU guest agent
    os_type = "cloud-init"
    cpu {
        cores = 2
        sockets = 1
        type = "host"
    }
    memory = 2048
    scsihw = "virtio-scsi-pci"
    # bootdisk = "scsi0"

    disk {
        slot = "scsi0"
        size = "20G"
        type = "disk"
        storage = "local-lvm"
    }

    network {
        id = 0
        model = "virtio"
        bridge = "vmbr0"
    }

    ipconfig0 = "ip=dhcp"
}

resource "proxmox_vm_qemu" "test_server1" {
    name = "terraform-vm-01"
    target_node = "kkproxmox"

    clone = "ubuntu-2404-template"

    agent = 1 #enable QEMU guest agent
    os_type = "cloud-init"
    cpu {
        cores = 2
        sockets = 1
        type = "host"
    }
    memory = 2048
    scsihw = "virtio-scsi-pci"
    # bootdisk = "scsi0"

    disk {
        slot = "scsi0"
        size = "20G"
        type = "disk"
        storage = "local-lvm"
    }

    network {
        id = 0
        model = "virtio"
        bridge = "vmbrEUZ40"
    }

    ipconfig0 = "ip=dhcp"
    skip_ipv6 = true
}