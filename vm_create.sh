# Create new VM
VBoxManage createvm --name "vc.hole" --register

# Set memory and CPU
VBoxManage modifyvm "vc.hole" --memory 16384 --cpus 8

# Add SCSI controller
VBoxManage storagectl "vc.hole" --name "SCSI" --add scsi --controller LSILogic

# Attach existing VDI disks from mojlab directory
VBoxManage storageattach "vc.hole" --storagectl "SCSI" --port 0 --device 0 --type hdd --medium "mojlab/disk1.vdi"
VBoxManage storageattach "vc.hole" --storagectl "SCSI" --port 1 --device 0 --type hdd --medium "mojlab/disk2.vdi"
VBoxManage storageattach "vc.hole" --storagectl "SCSI" --port 2 --device 0 --type hdd --medium "mojlab/disk3.vdi"

# Configure host-only network adapter
VBoxManage modifyvm "vc.hole" --nic1 hostonly --hostonlyadapter1 "VirtualBox Host-Only Ethernet Adapter #3"
