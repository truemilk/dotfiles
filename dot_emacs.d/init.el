;;; init.el --- Small, terminal-friendly Emacs configuration -*- lexical-binding: t; -*-

;; Collect no garbage while starting up; restore a sane threshold afterwards.
(setq gc-cons-threshold most-positive-fixnum)
(add-hook 'emacs-startup-hook
          (lambda () (setq gc-cons-threshold (* 32 1024 1024))))

;; Keep the terminal uncluttered and avoid unnecessary redisplay work.
(setq inhibit-startup-screen t
      inhibit-startup-message t
      initial-scratch-message nil
      ring-bell-function #'ignore
      visible-bell nil
      use-short-answers t
      redisplay-skip-fontification-on-input t
      fast-but-imprecise-scrolling t
      scroll-conservatively 101
      mouse-wheel-progressive-speed nil
      ;; Frames are sized by the window manager, not by mode or font changes.
      frame-inhibit-implied-resize t
      ;; Nerd Font glyph coverage is large; keep its cache resident.
      inhibit-compacting-font-caches t
      ;; This configuration never displays right-to-left text.
      bidi-inhibit-bpa t)
(setq-default bidi-paragraph-direction 'left-to-right)

(menu-bar-mode -1)
(when (fboundp 'tool-bar-mode) (tool-bar-mode -1))
(when (fboundp 'scroll-bar-mode) (scroll-bar-mode -1))
(blink-cursor-mode -1)

;; Terminal integration.
(when (not (display-graphic-p))
  (xterm-mouse-mode 1)
  (setq frame-title-format nil))

;; Native macOS frames should contain only the editor and essential status UI.
(defun my/macos-gui-frame-setup (&optional frame)
  "Apply minimal macOS GUI settings to FRAME."
  (let ((frame (or frame (selected-frame))))
    (when (and (eq system-type 'darwin) (display-graphic-p frame))
      (dolist (parameter '((fullscreen . maximized)
                           (font . "MesloLGS Nerd Font Mono-15")
                           ;; Let the title bar take the frame background colour.
                           (ns-transparent-titlebar . t)
                           (ns-appearance . dark)
                           (menu-bar-lines . 0)
                           (tool-bar-lines . 0)
                           (vertical-scroll-bars . nil)
                           (left-fringe . 0)
                           (right-fringe . 0)))
        (set-frame-parameter frame (car parameter) (cdr parameter)))
      (tooltip-mode -1)
      (setq select-enable-clipboard t))))

(when (eq system-type 'darwin)
  ;; Command is Super; Option supplies the Meta key used by Emacs commands.
  (setq ns-command-modifier 'super
        ns-option-modifier 'meta)
  (dolist (parameter '((fullscreen . maximized)
                       (font . "MesloLGS Nerd Font Mono-15")
                       ;; Let the title bar take the frame background colour.
                       (ns-transparent-titlebar . t)
                       (ns-appearance . dark)
                       (menu-bar-lines . 0)
                       (tool-bar-lines . 0)
                       (vertical-scroll-bars . nil)
                       (left-fringe . 0)
                       (right-fringe . 0)))
    (setf (alist-get (car parameter) default-frame-alist)
          (cdr parameter)))
  (add-hook 'after-make-frame-functions #'my/macos-gui-frame-setup)
  (my/macos-gui-frame-setup))

(setq-default cursor-type 'bar)
(set-language-environment "UTF-8")

;; Lightweight minibuffer completion; no external packages required.
(fido-vertical-mode 1)
(setq completion-ignore-case t
      read-buffer-completion-ignore-case t
      read-file-name-completion-ignore-case t
      completions-detailed t)

;; Useful defaults without expensive global visual features.
(column-number-mode 1)
(setq auto-revert-avoid-polling t)
(global-auto-revert-mode 1)
(delete-selection-mode 1)
(savehist-mode 1)
(save-place-mode 1)
(add-hook 'prog-mode-hook #'display-line-numbers-mode)
(setq display-line-numbers-width-start t)

;; Keep generated files out of project directories.
(let ((backup-dir (expand-file-name "backups/" user-emacs-directory))
      (autosave-dir (expand-file-name "auto-save/" user-emacs-directory)))
  (make-directory backup-dir t)
  (make-directory autosave-dir t)
  (setq backup-directory-alist `(("." . ,backup-dir))
        auto-save-file-name-transforms `((".*" ,autosave-dir t))
        auto-save-list-file-prefix (expand-file-name ".saves-" autosave-dir)))
(setq make-backup-files t
      version-control t
      kept-new-versions 5
      kept-old-versions 2
      delete-old-versions t
      create-lockfiles nil)

;; Keep third-party package management separate from the core configuration.
;; Load the byte-compiled form, recompiling it whenever the source is newer.
(let* ((source (expand-file-name "packages.el" user-emacs-directory))
       (compiled (concat source "c")))
  (when (file-newer-than-file-p source compiled)
    (require 'bytecomp)
    (byte-compile-file source))
  (load (file-name-sans-extension source) nil 'nomessage))

;; Tokyo Night everywhere; fall back to Wombat if the package is unavailable.
(unless (ignore-errors (load-theme 'tokyo-night t) t)
  (load-theme 'wombat t))

;; Put Customize output in its own file instead of appending to this one.
(setq custom-file (expand-file-name "custom.el" user-emacs-directory))
(when (file-exists-p custom-file)
  (load custom-file nil 'nomessage))

;;; init.el ends here
