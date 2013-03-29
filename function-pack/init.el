;; User pack init file
;;
;; User this file to initiate the pack configuration.
;; See README for more information.

;; Load bindings config
(live-load-config-file "bindings.el")
(live-load-config-file "org-mode.el")

(load (concat (live-pack-lib-dir) "functions.el"))
(load (concat (live-pack-lib-dir) "inf-mongo.el"))
