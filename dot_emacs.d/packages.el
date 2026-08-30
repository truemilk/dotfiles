;;; packages.el --- Third-party package configuration -*- lexical-binding: t; -*-

(require 'package)
(require 'seq)

;; Keep Emacs' default archives and add rolling MELPA releases.
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)

;; Collapse every package's autoloads into a single precomputed file.
(setq package-quickstart t)

(unless package--initialized
  (package-initialize))

(defconst my/managed-packages
  '(magit exec-path-from-shell corfu terraform-mode rust-mode tokyo-night)
  "Third-party packages installed by this configuration.")

;; Refresh archive metadata at most once, then install each available package
;; independently.  Network failures must not prevent Emacs from starting.
(when (seq-some (lambda (package) (not (package-installed-p package)))
                my/managed-packages)
  (unless package-archive-contents
    (condition-case err
        (package-refresh-contents)
      (error
       (display-warning
        'packages
        (format "Could not refresh package archives: %s"
                (error-message-string err))
        :warning))))
  (dolist (package my/managed-packages)
    (unless (package-installed-p package)
      (if (assq package package-archive-contents)
          (condition-case err
              (package-install package)
            (error
             (display-warning
              'packages
              (format "Could not install %s: %s"
                      package (error-message-string err))
              :warning)))
        (display-warning
         'packages
         (format "Could not install %s: package is unavailable" package)
         :warning)))))

;; `magit-status' is autoloaded, so binding it does not load Magit at startup.
(global-set-key (kbd "C-x g") #'magit-status)

(defvar my/macos-gui-environment-attempted nil
  "Non-nil after attempting to import the macOS GUI environment.")

(defun my/macos-gui-import-environment (&optional frame)
  "Import the login-shell environment once for a graphical macOS FRAME."
  (let ((frame (or frame (selected-frame))))
    (when (and (eq system-type 'darwin)
               (display-graphic-p frame)
               (not my/macos-gui-environment-attempted))
      (setq my/macos-gui-environment-attempted t)
      (if (require 'exec-path-from-shell nil t)
          (condition-case err
              (exec-path-from-shell-initialize)
            (error
             (display-warning
              'packages
              (format "Could not import the login-shell environment: %s"
                      (error-message-string err))
              :warning)))
        (display-warning
         'packages
         "Could not import the login-shell environment: exec-path-from-shell is unavailable"
         :warning)))))

(when (eq system-type 'darwin)
  (add-hook 'after-make-frame-functions #'my/macos-gui-import-environment)
  (my/macos-gui-import-environment))

;; In-buffer completion uses completion-at-point, including candidates supplied
;; by Eglot.  Fido remains responsible for minibuffer completion.
(when (require 'corfu nil t)
  (setq corfu-auto t
        corfu-auto-delay 0.2
        corfu-auto-prefix 2
        corfu-cycle t)
  (global-corfu-mode 1))

;; Terraform and Rust language support through Emacs' built-in LSP client.
;; Eglot itself is loaded on demand by `eglot-ensure'.
(with-eval-after-load 'eglot
  (add-to-list 'eglot-server-programs
               '(terraform-mode . ("terraform-ls" "serve")))
  (add-to-list 'eglot-server-programs
               '((rust-mode rust-ts-mode) . ("rust-analyzer"))))

(defun my/eglot-format-buffer ()
  "Format the current buffer when Eglot is connected."
  (when (and (featurep 'eglot) (eglot-current-server))
    (condition-case err
        (eglot-format-buffer)
      (error
       (display-warning
        'eglot
        (format "Could not format buffer: %s" (error-message-string err))
        :warning)))))

(defvar my/terraform-ls-missing-warning-shown nil
  "Non-nil after warning that terraform-ls is unavailable.")

(defun my/terraform-eglot-setup ()
  "Start terraform-ls and arrange safe format-on-save for this buffer."
  (add-hook 'before-save-hook #'my/eglot-format-buffer nil t)
  (if (executable-find "terraform-ls")
      (eglot-ensure)
    (unless my/terraform-ls-missing-warning-shown
      (setq my/terraform-ls-missing-warning-shown t)
      (display-warning
       'terraform
       (concat "terraform-ls was not found in PATH; Terraform LSP is disabled. "
               "On macOS, install it with: "
               "brew install hashicorp/tap/terraform-ls")
       :warning))))

(when (require 'terraform-mode nil t)
  (add-hook 'terraform-mode-hook #'my/terraform-eglot-setup))

(defvar my/rust-analyzer-missing-warning-shown nil
  "Non-nil after warning that rust-analyzer is unavailable.")

(defun my/rust-eglot-setup ()
  "Start rust-analyzer and arrange safe format-on-save for this buffer."
  (add-hook 'before-save-hook #'my/eglot-format-buffer nil t)
  (if (executable-find "rust-analyzer")
      (eglot-ensure)
    (unless my/rust-analyzer-missing-warning-shown
      (setq my/rust-analyzer-missing-warning-shown t)
      (display-warning
       'rust
       (concat "rust-analyzer was not found in PATH; Rust LSP is disabled. "
               "Install it with: rustup component add rust-analyzer")
       :warning))))

;; Support both MELPA's parser-independent mode and Emacs' tree-sitter mode.
(when (require 'rust-mode nil t)
  (add-hook 'rust-mode-hook #'my/rust-eglot-setup))
(add-hook 'rust-ts-mode-hook #'my/rust-eglot-setup)

(provide 'packages)
;;; packages.el ends here
