
(package-initialize)

(add-to-list 'package-archives
             '("melpa" . "https://melpa.org/packages/")
             '("melpa" . "http://melpa.milkbox.net/packages/"))
(package-initialize)

(let ((packages      
       '(company
         auctex
         avy
         cmake-ide
         cmake-mode
         dockerfile-mode
         edit-indirect
         exec-path-from-shell
         go-mode
         htmlize
         js2-mode
         json-mode
         lua-mode
         magit
         markdown-mode
         neotree
         password-store
         php-mode
         rainbow-mode
         rtags
         rust-mode
         web-mode
         window-numbering
         yaml-mode)))
  (when (member nil (mapcar 'package-installed-p packages))
    (package-refresh-contents)
    (mapc 'package-install packages)))

(global-set-key (kbd "C-c p") 'package-list-packages)

(load-theme 'my t)

(custom-set-variables
 '(custom-raised-buttons t)
 '(widget-push-button-prefix " ")
 '(widget-push-button-suffix " ")
 '(widget-link-prefix " ")
 '(widget-link-suffix " "))

;; (defun my/trim-whitespace--handler ()
;;   "Delete trailing whitespaces if `my/trim-whitespace-mode' is enabled."
;;   (when my/trim-whitespace-mode
;;     (delete-trailing-whitespace)))

;; (define-minor-mode my/trim-whitespace-mode
;;   "Delete trailing whitespaces on save."
;;   :init-value t
;;   :lighter " W"
;;   (my/trim-whitespace--handler))

(add-hook 'before-save-hook 'my/trim-whitespace--handler)

(global-set-key (kbd "C-c d") 'my/trim-whitespace-mode)

(defalias 'goto-line 'avy-goto-line)

(global-set-key (kbd "C-c l") 'avy-goto-char-timer)

(custom-set-variables
 '(backup-by-copying t)
 '(backup-directory-alist '(("." . "~/.emacs.d/backups"))))

(custom-set-variables
 '(calculator-electric-mode t))

(global-set-key (kbd "C-c m") 'calculator)

(custom-set-variables
 '(require-final-newline 'ask)
 '(fill-column 80)
 '(c-backslash-column 79)
 '(c-backslash-max-column 79)
 '(indent-tabs-mode nil)
 '(c-basic-offset 4)
 '(c-set-offset 'case-label '+)
 '(c-offsets-alist
   '((substatement-open . 0)
     (brace-list-intro . +)
     (arglist-intro . +)
     (arglist-close . 0)
     (cpp-macro . 0)
     (innamespace . 0))))

(add-hook 'after-init-hook 'global-company-mode)

(add-hook 'comb-buffer-setup-hook
          (lambda ()
            (toggle-truncate-lines nil)))

(global-set-key (kbd "C-c b") 'comb)

(custom-set-variables
 '(compile-command "make")
 '(compilation-scroll-output 'first-error)
 '(compilation-always-kill t)
 '(compilation-disable-input t))

(add-hook 'compilation-mode-hook 'visual-line-mode)

(defun my/compile-auto-quit (buffer status)
  (let ((window (get-buffer-window buffer)))
    (when (and (equal (buffer-name buffer) "*compilation*") ; do not kill grep and similar
               my/compile-should-auto-quit
               window
               (equal status "finished\n"))
      (run-at-time 1 nil 'quit-window nil window))))

(add-to-list 'compilation-finish-functions 'my/compile-auto-quit)

(defun my/compile-before (&rest ignore)
  (let* ((buffer (get-buffer "*compilation*"))
         (window (get-buffer-window buffer)))
    (setq my/compile-should-auto-quit (not (and buffer window)))))

(advice-add 'compile :before 'my/compile-before)
(advice-add 'recompile :before 'my/compile-before)

(defun my/smart-compile ()
  "Recompile or prompt a new compilation."
  (interactive)
  ;; reload safe variables silently
  (let ((enable-local-variables :safe))
    (hack-local-variables))
  ;; smart compile
  (if (local-variable-p 'compile-command)
      (compile compile-command)
    (let ((buffer (get-buffer "*compilation*")))
      (if buffer
          (with-current-buffer buffer
            (recompile))
        (call-interactively 'compile)))))

(global-set-key (kbd "C-c c") 'my/smart-compile)
(global-set-key (kbd "C-c C") 'compile)

(global-set-key (kbd "M-p") 'backward-paragraph)
(global-set-key (kbd "M-n") 'forward-paragraph)

(require 'ls-lisp)

(custom-set-variables
 '(ls-lisp-use-insert-directory-program nil))

(custom-set-variables
 '(ls-lisp-dirs-first t)
 '(ls-lisp-use-localized-time-format t)
 '(ls-lisp-verbosity '(uid gid)))

(custom-set-variables
 '(custom-file "/dev/null"))

(defun my/force-revert-buffer ()
  "Revert buffer without confirmation."
  (interactive)
  (revert-buffer t t))

(global-set-key (kbd "C-c R") 'my/force-revert-buffer)

(global-set-key (kbd "C-c v") 'eval-buffer)

(custom-set-variables
 '(erc-modules '(completion
                 autojoin
                 button
                 irccontrols
                 list
                 match
                 menu
                 move-to-prompt
                 netsplit
                 networks
                 noncommands
                 readonly
                 ring
                 stamp
                 track)))

(add-hook 'erc-mode-hook 'visual-line-mode)

(custom-set-variables
 '(erc-track-exclude-types '("JOIN" "KICK" "NICK" "PART" "QUIT" "MODE")))

(custom-set-variables
 '(erc-insert-timestamp-function 'erc-insert-timestamp-left)
 '(erc-timestamp-format "[%H:%M] ")
 '(erc-timestamp-only-if-changed-flag nil))

(add-hook 'erc-mode-hook
          (lambda ()
            (set (make-local-variable 'scroll-conservatively) 101)))

(defun my/irc ()
  (interactive)
  (let* ((credentials (split-string (password-store-get "Freenode")))
         (nick (nth 0 credentials))
         (password (nth 1 credentials)))
    (erc
     :server "irc.freenode.net"
     :port 6667
     :nick nick
     :password password)))

(custom-set-variables
 '(erc-autojoin-channels-alist '(("freenode.net$" . ("#emacs")))))

(global-set-key (kbd "C-c i") 'my/irc)

(global-set-key (kbd "<f5>") 'previous-error)
(global-set-key (kbd "<f8>") 'next-error)

(defun my/eshell-prompt-function ()
  (format "%s\n%s "
          (abbreviate-file-name (eshell/pwd))
          (if (= (user-uid) 0) "#" "$")))

(custom-set-variables
 '(eshell-banner-message "")
 '(eshell-prompt-regexp "^[$#] ")
 '(eshell-prompt-function 'my/eshell-prompt-function))

(global-set-key (kbd "C-c e") 'eshell)

(eval-after-load "grep"
  '(add-to-list 'grep-find-ignored-directories "node_modules"))

(defun my/rgrep-fix (&rest ignore)
  (save-excursion
    (with-current-buffer grep-last-buffer
      (goto-line 5) ; manually checked
      (narrow-to-region (point) (point-max)))))

(advice-add 'rgrep :after 'my/rgrep-fix)

(defun my/rgrep-again ()
  (interactive)
  (let* ((buffer (if (buffer-live-p grep-last-buffer)
                     grep-last-buffer (current-buffer)))
         (default-directory (buffer-local-value 'default-directory buffer)))
    (rgrep (thing-at-point 'symbol t)
           (car grep-files-history)
           default-directory)))

(global-set-key (kbd "C-c g") 'rgrep)
(global-set-key (kbd "C-c G") 'my/rgrep-again)

(add-to-list 'auto-mode-alist '("\\.html?\\'" . web-mode))

(custom-set-variables
 '(ibuffer-expert t))

(defalias 'list-buffers 'ibuffer)

(custom-set-variables
 '(initial-scratch-message "")
 '(initial-buffer-choice t))

(custom-set-variables
 '(ispell-silently-savep t))

(add-to-list 'safe-local-eval-forms
             '(setq ispell-personal-dictionary
                    (concat (locate-dominating-file default-directory ".dir-locals.el")
                            ".dictionary")))

(add-to-list 'auto-mode-alist '("\\.js\\'" . js2-mode))
(add-to-list 'interpreter-mode-alist '("node" . js2-mode))

(defun my/keywords-highlighting ()
  (let* ((regexp "\\<TODO\\>\\|\\<XXX\\>")
         (match `((,regexp 0 font-lock-warning-face t))))
    (font-lock-add-keywords nil match t)))

(add-hook 'text-mode-hook 'my/keywords-highlighting)
(add-hook 'prog-mode-hook 'my/keywords-highlighting)

(global-git-commit-mode)
(add-hook 'git-commit-setup-hook 'git-commit-turn-on-flyspell)

(global-set-key (kbd "C-c s") 'magit-status)

(custom-set-variables
 `(markdown-fontify-code-blocks-natively t))

(add-hook 'markdown-mode-hook 'visual-line-mode)

(custom-set-variables
 '(savehist-mode t)
 '(history-length t))

(custom-set-variables
 '(mouse-wheel-scroll-amount '(1 ((shift) . 5)))
 '(mouse-wheel-progressive-speed nil)
 '(mouse-yank-at-point t))

(defun my/yank-primary ()
  "Yank the primary selection (the one selected with the mouse)."
  (interactive)
  (insert-for-yank (gui-get-primary-selection)))

(global-set-key (kbd "S-<insert>") 'my/yank-primary)

(global-set-key (kbd "C-c n") 'neotree-toggle)

(custom-set-variables
 '(org-src-preserve-indentation t)
 '(org-src-tab-acts-natively t)
 '(org-startup-folded nil)
 '(org-cycle-separator-lines 1)
 '(org-blank-before-new-entry '((heading . t) (plain-list-item))))

(custom-set-variables
 '(org-highlight-latex-and-related '(latex))
 '(org-fontify-quote-and-verse-blocks t)
 '(org-src-fontify-natively t)
 '(org-fontify-whole-heading-line t)
 '(org-ellipsis "\u2026"))

(defun my/org-ispell ()
  "Skip regions from spell checking."
  (make-local-variable 'ispell-skip-region-alist)
  (add-to-list 'ispell-skip-region-alist '("~" . "~"))
  (add-to-list 'ispell-skip-region-alist '("=" . "="))
  (add-to-list 'ispell-skip-region-alist '("\\[" . "\\]"))
  (add-to-list 'ispell-skip-region-alist '("^ *#\\+OPTIONS:" . "$"))
  (add-to-list 'ispell-skip-region-alist '("^ *#\\+ATTR_" . "$"))
  (add-to-list 'ispell-skip-region-alist '("^ *#\\+BEGIN_SRC" . "^ *#\\+END_SRC"))
  (add-to-list 'ispell-skip-region-alist '("^ *#\\+BEGIN_EXAMPLE" . "^ *#\\+END_EXAMPLE")))

(add-hook 'org-mode-hook 'my/org-ispell)

(add-hook 'org-mode-hook 'visual-line-mode)
(add-hook 'org-mode-hook 'org-indent-mode)

(advice-add 'org-global-cycle :before 'beginning-of-buffer)

(add-to-list 'auto-mode-alist '("\\.inc$" . php-mode))

(advice-add 'iconify-or-deiconify-frame :before-until 'display-graphic-p)

(set-display-table-slot standard-display-table 'vertical-border #x2502)

(custom-set-variables
 '(python-shell-interpreter "python3"))

(custom-set-variables
 '(save-place-mode t))

(custom-set-variables
 '(scroll-step 1)
 '(scroll-margin 0)
 '(hscroll-step 1)
 '(hscroll-margin 0))

(custom-set-variables
 '(async-shell-command-buffer 'new-buffer)
 '(async-shell-command-display-buffer nil))

(custom-set-variables
 '(auto-insert t)
 '(auto-insert-mode t)
 '(auto-insert-query nil)
 '(auto-insert-alist nil))

(add-to-list 'auto-insert-alist '("\\.c\\'" . my/c-source-skeleton))

(define-skeleton my/c-source-skeleton
  "C source skeleton"
  nil
  "/* -*- compile-command: \"gcc -Wall -pedantic -g3 "
  (buffer-name) " -o " (file-name-base) "\" -*- */\n"
  "#include <stdio.h>\n"
  "#include <stdlib.h>\n"
  "#include <string.h>\n"
  "\n"
  "int main(int argc, char *argv[]) {\n"
  "    " _ "printf(\"Hello, world\\n\");\n"
  "    return EXIT_SUCCESS;\n"
  "}\n")

(add-to-list 'auto-insert-alist '("\\.cpp\\'" . my/c++-source-skeleton))

(define-skeleton my/c++-source-skeleton
  "C++ source skeleton"
  nil
  "// -*- compile-command: \"g++ -std=c++14 -Wall -pedantic -g3 "
  (buffer-name) " -o " (file-name-base) "\" -*-\n"
  "#include <iostream>\n"
  "\n"
  "int main(int argc, char *argv[]) {\n"
  "    " _ "std::cout << \"Hello, world\" << std::endl;\n"
  "}\n")

(add-to-list 'auto-insert-alist '("\\.html\\'" . my/html-skeleton))

(define-skeleton my/html-skeleton
  "HTML skeleton"
  nil
  "<!DOCTYPE html>\n"
  "<html lang=\"en\">\n"
  "    <head>\n"
  "        <meta charset=\"utf-8\">\n"
  "        <title></title>\n"
  "        <style></style>\n"
  "        <script></script>\n"
  "    </head>\n"
  "    <body>\n"
  "        " _ "Hello, world\n"
  "    </body>\n"
  "</html>\n")

(defun my/shell-terminal ()
  "Run a shell terminal without prompt."
  (interactive)
  (term (getenv "SHELL")))

(global-set-key (kbd "C-c t") 'my/shell-terminal)
(global-set-key (kbd "C-c l") 'shell)

(windmove-default-keybindings)

(custom-set-variables
 '(blink-cursor-mode nil)
 '(column-number-mode t)
 '(disabled-command-function nil)
 '(echo-keystrokes 0.25)
 '(font-lock-maximum-decoration 2)
 '(help-window-select t)
 '(indicate-buffer-boundaries 'left)
 '(indicate-empty-lines t)
 '(isearch-allow-scroll t)
 '(menu-bar-mode nil)
 '(ring-bell-function 'ignore)
 '(scroll-bar-mode nil)
 '(show-paren-mode t)
 '(tab-width 4)
 '(tool-bar-mode nil)
 '(truncate-lines t)
 '(use-dialog-box nil))

(custom-set-variables
 '(window-numbering-mode t))

(custom-set-variables
 '(winner-mode t))

(custom-set-variables
 '(woman-fill-frame t))

(add-hook 'yaml-mode-hook 'visual-line-mode)

(custom-set-variables
 '(zoom-mode t)
 '(zoom-size '(90 . 30))
 '(temp-buffer-resize-mode t))

(global-set-key (kbd "C-c z") 'zoom)

;; Standard Jedi.el setting for python autocompletion
(add-hook 'python-mode-hook 'jedi:setup)
(setq jedi:complete-on-dot t)

;; Type:
;;     M-x package-install RET jedi RET
;;     M-x jedi:install-server RET
;; Then open Python file.

;; golang
;; (add-to-list 'load-path "~/.emacs.d/go-mode")

(require 'go-complete)
(add-hook 'completion-at-point-functions 'go-complete-at-point)
