#!/bin/bash

# enable ssh login
sudo rm -f /etc/service/sshd/down
sudo sed -ri 's/^#?PermitRootLogin\s+.*/PermitRootLogin yes/' /etc/ssh/sshd_config
sudo sed -ri 's/#UseDNS\ no/UseDNS\ no/g' /etc/ssh/sshd_config
sudo sed -ri 's/StrictModes yes/StrictModes no/g' /etc/ssh/sshd_config
sudo sed -ri 's/UsePAM yes/UsePAM no/g' /etc/ssh/sshd_config

# Enable login with password
echo 'PasswordAuthentication yes' | sudo tee -a /etc/ssh/sshd_config > /dev/null
