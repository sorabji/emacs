;; User pack init file
;;
;; User this file to initiate the pack configuration.
;; See README for more information.

;; Load bindings config
(load (concat (live-pack-lib-dir) "go-autocomplete.el"))
(load (concat (live-pack-lib-dir) "go-mode.el"))

(require 'go-autocomplete)
(require 'auto-complete-config)
(add-to-list 'ac-modes 'go-mode)
