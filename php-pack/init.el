(live-add-pack-lib "php-mode")
(live-add-pack-lib "eproject")
;(live-add-pack-lib "phpunit")



(require 'compile)
(require 'sf)
(require 'php-mode)
(require 'php-doc nil t)
(require 'phpunit)

(setq php-doc-directory (expand-file-name "~/man/php-chunked-xhtml"))
(add-hook 'php-mode-hook
          '(lambda () (progn
                        (local-set-key "\t" 'php-doc-complete-function)
                        (local-set-key (kbd "\C-c h") 'php-doc)
                        (local-set-key (kbd "\C-c l") 'phplint-thisfile)
                        (local-set-key (kbd "<f12>") 'phpunit-src-dir-run)
                        (local-set-key (kbd "<f11>") 'phpunit-file-run)
                        (local-set-key (kbd "<f10>") 'phpunit-method-run-method-at-point)
                        (local-set-key (kbd "<f9>") 'phpunit-run-any-method)
                        (set (make-local-variable 'eldoc-documentation-function)
                             'php-doc-eldoc-function)
                        (eldoc-mode 1)
                        (define-abbrev php-mode-abbrev-table "ex" "extends"))))

(defun phplint-thisfile ()
  (interactive)
  (compile (format "php -l %s" (buffer-file-name))))

(setq mode-compile-always-save-buffer-p t)
(setq compilation-window-height 12)



;;open the composer.json file in a new buffer
(defun sf-app-composer ()
  "open the app composer.json file in a new buffer"
  (interactive)
  (sf-open-file "composer.json"))

(live-load-config-file "bindings.el")
