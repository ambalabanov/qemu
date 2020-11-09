#/bin/bash
qemu-system-x86_64 \
-accel hvf \
-smp 2 \
-m 2048 \
-cdrom ubuntu-16.04.7-server-amd64.iso \
-hda ubuntu.qcow2 \
-netdev user,id=mynet0,hostfwd=tcp:127.0.0.1:2203-:22 \
-device e1000,netdev=mynet0 \
-nographic
