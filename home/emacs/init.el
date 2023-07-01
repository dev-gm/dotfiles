(define-key key-translation-map "C-t" "C-x") 
(setq inhibit-startup-message t
	  visible-bell t
	  cursor-type 'bar)
(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)
(global-display-line-numbers-mode 1)
(load-theme 'deeper-blue t)
