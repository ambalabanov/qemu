# QEMU on macOS



### 1. Install tools

```shell
$ brew install qemu libvirt cdrtools
```

### 2. Manual install

Create disk

```shell
$ qemu-img create -f qcow2 ubuntu.qcow2 32G
or
$ ./disk.sh ubuntu
```

Install via script template

```shell
$ cat << 'EOF' > ubuntu.sh
#/bin/bash
qemu-system-x86_64 \
-accel hvf \
-smp 2 \
-m 2048 \
-cdrom ubuntu-16.04.7-server-amd64.iso \
-hda ubuntu.qcow2 \
-netdev user,id=mynet0,hostfwd=tcp:127.0.0.1:2203-:22 \
-device virtio-net-pci,netdev=mynet0 \
#-nographic
EOF
$ chmod +x ./ubuntu.sh
$ ./ubuntu.sh
```

Change boot options for -nographic 

```shell
$ vim /etc/default/grub
#
GRUB_CMDLINE_LINUX_DEFAULT="console=tty0 console=ttyS0,115200n8"
#
$ grub2-mkconfig -o /boot/grub2/grub.cfg
```

Create snapshot

```shell
$ qemu-img snapshot -c snap1 ubuntu.qcow2
$ qemu-img snapshot -l ubuntu.qcow2      
Snapshot list:
ID        TAG                     VM SIZE                DATE       VM CLOCK
1         snap1                       0 B 2020-11-09 10:08:54   00:00:00.000
```

Start with -nographic

```shell
$ sed -i.bak -e '/nographic/s/^#//g' ubuntu.sh
$ ./ubuntu.sh
```

### 3. Create libvirt domain

generate UUID

```shell
$ uuidgen                       
32663F34-00D7-4036-AD1C-90833F3BD3EB
```

craft xml domain file from template

```xml
$ UUID=$(uuidgen)
$ QEMU=$(which qemu-system-x86_64)
$ bash -c "cat << 'EOF' > ubuntu.xml
<domain type='qemu' xmlns:qemu='http://libvirt.org/schemas/domain/qemu/1.0'>
    <name>ubuntu</name>
    <uuid>$UUID</uuid>
    <memory unit='GB'>2</memory>
    <vcpu>2</vcpu>
    <os>
        <type arch='x86_64' machine='q35'>hvm</type>
        <bootmenu enable='yes'/>
    </os>
    <clock offset='localtime'/>
    <on_poweroff>destroy</on_poweroff>
    <on_reboot>restart</on_reboot>
    <on_crash>destroy</on_crash>
    <pm>
        <suspend-to-mem enabled='no'/>
        <suspend-to-disk enabled='no'/>
    </pm>
    <devices>
        <emulator>$QEMU</emulator>
        <controller type='usb' model='ehci'/>
        <disk type='file' device='disk'>
            <driver name='qemu' type='qcow2'/>
            <source file='$PWD/focal-server-cloudimg-amd64-disk-kvm.qcow2'/>
            <target dev='vda' bus='virtio'/>
        </disk>
        <disk type='file' device='cdrom'>
            <source file='$PWD/systemrescue-7.00-amd64.iso'/>
            <target dev='sdb' bus='sata'/>
        </disk>
        <console type='pty'>
            <target type='serial'/>
        </console>
        <input type='tablet' bus='usb'/>
        <input type='keyboard' bus='usb'/>
        <graphics type='vnc' port='5903' listen='127.0.0.1'/>
        <video>
            <model type='virtio' vram='16384'/>
        </video>
    </devices>
    <seclabel type='none'/>
    <qemu:commandline>
      	<qemu:arg value='-boot'/>
        <qemu:arg value='menu=on'/>
        <qemu:arg value='-machine'/>
        <qemu:arg value='type=q35,accel=hvf'/>
        <qemu:arg value='-netdev'/>
        <qemu:arg value='user,id=mynet0,hostfwd=tcp:127.0.0.1:2203-:22'/>
        <qemu:arg value='-device'/>
        <qemu:arg value='virtio-net-pci,netdev=mynet0'/>
    </qemu:commandline>
</domain>
EOF"
```

define domain in libvirt

```shell
$ virsh define ubuntu.xml
Domain ubuntu defined from ubuntu.xml
```

start domain

```shell
$ virsh start ubuntu
Domain ubuntu started

$ virsh list        
 Id   Name     State
------------------------
 1    ubuntu   running

```

stop domain

```shell
$ virsh shutdown ubuntu
Domain ubuntu is being shutdown
```

### 4. Cloud-init

Download image

```shell
$ wget https://download.fedoraproject.org/pub/fedora/linux/releases/33/Cloud/x86_64/images/Fedora-Cloud-Base-33-1.2.x86_64.qcow2
```

Resize

```shell
$ qemu-img resize Fedora-Cloud-Base-33-1.2.x86_64.qcow2 30G
Image resized.
```

Make metadata

```shell
$ PUBLIC_KEY=$(cat ~/.ssh/id_rsa.pub)
$ cat <<EOF > meta-data
instance-id: fedora33
local-hostname: fedora
EOF
$ cat <<EOF > user-data              
#cloud-config
debug: true
disable_root: false
users:
  - name: root
    shell: /bin/bash
    ssh-authorized-keys:
      - ${PUBLIC_KEY}
EOF
$ mkisofs -output cidata.iso -volid cidata -joliet -rock user-data meta-data
```

Create start script

```shell
$ cat << 'EOF' > fedora.sh
#/bin/bash
qemu-system-x86_64 \
-accel hvf \
-smp 2 \
-m 2048 \
-cdrom cidata.iso \
-hda Fedora-Cloud-Base-33-1.2.x86_64.qcow2 \
-netdev user,id=mynet0,hostfwd=tcp:127.0.0.1:2207-:22 \
-device virtio-net-pci,netdev=mynet0 \
-nographic
EOF
$ chmod +x ./fedora.sh
```

Create snapshot

```shell
$ qemu-img snapshot -c snap1 Fedora-Cloud-Base-33-1.2.x86_64.qcow2
$ qemu-img snapshot -l Fedora-Cloud-Base-33-1.2.x86_64.qcow2
Snapshot list:
ID        TAG                     VM SIZE                DATE       VM CLOCK
1         snap1                       0 B 2020-11-23 17:41:54   00:00:00.000
```

Start

```shell
$ ./fedora.sh 
```

