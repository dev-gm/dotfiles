(use-modules (gnu)
			 (gnu services)
			 (gnu home)
			 (gnu home services)
			 (gnu home services shells)
			 (gnu home services desktop)
			 (gnu home services guix)
			 (nongnu packages steam-client)
			 (nongnu packages messaging)
			 (nongnu packages fonts)
			 (games packages minecraft)
			 (guix build-system meson)
			 (guix build-system copy)
			 (guix build copy-build-system)
			 (guix build utils)
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

(use-package-modules wm admin xdisorg terminals networking bittorrent syncthing password-utils
					 pciutils package-management fonts ebook vim ocaml gnome pkg-config chromium
					 audio pulseaudio video web-browsers gnome-xyz freedesktop gnome-xyz xorg qt
					 linux vnc vim aidc gtk man pkg-config llvm java commencement base shells)

(define %username "gavin")
(define %email "github@gavinm.us")
(define %name "Gavin Mason")
(define %theme "Materia-dark-compact")
(define %icon-theme "Papirus-Dark")
(define %cursor "McMojave-cursors")
(define %cursor-size 18)
(define %font "Dejavu Sans 11")
(define %dark-theme #t)
(define %opam-feature #t)

(define (home-path path) (string-append "/home/" %username "/" path))

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

(define iwgtk
  (package
	(name "iwgtk")
	(version "0.9")
	(source (origin
			  (uri (string-append "https://github.com/J-Lentz/iwgtk/archive/refs/tags/v" version ".tar.gz"))
			  (method url-fetch)
			  (sha256
				(base32
				  "0c9xb08g83qp75s55nql84zkbhbmx508h52xlqs60lzy633jva44"))))
	(native-inputs (list scdoc pkg-config))
	(inputs (list iwd gtk qrencode))
	(build-system meson-build-system)
	(description "iwgtk is a wireless networking GUI for Linux. It is a front-end for iwd (iNet Wireless Daemon), with supported functionality similar to that of iwctl. Features include viewing and connecting to available networks, managing known networks, provisioning new networks via WPS or Wi-Fi Easy Connect, and an indicator (tray) icon displaying connection status and signal strength.")
	(synopsis "Lightweight wireless networking GUI (front-end for iwd)")
	(home-page "https://github.com/J-Lentz/iwgtk")
	(license gpl3+)))

(define wireguard-tray
  (package
	(name "wireguard-tray")
	(version "0.1")
	(source (origin
			  (uri (git-reference
					 (url "https://github.com/dev-gm/wireguard-tray")
					 (commit "e5399e427c0904233320b290541fc28f18a59961")))
			  (method git-fetch)
			  (sha256
				(base32
				  "08b5xg3yv9xrnqcbxqka5h7dzmjlygvznsvpry1gxs4yl85290jk"))))
	(native-inputs (list pkg-config clang-toolchain))
	(inputs (list libappindicator gtk+))
	(build-system copy-build-system)
	(arguments (list #:phases
					 #~(modify-phases %standard-phases
									  (add-before 'install 'install-new
												 (lambda* (#:key outputs #:allow-other-keys)
														  (system "rm wireguard-tray")
														  (invoke "make")
														  (system (string-append
																	"mkdir -p "
																	(assoc-ref outputs "out")
																	"/bin"))
														  (system (string-append
																	"cp wireguard-tray "
																	(assoc-ref outputs "out")
																	"/bin/wireguard-tray"))))
									  (delete 'install))))
	(description "My wireguard-tray application")
	(synopsis "A wireguard-tray application")
	(home-page "https://github.com/dev-gm/wireguard-tray")
	(license gpl3)))

(define firefox/wayland-114
  (let*
	((channels
	   (list (channel
			   (name 'guix)
			   (url "https://git.savannah.gnu.org/git/guix.git")
			   (branch "master")
			   (commit "10ff8ff4b5655b9f4dbb68535b949bd67c3b8028")
			   (introduction
				 (make-channel-introduction
				   "9edb3f66fd807b096b48283debdcddccfea34bad"
				   (openpgp-fingerprint
					 "BBB0 2DDF 2CEA F6A8 0D1D  E643 A2A0 6DF2 A33A 54FA"))))
			 (channel
			   (name 'nonguix)
			   (url "https://gitlab.com/nonguix/nonguix")
			   (branch "master")
			   (commit "91be26a9d59dbeb6a373b6737797852437463f45")
			   (introduction
				 (make-channel-introduction
				   "897c1a470da759236cc11798f4e0a5f7d4d59fbc"
				   (openpgp-fingerprint
					 "2A39 3FFF 68F4 EF7A 3D29  12AF 6F51 20A0 22FB B2D5"))))))
	 (inferior
	   (inferior-for-channels channels)))
	(first (lookup-inferior-packages inferior "firefox-wayland"))))

(define local-utils
  (package
	(name "local-utils")
	(build-system copy-build-system)
	(source (local-file "utils" #:recursive? #t))
	(arguments `(#:install-plan '(("." "bin"))))
	(version "1.0")
	(synopsis "local utils")
	(description "local utils")
	(home-page "https://github.com/dev-gm/dotfiles")
	(license gpl3)))

(define %packages
  (list font-adobe-source-code-pro font-adobe-source-sans-pro
		font-awesome font-dejavu font-fira-code font-go
		font-google-noto-emoji font-microsoft-web-core-fonts
		papirus-icon-theme McMojave-cursors materia-theme kvantum
		sway bemenu waybar swaylock swaynotificationcenter
		xorg-server-xwayland qtwayland-5
		grimshot clipman wl-clipboard solaar
		iwgtk blueman syncthing-gtk wireguard-tray
		wireplumber pipewire pulseaudio pavucontrol
		prismlauncher steam firefox/wayland-114 qutebrowser
		alacritty vim neovim fish
		obs obs-wlrobs signal-desktop keepassxc
		calibre deluge tigervnc-client baobab
		openjdk17 opam gcc-toolchain clang-toolchain gnu-make
		local-utils flatpak))

(define %bash-profile
  (string-append
(if %opam-feature
  "eval $(opam env)\n"
  "")
"export PATH=\"$PATH:" (home-path ".local/bin") ":"
	(home-path ".go/bin") ":"
	(home-path ".android/sdk/cmdline-tools/latest/bin") ":"
	(home-path ".android/sdk/platform-tools") "\"
if [ \"$(tty)\" = \"/dev/tty1\" ]; then
	dbus-run-session sway
fi"))

(define %bashrc "flashfetch")

(define %gtk2-config
  (string-append
"gtk-theme-name = \"" %theme "\"
gtk-cursor-theme-name = \"" %cursor "\"
gtk-cursor-theme-size = \"" (number->string %cursor-size) "\"
gtk-font-name = \"" %font "\"
gtk-icon-theme-name = \"" %icon-theme "\"
"))

(define %gtk3-and-4-config
  (string-append
"[Settings]
gtk-theme-name = " %theme "
gtk-cursor-theme-name = " %cursor "
gtk-cursor-theme-size = " (number->string %cursor-size) "
gtk-font-name = " %font "
gtk-icon-theme-name = " %icon-theme "
"(if %dark-theme
	"gtk-application-prefer-dark-theme = true\n"
	"")))

(define %qt4-config
  (string-append
"[Qt]
style=" %theme "
"))

(define %env-variables
   `(;("XDG_DATA_DIRS" . ,(home-path ".guix-home/profile/share"))
	 ("XDG_CURRENT_DESKTOP" . "sway")
	 ("XDG_SESSION_TYPE" . "wayland")
	 ("GTK_THEME" . ,%theme)
	 ("QT_SCALE_FACTOR" . "1")
	 ("QT_QPA_PLATFORM" . "wayland")
	 ("QT_STYLE_OVERRIDE" . "kvantum")
	 ("QT_WAYLAND_DISABLE_WINDOWDECORATION" . "1")
	 ("MOZ_ENABLE_WAYLAND" . "1")
	 ("ELM_ENGINE" . "wayland_egl")
	 ("ECORE_EVAS_ENGINE" . "wayland-egl")
	 ("GDK_BACKEND" . "wayland")
	 ("_JAVA_AWT_WM_NONREPARENTING" . "1")
	 ("GOPATH" . ,(home-path ".go"))
	 ("SDKMANAGER" . ,(home-path ".android/sdk/cmdline-tools/latest/bin/sdkmanager"))
	 ("ANDROID_SDK_ROOT" . ,(home-path ".android/sdk"))
	 ("ANDROID_NDK_ROOT" . ,(home-path ".android/sdk/ndk"))))

(define %kvantum-config "theme=MateriaDark")

(define %kvantum-MateriaDark-config-file
  (origin
	(uri "https://raw.githubusercontent.com/PapirusDevelopmentTeam/materia-kde/master/Kvantum/MateriaDark/MateriaDark.kvconfig")
	(method url-fetch)
	(sha256
	  (base32
		"0j1cd5yyah48kvgmz4bry06jhjl3mk2lrg88kh53ybm3vp3p670d"))))

(define %kvantum-MateriaDark-svg-file
  (origin
	(uri "https://raw.githubusercontent.com/PapirusDevelopmentTeam/materia-kde/master/Kvantum/MateriaDark/MateriaDark.svg")
	(method url-fetch)
	(sha256
	  (base32
		"1vaa9x69bm77633h2frix40gdbsnbvqyz2y3lahrmgw6hsj7a6pk"))))

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
	("sway/blobs-d.png" ,(local-file "sway/blobs-d.png"))
	("nvim/init.vim" ,(local-file "nvim/init.vim"))
	("waybar/config" ,(local-file "waybar/config"))
	("waybar/style.css" ,(local-file "waybar/style.css"))
	("alacritty/alacritty.yml" ,(local-file "alacritty/alacritty.yml"))
	("gtk-3.0/settings.ini" ,(plain-file "settings.ini" %gtk3-and-4-config))
	("gtk-4.0/settings.ini" ,(plain-file "settings.ini" %gtk3-and-4-config))
	("Kvantum/kvantum.kvconfig" ,(plain-file "kvantum.kvconfig" %kvantum-config))
	("Kvantum/MateriaDark/MateriaDark.kvconfig" ,%kvantum-MateriaDark-config-file)
	("Kvantum/MateriaDark/MateriaDark.svg" ,%kvantum-MateriaDark-svg-file)
	("Trolltech.conf" ,(plain-file "Trolltech.conf" %qt4-config))
	("solaar/config.json" ,(local-file "solaar/config.json"))
	("syncthing-gtk/config.json" ,(local-file "syncthing-gtk/config.json"))))

(define %home-files
  `((".local/share/nvim/site/autoload/plug.vim" ,%vim-plug-file)
	(".vimrc" ,(local-file "vim/vimrc"))
	(".gitconfig" ,(plain-file "gitconfig" %gitconfig-file))
	(".gtkrc-2.0" ,(plain-file "gtkrc-2.0" %gtk2-config))
	(".arduino15/arduino-cli.yaml" ,(local-file "arduino15/arduino-cli.yaml"))))

(define %extra-channels
  (list (channel
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
				"50F3 3E2E 5B0C 3D90 0424  ABE8 9BDC F497 A4BB CC7F"))))))

(define %services
  (list (service home-bash-service-type
				 (home-bash-configuration
				   (guix-defaults? #t)
				   (bash-profile (list (plain-file "bash-profile" %bash-profile)))
				   (bashrc (list (plain-file "bashrc" %bashrc)))))
		(simple-service 'env-variables-service
						home-environment-variables-service-type
						%env-variables)
		(simple-service 'xdg-config-files-service
						home-xdg-configuration-files-service-type
						%xdg-config-files)
		(simple-service 'home-files-service
						home-files-service-type
						%home-files)
		(simple-service 'extra-channels-service
						home-channels-service-type
						%extra-channels)))

(home-environment
  (packages %packages)
  (services %services))
