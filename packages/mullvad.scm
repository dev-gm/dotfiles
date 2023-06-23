(use-modules (guix git-download)
			 (guix packages)
			 (guix utils)
			 ((guix licenses) #: license:)
			 (gnu packages golang)
			 (gnu packages node)
			 (gnu packages protobuf)
			 (guix build-system cargo)
			 (guix build cargo-build-system)
			 (guix build utils))

(package
  (name "lobster")
  (version "v2023.6")
  (source (origin
			(uri (string-append "https://github.com/aardappel/lobster/archive/refs/tags/" version ".tar.gz"))
			(method url-fetch)
			(sha256
			  (base32
				"1mfa52i50zlwh00pb42qr64jz7v56pim1cp1igjdjrfapvigm5f4"))))
  (native-inputs (list go protobuf node))
  (inputs (list coreutils))
  (build-system cargo-build-system)
  (description "Mullvad VPN App")
  (synopsis "A VPN App")
  (home-page "https://aardappel.github.io/lobster")
  (license license:gpl3))
