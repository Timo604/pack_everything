variable "iso_checksum" {
  type    = string
  default = "28ccdb56450e643bad03bb7bcf7507ce3d8d90e8bf09e38f6bd9ac298a98eaad"
}

variable "iso_url" {
  type    = string
  default = "https://releases.ubuntu.com/20.04/ubuntu-20.04.4-live-server-amd64.iso"
}

source "vmware-iso" "vmware" {
  boot_command = [
    "<esc><esc><esc>",
    "<enter><wait>",
    "/casper/vmlinuz ",
    "root=/dev/sr0 ",
    "initrd=/casper/initrd ",
    "autoinstall ",
    "ds=nocloud-net;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/",
    "<enter>"
  ]
  boot_wait              = "5s"
  guest_os_type          = "ubuntu-64"
  headless               = false
  http_directory         = "http"
  iso_checksum           = "sha256:${var.iso_checksum}"
  iso_url                = "${var.iso_url}"
  memory                 = 1024
  network                = "nat"
  network_adapter_type   = "vmxnet3"
  shutdown_command       = "echo 'ubuntu'|sudo -S shutdown -P now"
  ssh_handshake_attempts = "100000"
  ssh_timeout            = "30m"
  ssh_password           = "ubuntu"
  ssh_username           = "ubuntu"
  vm_name                = "packer-ubuntu-20.04-amd64"
  vmx_data_post = {
    "ide0:0.clientDevice"   = "TRUE"
    "ide0:0.deviceType"     = "cdrom-raw"
    "ide0:0.fileName"       = "emptyBackingString"
    "ide0:0.present"        = "FALSE"
    "ide0:0.startConnected" = "FALSE"
  }
}

build {
  sources = ["source.vmware-iso.vmware"]

  provisioner "shell" {
    execute_command = "echo 'ubuntu' | {{ .Vars }} sudo -S bash -euxo pipefail '{{ .Path }}'"
    scripts         = ["scripts/setup_ubuntu2004.sh"]
  }
}
