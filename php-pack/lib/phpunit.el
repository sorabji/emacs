(defvar phpunit-executable
  "phpunit"
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

(defvar phpunit-toggle-switches
  nil
  "list of phpunit switches in format (var (on-msg on-switch) (off-msg off-switch))")

(defvar phpunit-env-toggles
  nil
  "list of commands to run before phpunit, same format as phpunit-toggle-switches")

(setq compilation-finish-function
      (lambda (buf str)
        (next-error-follow-minor-mode)
        (unless (string-match "exited abnormally" str)
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

(defun phpunit-process-setup ()
  "Setup compilation variables and buffer for `phpunit'.
Run `phpunit-setup-hook'."
  (run-hooks 'phpunit-setup-hook))

(defmacro phpunit-toggle (name on-msg on-switch off-msg &optional before)
  (let ((func (intern (concat "phpunit-toggle-" name)))
        (var (intern (concat "phpunit-" name)))
        (which-list (if before 'phpunit-env-toggles 'phpunit-toggle-switches)))
    `(list
      (defvar ,var nil)
      (add-to-list ',which-list '(,var (,on-msg ,on-switch) (,off-msg "")) t)
      (defun ,func ()
        (interactive)
        (setq ,var (not ,var))
        (message "%s" (if ,var ,on-msg ,off-msg))))))

(defun phpunit-get-toggle-msg (arg)
  (let ((var (symbol-value (first arg)))
        (on (first (second arg)))
        (off (first (third arg))))
    (if var on off)))

(defun phpunit-get-toggle-switch (arg)
  (let ((var (symbol-value (first arg)))
        (on (second (second arg)))
        (off (second (third arg))))
    (if var on off)))

(defun phpunit-status ()
  (interactive)
  (message "%s" (concat (mapconcat 'phpunit-get-toggle-msg phpunit-env-toggles "\n")
                        (mapconcat 'phpunit-get-toggle-msg phpunit-toggle-switches "\n"))))

(phpunit-toggle "debug" "debugging" "XDEBUG_CONFIG=jk " "not debugging" t)
(phpunit-toggle "clear-sf-cache" "clearing cache" "sf-clean.sh && " "not clearing cache" t)
(phpunit-toggle "drop-database" "dropping database" "bin/cleanEnv.sh && " "not dropping database" t)
(phpunit-toggle "stop-on-fail" "stop on fail" "--stop-on-failure --stop-on-error " "not stopping")
(phpunit-toggle "generate-coverage" "coverage" "--coverage-html /tmp/coverage/ " "no coverage")
(phpunit-toggle "testdox" "testdox" "--testdox " "no testdox")

(defun phpunit-toggle-file ()
  "top level of this"
  (interactive)
  (if (not (phpunit-find-test-file))
      (phpunit-find-file)))

(defun phpunit-find-test-file ()
  "hopes to find the corresponding phpunit test file. may depend heavily on symfony bundle structure (shrug)"
  (let* ((file (buffer-file-name))
         (test-dir (replace-regexp-in-string "Bundle/" "Bundle/Tests/" file))
         (fin (replace-regexp-in-string ".php" "Test.php" test-dir)))
    (if (file-exists-p fin)
        (find-file fin))))

(defun phpunit-find-file ()
  "hopes to find the corresponding file for a phpunit test file. likely depends heavily on symfony bundle structure (shrug)"
  (let* ((file (buffer-file-name))
         (test-dir (replace-regexp-in-string "Bundle/Tests/" "Bundle/" file))
         (fin (replace-regexp-in-string "Test.php" ".php" test-dir)))
    (if (file-exists-p fin)
        (find-file fin))))

(defun phpunit-root ()
  (locate-dominating-file (buffer-file-name) ".gitignore" ))

(defun phpunit-command ()
  (interactive)
  (concat
   "cd " (phpunit-root) " && "
   (mapconcat 'phpunit-get-toggle-switch phpunit-env-toggles " ")
   phpunit-executable " -c app/ "
   (mapconcat 'phpunit-get-toggle-switch phpunit-toggle-switches " ")))

(defun phpunit-src-dir-run-command ()
  (concat (phpunit-command) (phpunit-root) "src"))

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
  (interactive (list (read-directory-name "sDir: ")))
  (phpunit-run-test (concat (phpunit-command) dir)))

(defun phpunit-run-test (command)
  "Runs a test with PHPUnit."
  (interactive)
  (compilation-start command 'phpunit-run-mode))

(defun phpunit-watch-hook ()
  (interactive)
  (when (eq major-mode 'php-mode)
    (if (get-buffer "*phpunit-run*")
       (save-current-buffer
         (set-buffer "*phpunit-run*")
         (recompile)))))

(add-hook 'after-save-hook 'phpunit-watch-hook)

(provide 'phpunit)
