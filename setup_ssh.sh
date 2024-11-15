#!/bin/bash

# enable ssh login
sudo rm -f /etc/service/sshd/down
sudo sed -ri 's/^#?PermitRootLogin\s+.*/PermitRootLogin yes/' /etc/ssh/sshd_config &&\
sudo sed -ri 's/#UseDNS\ no/UseDNS\ no/g' /etc/ssh/sshd_config && \
sudo sed -ri "s/StrictModes yes/StrictModes no/g" /etc/ssh/sshd_config && \
sudo sed -ri "s/UsePAM yes/UsePAM no/g" /etc/ssh/sshd_config

# enable login with password
sudo echo 'PasswordAuthentication yes' >> /etc/ssh/sshd_config