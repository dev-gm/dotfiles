(use-modules (gnu)
			 (gnu system keyboard)
			 (gnu system mapped-devices)
			 (gnu system file-systems)
			 (gnu system linux-initrd)
			 (gnu bootloader)
			 (gnu bootloader grub)
			 (guix gexp)
			 (guix channels)
			 (guix inferior)
			 (guix download)
			 (guix packages)
			 (nongnu packages firmware)
			 (nongnu packages fonts)
			 (nongnu packages video)
			 (nongnu packages linux)
			 (nongnu system linux-initrd)
			 (ice-9 textual-ports)
			 (srfi srfi-1))

(use-service-modules base networking cups dbus authentication virtualization desktop syncthing admin pm vpn)

(use-package-modules base linux admin certs nvi gl vulkan video vpn)

(set! *random-state* (random-state-from-platform))

(define %keyboard-layout (keyboard-layout "us" "dvp"
										  #:options
										  (list
											"compose:102"
											"numpad:shift3"
											"kpdl:semi"
											"keypad:atm"
											"caps:super")))

(define %kernel
  (let*
	((channels
	   (list (channel
			   (name 'nonguix)
			   (url "https://gitlab.com/nonguix/nonguix")
			   (branch "master")
			   (commit "69b05a57eed16218d607a90d7bc49ba79a2d850e"))
			 (channel
			   (name 'guix)
			   (url "https://git.savannah.gnu.org/git/guix.git")
			   (branch "master")
			   (commit "2e0228e736bf08d376ffbce6b5c4f899babfee5e"))))
	 (inferior
	   (inferior-for-channels channels)))
	(first (lookup-inferior-packages inferior "linux"))))

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
					   (supplementary-groups '("wheel" "audio" "video" "netdev"
											   "network" "dialout" "kvm"
											   "audio" "video" "adbusers")))
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
					(list mesa vulkan-loader intel-media-driver intel-vaapi-driver libva wpa-supplicant
						  nss-certs nvi bluez fwupd-nonfree wireguard-tools iptables)
					%base-packages))

(define %iptables-rules
  (plain-file "iptables.rules"
			  "*filter
:INPUT DROP
:FORWARD ACCEPT
:OUTPUT ACCEPT
-A INPUT -i lo -j ACCEPT
-A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
COMMIT
"))

(define %ip6tables-rules
  (plain-file "ip6tables.rules"
			  "*filter
:INPUT DROP
:FORWARD ACCEPT
:OUTPUT ACCEPT
-A INPUT -i lo -j ACCEPT
-A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
COMMIT
"))

; /etc/wireguard/servers must contain all mullvad wireguard config files

(define %mullvad-server-type "sg-sin") ; singapore

(define %mullvad-dns "100.64.0.7")

(define %mullvad-kill-switch #t)

(define (make-mullvad-wireguard-configuration name addresses endpoint public-key kill-switch)
  (wireguard-configuration
	(addresses addresses)
	(dns (list %mullvad-dns))
	(private-key "/etc/wireguard/private.key")
	(post-up (if kill-switch
			   '("iptables -I OUTPUT ! -o %i -m mark ! --mark $(wg show %i fwmark) -m addrtype ! --dst-type LOCAL -j REJECT"
				 "ip6tables -I OUTPUT ! -o %i -m mark ! --mark $(wg show %i fwmark) -m addrtype ! --dst-type LOCAL -j REJECT")
			   '()))
	(pre-down (if kill-switch
				'("iptables -D OUTPUT ! -o %i -m mark ! --mark $(wg show %i fwmark) -m addrtype ! --dst-type LOCAL -j REJECT"
				  "ip6tables -D OUTPUT ! -o %i -m mark ! --mark $(wg show %i fwmark) -m addrtype ! --dst-type LOCAL -j REJECT")
				'()))
	(peers
	  (list
		(wireguard-peer
		  (name name)
		  (public-key public-key)
		  (allowed-ips '("0.0.0.0/0" "::0/0"))
		  (endpoint endpoint))))))

(define %wireguard-configuration
  (begin
	(system (string-join
			  (string-split
				(call-with-input-file
				  "wireguard/set-servers-list"
				  get-string-all) #\:)
			  %mullvad-server-type))
	(let* ((servers (read (open-input-file "/etc/wireguard/servers-list")))
		   (server (list-ref servers (random (length servers))))
		   (name (first server))
		   (addresses (string-split (second server) #\,))
		   (endpoint (third server))
		   (public-key (fourth server)))
	  (make-mullvad-wireguard-configuration name addresses endpoint public-key %mullvad-kill-switch))))

(define %solaar-udev-rules
  (file->udev-rule
	"42-logitech-unify-permissions.rules"
	(origin
	  (method url-fetch)
	  (uri "https://raw.githubusercontent.com/pwr-Solaar/Solaar/master/rules.d/42-logitech-unify-permissions.rules")
	  (sha256
		(base32
		  "1j2hizasd9303783ay7n2aymx12l3kk2jijcmn4dwczlk900h4ci")))))

(define %services (append
					(list (service wpa-supplicant-service-type)
						  (service network-manager-service-type)
						  (service iptables-service-type
								   (iptables-configuration
									 (ipv4-rules %iptables-rules)
									 (ipv6-rules %ip6tables-rules)))
						  (service wireguard-service-type
								   %wireguard-configuration)
						  (service openntpd-service-type
								   (openntpd-configuration))
						  (service syncthing-service-type
								   (syncthing-configuration
									 (user %primary-username)
									 (arguments (list "--no-default-folder"))))
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
									 (cpu-max-perf-on-bat 25)
									 (cpu-boost-on-ac? #t)
									 (cpu-boost-on-bat? #f)))
						  (service unattended-upgrade-service-type)
						  (udev-rules-service 'solaar %solaar-udev-rules))
					(modify-services %base-services
									 (guix-service-type config =>
														(guix-configuration
														  (inherit config)
														  (substitute-urls
															(append (list "https://substitutes.nonguix.org")
																	%default-substitute-urls))
														  (authorized-keys
															(append (list (local-file "nonguix-signing-key.pub"))
																	%default-authorized-guix-keys)))))))

(operating-system
  (host-name "laptop.gavinm.us")
  (timezone "America/New_York")
  (locale "en_US.utf8")
  (keyboard-layout %keyboard-layout)
  (users %users)
  (groups %groups)

  (sudoers-file %sudoers-file)
  (hosts-file %hosts-file)

  (kernel %kernel)
  (kernel-arguments %kernel-arguments)
  (bootloader %bootloader)
  (initrd %initrd)
  (firmware %firmware)

  (mapped-devices %mapped-devices)
  (file-systems %file-systems)

  (packages %packages)
  (services %services))
