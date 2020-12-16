;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets.
(setq user-full-name "GinShio"
      user-mail-address "iris@ginshio.org"
      user-gpg-key "52558B082D1A7C5FE62F7778F152EB9432ABA0F8"
      user-hugo-domain "https://blog.ginshio.org"
      org-export-html-highlight-style "atom-one-dark"
      wakatime-api-key "cb5cccd0-e5a0-4922-abfd-748a42a96cae"
      doom-config-dir (concat (getenv "HOME") "/" ".doom.d")
      )

;; Doom exposes five (optional) variables for controlling fonts in Doom. Here
;; are the three important ones:
;;
;; + `doom-font'
;; + `doom-variable-pitch-font'
;; + `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;;
;; They all accept either a font-spec, font string ("Input Mono-12"), or xlfd
;; font string. You generally only need these two:
;; (setq doom-font (font-spec :family "monospace" :size 12 :weight 'semi-light)
;;       doom-variable-pitch-font (font-spec :family "sans" :size 13))

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
(setq doom-theme 'doom-one)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/org/")

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type 'relative)


;; Here are some additional functions/macros that could help you configure Doom:
;;
;; - `load!' for loading external *.el files relative to this one
;; - `use-package!' for configuring packages
;; - `after!' for running code after a package has loaded
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c c k').
;; This will open documentation for it, including demos of how they are used.
;;
;; You can also try 'gd' (or 'C-c c d') to jump to their definition and see how
;; they are implemented.

;;;;;;;;;;;;;;;;;;;;;;;;; default ;;;;;;;;;;;;;;;;;;;;;;;;;
(use-package! exec-path-from-shell
  :if (memq window-system '(ns mac x))
  :config
  (setq exec-path-from-shell-arguments '("-l"))
  (exec-path-from-shell-initialize)
  ) ;; shell env
(when IS-WINDOWS
  (setq-default buffer-file-coding-system 'utf-8-unix)
  (setq-default default-buffer-file-coding-system 'utf-8-unix)
  (set-default-coding-systems 'utf-8-unix)
  (prefer-coding-system 'utf-8-unix)) ;; WindowsNT coding system
(use-package! hungry-delete
  :config
  (setq-default hungry-delete-chars-to-skip " \t\v")
  (add-hook! 'after-init-hook #'global-hungry-delete-mode)
  )
(after! company
  (custom-set-variables '(company-show-numbers t))
  )
(after! general
  (general-create-definer ginshio/leader :prefix "s-w")
  (ginshio/leader
    :keymaps 'global-map
    "o" '(nil :which-key "operations"))
  )
(after! hl-todo
  (custom-set-variables
   '(hl-todo-keyword-faces '(("NOTE" font-lock-variable-name-face bold) ;; needs discussion or further investigation.
                             ("REVIEW" font-lock-function-name-face bold) ;; review was conducted.
                             ("TODO" font-lock-constant-face bold) ;; tasks/features to be done.
                             ("HACK" font-lock-keyword-face bold) ;; workaround a known problem.
                             ("DEPRECATED" font-lock-doc-face bold) ;; why it was deprecated and to suggest an alternative.
                             ("XXX+" success bold) ;; warn other programmers of problematic or misguiding code.
                             ("FIXME" warning bold) ;; problematic or ugly code needing refactoring or cleanup.
                             ("BUG" error bold) ;; a known bug that should be corrected.
                             )))
  (ginshio/leader
    :keymaps 'hl-todo-mode-map
    "op" '(hl-todo-previous :which-key "hl-todo-previous")
    "on" '(hl-todo-next :which-key "hl-todo-next")
    "oo" '(hl-todo-occur :which-key "hl-todo-occur"))
  )
(after! ivy
  (define-key! ivy-minibuffer-map "TAB" #'ivy-partial-or-done)
  )
(after! yasnippet
  (custom-set-variables '(yas-snippet-dirs '(+snippets-dir)))
  (ginshio/leader
    :keymaps 'global-map
    "y" '(ivy-yasnippet :which-key "yasnippet"))
  )
(global-wakatime-mode)  ;; wakatime, dep wakatime
(custom-set-variables '(delete-selection-mode t) ;; delete when you select region and modify
                      '(delete-by-moving-to-trash t) ;; delete && move to transh
                      '(inhibit-compacting-font-caches t) ;; don’t compact font caches during GC.
                      '(gc-cons-percentage 1)
                      )
(run-with-idle-timer 16 t (lambda () (garbage-collect)))
(global-unset-key (kbd "C-z"))
(map! (:leader (:desc "Load a saved workspace" :g "wR" #'+workspace/load))) ;; workspace load keybind
(define-key! global-map "C-s" #'counsel-grep-or-swiper)
(define-key! global-map "M-s o" #'occur)
(define-key! global-map "M-s e" #'iedit-mode)
(add-hook 'ediff-after-quit-hook-internal 'winner-undo)
(add-hook 'doc-view-mode-hook 'auto-revert-mode) ;; auto revert file, if it has modified
(add-hook 'prog-mode-hook (lambda () (setq show-trailing-whitespace 1)))
(setq! auto-mode-alist
       (append '(("\\.tcc\\'" . c++-mode)
		 )
               auto-mode-alist))

;;;;; dired ;;;;;
;; mark files and ediff in dired mode <https://oremacs.com/2017/03/18/dired-ediff/>
;;;###autoload
(defun ginshio/dired-ediff-files ()
  "Mark files and ediff in dired mode, you can mark 1, 2 or 3 files and diff."
  (interactive)
  (let ((files (dired-get-marked-files)))
    (cond ((= (length files) 0))
          ((= (length files) 1)
           (let ((file1 (nth 0 files))
                 (file2 (read-file-name "file: " (dired-dwim-target-directory))))
             (ediff-files file1 file2)))
          ((= (length files) 2)
           (let ((file1 (nth 0 files)) (file2 (nth 1 files)))
             (ediff-files file1 file2)))
          ((= (length files) 3)
           (let ((file1 (car files)) (file2 (nth 1 files)) (file3 (nth 2 files)))
             (ediff-files3 file1 file2 file3)))
          (t (error "no more than 3 files should be marked")))))
(after! dired
  (define-key! dired-mode-map "RET" #'dired-find-alternate-file)
  (define-key! dired-mode-map "C" #'dired-async-do-copy)
  (define-key! dired-mode-map "H" #'dired-async-do-hardlink)
  (define-key! dired-mode-map "R" #'dired-async-do-rename)
  (define-key! dired-mode-map "S" #'dired-async-do-symlink)
  (define-key! dired-mode-map "n" #'dired-next-marked-file)
  (define-key! dired-mode-map "p" #'dired-prev-marked-file)
  (define-key! dired-mode-map "=" #'ginshio/dired-ediff-files)
  (define-key! dired-mode-map "<mouse-2>" #'dired-mouse-find-file)
  ;; show/hide dotfiles in current dired <https://www.emacswiki.org/emacs/DiredOmitMode>
  (define-advice dired-do-print (:override (&optional _))
    "show/hide dotfiles in current dired"
    (interactive)
    (if (or (not (boundp 'dired-dotfiles-show-p)) dired-dotfiles-show-p)
        (progn (setq-local dired-dotfiles-show-p nil)
               (dired-mark-files-regexp "^\\.")
               (dired-do-kill-lines))
      (revert-buffer)
      (setq-local dired-dotfiles-show-p t)))
  (define-advice dired-up-directory (:override (&optional _))
    "goto up directory in this buffer"
    (interactive)
    (find-alternate-file ".."))
  )


;;;;; translate ;;;;;
(use-package! youdao-dictionary
  :config
  (ginshio/leader
    :keymaps 'global-map
    "t" '(nil :which-key "translate")
    "ti" '(youdao-dictionary-search-from-input :which-key "translate (input)")
    "tt" '(youdao-dictionary-search-at-point-posframe :which-key "translate (point+)")
    "tT" '(youdao-dictionary-search-at-point :which-key "translate (point)")
    "tv" '(youdao-dictionary-play-voice-at-point :which-key "play voice (point)")
    "tV" '(youdao-dictionary-play-voice-from-input :which-key "play voice (input)")
    )
  ) ;; youdao translate
;; (use-package! go-translate
;;   :config
;;   (setq! go-translate-base-url "https://translate.google.cn"
;;          go-translate-local-language "zh-CN"
;;          go-translate-extra-directions '(("zh-CN" . "en") ("zh-CN". "ja") ("zh-CN" . "de") ("zh-CN" . "ru"))
;;          )
;;   (ginshio/leader
;;     :keymaps 'global-map
;;     "t" '(nil :which-key "translate")
;;     "ti" '(go-translate-popup :which-key "translate (input)")
;;     "tt" '(go-translate-popup-current :which-key "translate (point+)")
;;     "tT" '(go-translate :which-key "translate (point)")
;;     )
;;   ) ;; google translate

;;;;; yasnippt ;;;;;
;;;###autoload
(defun ginshio/get-file-name ()
  (file-name-nondirectory (buffer-file-name)))
;;;###autoload
(defun ginshio/get-file-in-project ()
  (substring (buffer-file-name)
             (length (projectile-project-root))))
;;;###autoload
(defun ginshio/get-header-define-guard ()
  (replace-regexp-in-string
   "[^a-z0-9A-Z_]" "_"
   (replace-regexp-in-string "C\\+\\+" "CXX"
                             (upcase (concat (let ((tmp_root (projectile-project-name)))
                                               (if (equal "-" tmp_root)
                                                   "" (concat tmp_root "_")))
                                             (ginshio/get-file-in-project) "_")))))
;;;###autoload
(defun ginshio/get-c-cxx-include-header ()
  (let (source source_exten header header_exten)
    (setq source (ginshio/get-file-in-project)
          source_exten (file-name-extension source))
    (cond ((equal source_exten "cpp") (setq header_exten "hpp"))
          ((equal source_exten "tcc") (setq header_exten "hh"))
          ((equal source_exten "cc") (setq header_exten "hh"))
          ((equal source_exten "cxx") (setq header_exten "hxx"))
          (t (setq header_exten "h")))
    (let ((s (replace-regexp-in-string (concat source_exten "$") header_exten source)))
      (if (equal (projectile-project-name) "-") s
        (let ((l (cdr (split-string s "/"))))
          (if l (string-join (add-to-list 'l "include") "/") s))))
    ))





;;;;;;;;;;;;;;;;;;;;;;;;; writer ;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;; org-mode ;;;;;
(setq! org-superstar-headline-bullets-list '("✙" "♱" "♰" "☥" "✞" "✟" "✝" "†"))
(after! org-fancy-priorities
  (custom-set-variables '(org-lowest-priority ?D))
  (setq! org-fancy-priorities-list '("⚡" "⮬" "⮮" "☕"))
  )
(use-package! org-crypt
  :after org
  :custom
  (org-crypt-key user-gpg-key)
  (org-tags-exclude-from-inheritance '("crypt")) ;; avoid repeated encryption
  :config
  (org-crypt-use-before-save-magic) ;; encrypt when writing back to the hard disk
  (ginshio/leader
    :keymaps 'org-mode-map
    "c" '(nil :which-key "org-crypt")
    "ce" '(org-encrypt-entry :which-key "encrypt one")   ;; encrypt one
    "ca" '(org-encrypt-entries :which-key "encrypt all") ;; encrypt all
    "cd" '(org-decrypt-entry :which-key "decrypt one")   ;; decrypt one
    "cc" '(org-decrypt-entries :which-key "decrypt all") ;; decrypt all
    ))
;; org-agenda files
(let ((org-agenda (concat org-directory "agenda/")))
  (setq! org-agenda-file-inbox (expand-file-name "inboxes.org" org-agenda)
         org-agenda-file-journal (expand-file-name "journals.org" org-agenda)
         org-agenda-file-note (expand-file-name "notes.org" org-agenda)
         org-agenda-file-snippet (expand-file-name "snippets.org" org-agenda)
         org-agenda-file-task (expand-file-name "tasks.org" org-agenda))
  (setq! org-agenda-files `(,org-agenda-file-task))
  )
(after! org-capture
  ;; http://www.howardism.org/Technical/Emacs/journaling-org.html
  ;; https://www.zmonster.me/2018/02/28/org-mode-capture.html
  (setq org-capture-templates
        `(("i" "Inbox" entry (file ,org-agenda-file-inbox)
           "* %^{heading} %^g\n%?" :empty-lines 1)
          ("j" "Journal")
          ("jc" "Crypt" entry (file+olp+datetree ,org-agenda-file-journal "Crypt")
           "* %<%H:%M> - %^{heading} :crypt:%^g\n%?" :empty-lines 1)
          ("jn" "Normal" entry (file+olp+datetree ,org-agenda-file-journal "Normal")
           "* %<%H:%M> - %^{heading} %^g\n%?" :empty-lines 1)
          ("n" "Note")
          ("nb" "Book" entry (file+olp+datetree ,org-agenda-file-note "Book")
           "* %^{heading} %^g\n%?\n" :empty-lines 1)
          ("nc" "Computer" entry (file+olp+datetree ,org-agenda-file-note "Computer")
           "* %^{heading} %^g\n%?\n" :empty-lines 1)
          ("ne" "Emacs" entry (file+olp ,org-agenda-file-note "Emacs")
           "* %^{heading} %^g\n%?\n" :empty-lines 1)
          ("nl" "Life" entry (file+olp+datetree ,org-agenda-file-note "Life")
           "* %^{heading} %^g\n%?\n" :empty-lines 1)
          ("s" "Code Snippet" entry (file ,org-agenda-file-snippet)
           "* %?\t%^g\n#+BEGIN_SRC %^{language}\n\n#+END_SRC" :empty-lines 1)
          ("t" "Tasks")
          ("te" "Emergency" entry (file+headline ,org-agenda-file-task "Emergency")
           "* TODO [#A] %^{heading}\n  SCHEDULED: %^T DEADLINE: %^T\n  :PROPERTIES:\n  :END:\n%?"
           :empty-lines 1)
          ("ti" "Important" entry (file+headline ,org-agenda-file-task "Important")
           "* TODO [#B] %^{heading}\n  SCHEDULED: %^T DEADLINE: %^T\n  :PROPERTIES:\n  :END:\n%?"
           :empty-lines 1)
          ("tt" "Task" entry (file+headline ,org-agenda-file-task "Task")
           "* TODO [#C] %^{heading}\n  SCHEDULED: %T DEADLINE: %^T\n  :PROPERTIES:\n  :END:\n%?"
           :empty-lines 1)
          )))
(use-package! ox-publish
  :after org
  :init
  ;; Use highlight.js <http://0x100.club/wiki_emacs/highlight-code.html>
  (defun ginshio//org-html-src-block (src-block _contents info)
    "Transcode a SRC-BLOCK element from Org to HTML.
CONTENTS holds the contents of the item.  INFO is a plist holding contextual information."
    (if (org-export-read-attribute :attr_html src-block :textarea)
        (org-html--textarea-block src-block)
      (let ((lang (org-element-property :language src-block))
            (code (org-html-format-code src-block info))
            (label (let ((lbl (and (org-element-property :name src-block)
                                   (org-export-get-reference src-block info))))
                     (if lbl (format " id=\"%s\"" lbl) ""))))
        (if (not lang) (format "<pre><code class=\"example\"%s>\n%s</code></pre>" label code)
          (format "<div class=\"container\">\n%s%s\n</div>"
                  ;; Build caption.
                  (let ((caption (org-export-get-caption src-block)))
                    (if (not caption) ""
                      (let ((listing-number
                             (format "<span class=\"listing-number\">%s </span>"
                                     (format
                                      (org-html--translate "Listing %d:" info)
                                      (org-export-get-ordinal src-block info nil #'org-html--has-caption-p)))))
                        (format "<label class=\"org-src-name\">%s%s</label>"
                                listing-number
                                (org-trim (org-export-data caption info))))))
                  ;; Contents.
                  (format "<pre><code class=\"%s\"%s>%s</code></pre>" lang label code))))))
  :config
  ;; \LaTeX
  (setq! org-latex-compiler "xelatex")
  (org-babel-do-load-languages
   'org-babel-load-languages
   '((sql . t)
     (shell . t)
     (perl . t)
     (ruby . t)
     (dot . t)
     (js . t)
     (latex .t)
     (python . t)
     (emacs-lisp . t)
     (C . t)
     (plantuml . t)
     (ditaa . t)))
  ;; HTML
  (setq org-html-html5-fancy t
        org-html-head-include-default-style nil
        org-html-htmlize-output-type nil
        org-html-head (concat "<!-- Style -->
<link rel=\"stylesheet\" type=\"text/css\" href=\"https://gongzhitaao.org/orgcss/org.css\"/>
<!-- Highlight -->
<link rel=\"stylesheet\" href=\"https://cdn.jsdelivr.net/gh/highlightjs/cdn-release@10.1.2/build/styles/" org-export-html-highlight-style ".min.css\">
<script src=\"https://cdn.jsdelivr.net/gh/highlightjs/cdn-release@10.1.2/build/highlight.min.js\"></script>
<script>hljs.initHighlightingOnLoad();</script>\n")
        org-publish-project-alist `(("org-notes"
                                     :base-directory ,(concat org-directory "publish/")
                                     :base-extension "org"
                                     :publishing-directory ,(concat org-directory "publish/posts")
                                     :recursive t
                                     :html-head ,org-html-head
                                     :publishing-function org-html-publish-to-html
                                     :headline-levels 3       ;; Just the default for this project.
                                     :auto-preamble t
                                     :section-numbers nil
                                     :html-doctype "html5"
                                     :html-preamble ""
                                     :author ,user-full-name
                                     :email ,user-mail-address
                                     :auto-sitemap t
                                     :sitemap-filename "sitemap.org"
                                     :sitemap-title "sitemap"
                                     :sitemap-sort-files anti-chronologically
                                     :sitemap-file-entry-format "%t") ;; %d to output date, we don't need date here
                                    ("org-static"
                                     :base-directory ,org-directory
                                     :base-extension "css\\|js\\|png\\|jpg\\|gif\\|pdf\\|mp3\\|ogg\\|swf"
                                     :publishing-directory ,(concat org-directory "publish/assets")
                                     :recursive t
                                     :publishing-function org-publish-attachment)
                                    ("org" :components ("org-notes" "org-static"))))
  (advice-add 'org-html-src-block :override 'ginshio//org-html-src-block)
  :custom
  (org-image-actual-width '(300))
  (org-latex-classes '(("article" "\\documentclass[utf8,11pt,a4paper]{article}
[DEFAULT-PACKAGES]\n[PACKAGES]
\\input{/home/GinShio/Templates/article/code}
\\input{/home/GinShio/Templates/article/style}
[EXTRA]
"
                        ("\\section{%s}" . "\\section*{%s}")
                        ("\\subsection{%s}" . "\\subsection*{%s}")
                        ("\\subsubsection{%s}" . "\\subsubsection*{%s}")
                        ("\\paragraph{%s}" . "\\paragraph*{%s}")
                        ("\\subparagraph{%s}" . "\\subparagraph*{%s}"))))
  (org-latex-pdf-process '("latexmk -pdf -f -bibtex -pdflatex=\"xelatex -shell-escape -8bit -synctex=1 -interaction=nonstopmode\" %f"
                           "latexmk -c"
                           "rm -rf .auctex-auto/ _minted-%b/ %b.listing %b.synctex.gz %b.thm %b.bbl %b.run.xml"))
  (org-latex-listings 'minted)
  )
(use-package! toc-org
  :defer t)
(after! org-roam
  (ginshio/leader
    :keymaps 'org-mode-map
    "r" '(nil :which-key "org-roam")
    "rt" 'org-roam-dailies-today
    "rb" '(org-roam-buffer-toggle-display :which-key "buffer-toggle-display")
    "ro" '(org-roam-switch-to-buffer :which-key "switch-to-buffer")
    "rf" 'org-roam-find-file
    "ri" 'org-roam-insert
    "rg" 'org-roam-graph)
  )
(use-package! easy-hugo
  :after ox-hugo
  :config
  (setq! easy-hugo-root (concat org-directory "hugo/")
         easy-hugo-basedir (concat org-directory "hugo/")
         easy-hugo-url user-hugo-domain
         easy-hugo-previewtime "300"
         easy-hugo-default-ext ".org"
         easy-hugo-server-flags "-D"
         easy-hugo-postdir "content/posts/")
  (ginshio/leader
    :keymaps 'org-mode-map
    "h" '(nil :which-key "hugo")
    "he" '(org-hugo-export-to-md :which-key "export")
    "hc" '(easy-hugo-open-config :which-key "config")
    "hl" '(easy-hugo :which-key "list-files")
    "hr" '(easy-hugo-refresh :which-key "refresh")
    "hs" '(easy-hugo-sort-time :which-key "sort-time")
    "hS" '(easy-hugo-sort-char :which-key "sort-char")
    "ha" '(easy-hugo-ag :which-key "ag-search")
    "hp" '(easy-hugo-preview :which-key "preview")
    "hP" '(easy-hugo-publish :which-key "publish")
    "hg" '(easy-hugo-github-deploy :which-key "github-deploy"))
  )
(after! org
  ;; insert-structure-template, keybinding "C-c C-,", like "<s tab"
  (require 'org-tempo)
  ;; toc-org
  (toc-org-mode t)
  (add-hook! 'org-mode-hook #'toc-org-mode)
  (define-key! org-mode-map "C-c C-i" #'toc-org-insert-toc)
  ;; org src block
  (define-key! org-mode-map "C-c c I" #'org-edit-src-code)
  ;; keybinding
  (ginshio/leader
    :keymaps 'org-mode-map
    "m" '(nil :which-key "meta-functions")
    "ml" '(org-metaright :which-key "metaright")
    "mh" '(org-metaleft :which-key "metaleft")
    "mk" '(org-metaup :which-key "metaup")
    "mj" '(org-metadown :which-key "metadown")
    "s" '(nil :which-key "shift-functions")
    "sl" '(org-shiftright :which-key "shiftright")
    "sh" '(org-shiftleft :which-key "shiftleft")
    "sk" '(org-shiftup :which-key "shiftup")
    "sj" '(org-shiftdown :which-key "shiftdown")
    "g" '(nil :which-key "shift-meta-functions")
    "gl" '(org-shiftmetaright :which-key "shiftmetaright")
    "gh" '(org-shiftmetaleft :which-key "shiftmetaleft")
    "gk" '(org-shiftmetaup :which-key "shiftmetaup")
    "gj" '(org-shiftmetadown :which-key "shiftmetadown"))
  )
;;;;; \LaTeX ;;;;;
(setq +latex-viewers '(okular))
;;;###autoload
(defun ginshio/latex-export-pdf ()
  (interactive)
  (call-process-shell-command
   (format "latexmk -pdf -f -bibtex -pdflatex=\"xelatex -shell-escape -8bit -synctex=1 -interaction=nonstopmode\" %s;\n
latexmk -c; rm -rf _minted-*/ .auctex-auto/ *.listing *.synctex.gz *.thm *.bbl *.run.xml"
           (buffer-file-name))
   nil nil))
;;;###autoload
(defun ginshio/latex-export-svg (filename svgname)
  (interactive
   (list (buffer-file-name)
         (read-file-name "Export svg name: "
                         (concat (file-name-sans-extension (buffer-file-name)) ".svg"))))
  (call-process-shell-command
   (format "xelatex -no-pdf -shell-escape -8bit -synctex=1 -interaction=nonstopmode %s;\n
dvisvgm --zoom=-1 --exact --font-format=woff -o %s %s;\n
latexmk -C; rm -rf *.xdv _minted-*/ .auctex-auto/ *.listing *.synctex.gz"
           filename svgname (concat (file-name-sans-extension filename) ".xdv"))
   nil nil))
;;;###autoload
(defun ginshio/latex-export-png (pngname)
  (interactive
   (list (read-file-name "Export png name: "
                         (concat (file-name-sans-extension (buffer-file-name)) ".png"))))
  (let ((svgname (concat (file-name-sans-extension (buffer-file-name)) ".svg")))
    (ginshio/latex-export-svg (buffer-file-name) svgname)
    (call-process-shell-command
     (format "convert -density 1024 %s %s;\nrm -rf %s" svgname pngname svgname)
     nil nil)))
(after! latex
  (custom-set-variables '(LaTeX-section-label '(("part" . "part:")
                                                ("chapter" . "chap:")
                                                ("section" . "sec:")
                                                ("subsection" . "subsec:")
                                                ("subsubsection" . "subsubsec:")))
                        '(TeX-auto-local "auto")
                        )
  (ginshio/leader
    :keymaps 'LaTeX-mode-map
    "e" '(nil :which-key "export")
    "ee" '(ginshio/latex-export-pdf :which-key "to-pdf")
    "es" '(ginshio/latex-export-svg :which-key "to-svg")
    "ep" '(ginshio/latex-export-png :which-key "to-png")
    )
  )
;;;;; Markdown ;;;;;
(after! markdown
  (toc-org-mode t)
  (add-hook! 'markdown-mode-hook #'toc-org-mode)
  (define-key! markdown-mode-map "C-c C-i" #'toc-org-insert-toc)
  )





;;;;;;;;;;;;;;;;;;;;;;;;; programming ;;;;;;;;;;;;;;;;;;;;;;;;;
;; TODO: parentheses <https://www.gtrun.org/post/init/#parentheses>
;;;;; CC ;;;;;
(setq! ginshio-c-style-list '(gnu
                              bsd
                              linux
                              google
                              llvm
                              ))
(defcustom ginshio-c-style 'google
  "GinShio C/C++ style"
  :type '(choice
          (const 'gnu)
          (const 'bsd)
          (const 'linux)
          (const 'google)
          (const 'llvm)
          )
  :group 'cc-mode)
(defun ginshio-hook-gnu-c-style ()
  )
(defun ginshio-hook-bsd-c-style ()
  (setq! tab-width 4)
  )
(defun ginshio-hook-google-c-style ()
  (setq-default tab-width 2
                fill-column 80
                indent-tabs-mode nil)
  (add-hook! 'c-mode-common-hook #'google-set-c-style)
  (add-hook! 'c-mode-common-hook #'google-make-newline-indent)
  )
(use-package! google-c-style
  :config
  (ginshio-hook-google-c-style)
  )





;;;;;;;;;;;;;;;;;;;;;;;;; ui ;;;;;;;;;;;;;;;;;;;;;;;;;
;; TODO: golden-ratio
(defun ginshio/init--farme()
  (when (display-graphic-p)
    (progn (menu-bar-mode t)
           (add-to-list 'initial-frame-alist '(fullscreen . maximized))
           ;; cursor
           (setq-default cursor-type 'box)
           (blink-cursor-mode -1)
           ;; set font
           (set-face-attribute 'default nil :font "Source Code Pro:pixelsize=15")
           (dolist (charset '(kana han symbol cjk-misc bopomofo))
             (set-fontset-font (frame-parameter nil 'font) charset
                               (font-spec :family "Source Han Sans HW SC" :size 18)))
           ;; random banner image from `~/.doom.d/banners'
           (setq! fancy-splash-image
                  (let ((banners (directory-files (concat doom-config-dir "/" "banners")
                                                  'full (rx ".png" eos))))
                    (elt banners (random (length banners)))))
           ;; random banner image from bing.com, NOTE: https://emacs-china.org/t/topic/264/33
           )))
(defun ginshio|init--farme(farme)
  (with-selected-frame farme
    (when (display-graphic-p) (ginshio/init--farme))))
(if (and (fboundp 'daemonp) (daemonp))
    (add-hook 'after-make-frame-functions #'ginshio|init--farme)
  (ginshio/init--farme))
;;;;; modeline ;;;;;
(after! doom-modeline
  (custom-set-variables '(doom-modeline-buffer-file-name-style 'relative-to-project)
                        '(doom-modeline-major-mode-icon t)
                        '(doom-modeline-modal-icon nil)
                        ))
(use-package! nyan-mode
  :config
  (setq nyan-animate-nyancat t
        nyan-cat-face-number 4
        nyan-bar-length 16
        nyan-minimum-window-width 64)
  (add-hook! 'doom-modeline-hook #'nyan-mode)
  (nyan-mode t)
  )
