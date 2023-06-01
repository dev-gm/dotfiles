(use-modules (gnu services base)
	     (gnu services networking)
	     (gnu services cups)
	     (gnu services dbus)
	     (gnu services authentication)
	     (gnu services desktop)
	     (gnu services syncthing)
	     (gnu services admin)
	     (gnu services pm)
	     (gnu packages cups)
	     (gnu packages fonts)
	     (gnu packages admin)
	     (gnu packages freedesktop)
	     (gnu packages base)
	     (gnu packages certs)
	     (gnu packages linux)
	     (gnu system keyboard)
	     (gnu system mapped-devices)
	     (gnu system file-systems)
	     (gnu bootloader)
	     (gnu bootloader grub)
	     (guix gexp)
	     (gnu packages vim)
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

(define %firmware (append
		    (list iwlwifi-firmware
			  i915-firmware
			  bluez-firmware)
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
		       (supplementary-groups '("wheel" "audio" "video" "netdev")))
		     %base-user-accounts))

(define %groups (cons (user-group
			 (name %primary-username)
			 (id 1000))
		       %base-groups))

(define %packages (append
		    (list intel-media-driver wpa-supplicant nss-certs vim bluez)
		    %base-packages))

(define %nftables-ruleset %default-nftables-ruleset)

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
			  (service unattended-upgrade-service-type
				   (unattended-upgrade-configuration))
			  (service cups-service-type
				   (cups-configuration
				     (web-interface? #t)
				     (extensions
				       (list epson-inkjet-printer-escpr))))
			  (service elogind-service-type
				   (elogind-configuration))
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
				     (cpu-boost-on-bat? #f))))
			  ;(service fprintd-service-type)
		    (modify-services %base-services
				     (mingetty-service-type config =>
							    (if (string=? "tty1" (mingetty-configuration-tty config))
							      (mingetty-configuration
								(inherit config)
								(auto-login %primary-username))
							      config)))))

(operating-system
  (host-name "laptop.gavinm.us")
  (timezone "America/New_York")
  (locale "en_US.utf8")
  (keyboard-layout %keyboard-layout)
  (users %users)
  (groups %groups)

  (kernel linux)
  (kernel-arguments %kernel-arguments)
  (bootloader %bootloader)
  (initrd microcode-initrd)
  (firmware %firmware)

  (mapped-devices %mapped-devices)
  (file-systems %file-systems)

  (packages %packages)
  (services %services))
