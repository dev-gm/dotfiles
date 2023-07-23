(use-modules (gnu)
			 (gnu bootloader)
			 (gnu bootloader grub)
			 (gnu home services utils)
			 (gnu system file-systems)
			 (gnu system keyboard)
			 (gnu system linux-initrd)
			 (gnu system mapped-devices)
			 (guix build utils)
			 (guix build-system copy)
			 (guix build gnu-build-system)
			 (guix channels)
			 (guix download)
			 (guix gexp)
			 (guix inferior)
			 (guix licenses)
			 (guix packages)
			 (guix records)
			 (guix utils)
			 (nongnu packages firmware)
			 (nongnu packages fonts)
			 (nongnu packages linux)
			 (nongnu packages video)
			 (nongnu system linux-initrd)
			 (ice-9 textual-ports)
			 (srfi srfi-1)
			 (srfi srfi-171))

(use-service-modules admin authentication base configuration cups dbus desktop games networking pm shepherd syncthing sysctl virtualization vpn)

(use-package-modules admin base certs compression cpio dns freedesktop gl networking ntp nvi linux video vpn vulkan)

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
											   "dialout" "kvm" "libvirt" "audio"
											   "video" "adbusers")))
					 %base-user-accounts))

(define %groups (append (list (user-group
								(name %primary-username)
								(id 1000))
							  (user-group
								(name "adbusers")))
						%base-groups))

(define %sudoers-file
  (plain-file "sudoers" (string-append "\
root ALL=(ALL) ALL
%wheel ALL=(ALL) ALL
" %primary-username " ALL=(ALL) NOPASSWD: /run/current-system/profile/bin/light
" %primary-username " ALL=(ALL) NOPASSWD: /run/current-system/profile/bin/herd stop wireguard-wg0
" %primary-username " ALL=(ALL) NOPASSWD: /run/current-system/profile/bin/herd restart wireguard-wg0")))

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
						  nss-certs iwd openntpd openresolv bluez wireguard-tools light)
					%base-packages))

(define (serialize-ini-config config)
  (define (serialize-val val)
	(cond
	  ((boolean? val) (if val "true" "false"))
	  ((list? val) (string-join (map serialize-val val) ","))
	  ((or (number? val) (symbol? val)) (maybe-object->string val))
	  (else val)))
  (define (serialize-field key val)
	(let ((val (serialize-val val))
		  (key (symbol->string key)))
	  (list key " = " val "\n")))
  (define* (concat-alist serialize li)
		   (generic-serialize-alist
			 (lambda* (#:rest r)
					  (string-concatenate
						(list-transduce tflatten rcons r)))
			 serialize li))
  (define (serialize-section key val)
	(list "[" (symbol->string key) "]\n" (concat-alist serialize-field val)))
  (concat-alist serialize-section config))

(define-configuration/no-serialization iwd-configuration
									   (iwd (package iwd) "")
									   (config (alist '()) ""))

(define (iwd-shepherd-service cfg)
  (match-record cfg <iwd-configuration>
				(iwd)
				(let ((environment #~(list (string-append
											 "PATH="
											 (string-append #$openresolv "/sbin")
											 ":"
											 (string-append #$coreutils "/bin")))))
				  (list
					(shepherd-service
					  (documentation "Run iwd")
					  (provision '(iwd networking))
					  (requirement '(user-processes dbus-system loopback))
					  (start #~(make-forkexec-constructor
								 (list (string-append #$iwd "/libexec/iwd"))
								 #:log-file "/var/log/iwd.log"
								 #:environment-variables #$environment))
					  (stop #~(make-kill-destructor)))))))

(define (iwd-etc-service cfg)
  (match-record cfg <iwd-configuration>
				(config)
				`(("iwd/main.conf"
				   ,(plain-file "main.conf" (serialize-ini-config config))))))

(define add-iwd-package (compose list iwd-configuration-iwd))

(define iwd-service-type
  (service-type
	(name 'iwd)
	(extensions
	  (list (service-extension
			  shepherd-root-service-type
			  iwd-shepherd-service)
			(service-extension
			  dbus-root-service-type
			  add-iwd-package)
			(service-extension
			  etc-service-type
			  iwd-etc-service)
			(service-extension
			  profile-service-type
			  add-iwd-package)))
	(default-value (iwd-configuration))
	(description "")))

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

(define (make-mullvad-wireguard-configuration name addresses endpoint public-key)
  (wireguard-configuration
	(addresses addresses)
	(dns (list %mullvad-dns))
	(private-key "/etc/wireguard/private.key")
	(post-up `(,(string-append "echo -n " %mullvad-server-type " > /var/lib/mullvad-status")))
	(pre-down '("echo > /var/lib/mullvad-status"))
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
	  (make-mullvad-wireguard-configuration name addresses endpoint public-key))))

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
					(list (service iwd-service-type
								   (iwd-configuration
									 (config '((General .  ((EnableNetworkConfiguration . #t)))
											   (Network . ((NameResolvingService . "resolvconf")))
											   (Scan . ((DisablePeriodicScan . #t)))))))
						  (service iptables-service-type
								   (iptables-configuration
									 (ipv4-rules %iptables-rules)
									 (ipv6-rules %ip6tables-rules)))
						  (service wireguard-service-type
								   %wireguard-configuration)
						  (service syncthing-service-type
								   (syncthing-configuration
									 (user %primary-username)
									 (arguments (list "--no-default-folder"))))
						  (service elogind-service-type
								   (elogind-configuration
									 (handle-lid-switch 'suspend)
									 (handle-lid-switch-docked 'ignore)
									 (handle-lid-switch-external-power 'ignore)
									 (suspend-state '("mem"))))
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
																	%default-authorized-guix-keys))))
									 (sysctl-service-type config =>
														  (sysctl-configuration
															(inherit config)
															(settings (append '(("net.ipv6.conf.all.use_tempaddr" . "2")
																				("net.ipv6.conf.default.use_tempaddr" . "2")
																				("net.ipv6.conf.nic.use_tempaddr" . "2"))))))
									 (mingetty-service-type config =>
															(mingetty-configuration
															  (inherit config)
															  (auto-login %primary-username))))))

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
