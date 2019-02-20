---
# Example for an ansible inventory file
all:
  vars:
    ansible_python_interpreter: '/usr/bin/python3'
    agent_private_ips:
      ${agent_private_ips}
    master_private_ips:
      ${master_private_ips}
    lb_public_dns:
      '${lb_public_dns}'
    lb_private_dns:
      '${lb_private_dns}'

  children:
    bootstrap:
      hosts:
        # Public IP Address of the Bootstrap Node
        ${bootstrap_node_public_ip}:
    masters:
      hosts:
        # Public IP Addresses for the Master Nodes
${master_node_ip_block}
    agents:
      hosts:
        # Public IP Addresses for the Agent Nodes
${private_agent_node_ip_block}
