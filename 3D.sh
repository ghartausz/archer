#!/bin/bash

C="\e[36m" #CYAN
E="\e[0m" #ENDCOLOR
G="\e[32m" #GREEN
R="\e[31m" #RED
LB="\e[1;34m" #LIGHT BLUE
B="\e[34m" #BLUE
P="\e[35m" #PURPLE
Y="\e[33m" #YELLOW

while true; do
	    read -p "Do you want to install the 3D stuff later? Y/N" yn
	    case $yn in
		[Yy]* ) sed -n '228,$p' inst.sh > /home/$username/3d.sh
			chmod +x /home/$username/3d.sh; break;;
		[Nn]* ) read -p "Do you want to install wmware guest system tools? " -n 1 -r
								echo    # (optional) move to a new line
									if [[ $REPLY =~ ^[Yy]$ ]]
									then
								pacman -S gtkmm open-vm-tools --noconfirm
								pacman -S xf86-video-vmware xf86-input-vmmouse
								systemctl enable vmtoolsd.service 
								systemctl enable vmware-vmblock-fuse.service
									fi
									read -p "Installing GNOME DE? " -n 1 -r
									echo    # (optional) move to a new line
									if [[ $REPLY =~ ^[Yy]$ ]]
										then
												pacman -S --noconfirm xorg gdm gnome gnome-extra
												systemctl enable gdm.service
												read -p "Disable Wayland for better 3D acceleration? " -n 1 -r
												echo    # (optional) move to a new line
												if [[ $REPLY =~ ^[Yy]$ ]]
													then
													sed -i '/Wayland/s/^#//g/' /etc/gdm/custom.conf
													cat /etc/gdm/custom.conf
											fi
										fi
										read -p "Sekiro GRUB theme? " -n 1 -r
										echo    # (optional) move to a new line
										if [[ $REPLY =~ ^[Yy]$ ]]
										then
												pacman -S --noconfirm git
												git clone https://github.com/semimqmo/sekiro_grub_theme.git
												cd sekiro_grub_theme
												chmod +x install.sh
												./install.sh
										fi
										echo;break;;
		* ) echo "Please answer yes or no.";;
	    esac
	  done
