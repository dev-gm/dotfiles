(use-modules (gnu services base)
			 (gnu services networking)
			 (gnu services cups)
			 (gnu services dbus)
			 (gnu services authentication)
			 (gnu services desktop)
			 (gnu services syncthing)
			 (gnu services admin)
			 (gnu services pm)
			 ;(gnu packages cups)
			 (gnu packages admin)
			 ;(gnu packages freedesktop)
			 (gnu packages certs)
			 (gnu packages admin)
			 (gnu packages nvi)
			 (gnu packages gl)
			 (gnu packages vulkan)
			 (gnu packages linux)
			 (gnu packages base)
			 (gnu system keyboard)
			 (gnu system mapped-devices)
			 (gnu system file-systems)
			 (gnu system linux-initrd)
			 (gnu bootloader)
			 (gnu bootloader grub)
			 (guix gexp)
			 (guix download)
			 (guix packages)
			 (nongnu packages firmware)
			 (nongnu packages fonts)
			 (nongnu packages video)
			 (nongnu packages linux)
			 (nongnu system linux-initrd))

(define %keyboard-layout (keyboard-layout "us" "dvp"
										  #:options
										  (list
											"compose:102"
											"numpad:shift3"
											"kpdl:semi"
											"keypad:atm"
											"caps:super")))

(define %kernel-arguments
  (list
	"net.ifnames=0"
	"modprobe.blacklist=hid_sensor_hub"
	"acpi_osi=\"!Windows 2020\""
	"quiet"
	"nvme.noacpi=1"))

(define %bootloader (bootloader-configuration
					  (bootloader grub-efi-bootloader)
					  (targets '("/boot/efi"))
					  (keyboard-layout %keyboard-layout)))

(define %initrd (lambda (file-systems . rest)
				  (apply microcode-initrd file-systems
						 #:initrd base-initrd
						 #:microcode-packages (list intel-microcode)
						 rest)))

(define %firmware (append
					(list i915-firmware
						  iwlwifi-firmware
						  ibt-hw-firmware)
					%base-firmware))

(define %mapped-devices
  (list (mapped-device
		  (source (uuid "1ff5d411-6151-4ee0-8c37-699f875adf75"))
		  (target "root")
		  (type luks-device-mapping))))

(define %file-systems (append
						(list (file-system
								(device (file-system-label "ROOT"))
								(mount-point "/")
								(type "ext4")
								(dependencies %mapped-devices))
							  (file-system
								(device (file-system-label "BOOT"))
								(mount-point "/boot/efi")
								(type "vfat")))
						%base-file-systems))

(define %primary-username "gavin")

(define %users (cons (user-account
					   (name %primary-username)
					   (group %primary-username)
					   (supplementary-groups '("wheel" "audio" "video"
											   "netdev" "network" "dialout"
											   "audio" "kvm" "video" "adbusers")))
					 %base-user-accounts))

(define %groups (append (list (user-group
								(name %primary-username)
								(id 1000))
							  (user-group
								(name "network"))
							  (user-group
								(name "adbusers")))
						%base-groups))

(define %sudoers-file
  (plain-file "sudoers" (string-append "\
root ALL=(ALL) ALL
%wheel ALL=(ALL) ALL
" %primary-username " ALL=(ALL) "
"NOPASSWD: /home/" %primary-username
"/.guix-home/profile/bin/light")))

(define %hosts-file (origin
					  (uri "https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts")
					  (method url-fetch)
					  (sha256
						(base32
						  "0na31fzvm5jh2c1rh260ghq61fsaqdfqmi0n7nbhjzpmcd23wx6z"))))

(define %packages (append
					(list mesa vulkan-loader intel-media-driver
						  wpa-supplicant nss-certs nvi bluez fwupd-nonfree)
					%base-packages))

(define %nftables-ruleset %default-nftables-ruleset) ;(plain-file "nftables.conf" ""))

(define %services (append
					(list (service wpa-supplicant-service-type)
						  (service network-manager-service-type
								   (network-manager-configuration))
						  (service nftables-service-type
								   (nftables-configuration
									 (ruleset %nftables-ruleset)))
						  (service openntpd-service-type
								   (openntpd-configuration))
						  (service syncthing-service-type
								   (syncthing-configuration
									 (user %primary-username)
									 (arguments (list "--no-default-folder"))))
						;  (service cups-service-type
						;		   (cups-configuration
						;			 (web-interface? #t)
						;			 (extensions
						;			   (list epson-inkjet-printer-escpr))))
						  (service elogind-service-type
								   (elogind-configuration
									 (handle-lid-switch 'suspend)
									 (handle-lid-switch-docked 'ignore)
									 (handle-lid-switch-external-power 'ignore)))
						  (service bluetooth-service-type
								   (bluetooth-configuration
									 (name "Laptop")))
						  (service tlp-service-type
								   (tlp-configuration
									 (tlp-default-mode "BAT")
									 (cpu-scaling-governor-on-ac (list "performance"))
									 (cpu-scaling-governor-on-bat (list "powersave"))
									 (cpu-max-perf-on-ac 100)
									 (cpu-max-perf-on-bat 30)
									 (cpu-boost-on-ac? #t)
									 (cpu-boost-on-bat? #f)))
						  (service greetd-service-type
								   (greetd-configuration
									 (terminals
									   (list
										 (greetd-terminal-configuration
										   (terminal-vt "1")
										   (terminal-switch #t)
										   (default-session-user "gavin")
										   (default-session-command
											 (program-file "sway" #~(exit)))))))))
					(modify-services %base-services
									 (delete login-service-type)
									 (delete mingetty-service-type))))

(operating-system
  (host-name "laptop.gavinm.us")
  (timezone "America/New_York")
  (locale "en_US.utf8")
  (keyboard-layout %keyboard-layout)
  (users %users)
  (groups %groups)

  (sudoers-file %sudoers-file)
  (hosts-file %hosts-file)

  (kernel linux)
  (kernel-arguments %kernel-arguments)
  (bootloader %bootloader)
  (initrd %initrd)
  (firmware %firmware)

  (mapped-devices %mapped-devices)
  (file-systems %file-systems)

  (packages %packages)
  (services %services))
