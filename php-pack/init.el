(live-add-pack-lib "php-mode")
(live-add-pack-lib "eproject")

(require 'compile)
(require 'sf)
(require 'php-mode)
(require 'php-doc nil t)



(setq php-doc-directory (expand-file-name "~/man/php-chunked-xhtml"))
(add-hook 'php-mode-hook
          '(lambda () (progn
                        (local-set-key "\t" 'php-doc-complete-function)
                        (local-set-key (kbd "\C-c h") 'php-doc)
                        (local-set-key (kbd "\C-c l") 'phplint-thisfile)
                        (local-set-key (kbd "<f12>") 'phpunit-file-run)
                        (local-set-key (kbd "<f11>") 'phpunit-method-run)
                        (local-set-key (kbd "<f10>") 'phplint-thisfile)
                        (set (make-local-variable 'eldoc-documentation-function)
                             'php-doc-eldoc-function)
                        (eldoc-mode 1)
                        (define-abbrev php-mode-abbrev-table "ex" "extends"))))

(defun clean-php-mode ()
    (interactive)
    (php-mode)
    (setq c-basic-offset 2)) ;2 tabs indenting

(defun phplint-thisfile ()
  (interactive)
  (compile (format "php -l %s" (buffer-file-name))))

(setq mode-compile-always-save-buffer-p t)
(setq compilation-window-height 12)

(setq compilation-finish-function
      (lambda (buf str)
        (unless (string-match "exited abnormally" str)
          ;;no errors, make the compilation window go away in a few seconds
          (run-at-time
           "2 sec" nil 'delete-windows-on
           (get-buffer-create "*compilation*"))
          (message "No Compilation Errors!"))))

(defun phpunit-command ()
  (let ((r (eproject-root)))
    (concat r "vendor/bin/phpunit -c "
                     r "app "
                     "--stop-on-failure --stop-on-error ")))

(defun get-function-name ()
  (interactive)
  (message (symbol-name (or (symbol-at-point)
                            (error "No function at point.")))))

(defun phpunit-method-run ()
  (interactive)
  (let ((symbol (symbol-at-point)))
    (if (not symbol)
        (message "No symbol at point.")
      (compile (concat (phpunit-command) "--filter=" (symbol-name symbol) " " (buffer-file-name))))))

(defun phpunit-file-run ()
  (interactive)
  (compile (concat (phpunit-command) (buffer-file-name))))

(live-load-config-file "bindings.el")
