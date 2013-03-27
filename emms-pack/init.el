;; User pack init file
;;
;; User this file to initiate the pack configuration.
;; See README for more information.

(add-to-list 'load-path "~/config/emacs-live-packs/emms-pack/lib/emms/lisp")
;(live-add-pack-lib "emms")
(require 'emms-setup)
(emms-standard)
(emms-default-players)
