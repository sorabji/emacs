(require 'package)
(add-to-list 'package-archives '("marmalade" ."http://marmalade-repo.org/packages/"))
(package-initialize)

(live-add-packs '(~/config/emacs-live-packs/php-pack
                  ~/config/emacs-live-packs/function-pack
                  ;~/config/emacs-live-packs/emms-pack
                  ~/config/emacs-live-packs/go-pack
                  ~/config/emacs-live-packs/mu4e-pack))
