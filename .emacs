(defvar aorst--gc-cons-threshold gc-cons-threshold)
(defvar aorst--gc-cons-percentage gc-cons-percentage)
(defvar aorst--file-name-handler-alist file-name-handler-alist)

(setq-default gc-cons-threshold 402653184
              gc-cons-percentage 0.6
              inhibit-compacting-font-caches t
              message-log-max 16384
              file-name-handler-alist nil)

(add-hook 'after-init-hook
          (lambda ()
            (setq gc-cons-threshold aorst--gc-cons-threshold
                  gc-cons-percentage aorst--gc-cons-percentage
                  file-name-handler-alist aorst--file-name-handler-alist)))

;(setq gc-cons-threshold 10000000)
;(message "[INIT] gs-cons-threshold increased to %S" gc-cons-threshold)
;
;(add-hook 'after-init-hook
;          (lambda ()
;            (setq gc-cons-threshold 1000000)
;            (message "[INIT] gc-cons-threshold restored to %S"
;                     gc-cons-threshold)))

(setq tls-checktrust t)
(require 'package)
(setq package-archives
      '(("gnu-elpa"     . "https://elpa.gnu.org/packages/")
        ("melpa-stable" . "https://stable.melpa.org/packages/")
        ("melpa"        . "https://melpa.org/packages/")
        )
      package-archive-priorities
      '(("gnu-elpa"     . 10)
        ("melpa-stable" . 5)
        ("melpa"        . 0)
))
(package-initialize)
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))
(eval-when-compile (require 'use-package))
(setq use-package-always-ensure t)

(tooltip-mode -1)
(setq ring-bell-function 'ignore)
(setq inhibit-startup-screen t)

(setq-default cursor-type '(bar . 3))

(when (window-system)
  ;(set-default-font "JetBrains Mono-15") ; doesn't work anymore in emacs 27 on osx
  (set-face-attribute 'default nil :family "JetBrains Mono" :height 170)
  (tool-bar-mode -1)
  (scroll-bar-mode -1)
  (load-theme 'leuven)
)

(when (not (window-system))
      (menu-bar-mode -1))

(setq show-paren-delay 0)
(show-paren-mode 1)

(defalias 'yes-or-no-p 'y-or-n-p)

(setq cursor-in-non-selected-windows nil)  ; Hide the cursor in inactive windows

(setq echo-keystrokes 0.1)

(setq-default indent-tabs-mode nil)
(setq default-tab-width 4)

(global-hl-line-mode 1)

(global-auto-revert-mode t)

(if (locate-library "electric-pair-mode")
    (progn
      (electric-pair-mode)))

(setq-default show-trailing-whitespace 't)
(setq-default indicate-empty-lines 't)
(setq-default require-final-newline 'ask)
(setq-default mode-require-final-newline 'ask)

(add-to-list 'default-frame-alist '(ns-transparent-titlebar . nil))

(setq make-backup-files nil) ; stop creating backup~ files
(setq auto-save-default nil) ; stop creating #autosave# files
(setq create-lockfiles nil)  ; stop creating .# files

(setq column-number-mode t)
(setq-default frame-title-format "%b (%f)")

(setq custom-file "~/.emacs.d/custom.el")
(load custom-file 'noerror)

;(require 'ido)
;(ido-mode t)

;;
;; mac shortcuts
;;

(setq mac-command-modifier 'super)
(setq mac-option-modifier 'meta)
(setq mac-right-command-modifier 'super)
(setq mac-right-option-modifier 'meta)

;; (global-set-key (kbd "s-<right>") 'move-end-of-line)
(global-set-key (kbd "s-<right>") 'end-of-visual-line)
;; (global-set-key (kbd "S-s-<right>") (kbd "C-S-e"))

(global-set-key (kbd "s-<left>") 'back-to-indentation)
;; (global-set-key (kbd "s-<left>") 'beginning-of-visual-line)
(global-set-key (kbd "S-s-<left>") (kbd "M-S-m"))

(global-set-key (kbd "s-<up>") 'beginning-of-buffer)
(global-set-key (kbd "s-<down>") 'end-of-buffer)

(global-set-key (kbd "s-l") 'goto-line)

(global-set-key (kbd "s-a") 'mark-whole-buffer)       ;; select all

(global-set-key (kbd "s-s") 'save-buffer)             ;; save
(global-set-key (kbd "s-S") 'write-file)              ;; save as

(global-set-key (kbd "s-w") 'kill-this-buffer)        ;; close
(global-set-key (kbd "s-q") 'save-buffers-kill-emacs) ;; quit

(global-set-key (kbd "s-z") 'undo)

(global-set-key (kbd "s-]") 'other-window)
(global-set-key (kbd "s-[") 'other-window)


(defun create-dir-if-missing (dir)
  (if (not (file-directory-p dir))
      (make-directory dir)))

;(defun create-file-if-missing (file)
;  (if (not (file-exist-p file))
                                        ;      (write-region "" nil file nil 0)))

(use-package display-line-numbers
  :ensure nil
  :custom
  (display-line-numbers-grow-only t)
  (display-line-numbers-width-start t))

(unless (version< emacs-version "27")
  (use-package tab-line
    :ensure nil
    :hook (after-init . global-tab-line-mode)
    ))

(use-package ivy
  :demand
  :config
  (setq ivy-use-virtual-buffers t
        enable-recursive-minibuffers t
        ivy-count-format "%d/%d ")
  )

(use-package counsel
  :bind
  (
   ("M-x"     . counsel-M-x)
   ("C-s"     . swiper)
   ("C-x C-f" . counsel-find-file)
   ("C-x b" . ivy-switch-buffer)
  )
  )

(use-package which-key
  :config
  (which-key-mode)
  )

(use-package org-bullets
  :hook (org-mode . org-bullets-mode))

;;
;; org-mode configuration
;;

(global-set-key "\C-ca" 'org-agenda)
(global-set-key "\C-cc" 'org-capture)

(create-dir-if-missing "~/org")
(if (not (file-exists-p "~/org/todo.org")) (write-region "" nil "~/org/todo.org" nil 0))
(if (not (file-exists-p "~/org/notes.org")) (write-region "" nil "~/org/notes.org" nil 0))

(setq org-agenda-files (directory-files-recursively "~/org/" "\\.org$"))
(setq org-todo-keywords (quote ((sequence "TODO(t)" "|" "DONE(d)") (sequence "WAITING(w)" "|" "CANCELLED(c)"))))
(setq org-highest-priority ?A)
(setq org-lowest-priority ?C)
(setq org-default-priority ?A)
(setq org-agenda-window-setup (quote current-window))
(setq org-agenda-span 90
      org-agenda-start-on-weekday nil
      ;org-agenda-start-day "-7d"
      )
(setq org-agenda-show-all-dates nil)
(setq org-deadline-warning-days 7)
(setq org-startup-indented 1)

(setq org-refile-targets '((nil :maxlevel . 9) (org-agenda-files :maxlevel . 9)))
(setq org-outline-path-complete-in-steps nil)         ; Refile in a single go
(setq org-refile-use-outline-path t)                  ; Show full paths for refiling

(setq org-capture-templates '(
    ("t" "Tasks")
    ("tt" "Todo" entry
     (file+headline "~/org/todo.org" "Tasks")
     "* TODO [#A] %? %^G\nCreated: %U"
     :empty-lines 1)
    ("ts" "Todo w/ Schedule" entry
     (file+headline "~/org/todo.org" "Tasks")
     "* TODO [#A] %? %^G\nSCHEDULED: %^t\nCreated: %U"
     :empty-lines 1)
    ("td" "Todo w/ Deadline" entry
     (file+headline "~/org/todo.org" "Tasks")
     "* TODO [#A] %? %^G\nDEADLINE: %^t\nCreated: %U"
     :empty-lines 1)
    ("n" "Notes")
    ("nn" "Note" entry
     (file+olp+datetree "~/org/notes.org")
     "* %?"
     :empty-lines 1)
))

;; Automatically save and restore sessions

(create-dir-if-missing "~/.emacs.d/desktop")

(setq desktop-dirname             "~/.emacs.d/desktop/"
      desktop-base-file-name      "emacs.desktop"
      desktop-base-lock-name      "lock"
      desktop-path                (list desktop-dirname)
      desktop-save                t
      desktop-files-not-to-save   "^$" ;reload tramp paths
      desktop-load-locked-desktop nil
      desktop-auto-save-timeout   30)
(desktop-save-mode 1)
