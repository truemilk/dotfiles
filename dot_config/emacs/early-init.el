;;; early-init.el --- Pre-package startup tuning -*- lexical-binding: t; -*-

;; This file runs BEFORE package activation and before ~/.emacs.
;;
;; The GC / file-name-handler tuning lives here rather than in ~/.emacs
;; because Emacs 27+ activates all installed packages before reading the init
;; file -- doing it in ~/.emacs missed the single most allocation-heavy phase
;; of startup entirely.

;;; Code:

(defvar ivan--file-name-handler-alist file-name-handler-alist
  "Saved value of `file-name-handler-alist', restored after startup.")

(defconst ivan-gc-cons-threshold-normal (* 16 1024 1024)
  "Post-startup GC threshold.
Deliberately much larger than the 800 kB default: eglot and corfu allocate
heavily, and 800 kB forces GC pauses during completion.")

;; During startup: raise the GC threshold sharply, and skip the regexp scan
;; that `file-name-handler-alist' performs on every `load' and `require'.
;;
;; 256 MB rather than `most-positive-fixnum': disabling GC outright means a
;; first run that byte-compiles a few hundred package files never reclaims
;; anything and can exhaust the heap.
(setq gc-cons-threshold (* 256 1024 1024)
      gc-cons-percentage 0.6
      file-name-handler-alist nil
      message-log-max 16384)

;; Roll autoloads of every installed package into one preloaded file instead
;; of loading N separate <pkg>-autoloads.el. package.el keeps it up to date
;; automatically on install/delete.
(setq package-quickstart t)

(add-hook 'emacs-startup-hook
          (lambda ()
            (setq gc-cons-threshold ivan-gc-cons-threshold-normal
                  gc-cons-percentage 0.1
                  file-name-handler-alist ivan--file-name-handler-alist)
            (garbage-collect)))

;;; early-init.el ends here
