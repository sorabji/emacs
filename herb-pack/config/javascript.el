;;; javascript --- customize
;;; Commentary:
;;;
;;; packages: flycheck, eproject, exec-path-from-shell, web-mode, tern, tern-auto-complete
;;;
;;; Code:
(add-to-list 'auto-mode-alist '("\\.jsx$" . web-mode))

(require 'flycheck)
(require 'web-mode)

(add-hook 'after-init-hook #'global-flycheck-mode)

(setq-default flycheck-disabled-checkers (append flycheck-disabled-checkers '(javascript-jshint)))

(flycheck-add-mode 'javascript-eslint 'web-mode)

(setq-default flycheck-temp-prefix ".flycheck")

(setq-default flycheck-disabled-checkers (append flycheck-disabled-checkers '(json-jsonlint)))

(exec-path-from-shell-initialize)

(defun sora/web-mode-hook ()
  (setq web-mode-markup-indent-offset 2)
  (setq web-mode-css-indent-offset 2)
  (setq web-mode-code-indent-offset 2))

(defun sora/js2-mode-2-space ()
  (setq js2-basic-offset 2))

(defun sora/delete-tern-process ()
  (interactive)
  (delete-process "Tern"))

(defun lunaryorn-use-js-executables-from-node-modules ()
  "Set executables of JS checkers from local node modules."
  (-when-let* ((file-name (buffer-file-name))
               (root (locate-dominating-file file-name "node_modules"))
               (module-directory (expand-file-name "node_modules" root)))
    (pcase-dolist (`(,checker . ,module) '((javascript-jshint . "jshint")
                                           (javascript-eslint . "eslint")
                                           (javascript-jscs   . "jscs")))
      (let ((package-directory (expand-file-name module module-directory))
            (executable-var (flycheck-checker-executable-variable checker)))
        (when (file-directory-p package-directory)
          (set (make-local-variable executable-var)
               (expand-file-name (concat "bin/" module ".js")
                                 package-directory)))))))

(add-hook 'js-mode-hook (lambda () (tern-mode t)))
(eval-after-load 'tern
   '(progn
      (require 'tern-auto-complete)
      (tern-ac-setup)))

(add-hook 'web-mode-hook 'sora/web-mode-hook)
(add-hook 'js2-mode-hook 'sora/js2-mode-2-space)
(add-hook 'flycheck-mode-hook 'lunaryorn-use-js-executables-from-node-modules)

(defadvice web-mode-highlight-part (around tweak-jsx activate)
  (if (equal web-mode-content-type "jsx")
      (let ((web-mode-enable-part-face nil))
        ad-do-it)
    ad-do-it))
