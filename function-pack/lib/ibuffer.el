(require 'ibuffer)

(setq ibuffer-saved-filter-groups
  (quote (("default"
            ("org" ;; all org-related buffers
              (mode . org-mode))
            ("getitfree"
              (filename . "gif/getitfree/"))
            ("samples"
             (filename . "samples/samples"))
            ("emacs-lisp"
             (mode . emacs-lisp-mode))
            ("dired"
             (mode . dired-mode))
            ("programming"
              (or
                (mode . c-mode)
                (mode . perl-mode)
                (mode . python-mode)))
            ("ERC"   (mode . erc-mode))))))

(add-hook 'ibuffer-mode-hook
  (lambda ()
    (ibuffer-switch-to-saved-filter-groups "default")))
