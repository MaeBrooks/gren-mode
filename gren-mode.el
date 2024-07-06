;;; gren-mode.el --- a simple package                     -*- lexical-binding: t; -*-

;; Copyright (C) 2014  Mae Brooks

;; Author: Mae Brooks <home_in_the_rain+developer@proton.me>
;; Keywords: lisp
;; Version: 0.0.1

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; A Simple Gren highlighting and formatting package

;;; Code:

;; FONT SETUP
(defvar gren-font-keywords nil "gren keywords")
(setq gren-font-keywords '("import" "module" "exposing" "as" "if" "then" "else" "type" "alias"))

(defvar gren-font-types nil "gren basic types")
(setq gren-font-types '("number" "Float" "Int" "Char" "String" "Bool"))

(defvar gren-font-constants nil "gren constants")
(setq gren-font-constants '("True" "False"))

(defvar gren-font-operators nil "gren operators")
(setq gren-font-operators '("<" ">" ":" "=" "|" "[" "]" "{" "}" "," "|>" "<|" "->" "++"))

(defvar gren-fontlock nil "list for font-lock-defaults")
(setq gren-fontlock
  (let (-types -consts -ops -kws -comments -char -digits)
    (setq -types    (regexp-opt gren-font-types     'words))
    (setq -consts   (regexp-opt gren-font-constants 'words))
    (setq -ops      (regexp-opt gren-font-operators nil   ))
    (setq -kws      (regexp-opt gren-font-keywords  'words))
    (setq -comments "\\-\\-.+")
    (setq -char     "'.\\{1,2\\}'")
    (setq -digits   "[0-9]+\\(\\.[0-9]*\\)")
    
    (list
      (cons -types     'font-lock-type-face)
      (cons -consts    'font-lock-builtin-face)
      (cons -digits    'font-lock-constant-face)
      (cons -ops       'font-lock-constant-face)
      (cons -char      'font-lock-string-face)
      (cons -kws       'font-lock-keyword-face)
      (cons -comments  'font-lock-comment-face)
      )
    ))

(define-derived-mode gren-mode fundamental-mode "gren"
  "Major mode for the gren programming language"
  (defun gren-format ()
    "Format gren with 'gren format <buffer-file-name>'"
    (interactive)
    (unless (not buffer-file-name)
      (save-buffer)
      ; 
      (shell-command (format "gren format %s" buffer-file-name) "*Shell Command Output*" "*Shell Command Output*")
      (revert-buffer :ignore-auto :noconfirm)
      ))
  
  (setq font-lock-defaults '((gren-fontlock)))
  )

(add-to-list 'auto-mode-alist '("\\.gren\\'" . gren-mode))
(provide 'gren-mode)

;;; gren-mode.el ends here
