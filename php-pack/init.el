(live-add-pack-lib "php-mode")
(live-add-pack-lib "eproject")
(live-add-pack-lib "php-auto-yasnippets")
(live-add-pack-lib "geben-on-emacs")
(live-add-pack-lib "ecb")
(live-add-pack-lib "php-boris")

(require 'compile)
(require 'sf)
(require 'php-mode)
(require 'php-doc nil t)
(require 'phpunit)
(require 'twig-mode)

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
                        (local-set-key (kbd "<f6>") 'phpunit-toggle-file)
                        (local-set-key (kbd "C-c C-y") 'yas/create-php-snippet)
                        (set (make-local-variable 'eldoc-documentation-function)
                             'php-doc-eldoc-function)
                        (eldoc-mode 1)
                        (flymake-mode 1)
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



(require 'php-auto-yasnippets)
(setq php-auto-yasnippet-php-program (expand-file-name "~/config/emacs-live-packs/php-pack/lib/php-auto-yasnippets/Create-PHP-YASnippet.php"))

(require 'geben)

(setq geben-pause-at-entry-line nil)

(defun my-geben-breakpoints (session)
  (message "Setting debugger breakpoints.")
  (geben-set-breakpoint-call "debugger"))
(add-hook 'geben-dbgp-init-hook #'my-geben-breakpoints t)

(defun my-geben-release ()
  (interactive)
  (geben-stop)
  (dolist (session geben-sessions)
    (ignore-errors
      (geben-session-release session))))

(require 'ecb)

(setq stack-trace-on-error t)

;; (setq ecb-source-path `(
;;                         ,(expand-file-name "~/dev/")
;;                         ,(expand-file-name "~/dev/zeeto/")))
;; (setq ecb-source-path nil)

(require 'php-boris)
