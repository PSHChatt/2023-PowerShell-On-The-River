vsphere_user                   = "terraform@vsphere.local"
vsphere_password               = "S3cr3tsquirr3l!"
vsphere_server                 = "corevcenter.lab.fullstackgeek.net"
vsphere_datacenter             = "CastleRock"
vsphere_cluster                = "Lab"
vsphere_datastore              = "ESXi_AllFlash"
vsphere_resource_pool          = "NestedLabs"
vsphere_network                = "CASTLEROCK-Prod"
vsphere_virtual_machine_folder = "Nested"
vsphere_template_name          = "TMPLT-Ubuntu-20041-SVR"

vsphere_virtual_machine_name   = "terraform-ubuntu-test-demo"
vsphere_virtual_machine_cpus   = 4
vsphere_virtual_machine_memory = 6144
