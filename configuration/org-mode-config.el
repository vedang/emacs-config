;; Configuration for org-mode

(require 'org-install)


(setq org-directory "~/Documents/Notes-GTD"
      org-archive-directory (concat org-directory "/archive")
      org-archive-location (concat org-archive-directory "/%s_archive::")
      org-completion-use-ido t
      org-default-notes-file (concat org-directory "/remember-notes.org")
      org-agenda-files (list
                        org-directory
                        org-archive-directory))


;; Standard org-mode key bindings
(global-set-key (kbd "C-c l") 'org-store-link)
(global-set-key (kbd "C-c t") 'org-todo)
(global-set-key (kbd "C-c C-r") 'org-capture)
(global-set-key (kbd "<f6>") 'org-capture)
(global-set-key (kbd "<S-f5>") 'widen)
(global-set-key (kbd "<f11>") 'org-clock-goto)
(global-set-key (kbd "<f12>") 'org-agenda)
(global-set-key (kbd "C-<f11>") 'org-clock-in)
(global-set-key (kbd "<f9> SPC") 'bh/clock-in-last-task)
(global-set-key (kbd "<f9> i") 'bh/clock-in)
(global-set-key (kbd "<f9> o") 'bh/clock-out)


;; Auto starting org-mode for following file types
(add-to-list 'auto-mode-alist '("\\.\\(org\\|org_archive\\|txt\\)$" . org-mode))
(transient-mark-mode 1)

;; Undefine C-c [ and C-c ] since this breaks my org-agenda files
;; when directories are included
;; It expands the files in the directories individually
(add-hook 'org-mode-hook (lambda ()
                           (turn-on-font-lock)
                           (org-defkey org-mode-map "\C-c[" 'undefined)
                           (org-defkey org-mode-map "\C-c]" 'undefined)))


;; Settings for org-capture
(setq org-capture-templates
      (quote
       (("t" "todo" entry
         (file (concat org-directory "/remember-notes.org"))
         "* TODO %?\n%U\n%a\n %i" :clock-in t :clock-resume t)
        ("n" "note" entry
         (file (concat org-directory "/remember-notes.org"))
         "* %?  :NOTE:\n%U\n%a\n  %i" :clock-in t :clock-resume t)
        ("l" "linklog" entry
         (file (concat org-directory "/linklog.org"))
         "* %?\n%U\n%a\n %i" :clock-in t :clock-resume t)
        ("p" "phone" entry
         (file (concat org-directory "/remember-notes.org"))
         "* %?\n%U\n%a\n %i" :clock-in t :clock-resume t))))


;; Setup for Re-filing:
;; Targets include this file and any file contributing to the agenda
;; - up to 2 levels deep
(setq org-refile-targets (quote ((org-agenda-files :maxlevel . 2)
                                 (nil :maxlevel . 2))))
;; Targets start with the file name - allows creating level 1 tasks
(setq org-refile-use-outline-path (quote file))
;; Targets complete directly with IDO
(setq org-outline-path-complete-in-steps nil)
;; Allow refile to create parent tasks with confirmation
(setq org-refile-allow-creating-parent-nodes (quote confirm))

;; org-todo settings
;; I need more todo keywords than present by default
;; keys mentioned in brackets are hot-keys for the States
;; ! indicates insert timestamp
;; @ indicates insert note
;; / indicates entering the state
(setq org-todo-keywords
      (quote ((sequence "TODO(t!/!)" "WORKING(w!/!)" "REDO(r@/!)" "|"
                        "DONE(d!/@)" "DELEGATED(e@/!)" "MOSTLYDONE(M@/!)")
              (sequence "PROJECT(p)" "TASK(T!/!)" "WAITINGTOMERGE(m/!)"
                        "WAITINGTODEPLOY(a/!)" "|"
                        "SOMEDAY(s)" "CANCELLED(c@/!)"))))
(setq org-todo-keyword-faces
      (quote (("TODO" :foreground "red" :weight bold)
              ("WORKING" :foreground "orange" :weight bold)
              ("REDO" :foreground "magenta" :weight bold)
              ("DONE" :foreground "lightgreen" :weight bold)
              ("DELEGATED" :foreground "lightgreen" :weight bold)
              ("MOSTLYDONE" :foreground "lightblue" :weight bold)
              ("PROJECT" :foreground "lightblue" :weight bold)
              ("TASK" :foreground "darkblue" :weight bold)
              ("WAITINGTOMERGE" :foreground "gray" :weight bold)
              ("WAITINGTODEPLOY" :foreground "gray" :weight bold)
              ("SOMEDAY" :foreground "magenta" :weight bold)
              ("CANCELLED" :foreground "lightgreen" :weight bold))))

;; Changing State should trigger following Tag changes
(setq org-todo-state-tags-triggers
      (quote (("SOMEDAY"
               ("WAITING" . t) ("NEXT"))
              (done
               ("NEXT") ("WAITING"))
              ("WAITINGTOMERGE"
               ("NEXT") ("WAITING" . t))
              ("WAITINGTODEPLOY"
               ("NEXT") ("WAITING" . t))
              ("TODO"
               ("WAITING"))
              ("WORKING"
               ("WAITING") ("NEXT" . t)))))
;; Faster state set
(setq org-use-fast-todo-selection t)
;;; Allow me to change state without it being logged
(setq org-treat-S-cursor-todo-selection-as-state-change nil)
;;; show TODO counts of _all_ subtasks under a heading
(setq org-hierarchical-todo-statistics nil
      org-hierarchical-checkbox-statistics nil)

;; Important Tag list
(setq org-tag-alist (quote ((:startgroup)
                            ("@office" . ?w)
                            ("@home" . ?h)
                            ("@errand" . ?e)
                            (:endgroup)
                            ("LowPri" . ?l)
                            ("NEXT" . ?N)
                            ("RELEASE" . ?r)
                            ("NOTE" . ?n)
                            ("PUBLISHED" . ?p)
                            ("WAITING" . ?a)
                            ("future" . ?f))))

;; I need more priorities that provided by default
(setq org-lowest-priority ?E)
(setq org-default-priority ?E)

;; Logbook settings
(setq org-log-done (quote time)
      org-log-into-drawer t
      org-log-reschedule 'note
      org-log-redeadline 'note)

;; settings for org-clock
;; Resume clocking tasks when emacs is restarted
(org-clock-persistence-insinuate)
(setq org-clock-history-length 35)
;; Resume clocking task on clock-in if the clock is open
(setq org-clock-in-resume t)
;; Change task state to WORKING when clocking in
(defun bh/clock-in-to-working (kw)
  "Switch task from TODO to WORKING when clocking in.
Skips capture tasks and tasks with subtasks"
  (if (and (string-equal kw "TODO")
           (not (and (boundp 'org-capture-mode) org-capture-mode)))
      (let ((subtree-end (save-excursion (org-end-of-subtree t)))
            (has-subtask nil))
        (save-excursion
          (forward-line 1)
          (while (and (not has-subtask)
                      (< (point) subtree-end)
                      (re-search-forward "^\*+ " subtree-end t))
            (when (member (org-get-todo-state) org-not-done-keywords)
              (setq has-subtask t))))
        (when (not has-subtask)
          "WORKING"))))
(setq org-clock-in-switch-to-state (quote bh/clock-in-to-working))
;; Separate drawers for clocking and logs
(setq org-drawers (quote ("PROPERTIES" "LOGBOOK" "CLOCK")))
;; Save clock data in the CLOCK drawer
;; and state changes and notes in the LOGBOOK drawer
(setq org-clock-into-drawer "CLOCK")
;; Sometimes I change tasks I'm clocking quickly
;; this removes clocked tasks with 0:00 duration
(setq org-clock-out-remove-zero-time-clocks t)
;; Remove empty drawers on clock out
(defun bh/remove-empty-drawer-on-clock-out ()
  (interactive)
  (save-excursion
    (beginning-of-line 0)
    (org-remove-empty-drawer-at "CLOCK" (point))
    (org-remove-empty-drawer-at "LOGBOOK" (point))))
(add-hook 'org-clock-out-hook 'bh/remove-empty-drawer-on-clock-out 'append)
;; Clock out when moving task to a done state
(setq org-clock-out-when-done t)
;; Save the running clock and all clock history when exiting Emacs,
;; load it on startup
(setq org-clock-persist t)
(setq org-clock-persist-file (concat tempfiles-dir "org-clock-save"))
;; Enable auto clock resolution for finding open clocks
(setq org-clock-auto-clock-resolution (quote when-no-clock-is-running))
;; Include current clocking task in clock reports
(setq org-clock-report-include-clocking-task t)

(setq bh/keep-clock-running nil)

(defun bh/clock-in-last-task ()
  "Clock in the interrupted task if there is one"
  (interactive)
  (let ((clock-in-to-task (if (org-clock-is-active)
                              (setq clock-in-to-task (cadr org-clock-history))
                            (setq clock-in-to-task (car org-clock-history)))))
    (org-with-point-at clock-in-to-task
      (org-clock-in nil))))

(defun bh/clock-in ()
  (interactive)
  (setq bh/keep-clock-running t)
  (if (marker-buffer org-clock-default-task)
      (bh/clock-in-default-task)
    (unless (marker-buffer org-clock-default-task)
      (org-agenda nil "c"))))

(defun bh/clock-out ()
  (interactive)
  (setq bh/keep-clock-running nil)
  (when (org-clock-is-active)
    (org-clock-out)))

(defun bh/clock-in-default-task ()
  (save-excursion
    (org-with-point-at org-clock-default-task
      (org-clock-in))))

(defun bh/clock-out-maybe ()
  (when (and bh/keep-clock-running
             (not org-clock-clocking-in)
             (marker-buffer org-clock-default-task))
    (bh/clock-in-default-task)))

(add-hook 'org-clock-out-hook 'bh/clock-out-maybe 'append)

(setq org-agenda-log-mode-items (quote (clock))
      org-agenda-clockreport-parameter-plist (quote
                                              (:link nil :maxlevel 3))
      org-agenda-span 1
      org-columns-default-format
      "%80ITEM(Task) %10Effort(Effort){:} %10CLOCKSUM"
      org-global-properties
      (quote (("Effort_ALL" . "0:10 0:30 1:00 2:00 3:00 4:00 5:00 6:00 8:00"))))

;; Custom views for Agenda
(setq org-agenda-custom-commands
      (quote (("d" "Tasks delegated to somebody" todo "DELEGATED"
               ((org-use-tag-inheritance nil)
                (org-agenda-todo-ignore-with-date nil)))
              ("w" "Tasks waiting for something" tags-todo "WAITING"
               ((org-use-tag-inheritance nil)
                (org-agenda-todo-ignore-with-date nil)))
              ("n" "Next Tasks" tags-todo "NEXT"
               ((org-use-tag-inheritance t)
                (org-agenda-todo-ignore-with-date nil)))
              ("r" "Release Tasks" tags-todo "RELEASE"
               ((org-use-tag-inheritance t)
                (org-agenda-todo-ignore-with-date nil)))
              ("R" "Refile New Notes and Tasks" tags "REFILE"
               ((org-agenda-todo-ignore-with-date nil)))
              ("c" "Select default clocking task" tags "LEVEL=1-REFILE"
               ((org-agenda-skip-function
                 '(org-agenda-skip-subtree-if 'notregexp "^\\* Organization"))
                (org-agenda-overriding-header
                 "Set default clocking task with C-u C-u I"))))))

;; Always highlight current agenda line
(add-hook 'org-agenda-mode-hook '(lambda ()
                                   (hl-line-mode 1)))
;; Don't show future entries for repeating tasks
(setq org-agenda-repeating-timestamp-show-all nil)
;; Show all agenda dates - even if empty
(setq org-agenda-show-all-dates t)
;; Sorting order for tasks on the agenda
(setq org-agenda-sorting-strategy
      (quote ((agenda time-up priority-down effort-up category-up)
              (todo todo-state-up priority-up)
              (tags priority-down))))
;; Start the weekly agenda today
(setq org-agenda-start-on-weekday nil)
;; Disable display of the time grid
(setq org-agenda-time-grid
      (quote (nil "----------------"
                  (800 1000 1200 1400 1600 1800 2000))))
;; Gimme 30 days warning of deadlines
(setq org-deadline-warning-days 30)
;; Keep tasks with dates off the global todo lists
(setq org-agenda-todo-ignore-with-date t)
;; Remove completed deadline tasks from the agenda view
(setq org-agenda-skip-deadline-if-done t)
;; Remove completed scheduled tasks from the agenda view
(setq org-agenda-skip-scheduled-if-done t)
;; Include agenda archive files when searching for things
(setq org-agenda-text-search-extra-files (quote (agenda-archives)))
;; Block task until all subtasks are in a done todo state
(setq org-enforce-todo-dependencies t)

;; Functions for / RET filtering in the agenda
(defun bh/weekday-p ()
  (let ((wday (nth 6 (decode-time))))
    (and (< wday 6) (> wday 0))))

(defun bh/working-p ()
  (let ((hour (nth 2 (decode-time))))
    (and (bh/weekday-p) (or (and (>= hour 9) (<= hour 12))
                            (and (>= hour 14) (<= hour 19))))))

(defun bh/org-auto-exclude-function (tag)
  (and (cond
        ((string= tag "@home")
         (bh/working-p))
        ((string= tag "@office")
         (not (bh/working-p)))
        ((or (string= tag "@errand") (string= tag "phone"))
         (let ((hour (nth 2 (decode-time))))
           (or (< hour 8) (> hour 21)))))
       (concat "-" tag)))

(setq org-agenda-auto-exclude-function 'bh/org-auto-exclude-function)


;; function to narrow view-field and make org-file more productive
(defun my-org-todo ()
  (interactive)
  (org-narrow-to-subtree)
  (org-show-todo-tree nil)
  (widen))

;; setup for Reminder
;; Erase all reminders and rebuild reminders for today from the agenda
(defadvice org-agenda-to-appt (before wickedcool activate)
  "Clear the appt-time-msg-list."
  (setq appt-time-msg-list nil))
(add-hook 'org-finalize-agenda-hook 'org-agenda-to-appt)
(appt-activate t)

;; If we leave Emacs running overnight -
;; reset the appointments one minute after midnight
(run-at-time "24:01" nil 'org-agenda-to-appt)

;; Make TAB the yas trigger key in the org-mode-hook and turn on flyspell mode
(add-hook 'org-mode-hook
          (lambda ()
            ;; yasnippet
            (make-variable-buffer-local 'yas/trigger-key)
            (setq yas/trigger-key [tab])
            (define-key yas/keymap [tab] 'yas/next-field-group)
            ;; flyspell mode to spell check everywhere
            (flyspell-mode 1)))

;; Export org table as CSV by default
(setq org-table-export-default-format "orgtbl-to-csv")


;; settings for Beamer
(setq org-ditaa-jar-path (concat dotfiles-dir
                                 "plugins/org-mode/contrib/scripts/ditaa.jar"))
(org-babel-do-load-languages
 'org-babel-load-languages
 '((ditaa . t)
   (dot . t)
   (C . t)
   (emacs-lisp . t)
   (python . t)
   (ruby . t)
   (sh . t)
   (clojure . t)))


(unless (boundp 'org-export-latex-classes)
  (setq org-export-latex-classes nil))
;; allow for export=>beamer by placing #+LaTeX_CLASS: beamer in org files
(add-to-list 'org-export-latex-classes
             ;; beamer class, for presentations
             '("beamer"
               "\\documentclass[11pt]{beamer}\n
      \\mode<{{{beamermode}}}>\n
      \\usetheme{{{{beamertheme}}}}\n
      \\usecolortheme{{{{beamercolortheme}}}}\n
      \\beamertemplateballitem\n
      \\setbeameroption{show notes}
      \\usepackage{color}
      \\usepackage{listings}
      \\lstset{numbers=none,language=[ISO]C++,tabsize=4,
  frame=single,
  basicstyle=\\small,
  showspaces=false,showstringspaces=false,
  showtabs=false,
  keywordstyle=\\color{blue}\\bfseries,
  commentstyle=\\color{red},
  }\n
      \\usepackage{verbatim}\n
      \\institute{{{{beamerinstitute}}}}\n
       \\subject{{{{beamersubject}}}}\n"

               ("\\section{%s}" . "\\section*{%s}")

               ("\\begin{frame}[fragile]\\frametitle{%s}"
                "\\end{frame}"
                "\\begin{frame}[fragile]\\frametitle{%s}"
                "\\end{frame}")))

;; letter class, for formal letters
(add-to-list 'org-export-latex-classes

             '("letter"
               "\\documentclass[11pt]{letter}\n
      \\usepackage{color}\n
      \\usepackage{listings}
      \\lstset{numbers=none,language=[ISO]C++,tabsize=4,
  frame=single,
  basicstyle=\\small,
  showspaces=false,showstringspaces=false,
  showtabs=false,
  keywordstyle=\\color{blue}\\bfseries,
  commentstyle=\\color{red},
  }\n
      \\usepackage{verbatim}\n"

               ("\\section{%s}" . "\\section*{%s}")
               ("\\subsection{%s}" . "\\subsection*{%s}")
               ("\\subsubsection{%s}" . "\\subsubsection*{%s}")
               ("\\paragraph{%s}" . "\\paragraph*{%s}")
               ("\\subparagraph{%s}" . "\\subparagraph*{%s}")))

;; article class, for articles
(add-to-list 'org-export-latex-classes
             '("article"
               "\\documentclass[10pt]{article}
\\usepackage{color}
\\usepackage{listings}
\\lstset{numbers=none,language=[ISO]C++,tabsize=4,
  frame=single,
  basicstyle=\\small,
  showspaces=false,showstringspaces=false,
  showtabs=false,
  keywordstyle=\\color{blue}\\bfseries,
  commentstyle=\\color{red},
  }\n
\\usepackage{verbatim}\n
\\usepackage[left=1in,top=1in,right=1in,bottom=1in,head=0.2in,foot=0.2in]{geometry}"
               ("\\section{%s}" . "\\section*{%s}")
               ("\\subsection{%s}" . "\\subsection*{%s}")
               ("\\subsubsection{%s}" . "\\subsubsection*{%s}")
               ("\\paragraph{%s}" . "\\paragraph*{%s}")
               ("\\subparagraph{%s}" . "\\subparagraph*{%s}")))

;; I don't want org mode to export a_b as a subscript b in latex.
;; I mostly write code documents and this is never the intended behavior
(setq org-export-with-sub-superscripts nil)

;; I want to add comments to my org files without
;; having them show up in the latex export.
(setq org-export-blocks nil)

(add-to-list 'org-export-blocks
             '(src org-babel-exp-src-blocks nil))
(add-to-list 'org-export-blocks
             '(comment org-export-blocks-format-comment nil))
(add-to-list 'org-export-blocks
             '(ditaa org-export-blocks-format-ditaa nil))
(add-to-list 'org-export-blocks
             '(dot org-export-blocks-format-dot nil))
;; ============================================================================

(provide 'org-mode-config)
;; A big thanks to Bernt Hansen for providing an awesome guide to
;; beginners so that we can harness the power of org-mode. Much of the
;; customization here is from his document about org-mode which can be
;; found here: http://doc.norang.ca/org-mode.html
