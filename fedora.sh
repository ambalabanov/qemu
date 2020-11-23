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
