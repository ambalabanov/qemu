#/bin/bash
qemu-system-x86_64 -m 2048 \
 -accel hvf \
 -cdrom alpine-standard-3.13.5-x86_64.iso \
 -hda alpine.qcow2 \
 -netdev user,id=mynet0,hostfwd=tcp:127.0.0.1:2202-:22 \
 -device e1000,netdev=mynet0 \
 -boot menu=on \
 -nographic
