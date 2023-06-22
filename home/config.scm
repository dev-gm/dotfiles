(use-modules (gnu)
			 (gnu services)
			 (gnu home)
			 (gnu home services)
			 (gnu home services shells)
			 (gnu home services desktop)
			 (gnu home services guix)
			 (nongnu packages mozilla)
			 (nongnu packages steam-client)
			 (nongnu packages fonts)
			 (guix build-system copy)
			 (guix build copy-build-system)
			 (guix utils)
			 (guix packages)
			 (guix channels)
			 (guix licenses)
			 (guix git-download)
			 (guix download)
			 (guix gexp)
			 (guix sets)
			 (guix inferior)
			 (srfi srfi-1))

(use-package-modules wm admin xdisorg terminals networking
					 chromium audio pulseaudio video
					 password-utils pciutils fonts ebook vim
					 emacs gnome-xyz xorg qt linux)

(define %username "gavin")
(define %email "github@gavinm.us")
(define %name "Gavin Mason")
(define %theme "Materia-dark-compact")
(define %cursor "McMojave-cursors")
(define %cursor-size 18)
(define %font "Dejavu Sans 11")
(define %dark-theme #t)
(define %opam-feature #t)

(define McMojave-cursors
  (package
	(name "McMojave-cursors")
	(build-system copy-build-system)
	(source (origin
			  (uri (git-reference
					 (url "https://github.com/vinceliuice/McMojave-cursors.git")
					 (commit "7d0bfc1")))
			  (method git-fetch)
			  (sha256
				(base32
				  "0p8r7rpkgxa4jyv8mxkwyj04z93wr4w00nlzp3nbh0virawr52p1"))))
	(arguments `(#:install-plan '(("dist" "/share/icons/McMojave-cursors"))))
	(version "1.0")
	(synopsis "McMojave cursors")
	(description "McMojave cursors")
	(home-page "https://github.com/vinceliuice/McMojave-cursors")
	(license gpl3)))

;(define firefox/wayland-112.0.2
;  (let*
;	((channels
;	   (list (channel
;			   (name 'nonguix)
;			   (url "https://gitlab.com/nonguix/nonguix")
;			   (branch "master")
;			   (commit "80e245c64551e16cf4472bca08bb444f97b336c0"))
;			 (channel
;			   (name 'guix)
;			   (url "https://git.savannah.gnu.org/git/guix.git")
;			   (branch "master")
;			   (commit "0a164b344d6dabb0dc38f61cc2f4868fa15dec63"))))
;	 (inferior
;	   (inferior-for-channels channels)))
;	(first (lookup-inferior-packages inferior "firefox-wayland"))))

(define %packages
  (list font-adobe-source-code-pro font-adobe-source-sans-pro
		font-awesome font-dejavu font-fira-code font-go
		font-google-noto-emoji font-microsoft-web-core-fonts
		McMojave-cursors materia-theme
		sway bemenu waybar swaylock swaynotificationcenter
		xorg-server-xwayland qtwayland
		grimshot clipman wl-clipboard light solaar
		blueman wireplumber pipewire pulseaudio pavucontrol
		alacritty neovim emacs
		steam ungoogled-chromium
		keepassxc calibre obs))

(define %bash-profile
  (string-append
(if %opam-feature
  "eval $(opam env)\n"
  "")
"export PATH=\"$PATH:/home/" %username "/.local/bin/\"
if [ \"$(tty)\" = \"/dev/tty1\" ]; then
	dbus-run-session sway
fi"))

(define %bashrc "flashfetch")

(define %wayland-env-variables
   `(("XDG_CURRENT_DESKTOP" . "sway")
	 ;("XDG_RUNTIME_DIR" . "/run/user/1000")
	 ("XDG_SESSION_TYPE" . "wayland")
	 ("QT_SCALE_FACTOR" . "1")
	 ;("QT_QPA_PLATFORM" . "wayland")
	 ("QT_WAYLAND_DISABLE_WINDOWDECORATION" . "1")
	 ("MOZ_ENABLE_WAYLAND" . "1")
	 ("ELM_ENGINE" . "wayland_egl")
	 ("ECORE_EVAS_ENGINE" . "wayland-egl")
	 ("GDK_BACKEND" . "wayland")
	 ("_JAVA_AWT_WM_NONREPARENTING" . "1")))

(define %qt5-theme-env-variable
  `(("QT_STYLE_OVERRIDE" . ,%theme)))

(define %gtk2-config
  (string-append
"gtk-theme-name=" %theme "
gtk-cursor-theme-name=" %cursor "
gtk-icon-theme-name=" %theme "
gtk-font-name=\"" %font "\"
"))

(define %gtk3-config
  (string-append
"[Settings]
gtk-theme-name=" %theme "
gtk-cursor-theme-name=" %cursor "
gtk-cursor-theme-size=" (number->string %cursor-size) "
gtk-icon-theme-name=" %theme "
gtk-font-name=" %font "
"(if %dark-theme
	"gtk-application-prefer-dark-theme=true\n"
	"")))

(define %qt4-config
  (string-append
"[Qt]
style=" %theme "
"))

(define %vim-plug-file
  (origin
	(uri "https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim")
	(method url-fetch)
	(sha256
	  (base32
		"1vcx8cn8y9v5zrl63par0w22pv0kk3c7avpwc7ca77qsr2p0nz5r"))))

(define %gitconfig-file
  (string-append
"[user]
	email=" %email "
	name=" %name "
[init]
	defaultBranch=main
"))

(define %xdg-config-files
  `(("sway/config" ,(local-file "sway/config"))
	("sway/blobs-d.svg" ,(local-file "sway/blobs-d.svg"))
	;("emacs/init.el" ,(local-file "emacs/init.el"))
	("nvim/init.vim" ,(local-file "nvim/init.vim"))
	("waybar/config" ,(local-file "waybar/config"))
	("waybar/style.css" ,(local-file "waybar/style.css"))
	("alacritty/alacritty.yml" ,(local-file "alacritty/alacritty.yml"))
	("gtk-3.0/settings.ini" ,(plain-file "settings.ini" %gtk3-config))
	("Trolltech.conf" ,(plain-file "Trolltech.conf" %qt4-config))))

(define %home-files
  `((".local/share/nvim/site/autoload/plug.vim" ,%vim-plug-file)
	;(".local/bin/flashfetch" ,(local-file "bin/flashfetch"))
	;(".local/bin/get-wattage" ,(local-file "bin/get-wattage"))
	(".vimrc" ,(local-file "vim/vimrc"))
	(".gitconfig" ,(plain-file "gitconfig" %gitconfig-file))
	(".gtkrc-2.0" ,(plain-file "gtkrc-2.0" %gtk2-config))))

(define %services
  (list
    (service home-bash-service-type
	     (home-bash-configuration
	       (guix-defaults? #t)
	       (bash-profile (list (plain-file "bash-profile" %bash-profile)))
		   (bashrc (list (plain-file "bashrc" %bashrc)))))
	(simple-service 'wayland-env-variables-service
					home-environment-variables-service-type
					%wayland-env-variables)
	(simple-service 'qt5-theme-env-variable-service
					home-environment-variables-service-type
					%qt5-theme-env-variable)
	(simple-service 'xdg-config-files-service
					home-xdg-configuration-files-service-type
					%xdg-config-files)
	(simple-service 'home-files-service
					home-files-service-type
					%home-files)
	(simple-service 'new-channels-service
					home-channels-service-type
					(append (list
							  (channel
								(name 'nonguix)
								(url "https://gitlab.com/nonguix/nonguix.git")
								(introduction
								  (make-channel-introduction
									"897c1a470da759236cc11798f4e0a5f7d4d59fbc"
									(openpgp-fingerprint
									  "2A39 3FFF 68F4 EF7A 3D29  12AF 6F51 20A0 22FB B2D5"))))
							  (channel
								(name 'guix-gaming-games)
								(url "https://gitlab.com/guix-gaming-channels/games.git")
								(introduction
								  (make-channel-introduction
									"c23d64f1b8cc086659f8781b27ab6c7314c5cca5"
									(openpgp-fingerprint
									  "50F3 3E2E 5B0C 3D90 0424  ABE8 9BDC F497 A4BB CC7F")))))
							%default-channels))))

(home-environment
  (packages %packages)
  (services %services))
