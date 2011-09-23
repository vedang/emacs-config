(autoload 'package-list-packages "elpa-config" "List Elpa packages" t)
(autoload 'dired "misc-requires" "Load dired-x" t)  ; Better dired
(autoload 'magit-status "magit" "Load magit" t)
(autoload 'cscope-set-initial-directory "cscope-mode-config" "Load cscope" t)
(autoload 'twit	"twittering-mode" "" t)
(autoload 'python-mode "python" "Load python mode" t)
(autoload 'no-easy-keys-minor-mode "no-easy-keys" "Load no easy keys" t)
(autoload 'js2-mode "js2-mode" nil t)
(autoload 'markdown-mode "markdown-mode.el"
  "Major mode for editing Markdown files" t)
(autoload 'mo-git-blame-file "mo-git-blame" nil t)
(autoload 'mo-git-blame-current "mo-git-blame" nil t)


;;; required magic
(require 'ido-mode-config)
(require 'ibuffer-mode-config)
(require 'auto-complete-mode-config)
(require 'revive-mode-config)
(require 'isearch-mode-config)
(require 'flymake-config)
(require 'jabber-autoloads)
(require 'erlang-start)
(require 'slime-autoloads)
(require 'swank-clojure-autoload)
(require 'clojure-mode-autoloads)
(require 'writegood-mode)
(require 'template)
(template-initialize)

;;; Eval after loads
(eval-after-load "org"
  '(progn
     (require 'org-mode-config)))
(eval-after-load "erc"
  '(require 'erc-mode-config))
(eval-after-load 'diff-mode
  '(progn
     (set-face-foreground 'diff-added "green4")
     (set-face-foreground 'diff-removed "red3")))
(eval-after-load 'magit
  '(progn
     (set-face-foreground 'magit-diff-add "green3")
     (set-face-foreground 'magit-diff-del "red3")))
(eval-after-load "jabber"
  '(require 'jabber-mode-config))
(eval-after-load "python"
  '(require 'python-mode-config))
(eval-after-load "erlang"
  '(require 'erlang-mode-config))
(eval-after-load "lisp-mode"
  '(require 'emacs-lisp-mode-config))
(eval-after-load "clojure"
  '(require 'clojure-mode-config))
(eval-after-load "slime"
  '(require 'lisp-mode-config))
(eval-after-load "LaTeX"
  '(require 'latex-mode-config))
(eval-after-load "js2-mode"
  '(require 'js2-mode-config))


;;; configuration too small to go into individual files
(require 'yasnippet) ;; not yasnippet-bundle
(global-set-key (kbd "S-TAB") 'yas/trigger-key)
(yas/initialize)
(yas/load-directory "~/.emacs.d/plugins/yasnippet/snippets")


(setq hippie-expand-try-functions-list
      '(try-expand-dabbrev
        try-expand-dabbrev-from-kill
        try-expand-dabbrev-all-buffers
        try-complete-file-name-partially
        try-complete-file-name
        try-complete-lisp-symbol-partially
        try-complete-lisp-symbol))


(setq uniquify-buffer-name-style 'reverse
      uniquify-separator "/"
      uniquify-after-kill-buffer-p t
      uniquify-ignore-buffers-re "^\\*")


(provide 'mode-config)
