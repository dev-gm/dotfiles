(use-modules (guix download)
			 (guix packages)
			 (guix utils)
			 (guix licenses)
			 (gnu packages base)
			 (gnu packages llvm)
			 (gnu packages gl)
			 (guix build-system cmake)
			 (guix build cmake-build-system)
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
  (propagated-inputs (list mesa mesa-headers glibc libcxx))
  (inputs (list coreutils))
  (build-system cmake-build-system)
  (arguments `(#:configure-flags '("-S ../lobster-2023.6/dev")
			   #:phases (modify-phases
						  %standard-phases
						  (delete 'check))))
  (description "Lobster is a programming language that tries to combine the advantages of static typing and compile-time memory management with a very lightweight, friendly and terse syntax, by doing most of the heavy lifting for you.")
  (synopsis "A statically-typed, compile-time memory managed programming language")
  (home-page "https://aardappel.github.io/lobster")
  (license asl2.0))
