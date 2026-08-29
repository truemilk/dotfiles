;;; init.el --- Small, terminal-friendly Emacs configuration -*- lexical-binding: t; -*-

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
      mouse-wheel-progressive-speed nil)

(menu-bar-mode -1)
(when (fboundp 'tool-bar-mode) (tool-bar-mode -1))
(when (fboundp 'scroll-bar-mode) (scroll-bar-mode -1))
(blink-cursor-mode -1)

;; Terminal integration.
(when (not (display-graphic-p))
  (xterm-mouse-mode 1)
  (setq frame-title-format nil))
(setq-default cursor-type 'bar)
(set-language-environment "UTF-8")

;; A readable built-in theme that works well with 256-colour terminals.
(load-theme 'wombat t)

;; Lightweight minibuffer completion; no external packages required.
(fido-vertical-mode 1)
(setq completion-ignore-case t
      read-buffer-completion-ignore-case t
      read-file-name-completion-ignore-case t
      completions-detailed t)

;; Useful defaults without expensive global visual features.
(column-number-mode 1)
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
(load (expand-file-name "packages.el" user-emacs-directory))

;; Put Customize output in its own file instead of appending to this one.
(setq custom-file (expand-file-name "custom.el" user-emacs-directory))
(when (file-exists-p custom-file)
  (load custom-file nil 'nomessage))

;;; init.el ends here
