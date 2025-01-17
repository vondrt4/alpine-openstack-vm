#!/bin/sh

_step_counter=0
step() {
	_step_counter=$(( _step_counter + 1 ))
	printf '\n\033[1;36m%d) %s\033[0m\n' $_step_counter "$@" >&2  # bold cyan
}


step 'Set up timezone'
setup-timezone -z Europe/Prague

step 'Set up networking'
cat > /etc/network/interfaces <<-EOF
	auto lo
	iface lo inet loopback

	auto eth0
	iface eth0 inet dhcp
	    udhcpc_opts -O staticroutes
EOF

step 'Set cloud configuration'
#sed -e '/disable_root:/ s/true/false/' \
sed -e '/ssh_pwauth:/ s/0/no/' \
    -e '/name: alpine/a \     passwd: "*"' \
    -e '/lock_passwd:/ s/True/False/' \
    -i /etc/cloud/cloud.cfg

step 'Allow only key based ssh login'
#sed -e '/PermitRootLogin yes/d' \
sed -e 's/^#PasswordAuthentication yes/PasswordAuthentication no/' \
    -e 's/^#PubkeyAuthentication yes/PubkeyAuthentication yes/' \
    -i /etc/ssh/sshd_config

# Terraform and github actions need ssh-rsa as accepted algorithm
# The ssh client needs to be updated (see https://www.openssh.com/txt/release-8.8)
echo "PubkeyAcceptedKeyTypes=+ssh-rsa" >> /etc/ssh/sshd_config

step 'Remove password for users'
usermod -p '*' root

step 'Adjust rc.conf'
sed -Ei \
	-e 's/^[# ](rc_depend_strict)=.*/\1=NO/' \
	-e 's/^[# ](rc_logger)=.*/\1=YES/' \
	-e 's/^[# ](unicode)=.*/\1=YES/' \
	/etc/rc.conf

# see https://gitlab.alpinelinux.org/alpine/aports/-/issues/8861
step 'Enable cloud-init configuration via NoCloud iso image'

echo "iso9660" >> /etc/filesystems

step 'Enable services'
rc-update add acpid default
rc-update add chronyd default
rc-update add crond default
rc-update add networking boot
rc-update add termencoding boot
rc-update add sshd default
rc-update add cloud-init default
rc-update add cloud-config default
rc-update add cloud-final default
