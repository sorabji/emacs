(require 'eproject)

(defvar phpunit-executable
  nil
  "points to the phpunit executable")

(defvar phpunit-regex
  '("^\\(.*\\.php\\):\\([0-9]+\\)$" 1 2 nil nil 1)
  "Regexp used to match PHPUnit output. See `compilation-error-regexp-alist'.")

(defvar phpunit-error-face compilation-error-face
  "Face name to use for phpunit errors.")

(defvar phpunit-warning-face compilation-warning-face
  "Face name to use for phpunit warnings.")

(defcustom phpunit-setup-hook nil
  "List of hook functions run by `phpunit-process-setup' (see `run-hooks')."
  :type 'hook
  :group 'phpunit)

(add-hook 'phpunit-setup-hook (lambda () (next-error-follow-minor-mode)))

(setq compilation-finish-function
      (lambda (buf str)
        (next-error-follow-minor-mode)
        (unless (string-match "exited abnormally" str)
          ;;no errors, make the compilation window go away in a few seconds
          (run-at-time
           "2 sec" nil 'delete-windows-on
           (get-buffer-create "*compilation*"))
          (and (next-error-follow-minor-mode) (message "No Compilation Errors!")))))

(define-compilation-mode phpunit-run-mode "PHPUnit"
  (add-to-list (make-local-variable 'compilation-error-regexp-alist)
               phpunit-regex)
  (set (make-local-variable 'compilation-error-face)
       phpunit-error-face)
  (set (make-local-variable 'compilation-warning-face)
       phpunit-warning-face)
  (set (make-local-variable 'compilation-process-setup-function)
       'phpunit-process-setup)
  (set (make-local-variable 'compilation-disable-input) t))

(defun set-phpunit-vendor-executable ()
  (interactive)
  (setq phpunit-executable (concat (eproject-root) "vendor/bin/phpunit ") ))

(defun set-phpunit-bin-executable ()
  (interactive)
  (setq phpunit-executable (concat (eproject-root) "bin/phpunit ") ))

(defun phpunit-process-setup ()
  "Setup compilation variables and buffer for `phpunit'.
Run `phpunit-setup-hook'."
  (run-hooks 'phpunit-setup-hook))

(defun phpunit-command ()
  (let ((r (eproject-root)))
    (concat phpunit-executable " -c "
                     r "app "
                     "--stop-on-failure --stop-on-error ")))

(defun phpunit-src-dir-run-command ()
  (concat (phpunit-command) (eproject-root) "src"))

(defun phpunit-src-dir-run ()
  (interactive)
  (phpunit-run-test (phpunit-src-dir-run-command)))

(defun phpunit-file-run-command (file)
  (concat (phpunit-command) file))

(defun phpunit-file-run (arg)
  (interactive "P")
  (let ((file nil))
    (if arg
        (setq file (list
                  (read-string (format "file (%s): " (buffer-file-name))
                               nil nil (buffer-file-name))))
      (setq file (buffer-file-name)))
    (phpunit-run-test (phpunit-file-run-command file))))

(defun phpunit-method-run-command (method)
  (concat (phpunit-command) "--filter=" method " " (buffer-file-name)))

(defun phpunit-method-run-method-at-point ()
  (interactive)
  (save-excursion
    (beginning-of-defun)
    (search-forward "(")
    (backward-word)
      (let ((symbol (symbol-at-point)))
        (if (not symbol)
            (message "No symbol at point.")
          (phpunit-run-test (phpunit-method-run-command (symbol-name symbol)))))))

(defun phpunit-run-any-method ()
  (interactive)
  (let ((ido-mode ido-mode)
          (ido-enable-flex-matching
           (if (boundp 'ido-enable-flex-matching)
               ido-enable-flex-matching t))
          name-and-pos symbol-names position)
      (unless ido-mode
        (ido-mode 1)
        (setq ido-enable-flex-matching t))
      (while (progn
               (imenu--cleanup)
               (setq imenu--index-alist nil)
               (ido-goto-symbol (imenu--make-index-alist))
               (setq selected-symbol
                     (ido-completing-read "Symbol? " symbol-names))
               (string= (car imenu--rescan-item) selected-symbol)))
      (phpunit-run-test (phpunit-method-run-command selected-symbol))))

(defun phpunit-directory-run-command (dir)
  (phpunit-run-test (concat (phpunit-command) dir)))

(defun phpunit-directory-run ()
  (interactive)
  (let ((ido-report-no-match nil)
	(ido-auto-merge-work-directories-length -1))
    ;; (ido-file-internal 'dired 'dired nil "Dired: " 'dir)
    (ido-file-internal 'phpunit-directory-run-command
                       'phpunit-directory-run-command
                       nil
                       "dkdk"
                       'dir)))

(defun test-directory-run ()
  (interactive)
  (let ((dir (ido-completing-read "Dir? " (ido-make-dir-list 'dir))))
    (message "%s" dir)))



(defun phpunit-run-test (command)
  "Runs a test with PHPUnit."
  (interactive)
  (compilation-start command 'phpunit-run-mode))

(provide 'phpunit)
