;;; utility-functions.el --- Useful Functions from around the web
;;; Author: Vedang Manerikar
;;; Created on: 08 Jan 2012
;;; Copyright (c) 2012 Vedang Manerikar <vedang.manerikar@gmail.com>

;; This file is not part of GNU Emacs.

;;; License:

;; This program is free software; you can redistribute it and/or
;; modify it under the terms of the Do What The Fuck You Want to
;; Public License, Version 2, which is included with this distribution.
;; See the file LICENSE.txt

;;; Code:


;;; function to display Tip of the Day
(defconst animate-n-steps 3)
(require 'cl-lib)
(random t)
(defun uf/totd ()
  (interactive)
  (let* ((commands (cl-loop for s being the symbols
                            when (commandp s) collect s))
         (command (nth (random (length commands)) commands)))
    (animate-string (concat ";; Initialization successful, welcome to "
                            (substring (emacs-version) 0 16)
                            "\n"
                            "Your tip for the day is:\n========================\n\n"
                            (describe-function command)
                            (delete-other-windows)
                            "\n\nInvoke with:\n\n"
                            (where-is command t)
                            (delete-other-windows))
                    0 0)))


;;; Function to launch a google search
(defun uf/google ()
  "googles a query or a selected region"
  (interactive)
  (browse-url
   (concat
    "http://www.google.com/search?q="
    (if mark-active
        (buffer-substring (region-beginning) (region-end))
      (read-string "Query: ")))))


;;; Function to mark complete word, and expand to sentence etc.
;;; by Nikolaj Schumacher, 2008-10-20. Released under GPL.
(defun uf/semnav-up (arg)
  (interactive "p")
  (when (nth 3 (syntax-ppss))
    (if (> arg 0)
        (progn
          (skip-syntax-forward "^\"")
          (goto-char (1+ (point)))
          (decf arg))
      (skip-syntax-backward "^\"")
      (goto-char (1- (point)))
      (incf arg)))
  (up-list arg))


;;; by Nikolaj Schumacher, 2008-10-20. Released under GPL.
;; NOTE: This function is rendered unnecessary since we now install
;; `magnars/expange-region'. Keeping this around because it's a nice
;; function that I like.
(defun uf/extend-selection (arg &optional incremental)
  "Select the current word.
Subsequent calls expands the selection to larger semantic unit."
  (interactive (list (prefix-numeric-value current-prefix-arg)
                     (or (and transient-mark-mode mark-active)
                         (eq last-command this-command))))
  (if incremental
      (progn
        (uf/semnav-up (- arg))
        (forward-sexp)
        (mark-sexp -1))
    (if (> arg 1)
        (uf/extend-selection (1- arg) t)
      (if (looking-at "\\=\\(\\s_\\|\\sw\\)*\\_>")
          (goto-char (match-end 0))
        (unless (memq (char-before) '(?\) ?\"))
          (forward-sexp)))
      (mark-sexp -1))))


;;; More Screen Space
(when (executable-find "wmctrl") ; apt-get install wmctrl
  (defun uf/full-screen-toggle ()
    (interactive)
    (shell-command "wmctrl -r :ACTIVE: -btoggle,fullscreen"))
  (global-set-key (kbd "<f1>") 'uf/full-screen-toggle))


;;; turn-on functions for various utilities
;;; =======================================


(defun uf/turn-on-hl-line-mode ()
  "highlight the current line"
  (if window-system (hl-line-mode t)))


(require 'whitespace)
(defun uf/turn-on-whitespace-mode ()
  (interactive)
  (setq whitespace-style '(face empty tabs lines trailing))
  (whitespace-mode t))


(defun uf/add-watchwords ()
  (font-lock-add-keywords
   nil '(("\\<\\(FIX\\|TODO\\|FIXME\\|HACK\\|REFACTOR\\):"
          1 font-lock-warning-face t))))


(defun uf/pretty-lambdas ()
  (font-lock-add-keywords
   nil `(("(?\\(lambda\\>\\)"
          (0 (progn (compose-region (match-beginning 1) (match-end 1)
                                    ,(make-char 'greek-iso8859-7 107))
                    nil))))))


(defun uf/untabify-buffer ()
  (interactive)
  (untabify (point-min) (point-max)))


(defun uf/indent-buffer ()
  (interactive)
  (indent-region (point-min) (point-max)))


(defun uf/cleanup-buffer ()
  "Perform a bunch of operations on the whitespace content of a buffer."
  (interactive)
  (uf/indent-buffer)
  (uf/untabify-buffer)
  (delete-trailing-whitespace))


(defun uf/sudo-edit (&optional arg)
  "Edit as root"
  (interactive "p")
  (if (or arg (not buffer-file-name))
      (find-file (concat "/sudo:root@localhost:" (ido-read-file-name "File: ")))
    (find-alternate-file (concat "/sudo:root@localhost:" buffer-file-name))))


(defun uf/revert-all-buffers ()
  "Refreshes all open buffers from their respective files."
  (interactive)
  (dolist (buf (buffer-list))
    (with-current-buffer buf
      (when (and (buffer-file-name) (not (buffer-modified-p)))
        (revert-buffer t t t))))
  (message "Refreshed open files."))


(defun uf/backward-kill-word-or-kill-region (&optional arg)
  "Rebind `C-w' to work differently based on whether a region is active.
If the region is selected, retain the original behaviour,
otherwise call `backward-kill-word' instead.  ARG is passed to
`backward-kill-word'."
  (interactive "p")
  (if (region-active-p)
      (kill-region (region-beginning) (region-end))
    (backward-kill-word arg)))


;; http://www.emacswiki.org/emacs/TransposeWindows
;;; When working with multiple windows it can be annoying if they get
;;; out of order. With this function it’s easy to fix that.
(defun uf/transpose-windows (arg)
  "Transpose the buffers shown in two windows."
  (interactive "p")
  (let ((selector (if (>= arg 0) 'next-window 'previous-window)))
    (while (/= arg 0)
      (let ((this-win (window-buffer))
            (next-win (window-buffer (funcall selector))))
        (set-window-buffer (selected-window) next-win)
        (set-window-buffer (funcall selector) this-win)
        (select-window (funcall selector)))
      (setq arg (if (plusp arg) (1- arg) (1+ arg))))))


;; Thank you @magnars
;; =================

(defun uf/eval-and-replace ()
  "Replace the preceding sexp with its value."
  (interactive)
  (backward-kill-sexp)
  (condition-case nil
      (prin1 (eval (read (current-kill 0)))
             (current-buffer))
    (error (message "Invalid expression")
           (insert (current-kill 0)))))


(defmacro uf/safe-wrap (fn &rest clean-up)
  "A wrapping over Emacs error handling"
  `(unwind-protect
       (let (retval)
         (condition-case ex
             (setq retval (progn ,fn))
           ('error
            (message (format "Caught exception: [%s]" ex))
            (setq retval (cons 'exception (list ex)))))
         retval)
     ,@clean-up))


;; http://emacsredux.com/blog/2013/05/04/rename-file-and-buffer/
;; ============================================================
(defun uf/rename-file-and-buffer ()
  "Rename the current buffer and file it is visiting."
  (interactive)
  (let ((filename (buffer-file-name)))
    (if (not (and filename (file-exists-p filename)))
        (message "Buffer is not visiting a file!")
      (let ((new-name (read-file-name "New name: " filename)))
        (cond
         ((vc-backend filename) (vc-rename-file filename new-name))
         (t
          (rename-file filename new-name t)
          (set-visited-file-name new-name t t)))))))

;; From Prelude
(defun prelude-copy-file-name-to-clipboard ()
  "Copy the current buffer file name to the clipboard."
  (interactive)
  (let ((filename (if (equal major-mode 'dired-mode)
                      default-directory
                    (buffer-file-name))))
    (when filename
      (kill-new filename)
      (message "Copied buffer file name '%s' to the clipboard." filename))))


;;; Stefan Monnier <foo at acm.org>. It is the opposite of fill-paragraph
(defun uf/unfill-paragraph (&optional region)
  "Takes a multi-line paragraph and makes it into a single line of text."
  (interactive (progn (barf-if-buffer-read-only) '(t)))
  (let ((fill-column (point-max))
        ;; This would override `fill-column' if it's an integer.
        (emacs-lisp-docstring-fill-column t))
    (fill-paragraph nil region)))

(defun uf/org-mermaid-convert-timestamps ()
  "Convert all org timestamps in the current buffer to standard mermaid."
  (interactive)
  (goto-char (point-min))
  (let ((org-time-stamp-custom-formats
         '("%Y-%m-%d" . "%Y-%m-%d %H:%M"))
        (org-display-custom-times 't))
    (while (re-search-forward (org-re-timestamp 'all) nil t)
      (replace-match
       (save-match-data
         (org-timestamp-translate (org-timestamp-from-string (match-string 0))))
       nil
       t
       nil))))

(defun uf/find-next-section-and-merge-single-dup ()
  "Look for the next section in the gantt diagram. Check if there
is a duplicate section, merge the two if you find one."
  (if (re-search-forward "section \\(.?+\\)\n" nil t)
      (progn (message "Found: %s" (match-string 1))
             (let ((curr-section-header-beg-pt (match-beginning 0))
                   (curr-section-header-end-pt (match-end 0))
                   (find-dup-sections-re (format "section %s\n" (match-string 1)))
                   (new-section-beg-pt (when (re-search-forward "section" nil t)
                                         (match-beginning 0))))
               (goto-char curr-section-header-end-pt)
               (if (and new-section-beg-pt
                        (re-search-forward find-dup-sections-re nil t))
                   (let ((dup-section-beg-pt (match-beginning 0))
                         (curr-pt (point))
                         (dup-section-end-pt (when (or (re-search-forward "section" nil t)
                                                       (re-search-forward "#\\+end_src" nil t))
                                               (match-beginning 0))))
                     (kill-region curr-pt dup-section-end-pt)
                     (delete-region dup-section-beg-pt curr-pt)
                     (goto-char new-section-beg-pt)
                     (forward-line -1)
                     (yank)
                     (goto-char curr-section-header-beg-pt))
                 (when new-section-beg-pt
                   (goto-char new-section-beg-pt)))))
    (progn (message "No Section Found! Exiting!")
           (goto-char (point-max)))))

(defun uf/org-mermaid-gantt-merge-duplicate-sections ()
  "In the current buffer, check if the same section has been
  duplicated and remove the duplicates by merging duplicate
  sections."
  (interactive)
  (goto-char (point-min))
  (while (not (eq (point) (point-max)))
    (uf/find-next-section-and-merge-single-dup)))

(defun uf/process-org-mermaid-file ()
  "Clean up current buffer for optimal mermaid graphs."
  (interactive)
  (uf/org-mermaid-gantt-merge-duplicate-sections)
  (save-buffer)
  (uf/org-mermaid-convert-timestamps)
  (delete-trailing-whitespace)
  (save-buffer))

(defun uf/create-datetree-heading (&optional toplevel)
  "Take a date input and create a datetree heading within subtree at point.

When called interactively with a `\\[universal-argument]' prefix
argument TOPLEVEL, create a top level datetree in the file."
  (interactive "P")
  (org-datetree-find-date-create
   (calendar-gregorian-from-absolute
    (org-time-string-to-absolute (org-read-date)))
   (if (equal toplevel '(4))
       nil
     'subtree-at-point)))

;;; The following code depends on `ts' library being installed.
(defun this-week-range ()
  "Return timestamps (BEG . END) spanning the current calendar work week.

(Mon to Fri)."
  (let* (;; Bind `now' to the current timestamp to ensure all calculations
         ;; begin from the same timestamp.  (In the unlikely event that
         ;; the execution of this code spanned from one day into the next,
         ;; that would cause a wrong result.)
         (now (ts-now))
         ;; We start by calculating the offsets for the beginning and
         ;; ending timestamps using the current day of the week.  Note
         ;; that the `ts-dow' slot uses the "%w" format specifier, which
         ;; counts from Sunday to Saturday as a number from 0 to 6.
         (adjust-beg-day (- (- (ts-dow now) 1)))
         (adjust-end-day (- 5 (ts-dow now)))
         ;; Make beginning/end timestamps based on `now', with adjusted
         ;; day and hour/minute/second values.  These functions return
         ;; new timestamps, so `now' is unchanged.
         (beg (thread-last now
                ;; `ts-adjust' makes relative adjustments to timestamps.
                (ts-adjust 'day adjust-beg-day)
                ;; `ts-apply' applies absolute values to timestamps.
                (ts-apply :hour 0 :minute 0 :second 0)))
         (end (thread-last now
                (ts-adjust 'day adjust-end-day)
                (ts-apply :hour 23 :minute 59 :second 59))))
    (cons beg end)))


(provide 'utility-functions)
