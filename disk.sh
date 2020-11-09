#/bin.bash
if [ -n "$1" ];then
	qemu-img create -f qcow2 $1.qcow2 32G
fi
