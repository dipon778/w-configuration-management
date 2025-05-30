FROM ubuntu:20.04

# 1. Ensure noninteractive frontend
ENV DEBIAN_FRONTEND=noninteractive

# 2. Add Puppet Labs repo
RUN apt-get update && \
    apt-get install -y \
      software-properties-common \
      curl \
      gnupg \
      wget \
      python3 \
      python3-pip && \
    apt-get update

# 3. Install specific versions
RUN apt-get install -y \
      openssh-server \
      cron \
      sshpass && \
    # Clean up
    apt-get clean && rm -rf /var/lib/apt/lists/*

# 4. Install latest Ansible via pip
RUN pip3 install --no-cache-dir ansible

# 5. Enable SSH root login and set root password
RUN mkdir /var/run/sshd && \
    sed -i 's/^#*PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    echo 'root:rootpassword' | chpasswd

EXPOSE 22 123/udp

CMD ["/usr/sbin/sshd", "-D"]
