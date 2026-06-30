#!/bin/bash
# Enable SSH login (idempotent: safe to re-run).

SSHD_CONFIG="/etc/ssh/sshd_config"

# runit-supervised sshd: clear any "down" marker (no-op on systemd/sysvinit).
sudo rm -f /etc/service/sshd/down

# Set a sshd_config directive idempotently: replace any existing (commented or
# active) line for the key, or append if the key is absent. Prevents the
# duplicate lines that `tee -a` produced on every re-run.
set_sshd() {
    local key="$1" val="$2"
    if sudo grep -qiE "^[#[:space:]]*${key}\b" "$SSHD_CONFIG"; then
        sudo sed -ri "s|^[#[:space:]]*${key}\b.*|${key} ${val}|" "$SSHD_CONFIG"
    else
        echo "${key} ${val}" | sudo tee -a "$SSHD_CONFIG" > /dev/null
    fi
}

set_sshd PermitRootLogin       yes
set_sshd UseDNS                no
set_sshd StrictModes           no
set_sshd UsePAM                no
set_sshd PasswordAuthentication yes

# Restart sshd to apply (best-effort across init systems).
if command -v systemctl >/dev/null 2>&1; then
    sudo systemctl restart ssh 2>/dev/null || sudo systemctl restart sshd 2>/dev/null || true
elif command -v service >/dev/null 2>&1; then
    sudo service ssh restart 2>/dev/null || sudo service sshd restart 2>/dev/null || true
fi
