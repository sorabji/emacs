;; User pack init file
;;
;; User this file to initiate the pack configuration.
;; See README for more information.

(live-add-pack-lib "restclient.el")
(live-add-pack-lib "nyan-mode")
(live-add-pack-lib "jira.el")
(live-add-pack-lib "emacs-google-this")
;(live-add-pack-lib "org-screenshot")
;(live-add-pack-lib "elfeed")
(live-add-pack-lib "twittering-mode")
;(live-add-pack-lib "sublimity")

(load (concat (live-pack-lib-dir) "functions.el"))
(load (concat (live-pack-lib-dir) "inf-mongo.el"))
(load (concat (live-pack-lib-dir) "ack-and-a-half.el"))
(load (concat (live-pack-lib-dir) "ibuffer.el"))
(load (concat (live-pack-lib-dir) "etags-search.el"))

(live-load-config-file "bindings.el")
(live-load-config-file "org-mode.el")
;(live-load-config-file "elfeed.el")

; w3m
;; (add-to-list 'load-path "/usr/share/emacs/site-lisp/w3m")
;; (require 'w3m-load)
;; (setq w3m-use-cookies t)
(setq browse-url-browser-function 'browse-url-generic
      browse-url-generic-program "google-chrome-unstable")

(require 'ack-and-a-half)
(defalias 'ack 'ack-and-a-half)
(defalias 'ack-same 'ack-and-a-half-same)
(defalias 'ack-find-file 'ack-and-a-half-find-file)
(defalias 'ack-find-file-same 'ack-and-a-half-find-file-same)
(setq ack-and-a-half-prompt-for-directory t)

(require 'restclient)
(require 'nyan-mode)

(require 'jira)
(setq jira-url "https://zeetomedia.atlassian.net/rpc/xmlrpc")

(require 'acme-search)
(global-set-key [(mouse-3)] 'acme-search-forward)
(global-set-key [(shift mouse-3)] 'acme-search-backward)

(require 'google-this)
(google-this-mode 1)

(require 'auto-complete)
(require 'auto-complete-config)
(ac-config-default)
(global-auto-complete-mode t)
(setq ac-disable-faces nil)             ;completion in alltheplaces!

;;; stupid shell scrolling
(remove-hook 'comint-output-filter-functions 'comint-postoutput-scroll-to-bottom)

(setq erc-hide-list '("JOIN"))


;(require 'org-screenshot)

(require 'twittering-mode)
(setq twittering-use-master-password t)
(setq twittering-icon-mode t)
(setq twittering-convert-fix-size 48)
(setq twittering-use-icon-storage t)

(setq sml/no-confirm-load-theme t)
(sml/setup)
(ido-vertical-mode)
(diminish 'eldoc-mode)
(diminish 'auto-complete-mode)
(diminish 'paredit-mode)
(diminish 'elisp-slime-nav-mode)
(diminish 'google-this-mode)
(diminish 'undo-tree-mode)
(diminish 'git-gutter-mode)
(diminish 'yas-minor-mode)

(require 'swoop)
(global-set-key (kbd "C-o")   'swoop)
(global-set-key (kbd "C-M-o") 'swoop-multi)
(global-set-key (kbd "M-o")   'swoop-pcre-regexp)
(global-set-key (kbd "C-S-o") 'swoop-back-to-last-position)
(define-key isearch-mode-map (kbd "C-o") 'swoop-from-isearch)
(define-key swoop-map (kbd "C-o") 'swoop-multi-from-swoop)
(setq swoop-font-size-change: nil)

(setq iswitchb-default-method 'samewindow)

(defun c++-ac-init ()
  (require 'auto-complete-c-headers)
  (add-to-list 'ac-sources 'ac-source-c-headers)
  (add-to-list 'ac-sources 'ac-source-semantic))

(add-hook 'c++-mode-hook 'c++-ac-init )

;; (semantic-mode 1)

;; (require 'sublimity)
;; (require 'sublimity-scroll)
;; (require 'sublimity-map)
;(require 'sublimity-attractive)

;; (sublimity-mode 1)

;; (setq sublimity-scroll-drift-length 5)
;; (sublimity-map-set-delay nil)

(defun ibuffer-enable-vc-groups ()
  (ibuffer-vc-set-filter-groups-by-vc-root)
    (unless (eq ibuffer-sorting-mode 'alphabetic)
      (ibuffer-do-sort-by-alphabetic)))

(add-hook 'ibuffer-hook 'ibuffer-enable-vc-groups)

(setq magit-status-buffer-switch-function 'switch-to-buffer)


(defun spotify-linux-command (command-name)
  "Execute command for Spotify"
  (interactive)
  (setq command-text (format "%s%s"
                             "dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player."
                             command-name))
  (shell-command command-text))

(defun spotify-toggle ()
  "Play/Pause Spotify"
  (interactive)
  (spotify-linux-command "PlayPause"))

(defun spotify-previous ()
  "Starts the song over in Spotify"
  (interactive)
  (spotify-linux-command "Previous"))

(defun spotify-next ()
  "Next song in Spotify"
  (interactive)
  (spotify-linux-command "Next"))

(global-set-key (kbd "<XF86AudioPlay>") 'spotify-toggle)
(global-set-key (kbd "<XF86Launch9>") 'spotify-next)
(global-set-key (kbd "<XF86Launch8>") 'spotify-previous)
(global-set-key (kbd "<pause>") 'spotify-toggle)


(setq js2-basic-offset 2)
(setq js2-bounce-indent-p t)
(setq-default js2-basic-offset 2)

(setq ham-mode-markdown-command '("/usr/bin/markdown" file))

(add-to-list 'default-frame-alist '(font . "Monaco 10"))

(setenv "GPG_AGENT_INFO" nil)

(defun eldoc-documentation-function-default ())

(elpy-enable)

(elpy-use-ipython)

(define-key yas-minor-mode-map (kbd "C-c k") 'yas-expand)
(define-key elpy-mode-map (kbd "C-c C-t") 'elpy-test-nose-runner)

(defun python-add-breakpoint ()
  "Add a break point"
  (interactive)
  (newline-and-indent)
  (insert "import ipdb; ipdb.set_trace()")
  (highlight-lines-matching-regexp "^[ ]*import ipdb; ipdb.set_trace()"))

(eval-after-load "eww"
  '(progn (define-key eww-mode-map "f" 'eww-lnum-follow)
          (define-key eww-mode-map "F" 'eww-lnum-universal)))

(global-auto-complete-mode nil)
(evil-mode)
(set-cursor-color "yellow")
(setq ac-modes (remove-if (lambda (x) (string= "python-mode" x)) ac-modes))
