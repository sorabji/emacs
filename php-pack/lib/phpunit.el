(defvar phpunit-regexp-alist
  '(("^\\(.*\\.php\\):\\([0-9]+\\)$" 1 2 nil nil 1))
  "Regexp used to match PHPUnit output. See `compilation-error-regexp-alist'.")

(defvar phpunit-error-face compilation-error-face
  "Face name to use for phpunit errors.")

(defvar phpunit-warning-face compilation-warning-face
  "Face name to use for phpunit warnings.")

(setq compilation-finish-function
      (lambda (buf str)
        (unless (string-match "exited abnormally" str)
          ;;no errors, make the compilation window go away in a few seconds
          (run-at-time
           "2 sec" nil 'delete-windows-on
           (get-buffer-create "*compilation*"))
          (message "No Compilation Errors!"))))

(define-compilation-mode phpunit-run-mode "PHPUnit"
  (set (make-local-variable 'compilation-error-regexp-alist)
       phpunit-regexp-alist)
  (set (make-local-variable 'compilation-error-face)
       phpunit-error-face)
  (set (make-local-variable 'compilation-warning-face)
       phpunit-warning-face)
  (set (make-local-variable 'compilation-disable-input) t))

(defun phpunit-command ()
  (let ((r (eproject-root)))
    (concat r "vendor/bin/phpunit -c "
                     r "app "
                     "--stop-on-failure --stop-on-error ")))

(defun get-function-name ()
  (interactive)
  (message (symbol-name (or (symbol-at-point)
                            (error "No function at point.")))))

(defun phpunit-method-run-command ()
  (interactive)
  (let ((symbol (symbol-at-point)))
    (if (not symbol)
        (message "No symbol at point.")
      (concat (phpunit-command) "--filter=" (symbol-name symbol) " " (buffer-file-name)))))

(defun phpunit-file-run-command ()
  (interactive)
  (concat (concat (phpunit-command) (buffer-file-name))))

(defun phpunit-file-run ()
  (interactive)
  (phpunit-run-test (phpunit-file-run-command)))

(defun phpunit-method-run ()
  (interactive)
  (phpunit-run-test (phpunit-method-run-command)))

(defun phpunit-run-test (command)
  "Runs a test with PHPUnit."
  (interactive)
  (compilation-start command 'phpunit-run-mode))

(provide 'phpunit)
