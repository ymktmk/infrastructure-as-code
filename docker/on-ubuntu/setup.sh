#!/bin/sh
sudo apt-get update -y

sudo apt-get install \
      ca-certificates \
      curl \
      gnupg \
      lsb-release -y

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
      $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update -y

sudo apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin -y

sudo chmod 666 /var/run/docker.sock

# sudo systemctl status docker
# sudo apt-get install cgroup-tools -y
