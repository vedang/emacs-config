;;; init-company-mode.el --- configuration for company-mode:
;;; complete anything.
;;; Author: Vedang Manerikar
;;; Created on: 28 May 2014
;;; Copyright (c) 2014 Vedang Manerikar <vedang.manerikar@gmail.com>

;; This file is not part of GNU Emacs.

;;; License:

;; This program is free software; you can redistribute it and/or
;; modify it under the terms of the Do What The Fuck You Want to
;; Public License, Version 2, which is included with this distribution.
;; See the file LICENSE.txt

;;; Code:


(add-hook 'after-init-hook 'global-company-mode)

(setq company-idle-delay 0.5
      company-require-match nil
      company-tooltip-align-annotations t)

(eval-after-load 'company
  '(progn (setq-default company-lighter " cmp")
          (define-key company-active-map [tab] 'company-complete)
          (define-key company-active-map (kbd "TAB") 'company-complete)))
