(require 'package)

(setq package-archives '(("gnu" . "http://elpa.gnu.org/packages/")
                         ("marmalade" . "http://marmalade-repo.org/packages/")
                         ("melpa" . "http://melpa.milkbox.net/packages/")))

(package-initialize)
;;(add-to-list 'package-archives '("marmalade" ."http://marmalade-repo.org/packages/"))
;; (add-to-list 'package-archives '("melpa" . "http://melpa.milkbox.net/packages/") t)
;;(add-to-list 'package-archives '("gnu" . "http://elpa.gnu.org/packages/"))

;; (setq package-archives '(("gnu" . "http://elpa.gnu.org/packages/")
;;                          ("marmalade" . "http://marmalade-repo.org/packages/")
;;                          ;; ("melpa" . "http://melpa.milkbox.net/packages/")
;;                          ))

;; (package-initialize)

(set-frame-font "Monaco 10")

(live-add-packs '(~/config/emacs-live-packs/php-pack
                  ~/config/emacs-live-packs/function-pack
                  ;~/config/emacs-live-packs/emms-pack
                  ~/config/emacs-live-packs/go-pack
                  ;~/config/emacs-live-packs/mu4e-pack
))
