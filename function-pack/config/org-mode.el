(require 'org)
(require 'org-id)
(require 'org-install)
(require 'org-protocol)
;;(require 'org-checklist)
(require 'org-crypt)
;(require 'org-contacts)

(add-to-list 'auto-mode-alist '("\\.org$" . org-mode))

(setq org-log-done t
      org-directory "~/org/"
      org-tags-exclude-from-inheritance (quote ("crypt")) ;; !(encrypt twice)
      org-crypt-key "nil" ;; who wants keys anways? use a passphrase
      auto-save-default nil)


                                        ; Encrypt all entries before saving
(org-crypt-use-before-save-magic)



  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; hooks                                             ;;
;; one of the more useful things about programming i ;;
;; think...it's like your own api.                   ;;
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(add-hook 'org-mode-hook (lambda () (abbrev-mode 1)))
(add-hook 'org-clock-out-hook 'bh/remove-empty-drawer-on-clock-out 'append)
(add-hook 'org-clock-out-hook 'bh/clock-out-maybe 'append)

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; org capture.                                       ;;
;; i will make you work in firefox one of these days. ;;
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(setq org-default-notes-file (concat org-directory "/notes.org")
      org-default-notes-file "~/org/refile.org")

;; Capture templates for: TODO tasks, Notes, appointments, phone calls, and org-protocol
(setq org-capture-templates
      (quote (("t" "todo" entry (file "~/org/refile.org")
               "* TODO %?\n%U\n%a\n  %i" :clock-in t :clock-resume t)
              ("n" "note" entry (file "~/org/refile.org")
               "* %? :NOTE:\n%U\n%a\n  %i" :clock-in t :clock-resume t)
              ("j" "Journal" entry (file+datetree "~/org/diary.org")
               "* %?\n%U\n  %i" :clock-in t :clock-resume t)
              ("w" "org-protocol" entry (file "~/org/refile.org")
               "* TODO Review %c\n%U\n  %i" :immediate-finish t)
              ("p" "Phone call" entry (file "~/org/refile.org")
               "* PHONE %? :PHONE:\n%U" :clock-in t :clock-resume t)
              ("c" "Contacts" entry (file "~/org/contacts.org")
               "* %(org-contacts-template-name)
  :PROPERTIES:%(org-contacts-template-email)

  :END:" :clock-in t :clock-resume t)
              ("h" "Habit" entry (file "~/org/refile.org")
               (concat "* NEXT %?\n%U\n%a\nSCHEDULED: %t .+1d/3d "
                       "\n:PROPERTIES:\n:STYLE: habit\n:REPEAT_TO_STATE: "
                       "NEXT\n:END:\n  %i")))))

                                        ; Targets include this file and any file contributing to the agenda - up to 2 levels deep
(setq org-refile-targets (quote ((nil :maxlevel . 3)
                                 (org-agenda-files :maxlevel . 3))))

                                        ; Stop using paths for refile targets - we file directly with IDO
(setq org-refile-use-outline-path nil)

                                        ; Targets complete directly with IDO
(setq org-outline-path-complete-in-steps nil)

                                        ; Allow refile to create parent tasks with confirmation
(setq org-refile-allow-creating-parent-nodes (quote confirm))

                                        ; Use IDO for both buffer and file completion and ido-everywhere to t
(setq org-completion-use-ido t
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
      ido-use-virtual-buffers t)

(ido-mode 'both)

;; Keep tasks with dates on the global todo lists
(setq org-agenda-todo-ignore-with-date nil)

;; Keep tasks with deadlines on the global todo lists
(setq org-agenda-todo-ignore-deadlines nil)

;; Keep tasks with scheduled dates on the global todo lists
(setq org-agenda-todo-ignore-scheduled nil)

;; Keep tasks with timestamps on the global todo lists
(setq org-agenda-todo-ignore-timestamp nil)

;; Remove completed deadline tasks from the agenda view
(setq org-agenda-skip-deadline-if-done t)

;; Remove completed scheduled tasks from the agenda view
(setq org-agenda-skip-scheduled-if-done t)

;; Remove completed items from search results
(setq org-agenda-skip-timestamp-if-done t)

(setq org-agenda-include-diary t)
(setq org-agenda-diary-file "~/org/diary.org")

(setq org-agenda-insert-diary-extract-time t)

;; Include agenda archive files when searching for things
(setq org-agenda-text-search-extra-files (quote (agenda-archives)))

;; Show all future entries for repeating tasks
(setq org-agenda-repeating-timestamp-show-all t)

;; Show all agenda dates - even if they are empty
(setq org-agenda-show-all-dates t)

;; Sorting order for tasks on the agenda
(setq org-agenda-sorting-strategy
      (quote ((agenda habit-down time-up user-defined-up priority-down effort-up category-keep)
              (todo category-up priority-down effort-up)
              (tags category-up priority-down effort-up)
              (search category-up))))

;; Start the weekly agenda today
(setq org-agenda-start-on-weekday nil)

;; Enable display of the time grid so we can see the marker for the current time
(setq org-agenda-time-grid (quote((daily today remove-match)
                                  #("----------------" 0 16
                                    (org-heading t))
                                  (800 1000 1200 1400 1600 1800 2000))))

;; Display tags farther right
(setq org-agenda-tags-column -102)

;;
;; Agenda sorting functions
;;
(setq org-agenda-cmp-user-defined 'bh/agenda-sort)

(defun bh/agenda-sort (a b)
  "Sorting strategy for agenda items.
  Late deadlines first, then scheduled, then non-late deadlines"
  (let (result num-a num-b)
    (cond
                                        ; time specific items are already sorted first by org-agenda-sorting-strategy

                                        ; non-deadline and non-scheduled items next
     ((bh/agenda-sort-test 'bh/is-not-scheduled-or-deadline a b))

                                        ; deadlines for today next
     ((bh/agenda-sort-test 'bh/is-due-deadline a b))

                                        ; late deadlines next
     ((bh/agenda-sort-test-num 'bh/is-late-deadline '< a b))

                                        ; scheduled items for today next
     ((bh/agenda-sort-test 'bh/is-scheduled-today a b))

                                        ; pending deadlines last
     ((bh/agenda-sort-test-num 'bh/is-pending-deadline '< a b))

                                        ; late scheduled items next
     ((bh/agenda-sort-test-num 'bh/is-scheduled-late '> a b))

                                        ; finally default to unsorted
     (t (setq result nil)))
    result))

(defmacro bh/agenda-sort-test (fn a b)
  "Test for agenda sort"
  `(cond
                                        ; if both match leave them unsorted
    ((and (apply ,fn (list ,a))
          (apply ,fn (list ,b)))
     (setq result nil))
                                        ; if a matches put a first
    ((apply ,fn (list ,a))
     (setq result -1))
                                        ; otherwise if b matches put b first
    ((apply ,fn (list ,b))
     (setq result 1))
                                        ; if none match leave them unsorted
    (t nil)))

(defmacro bh/agenda-sort-test-num (fn compfn a b)
  `(cond
    ((apply ,fn (list ,a))
     (setq num-a (string-to-number (match-string 1 ,a)))
     (if (apply ,fn (list ,b))
         (progn
           (setq num-b (string-to-number (match-string 1 ,b)))
           (setq result (if (apply ,compfn (list num-a num-b))
                            -1
                          1)))
       (setq result -1)))
    ((apply ,fn (list ,b))
     (setq result 1))
    (t nil)))

(defun bh/is-not-scheduled-or-deadline (date-str)
  (and (not (bh/is-deadline date-str))
       (not (bh/is-scheduled date-str))))

(defun bh/is-due-deadline (date-str)
  (string-match "Deadline:" date-str))

(defun bh/is-late-deadline (date-str)
  (string-match "In *\\(-.*\\)d\.:" date-str))

(defun bh/is-pending-deadline (date-str)
  (string-match "In \\([^-]*\\)d\.:" date-str))

(defun bh/is-deadline (date-str)
  (or (bh/is-due-deadline date-str)
      (bh/is-late-deadline date-str)
      (bh/is-pending-deadline date-str)))

(defun bh/is-scheduled (date-str)
  (or (bh/is-scheduled-today date-str)
      (bh/is-scheduled-late date-str)))

(defun bh/is-scheduled-today (date-str)
  (string-match "Scheduled:" date-str))

(defun bh/is-scheduled-late (date-str)
  (string-match "Sched\.\\(.*\\)x:" date-str))

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
                                      ("q" . bh/show-org-agenda)
                                      ("r" . org-reveal)
                                      ("s" . org-save-all-org-buffers)
                                      ("z" . org-add-note)
                                      ("t" . org-todo)
                                      ("c" . self-insert-command)
                                      ("C" . self-insert-command)
                                      ("J" . org-clock-goto))))
(setq require-final-newline t)



(add-hook 'org-insert-heading-hook 'bh/insert-heading-inactive-timestamp 'append)



(setq org-export-with-timestamps nil)

(setq org-return-follows-link nil)

(defun bh/prepare-meeting-notes ()
  "Prepare meeting notes for email
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

;; Mark parent tasks as started
(defvar bh/mark-parent-tasks-started nil)

(defun bh/mark-parent-tasks-started ()
  "Visit each parent task and change TODO states to STARTED"
  (unless bh/mark-parent-tasks-started
    (when (equal state "STARTED")
      (let ((bh/mark-parent-tasks-started t))
        (save-excursion
          (while (org-up-heading-safe)
            (when (member (nth 2 (org-heading-components)) (list "TODO" "NEXT"))
              (org-todo "STARTED"))))))))

(add-hook 'org-after-todo-state-change-hook 'bh/mark-parent-tasks-started 'append)


(setq org-enable-priority-commands nil)

(setq org-refile-target-verify-function 'bh/verify-refile-target)

(setq org-todo-keywords
      (quote ((sequence "TODO(t)" "NEXT(n)" "STARTED(s)" "|" "DONE(d!/!)")
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

;; (setq org-tag-persistent-alist
;;       '(("config " . ?c)
;;      ("dev" . ?d)
;;      ("emacs " . ?e)
;;      ("javascript " . ?j)
;;      ("music " . ?m)
;;      ("php" . ?p)
;;      ("project" . ?w)
;;      ("python" . ?g)
;;      ("self " . ?f)
;;      ("social " . ?s)
;;      ("tumbles " . ?t)
;;      ("vim" . ?v)))

;;dev(d) tumbles(t) social(s) config(c) project(p) self(f) music(m) emacs(e)
;; org-mode AGENDA stuff
;; (setq org-agenda-files (list "~/org/work.org"
;;                           "~/org/api.chaseleads.com.org"
;;                           "~/org/llinks.net.org"
;;                           "~/org/tools.org"
;;                           "~/org/gtd.org"
;;                           "~/org/refile.org"
;;                           "~/org/asp.net.org"
;;                           "~/org/patient.devvz.com.org"
;;                           "~/org/school.org"))

(setq org-agenda-files (list "~/org/gtd.org" "~/org/refile.org" "~/org/jira/"))

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
                            (org-tags-match-list-sublevels 'indented)
                            (org-agenda-skip-function 'bh/skip-non-stuck-projects)))
                (tags-todo "-WAITING-CANCELLED/!NEXT|STARTED"
                           ((org-agenda-overriding-header "Next Tasks")
                            (org-agenda-skip-function 'bh/skip-projects-and-habits)
                            (org-agenda-todo-ignore-scheduled t)
                            (org-agenda-todo-ignore-deadlines t)
                            (org-tags-match-list-sublevels t)
                            (org-agenda-sorting-strategy
                             '(todo-state-down effort-up category-keep))))
                (tags-todo "-REFILE-CANCELLED/!-NEXT-STARTED-WAITING"
                           ((org-agenda-overriding-header "Tasks")
                            (org-agenda-skip-function 'bh/skip-projects-and-habits)
                            (org-tags-match-list-sublevels 'indented)
                            (org-agenda-todo-ignore-scheduled t)
                            (org-agenda-todo-ignore-deadlines t)
                            (org-agenda-sorting-strategy
                             '(category-keep))))
                (tags-todo "-CANCELLED/!"
                           ((org-agenda-overriding-header "Projects")
                            (org-agenda-skip-function 'bh/skip-non-projects)
                            (org-tags-match-list-sublevels 'indented)
                            (org-agenda-sorting-strategy
                             '(category-keep))))
                (todo "WAITING|SOMEDAY"
                      ((org-agenda-overriding-header "Waiting and Postponed tasks")
                       (org-agenda-skip-function 'bh/skip-projects-and-habits)))
                (tags "-REFILE/"
                      ((org-agenda-overriding-header "Tasks to Archive")
                       (org-agenda-skip-function 'bh/skip-non-archivable-tasks))))
               nil)
              ("r" "Tasks to Refile" tags "REFILE"
               ((org-agenda-overriding-header "Notes and Tasks to Refile")
                (org-agenda-overriding-header "Tasks to Refile")))
              ("#" "Stuck Projects" tags-todo "-CANCELLED/!"
               ((org-agenda-overriding-header "Stuck Projects")
                (org-tags-match-list-sublevels 'indented)
                (org-agenda-skip-function 'bh/skip-non-stuck-projects)))
              ("n" "Next Tasks" tags-todo "-WAITING-CANCELLED/!NEXT|STARTED"
               ((org-agenda-overriding-header "Next Tasks")
                (org-agenda-skip-function 'bh/skip-projects-and-habits)
                (org-agenda-todo-ignore-scheduled t)
                (org-agenda-todo-ignore-deadlines t)
                (org-tags-match-list-sublevels t)
                (org-agenda-sorting-strategy
                 '(todo-state-down effort-up category-keep))))
              ("R" "Tasks" tags-todo "-REFILE-CANCELLED/!-NEXT-STARTED-WAITING"
               ((org-agenda-overriding-header "Tasks")
                (org-agenda-skip-function 'bh/skip-projects-and-habits)
                (org-tags-match-list-sublevels 'indented)
                (org-agenda-sorting-strategy
                 '(category-keep))))
              ("p" "Projects" tags-todo "-CANCELLED/!"
               ((org-agenda-overriding-header "Projects")
                (org-agenda-skip-function 'bh/skip-non-projects)
                (org-tags-match-list-sublevels 'indented)
                (org-agenda-sorting-strategy
                 '(category-keep))))
              ("w" "Waiting Tasks" todo "WAITING|SOMEDAY"
               ((org-agenda-overriding-header "Waiting and Postponed tasks"))
               (org-agenda-skip-function 'bh/skip-projects-and-habits))
              ("A" "Tasks to Archive" tags "-REFILE/"
               ((org-agenda-overriding-header "Tasks to Archive")
                (org-agenda-skip-function 'bh/skip-non-archivable-tasks))))))


(setq org-tags-match-list-sublevels nil)


  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;             clocking                 ;;
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; in case you ever want to mess with the header line...
;;(setq org-clock-in-hook '(lambda ()
;;                         (setq default-header-line-format '(("org-clocking: " org-mode-line-string " ")))))
;;(setq org-clock-out-hook '(lambda ()
;;                          (setq default-header-line-format nil)))
;;(setq org-clock-cancel-hook '(lambda ()
;;                             (setq default-header-line-format nil)))

;; Resume clocking tasks when emacs is restarted
(org-clock-persistence-insinuate)
;;
;; Small windows on my Eee PC displays only the end of long lists which isn't very useful
(setq org-clock-history-length 10)
;; Resume clocking task on clock-in if the clock is open
(setq org-clock-in-resume t)
;; Change task to STARTED when clocking in
(setq org-clock-in-switch-to-state 'bh/clock-in-to-started)
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

(setq bh/keep-clock-running nil)

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
(require 'org-publish)
(setq org-publish-project-alist
      '(("org-notes"
         :base-directory "~/org/"
         :base-extension "org"
         :publishing-directory "~/public_html/"
         :recursive t
         :publishing-function org-publish-org-to-html
         :headline-levels 10
         :makeindex t
         :auto-sitemap t
         :sitemap-filename "sitemap.org"
         :sitemap-title "Sitemap"
         :auto-preamble t)
        ("org-static"
         :base-directory "~/org/"
         :base-extension "css\\|js\\|png\\|jpg\\|gif\\|pdf\\|mp3\\|ogg\\|swf"
         :publishing-directory "~/public_html/"
         :recursive t
         :publishing-function org-publish-attachment)
        ("org" :components ("org-notes" "org-static"))))



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


  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; defuns...move this to another file someday ;;
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; always get the gtd
(defun gtd ()
  (interactive)
  (find-file "~/org/gtd.org"))

;; Remove empty LOGBOOK drawers on clock out
(defun bh/remove-empty-drawer-on-clock-out ()
  (interactive)
  (save-excursion
    (beginning-of-line 0)
    (org-remove-empty-drawer-at "LOGBOOK" (point))))

  ;;;; Refile settings
                                        ; Exclude DONE state tasks from refile targets
(defun bh/verify-refile-target ()
  "Exclude todo keywords with a done state from refile targets"
  (not (member (nth 2 (org-heading-components)) org-done-keywords)))

(defun bh/show-org-agenda ()
  (interactive)
  (switch-to-buffer "*Org Agenda*")
  (delete-other-windows))

(defun bh/insert-inactive-timestamp ()
  (interactive)
  (org-insert-time-stamp nil t t nil nil nil))

(defun bh/insert-heading-inactive-timestamp ()
  (save-excursion
    (org-return)
    (org-cycle)
    (bh/insert-inactive-timestamp)))

(defun bh/hide-other ()
  (interactive)
  (save-excursion
    (org-back-to-heading)
    (org-shifttab)
    (org-reveal)
    (org-cycle)))

(defun bh/set-truncate-lines ()
  "Toggle value of truncate-lines and refresh window display."
  (interactive)
  (setq truncate-lines (not truncate-lines))
  ;; now refresh window display (an idiom from simple.el):
  (save-excursion
    (set-window-start (selected-window)
                      (window-start (selected-window)))))

(defun bh/switch-to-scratch ()
  (interactive)
  (switch-to-buffer "*scratch*"))

(defun bh/untabify ()
  (interactive)
  (untabify (point-min) (point-max)))

(defun bh/clock-in-task-by-id (id)
  "Clock in a task by id"
  (save-restriction
    (widen)
    (org-with-point-at (org-id-find id 'marker)
      (org-clock-in nil))))

(defun bh/clock-in-last-task (arg)
  "Clock in the interrupted task if there is one
  Skip the default task and get the next one.
  A prefix arg forces clock in of the default task."
  (interactive "p")
  (let ((clock-in-to-task
         (cond
          ((eq arg 4) org-clock-default-task)
          ((and (org-clock-is-active)
                (equal org-clock-default-task (cadr org-clock-history)))
           (caddr org-clock-history))
          ((org-clock-is-active) (cadr org-clock-history))
          ((equal org-clock-default-task (car org-clock-history)) (cadr org-clock-history))
          (t (car org-clock-history)))))
    (org-with-point-at clock-in-to-task
      (org-clock-in nil))))

(defun bh/clock-in-to-started (kw)
  "Switch task from TODO or NEXT to STARTED when clocking in.
  Skips capture tasks."
  (if (and (member (org-get-todo-state) (list "TODO" "NEXT"))
           (not (and (boundp 'org-capture-mode) org-capture-mode)))
      "STARTED"))



(defun bh/org-todo ()
  (interactive)
  (widen)
  (org-narrow-to-subtree)
  (org-show-todo-tree nil))


(defun bh/widen ()
  (interactive)
  (widen)
  (org-reveal))

(defun bh/is-project-p ()
  "Any task with a todo keyword subtask"
  (let ((has-subtask)
        (subtree-end (save-excursion (org-end-of-subtree t)))
        (is-a-task (member (nth 2 (org-heading-components)) org-todo-keywords-1)))
    (save-excursion
      (forward-line 1)
      (while (and (not has-subtask)
                  (< (point) subtree-end)
                  (re-search-forward "^\*+ " subtree-end t))
        (when (member (org-get-todo-state) org-todo-keywords-1)
          (setq has-subtask t))))
    (and is-a-task has-subtask)))

(defun bh/is-subproject-p ()
  "Any task which is a subtask of another project"
  (let ((is-subproject)
        (is-a-task (member (nth 2 (org-heading-components)) org-todo-keywords-1)))
    (save-excursion
      (while (and (not is-subproject) (org-up-heading-safe))
        (when (member (nth 2 (org-heading-components)) org-todo-keywords-1)
          (setq is-subproject t))))
    (and is-a-task is-subproject)))

(defun bh/skip-non-stuck-projects ()
  "Skip trees that are not stuck projects"
  (let* ((next-headline (save-excursion (or (outline-next-heading) (point-max))))
         (subtree-end (save-excursion (org-end-of-subtree t)))
         (has-next (save-excursion
                     (forward-line 1)
                     (and (< (point) subtree-end)
                          (re-search-forward "^\\*+ \\(NEXT\\|STARTED\\) " subtree-end t)))))
    (if (and (bh/is-project-p) (not has-next))
        nil ; a stuck project, has subtasks but no next task
      next-headline)))

(defun bh/skip-non-projects ()
  "Skip trees that are not projects"
  (let ((subtree-end (save-excursion (org-end-of-subtree t))))
    (if (bh/is-project-p)
        nil
      subtree-end)))

(defun bh/skip-project-trees-and-habits ()
  "Skip trees that are projects"
  (let ((subtree-end (save-excursion (org-end-of-subtree t))))
    (cond
     ((bh/is-project-p)
      subtree-end)
     ;; ((org-is-habit-p)
     ;;  subtree-end)
     (t
      nil))))

(defun bh/skip-projects-and-habits ()
  "Skip trees that are projects and tasks that are habits"
  (let ((next-headline (save-excursion (or (outline-next-heading) (point-max)))))
    (cond
     ((bh/is-project-p)
      next-headline)
     ;; ((org-is-habit-p)
     ;;  next-headline)
     (t
      nil))))

(defun bh/skip-non-subprojects ()
  "Skip trees that are not projects"
  (let ((next-headline (save-excursion (outline-next-heading))))
    (if (bh/is-subproject-p)
        nil
      next-headline)))

(defun bh/find-project-task ()
  "Move point to the parent (project) task if any"
  (let ((parent-task (save-excursion (org-back-to-heading) (point))))
    (while (org-up-heading-safe)
      (when (member (nth 2 (org-heading-components)) org-todo-keywords-1)
        (setq parent-task (point))))
    (goto-char parent-task)
    parent-task))


(defun bh/set-agenda-restriction-lock (arg)
  "Set restriction lock to current subtree or file if prefix is specified"
  (interactive "p")
  (let* ((pom (org-get-at-bol 'org-hd-marker))
         (tags (org-with-point-at pom (org-get-tags-at))))
    (let ((restriction-type (if (equal arg 4) 'file 'subtree)))
      (cond
       ((equal major-mode 'org-agenda-mode)
        (org-with-point-at pom
          (org-agenda-set-restriction-lock restriction-type)))
       ((and (equal major-mode 'org-mode) (org-before-first-heading-p))
        (org-agenda-set-restriction-lock 'file))
       (t
        (org-with-point-at pom
          (org-agenda-set-restriction-lock restriction-type)))))))

(defun bh/punch-in (arg)
  "Start continuous clocking and set the default task to the
  selected task.  If no task is selected set the Organization task
  as the default task."
  (interactive "p")
  (setq bh/keep-clock-running t)
  (if (equal major-mode 'org-agenda-mode)
      ;;
      ;; We're in the agenda
      ;;
      (let* ((marker (org-get-at-bol 'org-hd-marker))
             (tags (org-with-point-at marker (org-get-tags-at))))
        (if (and (eq arg 4) tags)
            (org-agenda-clock-in '(16))
          (bh/clock-in-organization-task-as-default)))
    ;;
    ;; We are not in the agenda
    ;;
    (save-restriction
      (widen)
                                        ; Find the tags on the current task
      (if (and (equal major-mode 'org-mode) (not (org-before-first-heading-p)) (eq arg 4))
          (org-clock-in '(16))
        (bh/clock-in-organization-task-as-default)))))

(defun bh/punch-out ()
  (interactive)
  (setq bh/keep-clock-running nil)
  (when (org-clock-is-active)
    (org-clock-out))
  (org-agenda-remove-restriction-lock))

(defun bh/clock-in-default-task ()
  (save-excursion
    (org-with-point-at org-clock-default-task
      (org-clock-in))))

(defun bh/clock-in-parent-task ()
  "Move point to the parent (project) task if any and clock in"
  (let ((parent-task))
    (save-excursion
      (save-restriction
        (widen)
        (while (and (not parent-task) (org-up-heading-safe))
          (when (member (nth 2 (org-heading-components)) org-todo-keywords-1)
            (setq parent-task (point))))
        (if parent-task
            (org-with-point-at (or parent-task)
              (org-clock-in))
          (when bh/keep-clock-running
            (bh/clock-in-default-task)))))))

(defvar bh/organization-task-id (list "931ad773-8802-4749-b7e6-33a4c1cfaddf"))

(defun bh/clock-in-organization-task-as-default ()
  (interactive)
  (save-restriction
    (widen)
    (org-with-point-at (org-id-find bh/organization-task-id 'marker)
      (org-clock-in '(16)))))

(defun bh/clock-out-maybe ()
  (when (and bh/keep-clock-running
             (not org-clock-clocking-in)
             (marker-buffer org-clock-default-task)
             (not org-clock-resolving-clocks-due-to-idleness))
    (bh/clock-in-parent-task)))



;; unfortunately, sacha's functions seem to break everything...segmentation error...weak
;;
  ;;;;(defun sacha/org-show-load ()
   ;;;; "Show my unscheduled time and free time for the day."
    ;;;;(interactive)
    ;;;;(let ((time (sacha/org-calculate-free-time
                 ;;;; today
     ;;;;            (calendar-gregorian-from-absolute (time-to-days (current-time)))
                 ;;;; now
      ;;;;           (let* ((now (decode-time))
       ;;;;                 (cur-hour (nth 2 now))
        ;;;;                (cur-min (nth 1 now)))
;;          (+ (* cur-hour 60) cur-min))
;; until the last time in my time grid
;;       (let ((last (car (last (elt org-agenda-time-grid 2)))))
;;        (+ (* (/ last 100) 60) (% last 100))))))
;; (message "%.1f%% load: %d minutes to be scheduled, %d minutes free, %d minutes gap\n"
;;        (/ (car time) (* .01 (cdr time)))
;;       (car time)
;;      (cdr time)
;;     (- (cdr time) (car time)))))

;;(defun sacha/org-agenda-load (match)
;; "Can be included in `org-agenda-custom-commands'."
;;(let ((inhibit-read-only t)
;;     (time (sacha/org-calculate-free-time
;; today
;;           (calendar-gregorian-from-absolute org-starting-day)
;; now if today, else start of day
;;          (if (= org-starting-day
;;                (time-to-days (current-time)))
;;            (let* ((now (decode-time))
;;                  (cur-hour (nth 2 now))
;;                 (cur-min (nth 1 now)))
;;           (+ (* cur-hour 60) cur-min))
;;      (let ((start (car (elt org-agenda-time-grid 2))))
;;       (+ (* (/ start 100) 60) (% start 100))))
;; until the last time in my time grid
;;  (let ((last (car (last (elt org-agenda-time-grid 2)))))
;;   (+ (* (/ last 100) 60) (% last 100))))))
;;(goto-char (point-max))
;;(insert (format
;;        "%.1f%% load: %d minutes to be scheduled, %d minutes free, %d minutes gap\n"
;;       (/ (car time) (* .01 (cdr time)))
;;      (car time)
;;     (cdr time)
;;    (- (cdr time) (car time))))))
;;
;;(defun sacha/org-calculate-free-time (date start-time end-of-day)
;; "Return a cons cell of the form (TASK-TIME . FREE-TIME) for DATE, given START-TIME and END-OF-DAY.
;;DATE is a list of the form (MONTH DAY YEAR).
;;START-TIME and END-OF-DAY are the number of minutes past midnight."
;;(save-window-excursion
;;(let ((files org-agenda-files)
;;     (total-unscheduled 0)
;;    (total-gap 0)
;;   file
;;  rtn
;; rtnall
;;entry
;;(last-timestamp start-time)
;;scheduled-entries)
;;(while (setq file (car files))
;; (catch 'nextfile
;;  (org-check-agenda-file file)
;; (setq rtn (org-agenda-get-day-entries file date :scheduled :timestamp))
;;(setq rtnall (append rtnall rtn)))
;;(setq files (cdr files)))
;; For each item on the list
;;(while (setq entry (car rtnall))
;; (let ((time (get-text-property 1 'time entry)))
;;  (cond
;;  ((and time (string-match "\\([^-]+\\)-\\([^-]+\\)”" time))
;;  (setq scheduled-entries (cons (cons
;;                                (save-match-data (appt-convert-time (match-string 1 time)))
;;                               (save-match-data (appt-convert-time (match-string 2 time))))
;;                             scheduled-entries)))
;;((and time
;;     (string-match “\\([^-]+\\)\\.+” time)
;;    (string-match “^[A-Z]+ \\(\\[#[A-Z]\\]\\)? \\([0-9]+\\)” (get-text-property 1 ‘txt entry)))
;;(setq scheduled-entries
;;     (let ((start (and (string-match “\\([^-]+\\)\\.+” time)
;;                     (appt-convert-time (match-string 1 time)))))
;;     (cons (cons start
;;                (and (string-match “^[A-Z]+ \\(\\[#[A-Z]\\]\\)? \\([0-9]+\\) ” (get-text-property 1 ‘txt entry))
;;                    (+ start (string-to-number (match-string 2 (get-text-property 1 ‘txt entry))))))
;;        scheduled-entries))))
;;((string-match “^[A-Z]+ \\([0-9]+\\)” (get-text-property 1 ‘txt entry))
;;(setq total-unscheduled (+ (string-to-number
;;                           (match-string 1 (get-text-property 1 ‘txt entry)))
;;                         total-unscheduled)))))
;;(setq rtnall (cdr rtnall)))
;; Sort the scheduled entries by time
;;(setq scheduled-entries (sort scheduled-entries (lambda (a b) (< (car a) (car b)))))

;;(while scheduled-entries
;; (let ((start (car (car scheduled-entries)))
;;      (end (cdr (car scheduled-entries))))
;;(cond
;; are we in the middle of this timeslot?
;;((and (>= last-timestamp start)
;;     (< = last-timestamp end))
;; move timestamp later, no change to time
;;(setq last-timestamp end))
;; are we completely before this timeslot?
;;((< last-timestamp start)
;; add gap to total, skip to the end
;;(setq total-gap (+ (- start last-timestamp) total-gap))
;;(setq last-timestamp end)))
;;(setq scheduled-entries (cdr scheduled-entries))))
;;(if (< last-timestamp end-of-day)
;;   (setq total-gap (+ (- end-of-day last-timestamp) total-gap)))
;;(cons total-unscheduled total-gap))))

;;(defun sacha/org-clock-in-if-starting ()
;; "Clock in when the task is marked STARTED."
;;(when (and (string= state "STARTED")
;;          (not (string= last-state state)))
;;(org-clock-in)))
;;(add-hook 'org-after-todo-state-change-hook
;;        'sacha/org-clock-in-if-starting)
;;(defadvice org-clock-in (after sacha activate)
;; "Set this task's status to 'STARTED'."
;;(org-todo "STARTED"))

;;(defun sacha/org-clock-out-if-waiting ()
;; "Clock in when the task is marked STARTED."
;;(when (and (string= state "WAITING")
;;          (not (string= last-state state)))
;;(org-clock-out)))
;;(add-hook 'org-after-todo-state-change-hook
;;        'sacha/org-clock-out-if-waiting)
