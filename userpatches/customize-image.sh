#!/bin/bash

# arguments: $RELEASE $LINUXFAMILY $BOARD $BUILD_DESKTOP
#
# This is the image customization script

# NOTE: It is copied to /tmp directory inside the image
# and executed there inside chroot environment
# so don't reference any files that are not already installed

# NOTE: If you want to transfer files between chroot and host
# userpatches/overlay directory on host is bind-mounted to /tmp/overlay in chroot

RELEASE=$1
LINUXFAMILY=$2
BOARD=$3
BUILD_DESKTOP=$4

Main() {
	case $RELEASE in
		jessie)
			mycustomscript
			;;
		xenial)
			mycustomscript
			;;
		stretch)
			mycustomscript
			;;
		bionic)
			mycustomscript
			;;
	esac
} # Main

mycustomscript(){

	# make a separate config file

	# set user and hostname
	USERNAME="joe"
	HOSTNAME="hostname"

	# alter image type
	sed -i "s/^IMAGE_TYPE=.*/IMAGE_TYPE=custom/" /etc/armbian-release

	# install extra applications
	apt install -y speedtest-cli uuid-runtime

	# disable root login
	# passwd -l root

	# adjust ssh config
	sed -i '/^PermitRootLogin.*/ d' /etc/ssh/sshd_config
	sed -i "s/^PubkeyAuthentication.*/PubkeyAuthentication yes/" /etc/ssh/sshd_config

	# add normal user with sudo rights and without setting a password
	useradd ${USERNAME} -m -s /bin/bash
	for additionalgroup in sudo netdev audio video dialout plugdev bluetooth systemd-journal ssh; do
		usermod -aG ${additionalgroup} ${USERNAME} 2>/dev/null
	done

	# copy ssh key
	mkdir -p /home/${USERNAME}/.ssh/
	chmod 775 /home/${USERNAME}/.ssh/
	cp /tmp/overlay/public.key /home/${USERNAME}/.ssh/authorized_keys
	chmod 664 /home/${USERNAME}/.ssh/authorized_keys
	chown -R ${USERNAME}.${USERNAME} /home/${USERNAME}/.ssh/

	# change hostname
	sed -i "s/${BOARD}/${HOSTNAME}/" /etc/hostname
	sed -i "s/${BOARD}/${HOSTNAME}/" /etc/hosts

	# disable first run user scrips
	rm /root/.not_logged_in_yet
	export LANG=C LC_ALL="en_US.UTF-8"

	# enable virtual overlayroot
	#apt-get -o Dpkg::Options::="--force-confnew" -y --no-install-recommends install overlayroot
	#echo '#!/bin/bash' > /etc/update-motd.d/97-overlayroot
	#echo 'if [ -n "$(mount | grep -w tmpfs-root)" ]; then echo -e "\n[\e[0m \e[1mremember: your system is in virtual read only mode\e[0m ]";fi' >> /etc/update-motd.d/97-overlayroot
	#chmod +x /etc/update-motd.d/97-overlayroot
	#sed -i "s/^overlayroot=.*/overlayroot=\"tmpfs\"/" /etc/overlayroot.conf

	# disable u-boot updates
	apt-mark hold linux-u-boot-${BOARD}*
	apt-mark hold linux-image-*${LINUXFAMILY}*

	# create a cron job which runs under root every 15 minutes
	install -o ${USERNAME} -g ${USERNAME} -m 755 /tmp/overlay/cron-script.sh /home/${USERNAME}/cron-script.sh
	echo "*/10 * * * * ${USERNAME} /home/${USERNAME}/cron-script.sh" >/etc/cron.d/user-cron-script
    chmod 600 /etc/cron.d/user-cron-script
}

Main "$@"