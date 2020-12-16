%{ for id in range(instances_number) ~}
group_${id}:
  hosts:
    host_${id}:
      ansible_host: ${hw1_stack["${id}"]}
%{ endfor ~}

all:
  vars:
    ansible_user: ${ssh_user}
    ansible_ssh_private_key_file: "~/.aws/${key_name}.pem"
