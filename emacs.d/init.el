;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Global extras
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Jan24-20 attempt to fix copy-paste with xterm problem

;; Added by Package.el.  This must come before configurations of
;; installed packages.  Don't delete this line.  If you don't want it,
;; just comment it out by adding a semicolon to the start of the line.
;; You may delete these explanatory comments.
(package-initialize)

(setq x-select-enable-primary t)  ; stops killing/yanking interacting with primary X11 selection
(setq x-select-enable-clipboard t)  ; makes killing/yanking interact with clipboard X11 selection
(global-set-key (kbd "<mouse-2>") 'clipboard-yank)
(delete-selection-mode)

(global-set-key "\M-g" 'goto-line)
(global-set-key "\M-R" 'revert-buffer)
(global-set-key "\C-Z" nil)
(global-set-key [f10] 'compile)
(global-set-key [f11] 'cpplint-after-save-hook)

(setq c-default-style '((java-mode . "java")
                        (awk-mode . "awk")
                        (other . "bsd")))
(setq c-basic-offset 2)
(setq-default indent-tabs-mode nil)

(setq scroll-step 1)
(setq next-line-add-newlines nil)

(fset 'yes-or-no-p 'y-or-n-p)
(setq make-backup-files nil)
(setq backup-directory-alist (quote ((".*" . "~/.emacs_backups/"))))
(setq-default require-final-newline 't)

(put 'upcase-region 'disabled nil)

(if (fboundp 'global-font-lock-mode)
    (global-font-lock-mode 1)        ; GNU Emacs
  (setq font-lock-auto-fontify t))   ; XEmacs

;; add colors to compile frame
(require 'ansi-color)
(defun colorize-compilation-buffer ()
  (toggle-read-only)
  (ansi-color-apply-on-region compilation-filter-start (point))
  (toggle-read-only))
(add-hook 'compilation-filter-hook 'colorize-compilation-buffer)

;; disable line wrap
;; (setq-default truncate-lines t)

;; (defun cpplint-after-save-hook ()
;;   "Running CPPLINT"
;;   (if buffer-file-name
;;       (progn
;;         (setq is-hC-file (numberp (string-match "\.C$" buffer-file-name)))
;;         (if is-hC-file
;;             (progn
;;               (setq cwd (shell-command-to-string "echo Entering directory \`$PWD\'"))
;;               ;; (shell-commond (cwd))
;;               (setq cmd "/opt/xsite/cte/tools/python/3/bin/cpplint --extension=C,h,T,c,H,inl --filter=-build/include,-build/header_guard,-runtime/references --linelength=160 ")
;;               (setq cpplint_rc (shell-command-to-string (concat cmd buffer-file-name)))
;;               (message " Entering directory \`%s\'\n%s"  default-directory cpplint_rc buffer-file-name))))))
;; (add-hook 'after-save-hook 'cpplint-after-save-hook)

(defun cpplint-after-save-hook ()
  "Running CPPLINT"
  (if buffer-file-name
      (progn
        (setq is-hC-file (numberp (string-match "\.[hC]$" buffer-file-name)))
        (if is-hC-file
            (progn
              (setq cmd "/opt/xsite/cte/tools/python/3/bin/cpplint --extension=C,h,T,c,H,inl --filter=-build/include,-build/header_guard,-runtime/references --linelength=160 ")
              (compile (concat cmd buffer-file-name))
              )
          )
        )
    )
  )


;; (add-hook 'after-save-hook 'cpplint-after-save-hook)

              ;; (setq cwd (shell-command-to-string "echo Entering directory \`$PWD\'"))
              ;; (shell-commond (cwd))
              ;; (message " Entering directory \`%s\'\n%s"  default-directory cpplint_rc buffer-file-name))))))

(defun notify-compilation-result(buffer msg)
  "Notify that the compilation is finished,
close the *compilation* buffer if the compilation is successful,
and set the focus back to Emacs frame"
  (if (string-match "^finished" msg)
    (progn
     ;; (delete-windows-on buffer)
     (tooltip-show "\n Compilation Successful :-) \n "))
    (tooltip-show "\n Compilation Failed :-( \n "))
  (setq current-frame (car (car (cdr (current-frame-configuration)))))
  (select-frame-set-input-focus current-frame)
  )

(add-to-list 'compilation-finish-functions
             'notify-compilation-result)
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(inhibit-startup-screen t))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

(add-to-list 'load-path "~/.emacs.d/lisp/")

(require 'tracefile-mode)
(add-to-list 'auto-mode-alist '("\\.trace\\'" . tracefile-mode))
(add-to-list 'auto-mode-alist '("\\.trace.gz\\'" . tracefile-mode))

(require 'yaml-mode)
(add-to-list 'auto-mode-alist '("\\.yml\\'" . yaml-mode))
(add-to-list 'auto-mode-alist '("\\.yaml\\'" . yaml-mode))

(add-to-list 'auto-mode-alist '("\\.groovy\\'" . java-mode))
