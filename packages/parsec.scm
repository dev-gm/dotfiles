(use-modules (nonguix licenses)
			 (guix licenses)
			 (guix packages)
			 (guix download)
			 (guix build utils)
			 (guix build copy-build-system)
			 (guix gexp)
			 (guix build-system copy)
			 (guix build-system gnu)
			 (gnu packages commencement)
			 (gnu packages debian)
			 (gnu packages base)
			 (gnu packages elf)
			 (gnu packages llvm)
			 (gnu packages autotools))

;(define chrpath
;			   (package
;				 (name "chrpath")
;				 (version "0.16")
;				 (source (origin
;						   (method url-fetch)
;						   (uri (string-append "https://deb.debian.org/debian/pool/main/c/chrpath/chrpath_" version ".orig.tar.gz"))
;						   (sha256
;							 (base32
;							   "0yvfq891mcdkf8g18gjjkn2m5rvs8z4z4cl1vwdhx6f2p9a4q3dv"))
;						   (modules '((guix build utils)))
;						   (snippet
;							 ;; Remove generated Autotools files -- they are generated
;							 ;; and additionally don't support new architectures.
;							 '(for-each delete-file
;										(find-files "." "\\b(configure|config\\.sub|config.guess|Makefile\\.in|missing|depcomp|config\\.h\\.in|aclocal\\.m4|install-sh)$")))))
;				 (build-system gnu-build-system)
;				 (native-inputs (list autoconf automake))
;				 (home-page "https://tracker.debian.org/pkg/chrpath")
;				 (synopsis "Tool to edit the rpath of ELF binaries")
;				 (description "@code{chrpath} allows you to modify the dynamic library load path (rpath and runpath) of compiled programs and libraries")
;				 (license gpl1+)))
;
;(define elf_rpath
;			   (package
;				 (name "elf_rpath")
;				 (version "0")
;				 (source (origin
;						   (method url-fetch)
;						   (uri (string-append "https://raw.githubusercontent.com/antonio-pgarcia/elf-runpath/master/elf_rpath.c"))
;						   (sha256
;							 (base32
;							   "0rx3dcqc76ylm7i4y0ypddbbm9n3kzhhmvsjwgmrazl1b2x6wy2i"))))
;				 (build-system copy-build-system)
;				 (native-inputs (list gcc-toolchain))
;				 (inputs (list libelf))
;				 (arguments `(#:phases (modify-phases %standard-phases
;													  (add-after 'unpack 'build
;															   (lambda* (#:key inputs #:allow-other-keys)
;																 (let ((gcc (string-append (assoc-ref inputs "gcc-toolchain") "/bin/gcc")))
;																   (invoke gcc "elf_rpath.c" "-oelf_rpath" "-lelf")))))
;							  #:install-plan '(("elf_rpath" "bin/elf_rpath"))))
;				 (home-page "https://github.com/antonio-pgarcia/elf-runpath")
;				 (synopsis "Tool to edit the rpath of ELF binaries")
;				 (description "@code{chrpath} allows you to modify the dynamic library load path (rpath and runpath) of compiled programs and libraries")
;				 (license gpl1+)))

(package
  (name "parsec")
  (version "0")
  (source (origin
			(uri "https://builds.parsec.app/package/parsec-linux.deb")
			(method url-fetch)
			(sha256
			  (base32
				"1rgam27g8zhli9278k8nrqdpj9z3fqld7f16ys3pdb6xlkrp4063"))))
  (build-system copy-build-system)
  (arguments
	`(#:install-plan
	  '(("usr/bin/" "bin")
		("usr/share/" "share"))
	  #:phases
	  (modify-phases %standard-phases
					 (replace 'unpack
							  (lambda* (#:key inputs source #:allow-other-keys)
									   (let ((dpkg (string-append (assoc-ref inputs "dpkg")
																  "/bin/dpkg")))
										 (invoke dpkg "-x" source "."))))
					 (add-after 'unpack 'set-rpath
							  (lambda* (#:key inputs #:allow-other-keys)
									   (let ((patchelf (string-append (assoc-ref inputs "patchelf") "/bin/patchelf"))
											 (glibc (assoc-ref inputs "glibc")))
										 (invoke patchelf "--set-rpath" (string-append glibc "/lib:") "usr/bin/parsecd")
										 (invoke patchelf "--set-interpreter" (string-append glibc "/lib/ld-linux-x86-64.so.2") "usr/bin/parsecd")))))))
  (native-inputs (list dpkg patchelf))
  (inputs (list glibc))
  (supported-systems '("x86_64-linux"))
  (home-page "https://parsec.app/")
  (synopsis "parsec")
  (description "Parsec")
  (license (nonfree "https://unity.com/legal/parsec-additional-terms")))
