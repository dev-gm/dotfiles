(use-modules (guix git-download)
			 (guix packages)
			 (guix utils)
			 (guix licenses)
			 (gnu packages emacs)
			 (guix build utils))

(package
  (inherit emacs-next)
  (version "32b092c14297401ab9aa599c90f64a38a06d5a1f")
  (source (origin
			(method git-fetch)
			(uri "git://git.sv.gnu.org/emacs.git")
			(sha256
			  (base32
				"12144dcaihv2ymfm7g2vnvdl4h71hqnsz1mljzf34cpg6ci1h8gf"))
			(patches (search-patches "emacs-exec-path.patch"
									 "emacs-fix-scheme-indent-function.patch"
									 "emacs-source-date-epoch.patch"))
			(modules '((guix build utils)))
			(snippet
			  '(with-directory-excursion "lisp"
										 ;; Delete the bundled byte-compiled elisp files and generated
										 ;; autoloads.
										 (for-each delete-file
												   (append (find-files "." "\\.elc$")
														   (find-files "." "loaddefs\\.el$")
														   (find-files "eshell" "^esh-groups\\.el$"))

												   ; Make sure Tramp looks for binaries in the right places on
												   ;; remote Guix System machines, where 'getconf PATH' returns
												   ;; something bogus.
												   (substitute* "net/tramp.el"
																;; Patch the line after "(defcustom tramp-remote-path".
																(("\\(tramp-default-remote-path")
																 (format #f "(tramp-default-remote-path ~s ~s ~s ~s "
																		 "~/.guix-profile/bin" "~/.guix-profile/sbin"
																		 "/run/current-system/profile/bin"
																		 "/run/current-system/profile/sbin"))

																; Make sure Man looks for C header files in the right
																;; places.
																(substitute* "man.el"
																			 (("\"/usr/local/include\"" line)
																			  (string-join
																				(list line
																					  "\"~/.guix-profile/include\""
																					  "\"/var/guix/profiles/system/profile/include\"")
																				" "))))))))))
