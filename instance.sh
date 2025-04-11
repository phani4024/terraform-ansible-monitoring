#! /bin/bash

cd terraform
terraform init
terraform fmt -recursive
terraform plan
terraform apply --auto-approve

IP=$(terraform output -raw instance_ip)
echo "Instance IP : $IP"

cd ..

echo "$IP ansible_user=ec2-user ansible_ssh_private_key_file=~/.ssh/admin_key.pem" > inventory.ini
echo "running ansible playbook"
ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i inventory.ini ansible/monitor.yml -vvv
