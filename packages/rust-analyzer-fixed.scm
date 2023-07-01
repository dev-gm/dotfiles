(use-modules (guix git-download)
			 (guix utils)
			 (guix packages)
			 (guix licenses)
			 (guix build cargo-build-system)
			 (guix build-system cargo)
			 (gnu packages rust)
			 (gnu packages crates-io)
			 (gnu packages rust-apps))

(define rust-analyzer-fixed
  (package
	(name "rust-analyzer-fixed")
	(version "21fc83c")
	(source
	  (origin
		;; The crate at "crates.io" is empty.
		(method git-fetch)
		(uri (git-reference
			   (url "https://github.com/dev-gm/rust-analyzer-guix.git")
			   (commit version)))
		(file-name (git-file-name name version))
		(sha256
		  (base32
			"0xak6k477fqqcaw3sa3cgkj8mijr650wkpn5mb5sysgx49sakdz7"))))
	(build-system cargo-build-system)
	(arguments
	  `(#:install-source? #f             ; virtual manifest
		#:cargo-test-flags
		'("--release" "--"
		  "--skip=tests::test_version_check" ;it need rustc's version
		  ;; FIXME: Guix's rust does not install source in
		  ;; %out/lib/rustlib/src/rust so "can't load standard library from
		  ;; sysroot"
		  "--skip=tests::test_loading_rust_analyzer"
		  ;; Failed to run rustfmt from toolchain 'stable'.  Please run `rustup
		  ;; component add rustfmt --toolchain stable` to install it
		  "--skip=tests::sourcegen::sourcegen_assists_docs" ;need rustfmt
		  "--skip=tests::sourcegen_ast::sourcegen_ast"      ;sam

		  --skip=tidy::cargo_files_are_tidy"    ;not needed
		  "--skip=tidy::check_licenses"          ;it runs cargo metadata
		  "--skip=tidy::check_merge_commits"     ;it runs git rev-list
		  "--skip=tidy::check_code_formatting"   ;need rustfmt as cargo fmt
		  "--skip=tidy::generate_grammar"        ;same
		  "--skip=tidy::generate_assists_tests") ;same
		#:cargo-development-inputs
		(("rust-arbitrary" ,rust-arbitrary-1)
		 ("rust-derive-arbitrary" ,rust-derive-arbitrary-1)
		 ("rust-expect-test" ,rust-expect-test-1)
		 ("rust-oorandom" ,rust-oorandom-11.1)
		 ("rust-quote" ,rust-quote-1)
		 ("rust-rayon" ,rust-rayon-1)
		 ("rust-tracing" ,rust-tracing-0.1)
		 ("rust-tracing-subscriber" ,rust-tracing-subscriber-0.3)
		 ("rust-tracing-tree" ,rust-tracing-tree-0.2)
		 ("rust-ungrammar" ,rust-ungrammar-1))
		#:cargo-inputs
		(("rust-always-assert" ,rust-always-assert-0.1)
		 ("rust-anyhow" ,rust-anyhow-1)
		 ("rust-anymap" ,rust-anymap-0.12)
		 ("rust-arrayvec" ,rust-arrayvec-0.7)
		 ("rust-backtrace" ,rust-backtrace-0.3)
		 ("rust-cargo-metadata" ,rust-cargo-metadata-0.14)
		 ("rust-cfg-if" ,rust-cfg-if-1)
		 ("rust-chalk-ir" ,rust-chalk-ir-0.75)
		 ("rust-chalk-recursive" ,rust-chalk-recursive-0.75)
		 ("rust-chalk-solve" ,rust-chalk-solve-0.75)
		 ("rust-countme" ,rust-countme-3)
		 ("rust-cov-mark" ,rust-cov-mark-2)
		 ("rust-crossbeam-channel" ,rust-crossbeam-channel-0.5)
		 ("rust-dashmap" ,rust-dashmap-4)
		 ("rust-dissimilar" ,rust-dissimilar-1)
		 ("rust-dot" ,rust-dot-0.1)
		 ("rust-drop-bomb" ,rust-drop-bomb-0.1)
		 ("rust-either" ,rust-either-1)
		 ("rust-ena" ,rust-ena-0.14)
		 ("rust-env-logger" ,rust-env-logger-0.8)
		 ("rust-flate2" ,rust-flate2-1)
		 ("rust-fst" ,rust-fst-0.4)
		 ("rust-home" ,rust-home-0.5)
		 ("rust-indexmap" ,rust-indexmap-1)
		 ("rust-itertools" ,rust-itertools-0.10)
		 ("rust-jod-thread" ,rust-jod-thread-0.1)
		 ("rust-libc" ,rust-libc-0.2)
		 ("rust-libloading" ,rust-libloading-0.7)
		 ("rust-log" ,rust-log-0.4)
		 ("rust-lsp-server" ,rust-lsp-server-0.5)
		 ("rust-lsp-types" ,rust-lsp-types-0.91)
		 ("rust-memmap2" ,rust-memmap2-0.5)
		 ("rust-mimalloc" ,rust-mimalloc-0.1)
		 ("rust-miow" ,rust-miow-0.4)
		 ("rust-notify" ,rust-notify-5)
		 ("rust-object" ,rust-object-0.28)
		 ("rust-once-cell" ,rust-once-cell-1)
		 ("rust-parking-lot" ,rust-parking-lot-0.11)
		 ("rust-perf-event" ,rust-perf-event-0.4)
		 ("rust-proc-macro2" ,rust-proc-macro2-1)
		 ("rust-pulldown-cmark" ,rust-pulldown-cmark-0.8)
		 ("rust-pulldown-cmark-to-cmark" ,rust-pulldown-cmark-to-cmark-7)
		 ("rust-rowan" ,rust-rowan-0.15)
		 ("rust-rustc-ap-rustc-lexer" ,rust-rustc-ap-rustc-lexer-725)
		 ("rust-rustc-hash" ,rust-rustc-hash-1)
		 ("rust-salsa" ,rust-salsa-0.17)
		 ("rust-scoped-tls" ,rust-scoped-tls-1)
		 ("rust-serde" ,rust-serde-1)
		 ("rust-serde-json" ,rust-serde-json-1)
		 ("rust-serde-path-to-error" ,rust-serde-path-to-error-0.1)
		 ("rust-typed-arena" ,rust-typed-arena-2)
		 ("rust-smallvec" ,rust-smallvec-1)
		 ("rust-smol-str" ,rust-smol-str-0.1)
		 ("rust-snap" ,rust-snap-1)
		 ("rust-text-size" ,rust-text-size-1)
		 ("rust-threadpool" ,rust-threadpool-1)
		 ("rust-tikv-jemalloc-ctl" ,rust-tikv-jemalloc-ctl-0.4)
		 ("rust-tikv-jemallocator" ,rust-tikv-jemallocator-0.4)
		 ("rust-url" ,rust-url-2)
		 ("rust-walkdir" ,rust-walkdir-2)
		 ("rust-winapi" ,rust-winapi-0.3)
		 ("rust-write-json" ,rust-write-json-0.1)
		 ("rust-xflags" ,rust-xflags-0.2)
		 ("rust-xshell" ,rust-xshell-0.1))
		#:phases
		(modify-phases %standard-phases
					   (add-before 'check 'fix-tests
								   (lambda _
									 (let ((bash (string-append "#!" (which "bash"))))
									   (with-directory-excursion "crates/parser/test_data/lexer/ok"
																 (substitute* "single_line_comments.txt"
																			  (("SHEBANG 19")
																			   (string-append "SHEBANG "
																							  (number->string (string-length bash))))
																			  (("#!/usr/bin/env bash") bash))))))
					   (add-before 'install 'install-doc
								   (lambda* (#:key outputs #:allow-other-keys)
											(let* ((out (assoc-ref outputs "out"))
												   (doc (string-append out "/share/doc/rust-analyzer-"
																	   ,version)))
											  (copy-recursively "docs" doc))))
					   (add-before 'install 'chdir
								   (lambda _
									 (chdir "crates/rust-analyzer")))
					   (add-after 'install 'wrap-program
								  (lambda* (#:key inputs outputs #:allow-other-keys)
										   (let* ((out (assoc-ref outputs "out"))
												  (bin (string-append out "/bin"))
												  (rust-src-path (search-input-directory
																   inputs "/lib/rustlib/src/rust/library")))
											 ;; if environment variable RUST_SRC_PATH is not set, set it,
											 ;; make rust-analyzer work out of box.
											 (with-directory-excursion bin
																	   (let* ((prog "rust-analyzer")
																			  (wrapped-file (string-append (dirname prog)
																										   "/." (basename prog) "-real"))
																			  (prog-tmp (string-append wrapped-file "-tmp")))
																		 (link prog wrapped-file)
																		 (call-with-output-file prog-tmp
																								(lambda (port)
																								  (format port "#!~a
																										  if test -z \"${RUST_SRC_PATH}\";then export RUST_SRC_PATH=~S;fi;
																										  exec -a \"$0\" \"~a\" \"$@\""
																										  (which "bash")
																										  rust-src-path
																										  (canonicalize-path wrapped-file))))
																		 (chmod prog-tmp #o755)
																		 (rename-file prog-tmp prog))))))
					   (replace 'install-license-files
								(lambda* (#:key outputs #:allow-other-keys)
										 (let* ((out (assoc-ref outputs "out"))
												(doc (string-append out "/share/doc/rust-analyzer-"
																	,version)))
										   (chdir "../..")
										   (install-file "LICENSE-MIT" doc)
										   (install-file "LICENSE-APACHE" doc))))
					   (delete 'check))))
	(native-inputs (list rust-src))
	(home-page "https://rust-analyzer.github.io/")
	(synopsis "Experimental Rust compiler front-end for IDEs")
	(description "Rust-analyzer is a modular compiler frontend for the Rust
				 language.  It is a part of a larger rls-2.0 effort to create excellent IDE
				 support for Rust.")
				 (license (list expat asl2.0)))
