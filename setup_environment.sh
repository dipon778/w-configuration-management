#!/bin/bash

# This script automates the setup of the Docker environment with three Ubuntu 20.04 containers
# configured with Ansible and Puppet, and a Nagios monitoring server container.
# It also runs Ansible playbooks to configure cron jobs, deploy ntpd with custom config,
# and deploy Nagios monitoring templates.

set -e

echo "Step 1: Build the Docker images for app servers and Nagios server"

# Build the app server image
docker build -t fra1-host:20.04 .

# Build the Nagios server image
docker build -t fra1-nagios:20.04 -f Dockerfile.nagios .

echo "Step 2: Start all containers using docker-compose"
docker-compose up -d

echo "Step 3: Copy Ansible inventory and playbooks into app-vm1 container"

docker cp hosts.ini app-vm1:/root/hosts.ini
docker cp logrotate-cron.yml app-vm1:/root/logrotate-cron.yml
docker cp ntpd-deploy.yml app-vm1:/root/ntpd-deploy.yml
docker cp -r templates app-vm1:/root/templates

echo "Step 4: Run Ansible playbook to configure cron job for logrotate"
docker exec -it app-vm1 ansible-playbook -i /root/hosts.ini /root/logrotate-cron.yml --ask-become-pass

echo "Step 5: Run Ansible playbook to deploy ntpd package and custom configuration"
docker exec -it app-vm1 ansible-playbook -i /root/hosts.ini /root/ntpd-deploy.yml --ask-become-pass

echo "Step 6: Copy Nagios playbook and templates into Nagios container"
docker cp nagios-deploy.yml monitoring.fra1.internal:/root/nagios-deploy.yml
docker cp -r templates monitoring.fra1.internal:/root/templates

echo "Step 7: Run Ansible playbook to deploy Nagios monitoring templates"
docker exec -it monitoring.fra1.internal ansible-playbook -i /root/hosts.ini /root/nagios-deploy.yml --ask-become-pass

echo "Setup complete. You can now access the Nagios web interface on port 8080."
