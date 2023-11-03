## Topology

```jsx
Internet
   |
   | (Traffic to Postgres read replicas)
   |
   V
+-----------------------+              +-----------------------+
|     HAProxy Server A  |              |     HAProxy Server B  |
|     - Keepalived      |<----+  +---->|     - Keepalived      |
+-----------------------+     |  |     +-----------------------+
      |                  |     |  |     |                  |
      | (Load balancing) |     |  |     | (Load balancing) |
      V                  |     |  |     |                  V
+------------+      +------------+     +------------+      +------------+
| Replication|      | Replication|     | Replication|      | Replication|
| Server_1   |      | Server_2   |     | Server_1   |      | Server_2   |
| (Read Only)|      | (Read Only)|     | (Read Only)|      | (Read Only)|
+------------+      +------------+     +------------+      +------------+

      +                   +                  +                   +
      |                   |                  |                   |
      |                   |                  |                   |
      V                   V                  V                   V
   +------------+      +------------+     +------------+      +------------+
   |  Primary   |      |  Primary   |     |  Primary   |      |  Primary   |
   | Postgres   |      | Postgres   |     | Postgres   |      | Postgres   |
   | Server     |      | Server     |     | Server     |      | Server     |
   | (Read/Write)|     | (Read/Write)|    | (Read/Write)|     | (Read/Write)|
   +------------+      +------------+     +------------+      +------------+
```

## Setup and provision

```jsx
// setup the servers
cd infrastructure && terraform apply --auto-approve

// provision the servers using ansible playbook
./inventory.sh
ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i inventory playbook.yaml

```

## Others

- endpoint(virtual IP) for other application to connect within the VPC: 10.3.0.100
- port: 5433
- security group for connection: server_node_sg