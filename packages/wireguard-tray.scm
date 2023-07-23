(use-modules (gnu)
			 (guix git-download)
			 (guix packages)
			 (guix utils)
			 (guix gexp)
			 (guix licenses)
			 (guix build-system copy)
			 (guix build copy-build-system)
			 (guix build utils))

(use-package-modules freedesktop gtk pkg-config llvm base)

(package
  (name "wireguard-tray")
  (version "e5399e427c0904233320b290541fc28f18a59961")
  (source (origin
			(uri (git-reference
				   (url "https://github.com/dev-gm/wireguard-tray")
				   (commit version)))
			(method git-fetch)
			(sha256
			  (base32
				"0innkq1ildy1qzb5y4h2a3maq1jhccrnflr6ciagm874qwlh2c23"))))
  (build-system copy-build-system)
  (inputs (list libappindicator gtk+ pkg-config clang-toolchain coreutils gnu-make))
  (arguments (list #:phases
				   #~(modify-phases
					   %standard-phases
					   (add-before 'install 'build
								   (lambda* (#:key inputs #:allow-other-keys)
											(invoke (string-append (assoc-ref inputs "make") "/bin/make"))))
					   (delete 'install)
					   (add-after 'build 'install
								  (lambda* (#:key outputs #:allow-other-keys)
										   (let ((out-dir (assoc-ref outputs "out")))
											 (mkdir out-dir)
											 (mkdir (string-append out-dir "/bin"))
											 (copy-file "main" (string-append out-dir "/bin/wireguard-tray"))))))))
  (description "A very basic appindicator program for Linux to display a wireguard tray. Note: Only compatible with my specific Guix configuration.")
  (synopsis "A very basic appindicator program for Linux to display a wireguard tray.")
  (home-page "https://github.com/dev-gm/wireguard-tray")
  (license gpl3))
