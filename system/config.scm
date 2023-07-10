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
			 (guix licenses)
			 (guix utils)
			 (guix build utils)
			 (guix build-system copy)
			 (guix build gnu-build-system)
			 (nongnu packages firmware)
			 (nongnu packages fonts)
			 (nongnu packages video)
			 (nongnu packages linux)
			 (nongnu system linux-initrd)
			 (ice-9 textual-ports)
			 (srfi srfi-1))

(use-service-modules base networking cups dbus authentication virtualization desktop syncthing admin pm vpn games)

(use-package-modules base linux admin certs nvi gl vulkan video vpn freedesktop cpio compression)

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
			   (name 'guix)
			   (url "https://git.savannah.gnu.org/git/guix.git")
			   (branch "master")
			   (commit "669f0eaed6310233295fbd0a077afc9ce054c6ab")
			   (introduction
				 (make-channel-introduction
				   "9edb3f66fd807b096b48283debdcddccfea34bad"
				   (openpgp-fingerprint
					 "BBB0 2DDF 2CEA F6A8 0D1D  E643 A2A0 6DF2 A33A 54FA"))))
			 (channel
			   (name 'nonguix)
			   (url "https://gitlab.com/nonguix/nonguix")
			   (branch "master")
			   (commit "211635c8e024692c2b05d1af4c9c6a43b9fc0aa1")
			   (introduction
				 (make-channel-introduction
				   "897c1a470da759236cc11798f4e0a5f7d4d59fbc"
				   (openpgp-fingerprint
					 "2A39 3FFF 68F4 EF7A 3D29  12AF 6F51 20A0 22FB B2D5"))))))
	 (inferior
	   (inferior-for-channels channels)))
	(first (lookup-inferior-packages inferior "linux-xanmod"))))

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

(define %primary-username "gavin")

(define %users (cons (user-account
					   (name %primary-username)
					   (group %primary-username)
					   (supplementary-groups '("wheel" "audio" "video" "netdev"
											   "network" "dialout" "kvm" "libvirt"
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
"NOPASSWD: /run/current-system/profile/bin/light")))

(define %mapped-devices
  (list (mapped-device
		  (source (uuid "1ff5d411-6151-4ee0-8c37-699f875adf75"))
		  (target "root")
		  (type luks-device-mapping))))

(define %file-systems (append
						(list (file-system
								(device "/dev/mapper/root")
								(mount-point "/")
								(type "ext4")
								(dependencies %mapped-devices))
							  (file-system
								(device (file-system-label "BOOT"))
								(mount-point "/boot/efi")
								(type "vfat")))
						%base-file-systems))

(define %swap-devices
  (list
	(swap-space
	  (target "/swapfile")
	  (dependencies (filter (file-system-mount-point-predicate "/")
							%file-systems)))))

(define %hosts-file (origin
					  (uri "https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts")
					  (method url-fetch)
					  (sha256
						(base32
						  "0na31fzvm5jh2c1rh260ghq61fsaqdfqmi0n7nbhjzpmcd23wx6z"))))

(define %packages (append
					(list nvi mesa vulkan-loader intel-media-driver intel-vaapi-driver libva
						  nss-certs wpa-supplicant bluez wireguard-tools light fprintd)
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

(define %mullvad-server-type "sg")

(define %mullvad-dns "100.64.0.7")

(define %mullvad-kill-switch #t)

(define (make-mullvad-wireguard-configuration name addresses endpoint public-key kill-switch)
  (wireguard-configuration
	(addresses addresses)
	(dns (list %mullvad-dns))
	(private-key "/etc/wireguard/private.key")
	;(post-up (if kill-switch
	;		   '(("iptables -I OUTPUT ! -o %i -m mark ! --mark $(wg show %i fwmark) -m addrtype ! --dst-type LOCAL -j REJECT")
	;			 ("ip6tables -I OUTPUT ! -o %i -m mark ! --mark $(wg show %i fwmark) -m addrtype ! --dst-type LOCAL -j REJECT"))
	;		   '()))
	;(pre-down (if kill-switch
	;			'(("iptables -D OUTPUT ! -o %i -m mark ! --mark $(wg show %i fwmark) -m addrtype ! --dst-type LOCAL -j REJECT")
	;			  ("ip6tables -D OUTPUT ! -o %i -m mark ! --mark $(wg show %i fwmark) -m addrtype ! --dst-type LOCAL -j REJECT"))
	;			'()))
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
						  (service libvirt-service-type
								   (libvirt-configuration
									 (unix-sock-group "libvirt")))
						  (service virtlog-service-type)
						  ;(service fprintd-service-type)
						  (service joycond-service-type)
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
															(append (list (local-file "nonguix/signing-key.pub"))
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
  (swap-devices %swap-devices)

  (packages %packages)
  (services %services))
