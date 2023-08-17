cat inventory
ansible -m ping 127.0.0.1
ansible -m ping -i inventory member

ansible-playbook playbooks/wget_check.yml -i inventory
ansible-playbook playbooks/install_wget.yml -i inventory
ansible-playbook playbooks/set_timezone.yml -i inventory

