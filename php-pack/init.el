;; User pack init file
;;
;; User this file to initiate the pack configuration.
;; See README for more information.

(live-add-pack-lib "php-mode")
(live-add-pack-lib "eproject")

(require 'sf)
(require 'php-mode)
(require 'php-doc nil t)
(setq php-doc-directory (expand-file-name "~/man/php-chunked-xhtml"))
(add-hook 'php-mode-hook
          '(lambda () (progn
                        (local-set-key "\t" 'php-doc-complete-function)
                        (local-set-key (kbd "\C-c h") 'php-doc)
                        (local-set-key (kbd "\C-c l") 'phplint-thisfile)
                        (set (make-local-variable 'eldoc-documentation-function)
                             'php-doc-eldoc-function)
                        (eldoc-mode 1)
                        (define-abbrev php-mode-abbrev-table "ex" "extends"))))

(defun clean-php-mode ()
    (interactive)
    (php-mode)
    (setq c-basic-offset 2)) ;2 tabs indenting


;; sudo apt-get install php5-cli for lint features
;; run php lint w/ f8
(defun phplint-thisfile ()
  (interactive)
  (compile (format "php -l %s" (buffer-file-name))))


(live-load-config-file "bindings.el")
