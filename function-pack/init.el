;; User pack init file
;;
;; User this file to initiate the pack configuration.
;; See README for more information.

(live-add-pack-lib "restclient.el")
(live-add-pack-lib "nyan-mode")

;; Load bindings config
(live-load-config-file "bindings.el")
(live-load-config-file "org-mode.el")

(load (concat (live-pack-lib-dir) "functions.el"))
(load (concat (live-pack-lib-dir) "inf-mongo.el"))
(load (concat (live-pack-lib-dir) "ack-and-a-half.el"))


; w3m
(add-to-list 'load-path "/usr/share/emacs/site-lisp/w3m")
(require 'w3m-load)
(setq w3m-use-cookies t)
(setq browse-url-browser-function 'browse-url-generic
      browse-url-generic-program "firefox")

(require 'ack-and-a-half)
(defalias 'ack 'ack-and-a-half)
(defalias 'ack-same 'ack-and-a-half-same)
(defalias 'ack-find-file 'ack-and-a-half-find-file)
(defalias 'ack-find-file-same 'ack-and-a-half-find-file-same)


(require 'restclient)
(require 'nyan-mode)
