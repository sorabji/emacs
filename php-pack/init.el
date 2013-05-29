;; User pack init file
;;
;; User this file to initiate the pack configuration.
;; See README for more information.

(live-add-pack-lib "php-mode")

(require 'php-mode)
(add-hook 'php-mode-hook
          '(lambda () (progn
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
