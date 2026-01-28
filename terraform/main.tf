resource "proxmox_vm_qemu" "test_server" {
    name = "terraform-vm-01"
    target_node = "kkproxmox"

    clone = "ubuntu-2404-template"

    agent = 1 #enable QEMU guest agent
    
    cpu {
        cores = 2
        sockets = 1
        type = "host"
    }
    memory = 2048
    scsihw = "virtio-scsi-pci"
    # bootdisk = "scsi0"

    disk {
        slot    = "ide0"
        type    = "cloudinit"
        storage = "local-lvm"
    }

    disk {
        slot = "scsi0"
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
    }

    os_type = "cloud-init"
    ipconfig0 = "ip=dhcp"
    skip_ipv6 = true
}

resource "proxmox_vm_qemu" "test_server1" {
    name = "terraform-vm-02"
    target_node = "kkproxmox"

    clone = "ubuntu-2404-template"

    agent = 1 #enable QEMU guest agent
    
    cpu {
        cores = 2
        sockets = 1
        type = "host"
    }
    memory = 2048
    scsihw = "virtio-scsi-pci"
    # bootdisk = "scsi0"

    disk {
        slot    = "ide0"
        type    = "cloudinit"
        storage = "local-lvm"
    }

    disk {
        slot = "scsi0"
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
        bridge = "vmbrEUZ40"
    }

    os_type = "cloud-init"
    ipconfig0 = "ip=dhcp"
    skip_ipv6 = true
}