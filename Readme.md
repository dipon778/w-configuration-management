# Project Documentation

## Table of Contents
1. [Introduction](#introduction)
2. [Getting Started](#getting-started)
3. [Installation](#installation)
4. [Usage](#usage)
5. [Configuration](#configuration)
6. [Ansible Configuration Management Tasks](#ansible-configuration-management-tasks)
7. [API Reference](#api-reference)
8. [Contributing](#contributing)
9. [License](#license)

## Introduction
This section provides an overview of your project and its main features.

## Getting Started
Follow these steps to get your project up and running.

### Prerequisites
- Docker installed on your system
- Basic knowledge of Docker and Ansible
- SSH access to Docker containers (root user with password 'rootpassword')

## Installation
```bash
# Clone the repository
git clone https://github.com/yourusername/yourproject.git

# Navigate to project directory
cd yourproject

# Build the Docker image for app servers
docker build -t fra1-host:20.04 .

# Build the Docker image for Nagios server
docker build -t fra1-nagios:20.04 -f Dockerfile.nagios .

# Start all containers with docker-compose
docker-compose up -d
```

## Usage
Provide examples of how to use your project:

```bash
# Access the containers via SSH on mapped ports
ssh root@127.0.0.1 -p 2222  # app-vm1
ssh root@127.0.0.1 -p 2223  # db-vm1
ssh root@127.0.0.1 -p 2224  # web-vm1
ssh root@127.0.0.1 -p 8080  # monitoring.fra1.internal (Nagios web interface)

# Run ansible commands inside containers, for example:
docker exec -it app-vm1 ansible -i /root/hosts.ini fra1_hosts -m setup
```

## Configuration
Explain how to configure your project:

1. Create an Ansible inventory file with the following content:

```
[fra1_hosts]
app-vm1 ansible_host=192.168.0.2 ansible_port=22 ansible_user=root ansible_password=rootpassword ansible_ssh_common_args='-o StrictHostKeyChecking=no'
db-vm1 ansible_host=192.168.0.3 ansible_port=22 ansible_user=root ansible_password=rootpassword ansible_ssh_common_args='-o StrictHostKeyChecking=no'
web-vm1 ansible_host=192.168.0.4 ansible_port=22 ansible_user=root ansible_password=rootpassword ansible_ssh_common_args='-o StrictHostKeyChecking=no'

[nagios_server]
monitoring.fra1.internal ansible_host=192.168.0.100 ansible_port=22 ansible_user=root ansible_password=rootpassword ansible_ssh_common_args='-o StrictHostKeyChecking=no'
```

2. Use Ansible to manage the containers and apply configuration management tasks.

## Ansible Configuration Management Tasks
This project includes the following configuration management tasks using Ansible:

1. Display all ansible_ configuration for a host:
   ```
   ansible <hostname> -m setup
   ```

2. Configure a cron job to run logrotate every 10 minutes between 2h and 4h on all machines using the Ansible playbook `logrotate-cron.yml`. Run it inside a container with:

   ```
   docker cp logrotate-cron.yml app-vm1:/root/logrotate-cron.yml
   docker exec -it app-vm1 ansible-playbook -i /root/hosts.ini /root/logrotate-cron.yml --ask-become-pass
   ```

   Verify the cron job on each container with:

   ```
   docker exec -it <container_name> crontab -l
   ```

3. Deploy the ntpd package with a custom configuration on the following servers using the Ansible playbook `ntpd-deploy.yml`. Run it inside a container with:

   ```
   docker cp ntpd-deploy.yml app-vm1:/root/ntpd-deploy.yml
   docker cp -r templates app-vm1:/root/templates
   docker exec -it app-vm1 ansible-playbook -i /root/hosts.ini /root/ntpd-deploy.yml --ask-become-pass
   ```

   Verify the ntpd configuration file on each container with:

   ```
   docker exec -it <container_name> cat /etc/ntpd.conf
   ```

   Check the ntpd service status with:

   ```
   docker exec -it <container_name> service ntp status
   ```

4. Deploy monitoring templates on the Nagios server `monitoring.fra1.internal` for the above machines using the Ansible playbook `nagios-deploy.yml`. Run it inside the Nagios container with:

   ```
   docker cp nagios-deploy.yml monitoring.fra1.internal:/root/nagios-deploy.yml
   docker cp -r templates monitoring.fra1.internal:/root/templates
   docker exec -it monitoring.fra1.internal ansible-playbook -i /root/hosts.ini /root/nagios-deploy.yml --ask-become-pass
   ```

   Verify the Nagios configuration files on the Nagios server with:

   ```
   docker exec -it monitoring.fra1.internal ls /etc/nagios/conf.d/managed_hosts/
   ```

   Check the Nagios service status with:

   ```
   docker exec -it monitoring.fra1.internal service nagios status
   ```

---
**Note:** Remember to update this documentation as your project evolves.
