(use-modules (guix download)
			 (guix packages)
			 (guix utils)
			 (guix licenses)
			 (guix build-system copy)
			 (guix build copy-build-system))

(define* (font-tlwg-template type full-type hash #:optional (fontconfig #t))
	(package
	  (name (string-append "font-tlwg-" type))
	  (version "0.7.3")
	  (build-system copy-build-system)
	  (source (origin
				(uri (string-append "https://github.com/tlwg/fonts-tlwg/releases/download/v" version "/" type "-tlwg-" version ".tar.xz"))
				(method url-fetch)
				(sha256
				  (base32
					hash))))
	  (arguments `(#:install-plan
					   ,(append
						 `(("." ,(string-append "/share/fonts/" full-type) #:exclude ("fontconfig")))
						 (if fontconfig
						   '(("fontconfig/conf.avail" "/share/fontconfig/conf.avail"))
						   '()))))
	  (description "Fonts-TLWG is a collection of Thai scalable fonts available under free licenses. Its goal is to provide fonts that conform to existing standards and recommendations, so that it can be a reference implementation.")
	  (synopsis "A collection of Thai scalable fonts")
	  (home-page "https://linux.thai.net/projects/fonts-tlwg")
	  (license gpl2)))
	
(define (font-tlwg-template-fontconfig type full-type hash)
	(package
	  (name (string-append "font-tlwg-" type))
	  (version "0.7.3")
	  (build-system copy-build-system)
	  (source (origin
				(uri (string-append "https://github.com/tlwg/fonts-tlwg/releases/download/v" version "/" type "-tlwg-" version ".tar.xz"))
				(method url-fetch)
				(sha256
				  (base32
					hash))))
	  (arguments `(#:install-plan
				   '(`("." ,(string-append "/share/fonts/" full-type) #:exclude-regexp `("fontconfig" "Waree.*"))
					("fontconfig" "/share/fontconfig"))))
	  (description "Fonts-TLWG is a collection of Thai scalable fonts available under free licenses. Its goal is to provide fonts that conform to existing standards and recommendations, so that it can be a reference implementation.")
	  (synopsis "A collection of Thai scalable fonts")
	  (home-page "https://linux.thai.net/projects/fonts-tlwg")
	  (license gpl2)))

(define* (font-tlwg-template-no-fontconfig type full-type hash)
	(package
	  (name (string-append "font-tlwg-" type))
	  (version "0.7.3")
	  (build-system copy-build-system)
	  (source (origin
				(uri (string-append "https://github.com/tlwg/fonts-tlwg/releases/download/v" version "/" type "-tlwg-" version ".tar.xz"))
				(method url-fetch)
				(sha256
				  (base32
					hash))))
	  (arguments `(#:install-plan
				   (("." ,(string-append "/share/fonts/" full-type) #:exclude-regexp ("Waree.*")))))
	  (description "Fonts-TLWG is a collection of Thai scalable fonts available under free licenses. Its goal is to provide fonts that conform to existing standards and recommendations, so that it can be a reference implementation.")
	  (synopsis "A collection of Thai scalable fonts")
	  (home-page "https://linux.thai.net/projects/fonts-tlwg")
	  (license gpl2)))

(define font-tlwg-ttf (font-tlwg-template-fontconfig "ttf" "truetype" "1473v0b8x51r68w4009mvcg6pbl9qbindcm633i1gxz468rjl19l"))

(define font-tlwg-otf (font-tlwg-template-fontconfig "otf" "opentype" "1q2fzcc72fwx9kf81dbp98rvmizd6hak0jzw8ijik8ak1pqmncds"))

(define font-tlwg-woff (font-tlwg-template-no-fontconfig "woff" "web" "0g7psl75pljcxwr4l2b0yq6bbbgsyvz02lws49pz2147k8vlnhzg"))

(package
  (inherit font-tlwg-ttf)
  (name "font-tlwg")
  (propagated-inputs (list font-tlwg-otf font-tlwg-woff)))

