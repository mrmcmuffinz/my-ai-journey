all: ping hostnamectl

ping:
	ansible all -i inventories/inventory.ini -m ansible.builtin.ping

hostnamectl:
	ansible all -i inventories/inventory.ini -m raw -a "hostnamectl"
