(use-modules (guix git-download)
			 (guix utils)
			 (guix packages)
			 (guix licenses)
			 (guix build-system copy))

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

