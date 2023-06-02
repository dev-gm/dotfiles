(use-modules (gnu services)
			 (gnu home)
			 (gnu home services)
			 (gnu home services shells)
			 (gnu home services desktop)
			 (gnu home services guix)
			 (gnu packages wm)
			 (gnu packages admin)
			 (gnu packages xdisorg)
			 (gnu packages terminals)
			 (gnu packages networking)
			 (gnu packages web-browsers)
			 (gnu packages audio)
			 (gnu packages pulseaudio)
			 (gnu packages video)
			 (gnu packages password-utils)
			 (gnu packages pciutils)
			 (gnu packages fonts)
			 (gnu packages ebook)
			 (gnu packages vim)
			 (gnu packages emacs)
			 (gnu packages gnome-xyz)
			 (gnu packages linux)
			 (nongnu packages mozilla)
			 (nongnu packages steam-client)
			 (nongnu packages messaging)
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
			 (guix sets))

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

(define %packages
  (list font-microsoft-andale-mono
	font-microsoft-arial
	font-microsoft-arial-black
	font-microsoft-courier-new
	font-microsoft-georgia
	font-microsoft-impact
	font-microsoft-trebuchet-ms
	font-microsoft-times-new-roman
	font-microsoft-verdana
	font-microsoft-webdings
	font-google-noto-emoji
	font-dejavu
	font-adobe-source-code-pro
	font-adobe-source-sans-pro
	font-awesome
	font-go
	font-fira-code
	swaynotificationcenter
	alacritty
	pipewire
	wireplumber
	blueman
	swaylock
	solaar
	qutebrowser
	firefox/wayland
	steam
	clipman
	wl-clipboard
	pavucontrol
	sway
	waybar
	neovim
	emacs
	obs
	keepassxc
	grimshot
	calibre
	materia-theme
	McMojave-cursors
	bemenu
	light
	pulseaudio))

(define %username "gavin")
(define %email "github@gavinm.us")
(define %name "Gavin Mason")
(define %theme "Materia-dark-compact")
(define %cursor "McMojave-cursors")
(define %cursor-size 18)
(define %font "Dejavu Sans 11")
(define %dark-theme #t)

(define %bash-profile
  (string-append
"PATH=\"$PATH:/home/" %username "/.local/bin/\"
if [[ -z $DISPLAY ]] && [[ $(tty) = /dev/tty1 ]]; then
	exec dbus-run-session sway
fi"))

(define %bashrc "flashfetch")

(define %wayland-env-variables
   `(("XDG_CURRENT_DESKTOP" . "sway")
 	("XDG_SESSION_TYPE" . "wayland")
 	("MOZ_ENABLE_WAYLAND" . "1")
 	("ELM_ENGINE" . "wayland_egl")
 	("ECORE_EVAS_ENGINE" . "wayland-egl")
 	;("GDK_BACKEND" . "wayland")
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
gtk-font-name=" %font
(if %dark-theme
	"gtk-application-prefer-dark-theme=true"
"") "
"))

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
	(simple-service 'nonguix-channel-service
					home-channels-service-type
					(list
					  (channel
						(name 'nonguix)
						(url "https://gitlab.com/nonguix/nonguix"))))))

(home-environment
  (packages %packages)
  (services %services))

