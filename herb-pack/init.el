;; User pack init file
;;
;; Use this file to initiate the pack configuration.
;; See README for more information.

;; Load bindings config
(live-load-config-file "bindings.el")
(live-load-config-file "javascript.el")

(org-babel-do-load-languages
 'org-babel-load-languages
 '((restclient . t)
   (js . t)))

(setq mac-command-modifier 'meta)
(global-set-key (kbd "M-`") 'other-frame)

(ido-vertical-mode)

(sml/setup)

(setq org-confirm-babel-evaluate nil)

;; (setq org-todo-keywords
;;    '((sequence "TODO(t!)" "WAIT(w@/!)" "|" "DONE(d!)" "CANCELED(c@)")))


(require 'org)
(require 'org-id)
(require 'org-install)
(require 'org-protocol)
(require 'org-checklist)
(require 'org-crypt)
(require 'org-contacts)
(require 'ox-md)

(defun my-org-mode-hook ()
  (git-gutter-mode))

(add-hook 'org-mode 'my-org-mode-hook)

(add-to-list 'auto-mode-alist '("\\.org$" . org-mode))

(setq org-log-done t
      org-directory "~/org/"
      org-tags-exclude-from-inheritance (quote ("crypt")) ;; !(encrypt twice)
      org-crypt-key "nil" ;; who wants keys anways? use a passphrase
      auto-save-default nil)

(org-crypt-use-before-save-magic)

(setq org-default-notes-file "~/org/refile.org")

;; Capture templates for: TODO tasks, Notes, appointments, phone calls, and org-protocol
(setq org-capture-templates
      (quote (("t" "todo" entry (file "~/org/refile.org")
               "* TODO %?\n%U\n%a\n  %i" :clock-in t :clock-resume t)
              ("n" "note" entry (file "~/org/refile.org")
               "* %? :NOTE:\n%U\n%a\n  %i" :clock-in t :clock-resume t)
              ("j" "Journal" entry (file+datetree "~/org/diary.org")
               "* %?\n%U\n  %i")
              ("u" "url" entry (file "~/org/refile.org")
               "* %x :url:%^G\n %i")
              ("w" "org-protocol" entry (file "~/org/refile.org")
               "* TODO Review %c\n%U\n  %i" :immediate-finish t)
              ("p" "Phone call" entry (file "~/org/refile.org")
               "* PHONE %? :PHONE:\n%U")
              ("c" "Contacts" entry (file "~/org/contacts.org")
               "* %(org-contacts-template-name)
  :PROPERTIES:%(org-contacts-template-email)

  :END:" :clock-in t :clock-resume t))))

; Targets include this file and any file contributing to the agenda - up to 2 levels deep
(setq org-refile-targets (quote ((nil :maxlevel . 10)
                                 (org-agenda-files :maxlevel . 4)))
      org-refile-use-outline-path nil ; Stop using paths for refile targets - we file directly with IDO
      org-outline-path-complete-in-steps nil ; Targets complete directly with IDO
      org-refile-allow-creating-parent-nodes (quote confirm) ; Allow refile to create parent tasks with confirmation
      org-completion-use-ido t ; Use IDO for both buffer and file completion and ido-everywhere to t
      ido-everywhere t
      ido-max-directory-size 100000
      ido-create-new-buffer 'always
      ido-enable-flex-matching t
      ido-enable-last-directory-history nil
      ido-enable-regexp nil
      ido-max-directory-size 300000
      ido-max-file-prompt-width 0.1
      ido-use-filename-at-point (quote guess)
      ido-use-url-at-point t
      ido-use-virtual-buffers t
      org-agenda-todo-ignore-with-date nil ; Keep tasks with dates on the global todo lists
      org-agenda-todo-ignore-deadlines nil ; Keep tasks with deadlines on the global todo lists
      org-agenda-todo-ignore-scheduled nil ; Keep tasks with scheduled dates on the global todo lists
      org-agenda-todo-ignore-timestamp nil ; Keep tasks with timestamps on the global todo lists
      org-agenda-skip-deadline-if-done t ; Remove completed deadline tasks from the agenda view
      org-agenda-skip-scheduled-if-done t ; Remove completed scheduled tasks from the agenda view
      org-agenda-skip-timestamp-if-done t ; Remove completed items from search results
      org-agenda-include-diary t
      org-agenda-diary-file "~/org/diary.org"
      org-agenda-insert-diary-extract-time t
      org-agenda-text-search-extra-files (quote (agenda-archives)) ; Include agenda archive files when searching for things
      org-agenda-repeating-timestamp-show-all t ; Show all future entries for repeating tasks
      org-agenda-show-all-dates t ; Show all agenda dates - even if they are empty
      org-agenda-start-on-weekday nil ; Start the weekly agenda today
      org-agenda-tags-column -102 ; Display tags farther right
      )

(ido-mode 'both)


;; Sorting order for tasks on the agenda
(setq org-agenda-sorting-strategy
      (quote ((agenda habit-down time-up user-defined-up priority-down effort-up category-keep)
              (todo category-up priority-down effort-up)
              (tags category-up priority-down effort-up)
              (search category-up))))


;; Enable display of the time grid so we can see the marker for the current time
(setq org-agenda-time-grid (quote((daily today remove-match)
                                  #("----------------" 0 16
                                    (org-heading t))
                                  (800 1000 1200 1400 1600 1800 2000))))

;;
;; Agenda sorting functions
;;

(setq org-enforce-todo-dependencies t)

(setq org-startup-indented t)

(setq org-odd-levels-only nil)

(setq org-cycle-separator-lines 2)

(setq org-blank-before-new-entry (quote ((heading)
                                         (plain-list-item))))

(setq org-insert-heading-respect-content nil)

(setq org-reverse-note-order nil)

(setq org-show-following-heading t)
(setq org-show-hierarchy-above t)
(setq org-show-siblings nil)

(setq org-special-ctrl-a/e 'reversed)
(setq org-special-ctrl-k t)
(setq org-yank-adjusted-subtrees t)

(setq org-id-method (quote uuidgen))

(setq org-deadline-warning-days 30)

(setq org-table-export-default-format "orgtbl-to-csv")

(setq org-log-done (quote time))

(setq org-log-into-drawer t)

;;(setq org-clock-sound "/usr/local/lib/tngchime.wav")

                                        ; Enable habit tracking (and a bunch of other modules)
(setq org-modules (quote (org-bbdb
                          org-bibtex
                          org-gnus
                          org-id
                          org-info
                          org-jsinfo
                          org-habit
                          org-inlinetask
                          org-irc
                          org-mew
                          org-mhe
                          org-protocol
                          org-rmail
                          org-vm
                          org-wl
                          org-w3m)))

                                        ; global STYLE property values for completion
(setq org-global-properties (quote (("STYLE_ALL" . "habit"))))
                                        ; position the habit graph on the agenda to the right of the default
(setq org-habit-graph-column 50)

(run-at-time "06:00" 86400 '(lambda () (setq org-habit-show-habits t)))
(run-at-time "00:59" 3600 'org-save-all-org-buffers)

(setq global-auto-revert-mode t)



(setq org-use-speed-commands t)
(setq org-speed-commands-user (quote (("1" . delete-other-windows)
                                      ("2" . split-window-vertically)
                                      ("3" . split-window-horizontally)
                                      ("h" . hide-other)
                                      ("k" . org-kill-note-or-show-branches)
                                      ("r" . org-reveal)
                                      ("s" . org-save-all-org-buffers)
                                      ("z" . org-add-note)
                                      ("t" . org-todo)
                                      ("c" . self-insert-command)
                                      ("C" . self-insert-command)
                                      ("J" . org-clock-goto))))
(setq require-final-newline t)

(setq org-export-with-timestamps nil)

(setq org-return-follows-link nil)

(setq org-remove-highlights-with-change nil)

(setq org-list-demote-modify-bullet (quote (("+" . "-")
                                            ("*" . "-")
                                            ("1." . "-")
                                            ("1)" . "-"))))

(setq org-tags-match-list-sublevels t)

(setq org-agenda-persistent-filter t)


                                        ; Overwrite the current window with the agenda
(setq org-agenda-window-setup 'current-window)

(setq org-clone-delete-id t)

(setq org-enable-priority-commands nil)

(setq org-todo-keywords
      (quote ((sequence "TODO(t)" "STARTED(s)" "|" "DONE(d!/!)")
              (sequence "WAITING(w@/!)" "SOMEDAY(S!)" "|" "CANCELLED(c@/!)" "PHONE")
              (sequence "OPEN(O!)" "|" "CLOSED(C!)"))))

(setq org-fast-todo-selection t)

                                        ; Tags with fast selection keys
(setq org-tag-persistent-alist (quote ((:startgroup)
                                       ("@errand" . ?e)
                                       ("@office" . ?o)
                                       ("@home" . ?h)
                                       (:endgroup)
                                       ("PHONE" . ?p)
                                       ("WAITING" . ?w)
                                       ("PERSONAL" . ?P)
                                       ("WORK" . ?W)
                                       ("ORG" . ?O)
                                       ("NOTE" . ?n)
                                       ("CANCELLED" . ?c)
                                       ("FLAGGED" . ??))))

                                        ; Allow setting single tags without the menu
;;(setq org-fast-tag-selection-single-key (quote expert))

                                        ; For tag searches ignore tasks with scheduled and deadline dates
(setq org-agenda-tags-todo-honor-ignore-options t)

(setq org-agenda-files (list "~/org/gtd.org" "~/org/refile.org" "~/org/jira/" "~/dev/NOTES.org"))

;; Do not dim blocked tasks
(setq org-agenda-dim-blocked-tasks nil)

;; stuck projects
(setq org-stuck-projects (quote ("" nil nil "")))

;; Custom agenda command definitions
(setq org-agenda-custom-commands
      (quote (("N" "Notes" tags "NOTE"
               ((org-agenda-overriding-header "Notes")
                (org-tags-match-list-sublevels t)))
              ("h" "Habits" tags-todo "STYLE=\"habit\""
               ((org-agenda-overriding-header "Habits")
                (org-agenda-sorting-strategy
                 '(todo-state-down effort-up category-keep))))
              (" " "Agenda"
               ((agenda "" nil)
                (tags "REFILE"
                      ((org-agenda-overriding-header "Notes and Tasks to Refile")
                       (org-agenda-overriding-header "Tasks to Refile")))
                (tags-todo "-CANCELLED/!"
                           ((org-agenda-overriding-header "Stuck Projects")
                            (org-tags-match-list-sublevels 'indented)))
                (tags-todo "-WAITING-CANCELLED/!NEXT|STARTED"
                           ((org-agenda-overriding-header "Next Tasks")
                            (org-agenda-todo-ignore-scheduled t)
                            (org-agenda-todo-ignore-deadlines t)
                            (org-tags-match-list-sublevels t)
                            (org-agenda-sorting-strategy
                             '(todo-state-down effort-up category-keep))))
                (tags-todo "-REFILE-CANCELLED/!-NEXT-STARTED-WAITING"
                           ((org-agenda-overriding-header "Tasks")
                            (org-tags-match-list-sublevels 'indented)
                            (org-agenda-todo-ignore-scheduled t)
                            (org-agenda-todo-ignore-deadlines t)
                            (org-agenda-sorting-strategy
                             '(category-keep))))
                (tags-todo "-CANCELLED/!"
                           ((org-agenda-overriding-header "Projects")
                            (org-tags-match-list-sublevels 'indented)
                            (org-agenda-sorting-strategy
                             '(category-keep))))
                (todo "WAITING|SOMEDAY"
                      ((org-agenda-overriding-header "Waiting and Postponed tasks")))
                (tags "-REFILE/"
                      ((org-agenda-overriding-header "Tasks to Archive"))))
               nil)
              ("r" "Tasks to Refile" tags "REFILE"
               ((org-agenda-overriding-header "Notes and Tasks to Refile")
                (org-agenda-overriding-header "Tasks to Refile")))
              ("#" "Stuck Projects" tags-todo "-CANCELLED/!"
               ((org-agenda-overriding-header "Stuck Projects")
                (org-tags-match-list-sublevels 'indented)))
              ("n" "Next Tasks" tags-todo "-WAITING-CANCELLED/!NEXT|STARTED"
               ((org-agenda-overriding-header "Next Tasks")
                (org-agenda-todo-ignore-scheduled t)
                (org-agenda-todo-ignore-deadlines t)
                (org-tags-match-list-sublevels t)
                (org-agenda-sorting-strategy
                 '(todo-state-down effort-up category-keep))))
              ("R" "Tasks" tags-todo "-REFILE-CANCELLED/!-NEXT-STARTED-WAITING"
               ((org-agenda-overriding-header "Tasks")
                (org-tags-match-list-sublevels 'indented)
                (org-agenda-sorting-strategy
                 '(category-keep))))
              ("p" "Projects" tags-todo "-CANCELLED/!"
               ((org-agenda-overriding-header "Projects")
                (org-tags-match-list-sublevels 'indented)
                (org-agenda-sorting-strategy
                 '(category-keep))))
              ("w" "Waiting Tasks" todo "WAITING|SOMEDAY"
               ((org-agenda-overriding-header "Waiting and Postponed tasks")))
              ("A" "Tasks to Archive" tags "-REFILE/"
               ((org-agenda-overriding-header "Tasks to Archive"))))))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;             clocking                 ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Resume clocking tasks when emacs is restarted
(org-clock-persistence-insinuate)

;; Small windows on my Eee PC displays only the end of long lists which isn't very useful
(setq org-clock-history-length 10)
;; Resume clocking task on clock-in if the clock is open
(setq org-clock-in-resume t)
;; Separate drawers for clocking and logs
(setq org-drawers (quote ("PROPERTIES" "LOGBOOK")))
;; Save clock data and state changes and notes in the LOGBOOK drawer
(setq org-clock-into-drawer t)
;; Sometimes I change tasks I'm clocking quickly - this removes clocked tasks with 0:00 duration
(setq org-clock-out-remove-zero-time-clocks t)
;; Clock out when moving task to a done state
(setq org-clock-out-when-done t)
;; Save the running clock and all clock history when exiting Emacs, load it on startup
(setq org-clock-persist (quote history))
;; Enable auto clock resolution for finding open clocks
(setq org-clock-auto-clock-resolution (quote when-no-clock-is-running))
;; Include current clocking task in clock reports
(setq org-clock-report-include-clocking-task t)
;; better mode-line
(setq org-clock-modeline-total 'current)

(setq org-time-stamp-rounding-minutes (quote (1 1)))

(setq org-clock-out-remove-zero-time-clocks t)

;; Agenda log mode items to display (clock time only by default)
(setq org-agenda-log-mode-items (quote (clock)))

;; Agenda clock report parameters
(setq org-agenda-clockreport-parameter-plist
      (quote (:link t :maxlevel 5 :fileskip0 t :compact nil)))

                                        ; Set default column view headings: Task Effort Clock_Summary
(setq org-columns-default-format "%80ITEM(Task) %10Effort(Effort){:} %10CLOCKSUM")

                                        ; global Effort estimate values
(setq org-global-properties (quote (("Effort_ALL" . "0:10 0:30 1:00 2:00 3:00 4:00 5:00 6:00 7:00 8:00"))))



(setq org-agenda-clock-consistency-checks
      (quote (:max-duration "4:00"
                            :min-duration 0
                            :max-gap 0
                            :gap-ok-around ("4:00"))))

(add-hook 'org-agenda-mode-hook '(lambda () (hl-line-mode 1)) 'append)




;; org-publish settings
;; (require 'org-publish)
;; (setq org-publish-project-alist
;;       '(("org-notes"
;;          :base-directory "~/org/"
;;          :base-extension "org"
;;          :publishing-directory "~/org-www/"
;;          :recursive t
;;          :publishing-function org-html-publish-to-html
;;          :headline-levels 10
;;          :makeindex t
;;          :auto-sitemap t
;;          :sitemap-filename "sitemap.org"
;;          :sitemap-title "Sitemap"
;;          :auto-preamble t)
;;         ("org-static"
;;          :base-directory "~/org/"
;;          :base-extension "css\\|js\\|png\\|jpg\\|gif\\|pdf\\|mp3\\|ogg\\|swf"
;;          :publishing-directory "~/org-www/"
;;          :recursive t
;;          :publishing-function org-html-publish-to-html)
;;         ("org" :components ("org-notes" "org-static"))))

 (setq org-export-html-style-include-scripts nil
       org-export-html-style-include-default nil)
 (setq org-export-html-style
   "<link rel=\"stylesheet\" type=\"text/css\" href=\"solarized.dark.css\" />")

(setq org-todo-state-tags-triggers
      (quote (("CANCELLED" ("CANCELLED" . t))
              ("WAITING" ("WAITING" . t))
              ("SOMEDAY" ("WAITING" . t))
              (done ("WAITING"))
              ("TODO" ("WAITING") ("CANCELLED"))
              ("NEXT" ("WAITING"))
              ("STARTED" ("WAITING"))
              ("DONE" ("WAITING") ("CANCELLED")))))

;; org-babel

(add-hook 'org-babel-after-execute-hook 'org-display-inline-images 'append)

(org-babel-do-load-languages
 (quote org-babel-load-languages)
 (quote ((emacs-lisp . t)
         (dot . t)
         (ditaa . t)
         (R . t)
         (python . t)
         (ruby . t)
         (gnuplot . t)
         (clojure . t)
         (sh . t)
         (ledger . t)
         (org . t)
         (plantuml . t)
         (latex . t))))

(setq org-confirm-babel-evaluate nil)
(setq org-plantuml-jar-path (expand-file-name "~/Downloads/plantuml.jar"))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; defuns...move this to another file someday ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; always get the gtd
(defun gtd ()
  (interactive)
  (find-file "~/org/gtd.org")
  (set-buffer "gtd.org")
  (git-gutter-mode -1))

(defun prepare-meeting-notes ()
  "Prepare meeting notes
   Take selected region and convert tabs to spaces, mark TODOs with leading >>>, and copy to kill ring for pasting"
  (interactive)
  (let (prefix)
    (save-excursion
      (save-restriction
        (narrow-to-region (region-beginning) (region-end))
        (untabify (point-min) (point-max))
        (goto-char (point-min))
        (while (re-search-forward "^\\( *-\\\) \\(TODO\\|DONE\\): " (point-max) t)
          (replace-match (concat (make-string (length (match-string 1)) ?>) " " (match-string 2) ": ")))
        (goto-char (point-min))
        (kill-ring-save (point-min) (point-max))))))
