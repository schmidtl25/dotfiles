;; This buffer is for text that is not saved, and for Lisp evaluation.
;; To create a file, visit it with C-x C-f and enter text in its buffer.

(setq tracefile-highlights
      '(("instr-seq=[0-9]+" . font-lock-function-name-face)
        ("seq=[0-9]+" . font-lock-function-name-face)
        ("Cyc [0-9]+: ERROR" . font-lock-comment-face)
        (" Complete " . font-lock-keyword-face)
        (" RegChange " . font-lock-function-name-face)
        ("Cyc [0-9]+: " . font-lock-constant-face)))

(define-derived-mode tracefile-mode fundamental-mode "tracefile"
  "major mode for editing tracefile."
  (setq font-lock-defaults '(tracefile-highlights)))

(provide 'tracefile-mode)
