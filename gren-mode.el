;;; gren-mode.el --- a simple package                     -*- lexical-binding: t; -*-

;; Copyright (C) 2024  Mae Brooks

;; Author: Mae Brooks <home_in_the_rain+developer@proton.me>
;; Keywords: lisp
;; Version: 0.0.2

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

(require 'prog-mode)
(require 'treesit)

(defcustom gren-tree-sitter-grammar-url "https://github.com/MaeBrooks/tree-sitter-gren"
  "The url to use to install the gren tree-sitter grammar the default is: https://github.com/MaeBrooks/tree-sitter-gren")
(defcustom gren-tree-sitter-grammar-revision "when_is"
  "The revision - the git tag or branch")

(defun gren-format ()
  "Format gren with 'gren format <buffer-file-name>'"
  (interactive)
  (unless (not buffer-file-name)
    (save-buffer)
                                        ; 
    (shell-command (format "gren format %s" buffer-file-name) "*Shell Command Output*" "*Shell Command Output*")
    (revert-buffer :ignore-auto :noconfirm)))

(defun gren-mode-setup ())
(defun gren-ts-mode-prepare ()
  ;; Ensure that gren tree sitter is in the install list
  (defun ensure-gren-ts-grammar-is-installable ()
    (setq-local default-gren-language-source
                `(gren
                  ,gren-tree-sitter-grammar-url
                  ,gren-tree-sitter-grammar-revision))

    (if (not (boundp 'treesit-language-source-alist))
        (setq treesit-language-source-alist (list default-gren-language-source))
      (if (not (assoc 'gren treesit-language-source-alist))
          (add-to-list treesit-language-source-alist default-gren-language-source)))))

(defun gren-ts-mode-setup ()
  (defun setup-font-lock ()
    ;; What Decoration Levels are activated
    ;; (setq treesit-font-lock-level)
    ;; treesit-font-lock-level is set by the user / defaults to 3 - value of 1 - 4 1 being low highlighting 4 being higher (in general)
    ;; Decoration Levels / Precidence
    (setq treesit-font-lock-feature-list
          '((comment string keyword property number)
            (type function bracket variable)
            (control operator punctuation builtin)))

    ;; Map 
    (setq treesit-font-lock-settings
          (treesit-font-lock-rules
           :language 'gren
           :feature 'builtin
           :override 't
           ;; builtin-face constant-face
           '((module_declaration (upper_case_qid (upper_case_identifier))) @font-lock-builtin-face
             (import_clause (upper_case_qid (upper_case_identifier)))      @font-lock-builtin-face
             (value_qid (upper_case_identifier))                           @font-lock-builtin-face
             (value_qid
              (upper_case_identifier)
              (dot)
              (lower_case_identifier))
             @font-lock-builtin-face)
          
           :language 'gren
           :feature 'function
           :override 'keep
           '((type_annotation) @font-lock-function-name-face)

           :language 'gren
           :feature 'variable
           :override t
           '((lower_case_identifier) @font-lock-variable-name-face)

           :language 'gren
           :feature 'property
           :override t
           '((field) @font-lock-property-name-face)
           
           :language 'gren
           :feature 'type
           :override t
           '((type_ref (upper_case_qid (upper_case_identifier))) @font-lock-type-face
             (exposed_type (upper_case_identifier)) @font-lock-type-face
             (double_dot) @font-lock-type-face
             (type_declaration (upper_case_identifier)) @font-lock-type-face
             (union_variant (upper_case_identifier)) @font-lock-type-face
             (union_pattern (upper_case_qid (upper_case_identifier))) @font-lock-type-face
             (value_expr name: (upper_case_qid (upper_case_identifier)) @font-lock-type-face))
          
           
           :language 'gren
           :feature 'function
           :override t
           '(
             ;; exposing (<value>)
             (exposed_value (lower_case_identifier))             @font-lock-function-name-face
             ;; <main> =
             (function_declaration_left (lower_case_identifier)) @font-lock-function-name-face
             ;; (function_declaration_left (lower_case_identifier)) @font-lock-function-name-face
             ;; ((dot .) (lower_case_identifier)) @font-lock-function-name-face
             ;;   (value_expr (value_qid (lower_case_identifier))) @font-lock-function-name-face
             )

           :language 'gren
           :feature 'variable
           :override t
           '((lower_pattern (lower_case_identifier)) @font-lock-variable-name-face
             ;; Foo <lower case>
             (type_variable (lower_case_identifier)) @font-lock-variable-name-face
             (lower_type_name (lower_case_identifier)) @font-lock-variable-name-face
             )

           :language 'gren
           :feature 'number
           :override t
           '((number_literal) @font-lock-number-face)

           :language 'gren
           :feature 'string
           :override t
           '((string_constant_expr) @font-lock-string-face)

           :language 'gren
           :feature 'keyword
           :override t
           '((type)     @font-lock-keyword-face
             (port)     @font-lock-keyword-face
             (module)   @font-lock-keyword-face
             (import)   @font-lock-keyword-face
             (exposing) @font-lock-keyword-face
             (is)       @font-lock-keyword-face
             (when)     @font-lock-keyword-face
             (alias)    @font-lock-keyword-face
             (infix)    @font-lock-keyword-face
             "if"       @font-lock-keyword-face
             "else"     @font-lock-keyword-face
             "let"      @font-lock-keyword-face
             "in"       @font-lock-keyword-face)

           :language 'gren
           :feature 'operator
           :override t
           '((operator_identifier) @font-lock-operator-face
             (eq)                  @font-lock-operator-face
             (arrow)               @font-lock-operator-face
             (colon)               @font-lock-operator-face
             "|"                   @font-lock-operator-face)

           :language 'gren
           :feature 'bracket 
           :override t
           '("{" @font-lock-bracket-face
             "}" @font-lock-bracket-face
             "[" @font-lock-bracket-face
             "]" @font-lock-bracket-face
             "(" @font-lock-bracket-face
             ")" @font-lock-bracket-face)
           
           :language 'gren
           :feature 'punctuation
           :override t
           '("," @font-lock-punctuation-face
             "." @font-lock-punctuation-face)
           
           :language 'gren
           :feature 'comment
           :override t
           '((line_comment) @font-lock-comment-face)
           )))

  (defun setup-indentation ()
    (setq treesit-simple-indent-rules
          `((gren
             ;; Function Calls
             ((node-is "function_call_expr") parent 4)
             ((parent-is "function_call_expr") parent 2)
             ;; Records
             ((node-is "record_expr") parent 4)
             ((parent-is "record_expr") parent 0)
             ;; Type definition (type X)
             ((parent-is "type_expression") parent 4)
             ((node-is "union_variant") parent 4)
             ;; Function type def (foo : string)
             ((parent-is "type_declaration") parent 4)
             ;; Function Definition
             ((parent-is "value_declaration") parent 4)
             ((parent-is "function_declaration_left") parent 4)
             ;; When ... is
             ((parent-is "when_is_expr") parent 4)
             ((parent-is "when_is_branch") parent 4)
             ((praent-is "pattern") parent 4)
             ;; (
             ((parent-is "parenthesized_expr") parent 0)
             ((parent-is "list_expr") parent 0)
             ;; let ... in
             ((node-is "value_declaration") parent 4)
             ((parent-is "let_in_expr") parent 0)
             
             ((node-is "comment") parent 0)
             
             ;; ((node-is "field") parent 0)
             ;; Default
             ;; ((no-node) parent 0)
             ))))

  (setup-font-lock)
  (setup-indentation))

(define-derived-mode gren-ts-mode prog-mode "gren[ts]"
  "Major mode for the gren programming language"
  (when (treesit-ready-p 'gren)
    (gren-mode-setup)
    (gren-ts-mode-prepare)
    (gren-ts-mode-setup)

    ;; Finally Set this up as a major tree sitter mode
    (treesit-parser-create 'gren)
    (treesit-major-mode-setup)))

(add-to-list 'auto-mode-alist '("\\.gren\\'" . gren-ts-mode))
(provide 'gren-ts-mode)

;;; gren-mode.el ends here
