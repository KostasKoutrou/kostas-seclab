variable "proxmox_api_url" {
    type = string
    description = "The URL for the Proxmox API (e.g., https://192.168.0.50:8006/api2/json)"
}

variable "proxmox_api_token_id" {
    type = string
    sensitive = true
    description = "The API Token ID (e.g., root@pam!terraform)"
}

variable "proxmox_api_token_secret" {
    type = string
    sensitive = true
    description = "The API Token Secret (UUID)"
}