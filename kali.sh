#/bin/bash
qemu-system-x86_64 \
 -accel hvf \
 -smp 2 \
 -m 2048 \
 -cdrom kali-linux-2020-W46-installer-netinst-amd64.iso \
 -hda kali.qcow2 \
 -netdev user,id=mynet0,hostfwd=tcp:127.0.0.1:2205-:22 \
 -device e1000,netdev=mynet0 \
 -nographic 
