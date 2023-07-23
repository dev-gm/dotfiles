(use-modules (gnu)
			 (guix git-download)
			 (guix packages)
			 (guix utils)
			 (nonguix licenses)
			 (guix build copy-build-system)
			 (guix build-system copy)
			 (guix build utils))

(use-package-modules base freedesktop gtk golang)

(package
  (name "Wireguard-Bravo")
  (version "f1b58d1e80b77815ae6abd75de64b9ab9636d274")
  (source (origin
			(uri (git-reference
				   (url "https://github.com/metalcated/Wireguard-Bravo.git")
				   (commit "f1b58d1e80b77815ae6abd75de64b9ab9636d274")))
			(method git-fetch)
			(sha256
			  (base32
				"1ikkh19m46yd6g6qnpzw2q1ams1mjaj2yrgsqjqiw32lrjl4zs7q"))))
  (native-inputs (list go))
  (inputs (list libappindicator gtk+))
  (arguments (list #:phases
				   #~(modify-phases
					   %standard-phases
					   (delete 'build)
					   (add-after 'patch-source-shebangs 'build
								  (lambda* (#:key inputs #:allow-other-keys)
										   (invoke "ls")
										   (invoke (string-append (assoc-ref inputs "make") "/bin/make") "build")))
					   (delete 'install)
					   (add-after 'build 'install
								  (lambda* (#:key outputs #:allow-other-keys)
										   (copy-file "bravo" (string-append (assoc-ref outputs "out") "/bin/bravo")))))))
  (build-system copy-build-system)
  (description "WireGuard system tray GUI")
  (synopsis "WireGuard system tray GUI")
  (home-page "https://github.com/metalcated/Wireguard-Bravo")
  (license (nonfree "file://LICENSE")))
