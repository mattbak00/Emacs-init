;;; Package config -- see https://melpa.org/#/getting-started
(require 'package)
(let* ((no-ssl (and (memq system-type '(windows-nt ms-dos))
                    (not (gnutls-available-p))))
       (proto (if no-ssl "http" "https")))
  ;; Comment/uncomment these two lines to enable/disable MELPA and MELPA Stable as desired
  (add-to-list 'package-archives (cons "melpa" (concat proto "://melpa.org/packages/")) t)
  ;;(add-to-list 'package-archives (cons "melpa-stable" (concat proto "://stable.melpa.org/packages/")) t)
  (when (< emacs-major-version 24)
    ;; For important compatibility libraries like cl-lib
    (add-to-list 'package-archives '("gnu" . (concat proto "://elpa.gnu.org/packages/")))))
(package-initialize)


;;; installing use-package
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))


;;; manual load path to lisp folder
(add-to-list 'load-path "~/.emacs.d/lisp/")


;;; alect-black theme
(use-package alect-themes)
(load-theme 'alect-black t)


;;; Org-mode bullets
(require 'org-bullets)
(setq org-bullets-bullet-list '("○"))
(add-hook 'org-mode-hook (lambda () (org-bullets-mode t)))


;;; Save backup files elsewhere
(setq backup-directory-alist `(("." . "~/.saves")))
;;; Save autosave files elsewhere
(setq auto-save-file-name-transforms `((".*" "/home/matthijs/.saves" t)))


;;; Fira-code setup
(defun fira-code-mode--make-alist (list)
  "Generate prettify-symbols alist from LIST."
  (let ((idx -1))
    (mapcar
     (lambda (s)
       (setq idx (1+ idx))
       (let* ((code (+ #Xe100 idx))
          (width (string-width s))
          (prefix ())
          (suffix '(?\s (Br . Br)))
          (n 1))
     (while (< n width)
       (setq prefix (append prefix '(?\s (Br . Bl))))
       (setq n (1+ n)))
     (cons s (append prefix suffix (list (decode-char 'ucs code))))))
     list)))

(defconst fira-code-mode--ligatures
  '("www" "**" "***" "**/" "*>" "*/" "\\\\" "\\\\\\"
    "{-" "[]" "::" ":::" ":=" "!!" "!=" "!==" "-}"
    "--" "---" "-->" "->" "->>" "-<" "-<<" "-~"
    "#{" "#[" "##" "###" "####" "#(" "#?" "#_" "#_("
    ".-" ".=" ".." "..<" "..." "?=" "??" ";;" "/*"
    "/**" "/=" "/==" "/>" "//" "///" "&&" "||" "||="
    "|=" "|>" "^=" "$>" "++" "+++" "+>" "=:=" "=="
    "===" "==>" "=>" "=>>" "<=" "=<<" "=/=" ">-" ">="
    ">=>" ">>" ">>-" ">>=" ">>>" "<*" "<*>" "<|" "<|>"
    "<$" "<$>" "<!--" "<-" "<--" "<->" "<+" "<+>" "<="
    "<==" "<=>" "<=<" "<>" "<<" "<<-" "<<=" "<<<" "<~"
    "<~~" "</" "</>" "~@" "~-" "~=" "~>" "~~" "~~>" "%%"
    "x" ":" "+" "+" "*"))

(defvar fira-code-mode--old-prettify-alist)

(defun fira-code-mode--enable ()
  "Enable Fira Code ligatures in current buffer."
  (setq-local fira-code-mode--old-prettify-alist prettify-symbols-alist)
  (setq-local prettify-symbols-alist (append (fira-code-mode--make-alist fira-code-mode--ligatures) fira-code-mode--old-prettify-alist))
  (prettify-symbols-mode t))

(defun fira-code-mode--disable ()
  "Disable Fira Code ligatures in current buffer."
  (setq-local prettify-symbols-alist fira-code-mode--old-prettify-alist)
  (prettify-symbols-mode -1))

(define-minor-mode fira-code-mode
  "Fira Code ligatures minor mode"
  :lighter " Fira Code"
  (setq-local prettify-symbols-unprettify-at-point 'right-edge)
  (if fira-code-mode
      (fira-code-mode--enable)
    (fira-code-mode--disable)))

(defun fira-code-mode--setup ()
  "Setup Fira Code Symbols"
  (set-fontset-font t '(#Xe100 . #Xe16f) "Fira Code Symbol"))

(provide 'fira-code-mode)

;; Making sure that the ligatures are visible
(set-language-environment "UTF-8")
(set-default-coding-systems 'utf-8)

;; Make sure that the spacing for ligatures is correct
(defun my-correct-symbol-bounds (pretty-alist)
  "Prepend a TAB character to each symbol in this alist,
this way compose-region called by prettify-symbols-mode
will use the correct width of the symbols
instead of the width measured by char-width."
  (mapcar (lambda (el)
            (setcdr el (string ?\t (cdr el)))
            el)
          pretty-alist))

;; Enable ligatures in the following modes
(add-hook 'c++-mode-hook 'fira-code-mode)
(add-hook 'emacs-lisp-mode-hook 'fira-code-mode)


;;; Inhibit toolbar
(tool-bar-mode -1)

;;; Inhibit scrollbar
(toggle-scroll-bar -1)


;;; Inhibit menubar
(menu-bar-mode -1)


;;; Helm
(use-package helm
  :ensure t
  :init
  (require 'helm-config)
  :config
  (global-set-key (kbd "M-x") #'helm-M-x)
  (global-set-key (kbd "C-x r b") #'helm-filtered-bookmarks)
  (global-set-key (kbd "C-x C-f") #'helm-find-files)
  (helm-mode 1)
  (setq helm-split-window-in-side-p t
	helm-echo-input-in-header-line t
	helm-display-header-line nil)

  (defun my/helm-hide-minibuffer-maybe ()
	(when (with-helm-buffer helm-echo-input-in-header-line)
      (let ((ov (make-overlay (point-min) (point-max) nil nil t)))
        (overlay-put ov 'window (selected-window))
        (overlay-put ov 'face (let ((bg-color (face-background 'default nil)))
                                `(:background ,bg-color :foreground ,bg-color)))
        (setq-local cursor-type nil))))
  
  (add-hook 'helm-minibuffer-set-up-hook 'helm-hide-minibuffer-maybe))


;;; which-key
;; Shows different key-bindings when pressing leader key
(use-package which-key
  :ensure t
  :config
  (which-key-mode))


;;;smartparens
;;automatic parenthesees completion, etc.
(use-package smartparens
  :ensure t
  :init
  (smartparens-global-mode))

;;; Show parens mode
(setq show-paren-delay 0)
(show-paren-mode)


;;; Line numbers
(setq display-line-numbers t)
(global-linum-mode t)
(linum-relative-mode t) ; Set the line numbers to relative
(setq linum-relative-backend 'display-line-numbers-mode)
(setq linum-relative-current-symbol "")

;;; Custom variables
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(column-number-mode t)
 '(custom-safe-themes
   (quote
	("04dd0236a367865e591927a3810f178e8d33c372ad5bfef48b5ce90d4b476481" "7153b82e50b6f7452b4519097f880d968a6eaf6f6ef38cc45a144958e553fbc6" default)))
 '(delete-selection-mode t)
 '(global-linum-mode t)
 '(helm-completion-style (quote emacs))
 '(line-number-mode nil)
 '(package-selected-packages
   (quote
	(expand-region linum-relative highligt-indent-guides highlight-indent-guides company-irony company which-key use-package smartparens org-bullets helm alect-themes)))
 '(scroll-bar-mode nil)
 '(size-indication-mode t))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(alect-color-level-1 ((t (:foreground "#1e7bda")))))


;;; Org-mode normal size headers
(defun my-org-mode-hook ()
  "Stop the org-level headers from increasing in height relative to the other text."
  (dolist (face '(org-level-1
                  org-level-2
                  org-level-3
                  org-level-4
                  org-level-5))
    (set-face-attribute face nil :weight 'medium :height 1.0)))

(add-hook 'org-mode-hook 'my-org-mode-hook)


;;; Change C-type language style
(setq-default c-default-style "linux"
							c-basic-offset 4
							tab-width 4
							indent-tabs-mode t)   ;;; not working??

;;; Company autocompletion setup
;; (use-package company
;;   :ensure t
;;   :init
;;   (add-hook 'after-init-hook 'global-company-mode)
;;   :config
;;   (setq company-dabbrev-downcase 0)
;;   (setq company-idle-delay 0.1)
;;   (setq company-minimum-prefix-length 1)
;;   (setq company-tooltip-align-annotations t))


;;; Irony, company backend
(eval-after-load 'company
  '(add-to-list 'company-backends 'company-irony))

;;; Save buffers
(setq desktop-save-mode t
	  save-place-mode t)

;;; Indentation guide
(add-hook 'prog-mode-hook 'highlight-indent-guides-mode)
(setq highlight-indent-guides-method 'character
	  highlight-indent-guides-auto-enabled t)


;;; Modeline configurations
(line-number-mode -1)
(column-number-mode t)


;;; Delete selection mode when typing
(delete-selection-mode t)

;;; Expand region
(use-package expand-region
  :config
  (global-set-key (kbd "C-=") 'er/expand-region))
