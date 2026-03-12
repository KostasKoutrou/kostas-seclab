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

    # This is addeded to the default ciuser "ubuntu". ssh-keygen -t rsa to generate the key pair.
    sshkeys = "${file("~/.ssh/id_rsa.pub")}"

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

    connection {
      type = "ssh"
      user = "root"
      private_key = file("~/.ssh/id_rsa")
      host = self.ssh_host
    }

    provisioner "file" {
      content = templatefile("${path.module}/template_config_opnsense_lab.xml",
        {
            dynamic_ssh_key = base64encode(file("~/.ssh/id_rsa.pub"))
            wan_if = "vtnet0"
            wan_descr = "WAN"
            wan_ip = "192.168.0.51"
            wan_subnet = "24"
            wan_gw = "WAN_GW"
            dmz20_if = "vtnet1"
            dmz20_descr = "DMZ20"
            dmz20_ip = "10.0.20.1"
            dmz20_subnet = "24"
            iz30_if = "vtnet2"
            iz30_descr = "IZ30"
            iz30_ip = "10.0.30.1"
            iz30_subnet = "24"
            euz40_if = "vtnet3"
            euz40_descr = "EUZ40"
            euz40_ip = "10.0.40.1"
            euz40_subnet = "24"
        }
      )
      destination = "/conf/config.xml"
    }

    provisioner "remote-exec" {
      inline = [ 
        "echo 'Injecting Cyber Range Topology by restarting OPNSense. Machine will restart 3 seconds after Terraform has provisioned it.'",
        # "cat /tmp/config.xml",
        # "cp /tmp/config.xml /conf/config.xml"
        "daemon -f /bin/sh -c 'sleep 3; /sbin/reboot'"
       ]
    }
}