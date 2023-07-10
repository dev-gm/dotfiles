(use-modules (gnu packages java)
			 (gnu packages bash)
			 (gnu packages compression)
			 (guix download)
			 (guix utils)
			 (guix packages)
			 (guix licenses)
			 (guix build-system copy))

(package
  (name "Digital")
  (version "0.30")
  (source (origin
			(uri (string-append "https://github.com/hneemann/Digital/releases/download/v" version "/Digital.zip"))
			(method url-fetch)
			(sha256
			  (base32
				"0xj4fcahanyb6jazgw60qqbnbl4ajbh5hai5fdwrkdsxr6w81dqp"))))
  (build-system copy-build-system)
  (native-inputs (list unzip))
  (inputs (list bash))
  (propagated-inputs (list openjdk12))
  (arguments `(#:install-plan '(("Digital.sh" "bin/Digital"))))
  (synopsis "A digital logic designer and circuit simulator.")
  (description "Digital is an easy-to-use digital logic designer and circuit simulator designed for educational purposes.")
  (home-page "https://github.com/hneemann/Digital")
  (license gpl3))
