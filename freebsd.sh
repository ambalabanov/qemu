#/bin/bash
qemu-system-x86_64 -m 2048 \
 -accel hvf \
 -hda FreeBSD-13.0-RELEASE-amd64.qcow2 \
 -netdev user,id=mynet0,hostfwd=tcp:127.0.0.1:2201-:22 \
 -device e1000,netdev=mynet0 \
 -nographic 
