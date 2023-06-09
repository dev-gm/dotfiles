(use-modules (guix packages)
			 (guix download)
			 (guix git-download)
			 (guix licenses)
			 (guix build-system trivial)
			 (guix build-system gnu)
			 (guix build gnu-build-system)
			 (guix build utils)
			 (guix gexp)
			 (guix derivations)
			 (gnu packages version-control)
			 (gnu packages commencement)
			 (gnu packages llvm)
			 ;(gnu packages c)
			 (gnu packages base))

(define vlang-vc
  (package
	(name "vlang-vc")
	(version "0.3.4")
	(source
	  (origin
		(method url-fetch)
		(uri "https://raw.githubusercontent.com/dev-gm/vc/master/v.c")
		(sha256
		  (base32
			"1bqkyg2ghc3vv3k7fc91l9g3ny5v89fwv3xy109kc3p6g530q46m"))))
	(build-system trivial-build-system)
	(native-inputs (list coreutils findutils))
	(arguments (list #:builder
					 #~(system* (string-append #+findutils "/bin/find") "/gnu/store" "-maxdepth" "1" "-regextype" "posix-basic" "-regex" ".*-v\\.c" "-exec" (string-append #+coreutils "/bin/cp") "{}" #$output ";")))
	(synopsis "Helps build vlang")
	(description "Helps build vlang")
	(home-page "https://github.com/vlang/vc")
	(license expat)))

(define %Makefile-patch
"--- Makefile	2023-06-09 17:20:27.058386893 -0400
+++ Makefile	2023-06-09 18:00:56.543451955 -0400
@@ -3,20 +3,18 @@
 CFLAGS ?=
 LDFLAGS ?=
   
-.PHONY: all check download_vc v
+.PHONY: all v install
   
-all: download_vc v
-
-download_vc:
-	if [ -f vc/v.c ] ; then git -C vc/ pull; else git clone --filter=blob:none https://github.com/vlang/vc vc/; fi
+all: v

 v:
-	$(CC) $(CFLAGS) -std=gnu11 -w -o v1 vc/v.c -lm -lexecinfo -lpthread $(LDFLAGS)
+	$(CC) $(CFLAGS) -std=gnu11 -w -o v1 vc/v.c -lm -lpthread $(LDFLAGS)
 	./v1 -no-parallel -o v2 $(VFLAGS) cmd/v
	./v2 -o v $(VFLAGS) cmd/v
 	rm -rf v1 v2
 	@echo \"V has been successfully built\"
 	./v run ./cmd/tools/detect_tcc.v

-check:
-	./v test-all
+install:
+	cp ./v /bin/v
+
")

(package
  (name "vlang")
  (version "0.3.4")
  (source
	(origin
	  (method git-fetch)
	  (uri (git-reference
			 (url "https://github.com/vlang/v")
			 (commit version)))
	  (sha256
		(base32
		  "1rqa17v6gi4brqw6gbdfp6rsgrg8hwdzj8sqq7b132wav7xmnhr4"))))
  (build-system gnu-build-system)
  (native-inputs (list git))
  (inputs (list clang-toolchain vlang-vc))
  (propagated-inputs (list libcxx)) ;tcc))
  (arguments (list #:phases #~(modify-phases
								%standard-phases
								(add-before 'build 'prepare
											(lambda _
											  ;(invoke "find" "/gnu/store" "-maxdepth" "1" "-regextype" "posix-basic" "-regex" ".*-tcc-0\\.9\\.27-1\\.a83b285" "-exec" "cp" "-r" "{}" "./thirdparty/tcc" ";")
											  (invoke "mkdir" "home")
											  (putenv "HOME=/tmp/guix-build-vlang-0.3.4.drv-0/source/home")
											  (invoke "sh" "-c" (string-append "echo '" #$%Makefile-patch "' > cc-gcc.patch"))
											  (invoke "sh" "-c" "patch < cc-gcc.patch")
											  (invoke "rm" "GNUmakefile")
											  (invoke "mkdir" "vc")
											  (invoke "find" "/gnu/store" "-maxdepth" "1" "-regextype" "posix-basic" "-regex" ".*-vlang-vc-0\\.3\\.4" "-exec" "cp" "{}" "vc/v.c" ";")))
								(delete 'check)
								(delete 'configure))))
  (synopsis "Compiler for the V programming language")
  (description "V is a systems programming language. It provides memory safety and thread safety guarantees with minimal abstraction.")
  (home-page "https://vlang.io/")
  (license expat))
