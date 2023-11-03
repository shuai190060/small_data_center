#!/bin/bash

# clean the inventory file
echo "" > inventory
# Extract values from JSON output
MASTER=$(terraform output -json | jq -r '.load_balancer_node.value')
SLAVE_1=$(terraform output -json server_ips | jq -r '.server_1.public_ip')
SLAVE_2=$(terraform output -json server_ips | jq -r '.server_2.public_ip')
PRIMARY_SERVER=$(terraform output -json | jq -r '.primary_server.value')
PG_BOUNCER=$(terraform output -json | jq -r '.pgbouncer_public.value')


# create load balancer group
echo "[load_balancer]" >> inventory
master="load_balancer_server ansible_host={MASTER} ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/ansible"
master=$(echo "$master" | sed "s/{MASTER}/$MASTER/g")
echo $master >> inventory


# create pgbouncer group
echo "[additional_haproxy]" >> inventory
haproxy_server="haproxy_server ansible_host={PG_BOUNCER} ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/ansible"
haproxy_server=$(echo "$haproxy_server" | sed "s/{PG_BOUNCER}/$PG_BOUNCER/g")
echo $haproxy_server >> inventory


# create load balancer group
echo "[primary_server]" >> inventory
primary_server="primary_server ansible_host={PRIMARY_SERVER} ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/ansible"
primary_server=$(echo "$primary_server" | sed "s/{PRIMARY_SERVER}/$PRIMARY_SERVER/g")
echo $primary_server >> inventory

# create replicas group
echo "[replicas]" >> inventory

slave_1="server_1 ansible_host={SLAVE_1} ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/ansible"
slave_1=$(echo "$slave_1" | sed "s/{SLAVE_1}/$SLAVE_1/g")
echo $slave_1 >> inventory

slave_2="server_2 ansible_host={SLAVE_2} ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/ansible"
slave_2=$(echo "$slave_2" | sed "s/{SLAVE_2}/$SLAVE_2/g")
echo $slave_2 >> inventory

