(use-modules (guix download)
			 (guix packages)
			 (guix utils)
			 (guix licenses)
			 (guix gexp)
			 (gnu packages)
			 (gnu packages base)
			 (gnu packages linux)
			 (gnu packages cpio)
			 (gnu packages compression))

(define (make-linux-clear version revision)
  (package
	(inherit
	  (customize-linux
		#:name "linux-clear"
		#:source (origin
				   (uri (string-append "https://github.com/clearlinux-pkgs/linux/archive/refs/tags/" version "-" revision ".tar.gz")))))
	(version version)
	(home-page "https://clearlinux.org/")
	(synopsis "A custom kernel that offers highly optimized performance, security, versatility, and manageability")
	(description "Clear Linux OS is an open source, rolling release Linux distribution optimized for performance and security, from the Cloud to the Edge, designed for customization, and manageability.")))

(make-linux-clear "6.4.2" "1331")
