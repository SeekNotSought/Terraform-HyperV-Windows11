# Virtual switch (or reference an existing one)
resource "hyperv_network_switch" "external" {
  name = "ExternalSwitch"
  type = "External"
  # If you already have a switch, you can skip this and just use its name below.
}

# OS disk VHDX (empty disk to install Windows 11 onto)
resource "hyperv_vhd" "win11_osdisk" {
  name        = "Win11-OSDisk.vhdx"
  path        = "D:/HyperV/Virtual Hard Disks/Win11-OSDisk.vhdx"
  size        = 64 # GB
  generation  = 2
  vhd_type    = "Dynamic"
}

# Optional: data disk
resource "hyperv_vhd" "win11_datadisk" {
  name        = "Win11-DataDisk.vhdx"
  path        = "D:/HyperV/Virtual Hard Disks/Win11-DataDisk.vhdx"
  size        = 128
  generation  = 2
  vhd_type    = "Dynamic"
}

# Windows 11 VM
resource "hyperv_machine_instance" "win11" {
  name              = "Win11-Client01"
  generation        = 2
  state             = "Running"
  automatic_start_action = "StartIfRunning"
  automatic_stop_action  = "Save"

  # CPU / Memory
  processor_count   = 4
  static_memory     = true
  memory_startup_bytes = 8 * 1024 * 1024 * 1024 # 8 GB

  # Networking
  network_adapters = [{
    name               = "Ethernet0"
    switch_name        = hyperv_network_switch.external.name
    mac_address        = ""
    dynamic_mac_address = true
  }]

  # Disks
  hard_drives = [
    {
      controller_type = "SCSI"
      controller_number = 0
      controller_location = 0
      path = hyperv_vhd.win11_osdisk.path
    },
    {
      controller_type = "SCSI"
      controller_number = 0
      controller_location = 1
      path = hyperv_vhd.win11_datadisk.path
    }
  ]

  # Attach Windows 11 ISO for installation
  dvd_drives = [{
    controller_type    = "IDE"
    controller_number  = 1
    controller_location = 0
    path               = "D:/ISOs/Win11_23H2_English_x64.iso"
  }]

  # Boot order: DVD first so it boots into Windows setup
  boot_order = [
    "DVD",
    "VHD",
    "Network"
  ]
}