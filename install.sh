if grep -q ^flags.*\ hypervisor\  /proc/cpuinfo; then
	echo "This is a virtual machine"
	if ping -n 1 archlinux.org; then
		echo "INTERNET CONNECTION FOUND"
	else
		echo "INTERNET CONNECTION NOT FOUND"
	fi
	echo -e "\nTO MODIFY CONNECTION, CHANGE CONNECTION ON HOST MACHINE"
else
	echo "Running on BARE METAL"
	if ping -n 1 archlinux.org; then
		echo "INTERNET CONNECTION FOUND"
	else
		echo "INTERNET CONNECTION NOT FOUND"
	fi
	entry="nope"
	while [[ ! "$entry" =~ ^[YyNn]$ ]]; do
	    read -p "MODIFY CONNECTION? " entry
	    echo "$entry"
	done
fi

if [[ "$entry" =~ ^[YyNn]$ ]]; then
	iwctl
fi
