;;; init-cider.el --- Configuration for Cider.
;;; Author: Vedang Manerikar
;;; Created on: 27 Oct 2013
;;; Copyright (c) 2013 Vedang Manerikar <vedang.manerikar@gmail.com>

;; This file is not part of GNU Emacs.

;;; License:

;; This program is free software; you can redistribute it and/or
;; modify it under the terms of the Do What The Fuck You Want to
;; Public License, Version 2, which is included with this distribution.
;; See the file LICENSE.txt

;;; Code:


(when (not (boundp 'tempfiles-dirname))
  (setq tempfiles-dirname "~/.emacs.d/"))


(defun cider-repl-prompt-on-newline (namespace)
  "Return a prompt string with newline"
  (concat namespace ">\n"))


(setq cider-repl-popup-stacktraces t
      cider-repl-history-file (concat tempfiles-dirname "nrepl-history.txt")
      cider-repl-history-size most-positive-fixnum
      cider-repl-print-length 100
      cider-repl-wrap-history t
      cider-repl-prompt-function 'cider-repl-prompt-on-newline
      nrepl-buffer-name-separator "-"
      nrepl-buffer-name-show-port t
      nrepl-log-messages t
      cider-switch-to-repl-command 'cider-switch-to-current-repl-buffer
      cider-mode-line nil
      cider-annotate-completion-candidates t
      cider-completion-annotations-include-ns 'always
      cider-show-error-buffer 'except-in-repl
      cider-prompt-for-symbol nil)


(add-hook 'cider-mode-hook 'eldoc-mode)
(add-hook 'cider-repl-mode-hook 'subword-mode)
(eval-after-load 'cider-mode
  '(progn
     (define-key cider-mode-map (kbd "C-c z") 'cider-selector)))


(provide 'init-cider)

;;; init-cider ends here
