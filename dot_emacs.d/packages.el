;;; packages.el --- Third-party package configuration -*- lexical-binding: t; -*-

(require 'package)

;; Keep Emacs' default archives and add rolling MELPA releases.
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)

(unless package--initialized
  (package-initialize))

;; Install Magit on first use of this configuration.  A network failure should
;; not prevent Emacs from starting; a later connected startup will retry.
(unless (package-installed-p 'magit)
  (condition-case err
      (progn
        (unless package-archive-contents
          (package-refresh-contents))
        (package-install 'magit))
    (error
     (display-warning
      'packages
      (format "Could not install Magit: %s" (error-message-string err))
      :warning))))

(when (require 'magit nil t)
  (global-set-key (kbd "C-x g") #'magit-status))

(provide 'packages)
;;; packages.el ends here
