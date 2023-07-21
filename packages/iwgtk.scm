(use-modules (gnu)
			 (guix download)
			 (guix packages)
			 (guix utils)
			 (guix licenses)
			 (guix build-system meson)
			 (guix build meson-build-system)
			 (guix build utils))

(use-package-modules aidc gtk man networking)

(package
  (name "iwgtk")
  (version "0.9")
  (source (origin
			(uri (string-append "https://github.com/J-Lentz/iwgtk/archive/refs/tags/v" version ".tar.gz"))
			(method url-fetch)
			(sha256
			  (base32
				"1mfa52i50zlwh00pb42qr64jz7v56pim1cp1igjdjrfapvigm5f4"))))
  (native-inputs (list scdoc))
  (inputs (list iwd gtk qrencode))
  (build-system meson-build-system)
  (description "iwgtk is a wireless networking GUI for Linux. It is a front-end for iwd (iNet Wireless Daemon), with supported functionality similar to that of iwctl. Features include viewing and connecting to available networks, managing known networks, provisioning new networks via WPS or Wi-Fi Easy Connect, and an indicator (tray) icon displaying connection status and signal strength.")
  (synopsis "Lightweight wireless networking GUI (front-end for iwd)")
  (home-page "https://github.com/J-Lentz/iwgtk")
  (license gpl3+))
