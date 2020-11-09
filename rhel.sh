#/bin/bash
qemu-system-x86_64 \
 -accel hvf \
 -smp 2 \
 -m 2048 \
 -cdrom rhel-8.3-x86_64-boot.iso \
 -hda rhel-8.3-x86_64-kvm.qcow2 \
 -netdev user,id=mynet0,hostfwd=tcp:127.0.0.1:2202-:22 \
 -device e1000,netdev=mynet0 \
 -nographic