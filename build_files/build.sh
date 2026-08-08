#!/bin/bash

set -ouex pipefail

# Copy the contents of system_files/ of the git repo to /
cp -avf "/ctx/system_files"/. /


### Remove packages
sudo dnf remove \
    waydroid \
    waydroid-selinux

### Install packages

# Packages can be installed from any enabled yum repo on the image.
# RPMfusion repos are available by default in ublue main images
# List of rpmfusion packages can be found here:
# https://mirrors.rpmfusion.org/mirrorlist?path=free/fedora/updates/43/x86_64/repoview/index.html&protocol=https&redirect=1

# this installs a package from fedora repos

dnf5 install -y \
    google-noto-sans-fonts \
    podman-tui \
    restic \
    zsh \
    qemu \
    libvirt \
    qemu-kvm \
    virt-manager \
    edk2-ovmf \
    guestfs-tools

# Use a COPR Example:
#
# dnf5 -y copr enable ublue-os/staging
# dnf5 -y install package
# Disable COPRs so they don't end up enabled on the final image:
# dnf5 -y copr disable ublue-os/staging

dnf5 config-manager addrepo --from-repofile="https://packages.microsoft.com/yumrepos/vscode/config.repo"
dnf5 config-manager setopt vscode-yum.enabled=0
dnf5 install --enable-repo="vscode-yum" -y \
    code

dnf5 config-manager addrepo --from-repofile="https://repository.mullvad.net/rpm/stable/mullvad.repo"
dnf5 config-manager setopt vscode-yum.enabled=0
dnf5 install --enable-repo="mullvad-stable" -y\
    mullvad-vpn

# Enable services
systemctl --global enable ublue-user-setup.service
systemctl enable bazzite-dx-groups.service

# Clean package manager cache
dnf5 clean all

# Clean temporary files
rm -rf /tmp/* || true

# Cleanup the entirety of `/var`.
# None of these get in the end-user system and bootc lints get super mad if anything is in there
rm -rf /var
mkdir -p /var/tmp
chmod -R 1777 /var/tmp