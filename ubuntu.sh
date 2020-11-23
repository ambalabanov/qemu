#/bin/bash
qemu-system-x86_64 \
-accel hvf \
-smp 2 \
-m 2048 \
-boot menu=on \
-cdrom systemrescue-7.00-amd64.iso \
-hda focal-server-cloudimg-amd64-disk-kvm.qcow2 \
-netdev user,id=mynet0,hostfwd=tcp:127.0.0.1:2203-:22 \
-device virtio-net-pci,netdev=mynet0 \
-nographic
