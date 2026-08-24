;;; .emacs --- Ivan's Emacs configuration -*- lexical-binding: t; -*-

;; Target: GNU Emacs 30.2, Homebrew build.
;;
;; NOTE: this build is compiled --without-ns --without-x, so it is terminal
;; only: no toolbar, no scrollbar, no tooltips, no image support (SVG/PNG are
;; unavailable), and the mac-*-modifier variables do not exist. Nothing here
;; assumes a graphical frame. If you ever move to emacs-plus/emacs-mac, the
;; GUI-specific settings need to be added back deliberately.
;;
;; Startup GC and I/O tuning lives in ~/.emacs.d/early-init.el.

;;; Code:

;;; ---------------------------------------------------------------- Packages

(require 'package)

(setq package-archives
      '(("gnu-elpa"     . "https://elpa.gnu.org/packages/")
        ("nongnu"       . "https://elpa.nongnu.org/nongnu/")
        ("melpa-stable" . "https://stable.melpa.org/packages/")
        ("melpa"        . "https://melpa.org/packages/"))
      package-archive-priorities
      '(("gnu-elpa"     . 10)
        ("nongnu"       . 8)
        ("melpa-stable" . 5)
        ("melpa"        . 0)))

;; Verify TLS certificates when talking to the archives above.
;;(setq tls-checktrust t
;;      gnutls-verify-error t)

;; No bootstrap block is needed: Emacs 27+ activates packages automatically
;; before this file is read, and use-package 2.4.6 is built in.
;;
;; Deliberately no `package-refresh-contents' here. `package-quickstart' (see
;; early-init.el) activates packages without filling `package-archive-contents',
;; so any "refresh if empty" guard would re-download all four archives on every
;; single startup. use-package's :ensure already refreshes on demand when a
;; package it needs is missing from the cache.
(require 'use-package)
(setq use-package-always-ensure t)
;; Uncomment, restart, then M-x use-package-report to profile load times.
;; (setq use-package-compute-statistics t)

(defun ivan/ensure-directory (dir)
  "Create DIR and any missing parents unless it already exists."
  (unless (file-directory-p dir)
    (make-directory dir t)))

;;; --------------------------------------------------------------------- UI

(menu-bar-mode -1)

(load-theme 'wombat t)

(setq inhibit-startup-screen t
      ring-bell-function #'ignore
      echo-keystrokes 0.1
      use-short-answers t                 ; Emacs 28+ replacement for the old
                                          ; (defalias 'yes-or-no-p 'y-or-n-p)
      cursor-in-non-selected-windows nil
      show-paren-delay 0)

(setq-default frame-title-format "%b (%f)")

(column-number-mode 1)
(show-paren-mode 1)
(global-hl-line-mode 1)

;; Built in since Emacs 24.1. The previous guard checked
;; (locate-library "electric-pair-mode"), which always returns nil -- the
;; library is elec-pair.el -- so this mode was silently never enabled.
(electric-pair-mode 1)

(use-package display-line-numbers
  :ensure nil
  :custom
  (display-line-numbers-type 'relative)
  (display-line-numbers-grow-only t)
  (display-line-numbers-width-start t)
  ;; Scoped to editing buffers rather than global: line numbers in magit,
  ;; dirvish, help and the agenda are noise and cost redisplay on every move.
  :hook ((prog-mode text-mode conf-mode) . display-line-numbers-mode))

;;; ---------------------------------------------------------------- Editing

(setq-default indent-tabs-mode nil
              tab-width 4                 ; was `default-tab-width', a variable
                                          ; removed in Emacs 23 -- the old
                                          ; setting was a no-op and tabs
                                          ; rendered 8 wide
              require-final-newline 'ask
              mode-require-final-newline 'ask
              indicate-empty-lines t)

;; Globally, `show-trailing-whitespace' also lights up the minibuffer, help,
;; magit and shell buffers. Restrict it to buffers you actually edit.
(dolist (hook '(prog-mode-hook text-mode-hook conf-mode-hook))
  (add-hook hook (lambda () (setq show-trailing-whitespace t))))

;;; ------------------------------------------------------------------ Files

(setq make-backup-files nil                ; no backup~ files
      auto-save-default nil                ; no #autosave# files
      create-lockfiles nil                 ; no .# files
      ;; Send Customize writes to the void so all config lives in this file.
      ;; (M-x customize changes will not persist.)
      custom-file null-device)

;; Watch files via the filesystem notification API instead of polling every
;; five seconds on a timer.
(setq auto-revert-avoid-polling t
      auto-revert-verbose nil)
(global-auto-revert-mode 1)

;;; --------------------------------------------- Minibuffer completion stack
;;
;; vertico + consult + marginalia + orderless. These share one matching engine
;; (orderless) with corfu below, so in-buffer and minibuffer completion behave
;; identically. This replaces the previous ivy/counsel/swiper setup, which
;; used its own incompatible matcher and never actually enabled `ivy-mode'.

(use-package vertico
  :init (vertico-mode))

(use-package savehist                      ; vertico sorts by recency
  :ensure nil
  :init (savehist-mode))

(use-package marginalia
  :init (marginalia-mode))

(use-package orderless
  :custom
  (completion-styles '(orderless basic))
  (completion-category-defaults nil)
  (completion-category-overrides '((file (styles partial-completion)))))

(use-package recentf                       ; feeds consult-buffer
  :ensure nil
  :custom (recentf-max-saved-items 200)
  :init (recentf-mode))

;; M-x and C-x C-f keep their default commands: vertico + marginalia already
;; make them better than the counsel equivalents they used to be bound to.
(use-package consult
  :bind (("C-s"   . consult-line)          ; was swiper
         ("C-x b" . consult-buffer)        ; was ivy-switch-buffer
         ("M-y"   . consult-yank-pop)
         ("M-g g" . consult-goto-line)
         ("M-g i" . consult-imenu)
         ("C-c s" . consult-ripgrep)))     ; rg is on PATH

(use-package which-key                     ; built in since Emacs 30
  :ensure nil
  :init (which-key-mode))

;;; ------------------------------------------------- In-buffer completion

(use-package corfu
  :init (global-corfu-mode)
  :custom
  (corfu-auto t)
  (corfu-auto-delay 0.2)
  (corfu-auto-prefix 2)
  (corfu-cycle t)
  :config
  (corfu-popupinfo-mode))

(use-package corfu-terminal
  :after corfu
  :config
  (unless (display-graphic-p)
    (corfu-terminal-mode 1)))

(use-package nerd-icons)

;; Replaces kind-icon, which renders through svg-lib. This build reports
;; (image-type-available-p 'svg) => nil, so kind-icon could never draw
;; anything. nerd-icons-corfu uses plain font glyphs and works in a terminal.
(use-package nerd-icons-corfu
  :after corfu
  :config
  (add-to-list 'corfu-margin-formatters #'nerd-icons-corfu-formatter))

;; Depths keep mode-specific capfs (eglot, at depth 0) ahead of the fallbacks.
;; The previous `add-to-list' calls prepended these, letting file and dabbrev
;; completion shadow the LSP.
(use-package cape
  :init
  (add-hook 'completion-at-point-functions #'cape-file 10)
  (add-hook 'completion-at-point-functions #'cape-dabbrev 20))

;;; ------------------------------------------------------------ Programming

(setq read-process-output-max (* 1024 1024))  ; larger LSP reads

(use-package terraform-mode :mode ("\\.tf\\'" "\\.tfvars\\'"))
(use-package rust-mode      :mode "\\.rs\\'")
(use-package go-mode        :mode "\\.go\\'")

;; eglot is the built-in LSP client and uses eldoc + flymake for docs and
;; diagnostics, so no extra UI package is needed.
(use-package eglot
  :ensure nil
  :hook ((terraform-mode . eglot-ensure)
         (rust-mode      . eglot-ensure)
         (go-mode        . eglot-ensure))
  :custom
  ;; No eglot-server-programs entry is required: Emacs 30.2 already ships
  ;; (terraform-mode "terraform-ls" "serve") plus rust-analyzer and gopls.
  ;; Suppress the event log; it retains every JSON-RPC message otherwise.
  (eglot-events-buffer-config '(:size 0 :format full))
  (eglot-autoshutdown t))

(use-package magit
  :bind (("C-x g"   . magit-status)
         ("C-x C-g" . magit-status))
  :custom
  (magit-diff-refine-hunk 'all)             ; word-level highlighting in diffs
  (magit-save-repository-buffers 'dontask)) ; auto-save before magit ops

;;; --------------------------------------------------------- File explorer

(use-package dirvish
  :custom
  (dirvish-attributes '(nerd-icons file-size))
  :bind (("C-c f" . dirvish-side)          ; toggle the sidebar tree
         ("C-x d" . dirvish))              ; full-frame dirvish w/ preview
  ;; Taking over dired loads dirvish, so do it once startup is done rather
  ;; than on the critical path.
  :hook (after-init . dirvish-override-dired-mode)
  :config
  ;; Some dirvish builds keep their extensions in a subdirectory that is not
  ;; on `load-path'. Add it only when it really exists -- the previous
  ;; unconditional version raised an error if dirvish failed to install,
  ;; taking the rest of this file down with it.
  (let* ((main (locate-library "dirvish"))
         (ext  (and main (expand-file-name "extensions"
                                           (file-name-directory main)))))
    (when (and ext (file-directory-p ext))
      (add-to-list 'load-path ext)))
  (require 'dirvish-side nil t))

;;; -------------------------------------------------------------------- Org

(ivan/ensure-directory "~/org")

(use-package org
  :ensure nil
  :bind (("C-c a" . org-agenda)
         ("C-c c" . org-capture))
  :custom
  ;; A directory entry is expanded when the agenda is built, so new files are
  ;; picked up without restarting Emacs. The previous
  ;; `directory-files-recursively' call walked ~/org on every startup and then
  ;; froze the result for the session.
  ;; Caveat: directory entries are NOT recursive. If you start nesting files
  ;; in ~/org/subdir/, list those directories here explicitly.
  (org-agenda-files '("~/org/"))
  (org-todo-keywords '((sequence "TODO(t)" "|" "DONE(d)")
                       (sequence "WAITING(w)" "|" "CANCELLED(c)")))
  (org-highest-priority ?A)
  (org-lowest-priority ?C)
  (org-default-priority ?A)
  (org-agenda-window-setup 'current-window)
  (org-agenda-span 90)
  (org-agenda-start-on-weekday nil)
  (org-agenda-show-all-dates nil)
  (org-deadline-warning-days 7)
  (org-startup-indented t)                 ; was 1
  (org-refile-targets '((nil :maxlevel . 9)
                        (org-agenda-files :maxlevel . 9)))
  (org-outline-path-complete-in-steps nil)  ; refile in a single go
  (org-refile-use-outline-path t)           ; show full paths when refiling
  ;; org-capture creates these files on demand, so there is no need to
  ;; write-region empty todo.org/notes.org on every startup.
  (org-capture-templates
   '(("t" "Tasks")
     ("tt" "Todo" entry
      (file+headline "~/org/todo.org" "Tasks")
      "* TODO [#A] %? %^G\nCreated: %U" :empty-lines 1)
     ("ts" "Todo w/ Schedule" entry
      (file+headline "~/org/todo.org" "Tasks")
      "* TODO [#A] %? %^G\nSCHEDULED: %^t\nCreated: %U" :empty-lines 1)
     ("td" "Todo w/ Deadline" entry
      (file+headline "~/org/todo.org" "Tasks")
      "* TODO [#A] %? %^G\nDEADLINE: %^t\nCreated: %U" :empty-lines 1)
     ("n" "Notes")
     ("nn" "Note" entry
      (file+olp+datetree "~/org/notes.org")
      "* %?" :empty-lines 1))))

;;; .emacs ends here
