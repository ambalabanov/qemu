#/bin/bash
qemu-system-x86_64 \
-accel hvf \
-smp 2 \
-m 2048 \
-hda openSUSE-Leap-15.2-JeOS.x86_64-15.2-kvm-and-xen-Build31.240.qcow2 \
-netdev user,id=mynet0,hostfwd=tcp:127.0.0.1:2206-:22 \
-device virtio-net-pci,netdev=mynet0 \
-nographic
