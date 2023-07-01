(use-modules (guix git-download)
			 (guix packages)
			 (guix utils)
			 (guix gexp)
			 ((guix licenses) #:prefix license:)
			 (gnu packages commencement)
			 (gnu packages ninja)
			 (gnu packages version-control)
			 (gnu packages cpp)
			 (gnu packages compression)
			 (gnu packages pretty-print)
			 (gnu packages check)
			 (gnu packages boost)
			 (gnu packages qt)
			 (gnu packages xiph)
			 (gnu packages sdl)
			 (gnu packages video)
			 (gnu packages cmake)
			 (gnu packages llvm)
			 (gnu packages tls)
			 (gnu packages base)
			 (guix build-system cmake)
			 (guix build cmake-build-system)
			 (guix build utils))

(package
  (name "yuzu")
  (version "e3122c5b4")
  (source (origin
			(uri (git-reference
				   (url "https://github.com/yuzu-emu/yuzu")
				   (commit version)))
			(method git-fetch)
			(snippet #~(begin
						 (system* (string-append #+git "/bin/git") "submodule" "update" "--init" "--recursive")
						 (system* (string-append #+coreutils "/bin/ls") "-al")))
			(sha256
			  (base32
				"18s4fyagxv68k4xc8h6jd73zxiz272qdnv87z5hn7arn154sw277"))))
  (native-inputs (list gcc-toolchain clang-toolchain cmake ninja git coreutils))
  (inputs (list ffmpeg sdl2 opus qtbase-5 qtdeclarative-5 boost catch2 fmt lz4 nlohmann-json openssl zlib zstd unzip zip))
  (build-system cmake-build-system)
  (description "Yuzu")
  (synopsis "Yuzu")
  (home-page "https://github.com/yuzu-emu/yuzu")
  (license license:gpl3))
