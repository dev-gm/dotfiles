(use-modules (guix download)
			 (guix utils)
			 (guix packages)
			 (guix licenses)
			 (guix build-system copy))

(package
  (name "arduino-cli")
  (version "latest")
  (build-system copy-build-system)
  (source (origin
			(uri "https://downloads.arduino.cc/arduino-cli/arduino-cli_latest_Linux_64bit.tar.gz")
			(method url-fetch)
			(sha256
			  (base32
				"0ax4470ff4gdndpcw8k1fci5ncymag7ilagwa6cga226cr19b6lm"))))
  (arguments `(#:install-plan '(("arduino-cli" "/bin/arduino-cli"))))
  (synopsis "arduino-cli")
  (description "arduino-cli")
  (home-page "https://arduino.github.io/arduino-cli")
  (license gpl3))
