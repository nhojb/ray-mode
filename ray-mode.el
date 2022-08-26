;;; ray-mode.el --- Develop Raycast Extensions -*- lexical-binding: t; -*-

;; Copyright (c) 2022 John Buckley <nhoj.buckley@gmail.com>

;; Author: John Buckley <nhoj.buckley@gmail.com>
;; URL: https://github.com/nhojb/ray-mode
;; Version: 1.0
;; Keywords: convenience, languages, tools
;; Package-Requires: ((emacs "26.1"))

;; This file is not part of GNU Emacs.

;; MIT License

;; Permission is hereby granted, free of charge, to any person obtaining
;; a copy of this software and associated documentation files (the
;; "Software"), to deal in the Software without restriction, including
;; without limitation the rights to use, copy, modify, merge, publish,
;; distribute, sublicense, and/or sell copies of the Software, and to
;; permit persons to whom the Software is furnished to do so, subject to
;; the following conditions:

;; The above copyright notice and this permission notice shall be
;; included in all copies or substantial portions of the Software.

;; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
;; EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
;; MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
;; NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
;; BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
;; ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
;; CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
;; SOFTWARE.

;;; Commentary:

;; A minor mode for developers building Raycast extensions.
;;
;; Features:
;;
;; Develop, lint, build and publish your Raycast extensions from Emacs.
;;
;; Installation:
;;
;; In your `init.el`
;;
;; (require 'ray-mode)
;;
;; or with `use-package`:
;;
;; (use-package ray-mode)
;;

;;; Code:

(require 'compile)

(defgroup ray-mode nil
  "A minor mode for building, running & validating Raycast extensions."
  :group 'emacs)

(defcustom ray-mode-emoji t
  "If non-nil enable emoji in ray output."
  :type 'boolean
  :group 'ray-mode)

(defcustom ray-mode-target nil
  "If non-nil use the specific ray target."
  :type 'string
  :group 'ray-mode)

(defvar ray-mode-map
  (make-sparse-keymap)
  "Keymap for `ray-mode`.")

(define-key ray-mode-map
  (kbd "C-c yd") 'ray-mode-develop)

(define-key ray-mode-map
  (kbd "C-c yl") 'ray-mode-lint)

(define-key ray-mode-map
  (kbd "C-c yf") 'ray-mode-fix-lint)

(define-key ray-mode-map
  (kbd "C-c yp") 'ray-mode-publish)

(define-key ray-mode-map
  (kbd "C-c ys") 'ray-mode-stop)

;; TD: Check if compilation is running 😱
;; Use a custom buffer name?

(defun ray-mode-build()
  "Run `npm run build`."
  (interactive)
  (ray-mode--compile "build"))

(defun ray-mode-develop()
  "Run `npm run dev`."
  (interactive)
  (ray-mode--compile "dev" ray-mode-target))

(defun ray-mode-lint()
  "Run `npm run lint`."
  (interactive)
  (ray-mode--compile "lint"))

(defun ray-mode-fix-lint()
  "Run `npm run fix-lint`."
  (interactive)
  (ray-mode--compile "fix-lint"))

(defun ray-mode-publish()
  "Run `npm run publish`."
  (interactive)
  (ray-mode--compile "publish"))

(defun ray-mode-stop()
  "Stop development."
  (interactive)
  (kill-compilation))

(defun ray-mode--extension-directory()
  "Get the current extension's root directory."
  (or (locate-dominating-file default-directory "package.json")
      default-directory))

(defun ray-mode--compile (command &optional target)
  "Run COMMAND for the current extension and TARGET."
  (let ((default-directory (ray-mode--extension-directory))
        (ray-command (cond
                      ((and ray-mode-emoji target)
                       (format "npm run %s -- --emoji --target %s" command target))
                      (ray-mode-emoji
                       (format "npm run %s -- --emoji" command))
                      (target
                       (format "npm run %s -- --target %s" command target))
                      (t (format "npm run %s" command)))))
    (compile ray-command)))

;;;###autoload
(define-minor-mode ray-mode
  "Minor mode for building Raycast extensions."
  :lighter " ray"
  :keymap ray-mode-map)

(provide 'ray-mode)

;;; ray-mode.el ends here

