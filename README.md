# QEMU start scripts on macOS



### 1. Install qemu

```shell
$ brew install qemu
```

### 2. Create disk

```shell
$ qemu-img create -f qcow2 ubuntu.qcow2 32G
or
$ ./disk.sh ubuntu
```

### 3. Install via script template

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
-device e1000,netdev=mynet0 \
#-nographic
EOF
$ chmod +x ./ubuntu.sh
$ ./ubuntu.sh
```

### 4. Change boot options for -nographic 

```shell
$ vim /etc/default/grub
#
GRUB_CMDLINE_LINUX_DEFAULT="console=tty0 console=ttyS0,115200n8"
#
$ grub2-mkconfig -o /boot/grub2/grub.cfg
```

### 5. Create snapshot

```shell
$ qemu-img snapshot -c snap1 ubuntu.qcow2
$ qemu-img snapshot -l ubuntu.qcow2      
Snapshot list:
ID        TAG                     VM SIZE                DATE       VM CLOCK
1         snap1                       0 B 2020-11-09 10:08:54   00:00:00.000
```

### 6. Start with -nographic

```shell
$ sed -i.bak -e '/nographic/s/^#//g' ubuntu.sh
$ ./ubuntu.sh
```

