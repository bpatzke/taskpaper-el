;;; taskpaper.el --- Taskpaper editing mode

;; Copyright (C) 2008 Kentaro Kuribayashi (original)
;; Copyright (c) 2010 Jonas Oberschweiber <jonas@oberschweiber.com> (updates)
;; Copyright (C) 2010 Ted Roden (updates)
;; Copyright (C) 2015 Bryan Patzke

;; Version: 20150708

;; Author: kentaro <kentarok@gmail.com>
;; Author: Jonas Oberschweiber <jonas@oberschweiber.com>
;; Author: Ted Roden <tedroden@gmail.com>
;; Author: Bryan Patzke <projects@2bpencil.com>

;; Keywords: tools, task

;; This file is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 2, or (at your option)
;; any later version.

;; This file is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs; see the file COPYING.  If not, write to
;; the Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
;; Boston, MA 02110-1301, USA.

;;; Commentary:

;; Installation
;;
;; After downloading this file, put it somewhere in your load-path.
;; Then put the code below into your .emacs.
;;
;;   (require 'taskpaper)
;;
;; Usage
;;
;; (1) Create a Taskpaper file
;;
;;   M-x find-file RET 2008-02-18.taskpaper
;;
;; (2) Create a new project
;;
;;   `C-c C-p' or just write as follows:
;;
;;   Project 1:
;;
;; (2) List tasks as follows:
;;
;;   `C-c C-t' or just write as follows:
;;
;;   Project 1:
;;
;;   - task 1
;;   - task 2
;;
;;   Project 2:
;;
;;   - task 3
;;   - task 4
;;
;; (3) Mark task as done
;;
;;   `C-c C-d' on the task you have done.
;;
;; (4) Misc:
;;
;;   `M-<up>'   Increase the priority of a task.
;;   `M-<down>' Decrease the priority of a task.
;;   `M-RET'    Create a new task from anywhere on the line.
;;   `C-M-T'    View a list of tasks tagged with "@today".
;;              in a new buffer `taskpaper-list-today`.

;;; Code:

(defgroup taskpaper nil
  "The group of customizable items for taskpaper mode."
  :group 'Text
  :version "24.5.1"
  :link "http://github.com/bpatzke/taskpaper-el")

;; Customizable variables
(defcustom taskpaper-priority-max 5
  "The maximum priority for an item."
  :group 'taskpaper
  :type 'integer
  :options '(taskpaper-priority-max 5))

(defcustom taskpaper-priority-min 1
  "The minimum priority for an item."
  :group 'taskpaper
  :type 'integer
  :options '(taskpaper-priority-min 1))

;; Hook
(defvar taskpaper-mode-hook nil
  "*Hooks for Taskpaper major mode.")

;; Keymap
(defvar taskpaper-mode-map (make-keymap)
  "*Keymap for Taskpaper major mode.")

(defvar taskpaper-indent-amount 4)

(define-key taskpaper-mode-map "\C-c\C-p"       'taskpaper-create-new-project)
(define-key taskpaper-mode-map "\C-c\C-d"       'taskpaper-toggle-task-done)
(define-key taskpaper-mode-map "\C-c\C-x\C-t"   'taskpaper-toggle-today)
(define-key taskpaper-mode-map "-"              'taskpaper-electric-mark)
(define-key taskpaper-mode-map (kbd "M-RET")    'taskpaper-newline-and-electric-mark)
(define-key taskpaper-mode-map (kbd "M-<up>")   'taskpaper-priority-increase)
(define-key taskpaper-mode-map (kbd "M-<down>") 'taskpaper-priority-decrease)
(define-key taskpaper-mode-map "\C-c\C-x\C-f"   'taskpaper-focus-on-current-project)

;; Face
(defface taskpaper-project-face
  '((((class color) (background light))
     (:foreground "gold1" :weight bold))
    (((class color) (background dark))
     (:foreground "gold1" :weight bold)))
  "Face definition for project name")

(defface taskpaper-task-face
  '((((class color) (background light))
     (:foreground "burlywood1"))
    (((class color) (background dark))
     (:foreground "burlywood1")))
  "Face definition for task")

(defface taskpaper-task-marked-as-done-face
  '((((class color) (background light))
     (:foreground "grey40" :weight light :strike-through t))
    (((class color) (background dark))
     (:foreground "grey40" :weight light :strike-through t)))
  "Face definition for task marked as done")

;; Make one face for all priorities. Then I won't have to worry about
;; face configuration for a variable number of things.
;;
;; (defface taskpaper-task-priority-3-face
;;   '((((class color) (background light))
;;      (:foreground "red1"))
;;     (((class color) (background dark))
;;      (:foreground "red1")))
;;   "Priority 3 Face")
;;
;; (defface taskpaper-task-priority-2-face
;;   '((((class color) (background light))
;;      (:foreground "OrangeRed1"))
;;     (((class color) (background dark))
;;      (:foreground "OrangeRed1")))
;;   "Priority 2 Face")
;;
;; (defface taskpaper-task-priority-1-face
;;   '((((class color) (background light))
;;      (:foreground "orange1"))
;;     (((class color) (background dark))
;;      (:foreground "orange1")))
;;   "Priority 1 Face")

(defface taskpaper-task-today-face
  '((((class color) (background light))
     (:foreground "LimeGreen"))
    (((class color) (background dark))
     (:foreground "LimeGreen")))
  "today's tasks Face")

(defvar taskpaper-project-face 'taskpaper-project-face)
(defvar taskpaper-task-face 'taskpaper-task-face)
(defvar taskpaper-task-marked-as-done-face 'taskpaper-task-marked-as-done-face)
(defvar taskpaper-task-today-face 'taskpaper-task-today-face)
;; (defvar taskpaper-task-priority-1-face 'taskpaper-task-priority-1-face)
;; (defvar taskpaper-task-priority-2-face 'taskpaper-task-priority-2-face)
;; (defvar taskpaper-task-priority-3-face 'taskpaper-task-priority-3-face)

(defvar taskpaper-font-lock-keywords
  '(
	("^.+:[ \t]*\\(?:[ \t]*@.+\\)*$" 0 taskpaper-project-face)
    ("^[ \t]*\\(?:-.*\\)$" 0 taskpaper-task-face)

	(".+@today.*" (0 taskpaper-task-today-face prepend))

	;; ("^.+@priority\(1\)$" (0 taskpaper-task-priority-1-face prepend))
	;; ("^.+@priority\(2\)$" (0 taskpaper-task-priority-2-face prepend))
	;; ("^.+@priority\(3\)$" (0 taskpaper-task-priority-3-face prepend))

	;; ;; Set the face for "@done" items.
	;; ;; This will need to be updated to allow for arbritrary colors
	;; ;; for arbitrary tags.
    ("^[ \t]*\\(.+@done.*\\)$" (1 taskpaper-task-marked-as-done-face prepend))))

;; Taskpaper major mode
(define-derived-mode taskpaper-mode fundamental-mode "Taskpaper"
  "Major mode for editing taskpaper documents."
  (kill-all-local-variables)
  (setq major-mode 'taskpaper-mode)
  (setq mode-name "Taskpaper")
  (use-local-map taskpaper-mode-map)
  (set (make-local-variable 'font-lock-defaults) '(taskpaper-font-lock-keywords))
  (set (make-local-variable 'font-lock-string-face) nil)
  (set (make-local-variable 'indent-line-function) 'taskpaper-indent-line)
  (run-hooks 'taskpaper-mode-hook))

;; start up when we see these files
(add-to-list 'auto-mode-alist (cons "\\.taskpaper$" 'taskpaper-mode))

;; Utility funcitons
(defun bp/trim-line ()
  (interactive)
  (save-excursion
	(beginning-of-line)
	(set-mark (point))
	(end-of-line)
	(delete-trailing-whitespace)))

;; Commands
(defun taskpaper-create-new-project (name)
  "Create new project called NAME."
  (interactive "sProject Name: ")
  (insert (concat name ":\n")))

;; Make sure this moves to the next line, and adjusts indentation to match the
;; any existing indentation.
(defun taskpaper-create-new-task (task)
  "Create new TASK."
  (interactive "sNew Task: ")
  (insert (concat "- " task)))

(defun taskpaper-toggle-task-done ()
  "Mark task as done."
  (interactive)
  (save-excursion
    (beginning-of-line)
	(if (looking-at ".*\\( ?@done\\(?:([[:digit:]]\\{4\\}-[[:digit:]]\\{2\\}-[[:digit:]]\\{2\\})\\)*\\)")
		;; Delete the @done tag (with optional date stamp).
		(delete-region (match-beginning 1) (match-end 1))
	  (bp/trim-line)
	  (end-of-line)
	  (insert
	   (concat " @done("
			   (format-time-string "%Y-%m-%d)"))))))

(defun taskpaper-toggle-today ()
  "Tag current item with @today."
  (interactive)
  (save-excursion
	;; get to the start of the line
	(beginning-of-line)
	;; already tagged?
	(if (looking-at ".*\\( ?@today\\).*")
		;; delete the @today tag
		(delete-region (match-beginning 1) (match-end 1))
	  (bp/trim-line)
	  (end-of-line)
	  (insert " @today"))))

(defun taskpaper-indent-line ()
  "Detect if list mark is needed when indented." ;; ???
  (interactive)
  (let ((mark-flag nil)
        (in-project nil)
        (old-tabs indent-tabs-mode))
    ;; TaskPaper won't recognize the indents otherwise.
    (setq indent-tabs-mode t)
    (save-excursion
      (while (and (not in-project) (not (bobp)))
        (forward-line -1)
        (when (looking-at "^.+:[ \t]*$") (setq in-project t))
        (when (looking-at "-") (setq mark-flag t))))
    (when mark-flag (insert "- "))
    (when in-project (indent-line-to taskpaper-indent-amount))
    (setq indent-tabs-mode old-tabs)))

;; I think taskpaper only recognizes one list marker. I'll have to check that.
(defun taskpaper-electric-mark (arg)
  "Insert a list mark using ARG.  I'm not really sure how yet."
  (interactive "*p")
  (if (zerop (current-column))
      (progn
        (taskpaper-indent-line)
        (self-insert-command arg)
        (insert " "))
    (self-insert-command arg)))

(defun taskpaper-newline-and-electric-mark ()
  "Create a new task on the next line."
  (interactive)
  (progn
	(end-of-line)
	(insert "\n")
	(taskpaper-indent-line)
	(insert "- ")))

;; (defun taskpaper-focus-on-today ()
;;   "List all tasks tagged with @today in a new (read-only) buffer."
;;   (interactive)
;;   (taskpaper-focus-on-tag "@today"))
;;
;; (defun taskpaper-focus-on-tag (tag)
;;   "List all tasks tagged with TAG in a new (read-only) buffer."
;;   (interactive)
;;   (message (format "Focusing on %s" tag))
;;
;;   (setq taskpaper-list-today (format "* Taskpaper Focus: %s *" tag))
;;  
;;   (save-excursion
;; 	;; go to the beginning of the buffer
;; 	(goto-char 0)
;;
;; 	;; FIXME: probably a rough way to get a blank buffer
;; 	;; if we already have this buffer, kill it and try again
;; 	(if (get-buffer taskpaper-list-today)
;; 		(kill-buffer taskpaper-list-today))
;; 	(get-buffer-create taskpaper-list-today)
;;	
;; 	;; set up some basic variables
;; 	(setq current-project "")
;; 	(setq current-project-has-tasks nil)
;; 	(setq this-buffer (current-buffer))
;;
;; 	;; probably not the best way to loop through the contents of a buffer...
;; 	(setq moving t)
;;
;; 	(setq tag-regexp (format "^.*%s.*" tag))
;;
;; 	(while moving
;;
;; 	  (when (looking-at "^\\(.+\\):[ \t]+*$")
;; 		(setq current-project (buffer-substring-no-properties (match-beginning 1) (match-end 1)))
;; 		(setq current-project-has-tasks nil))
;;	  
;; 	  (when (looking-at tag-regexp)
;; 		;; set the current task
;; 		(setq current-task (thing-at-point 'line))
;;
;; 		;; write the task/project into the new buffer
;; 		(set-buffer taskpaper-list-today)
;;
;; 		;; if it's the first task for this project... add the project name
;; 		(when (not current-project-has-tasks)
;; 		  (setq current-project-has-tasks t)
;; 		  (insert (format "\n%s:\n" current-project)))
;;
;; 		;; inser the final task
;; 		(insert current-task))
;;
;; 	  ;; ensure that we go forward in the proper buffer
;; 	  (set-buffer this-buffer)
;; 	  (when (< 0 (forward-line))
;; 		(setq moving nil)))
;;
;; 	;; switch to the new buffer
;; 	(switch-to-buffer taskpaper-list-today)
;; 	;; mark it as read only... we don't save from here
;; 	(setq buffer-read-only t)
;; 	;; use this mode
;; 	(taskpaper-mode)))
;;
;;
;; (defun taskpaper-focus-on-current-project ()
;;   "Limit the view to only the current project."
;;   (interactive)
;;
;;   (save-excursion
;;
;; 	(setq this-buffer (current-buffer))
;;
;; 	(setq current-project nil)
;; 	(setq moving t)
;;
;; 	;; crawl back to project line
;; 	(while moving
;;	  
;; 	  (when (looking-at "^\\(.+\\):[ \t]+*$")
;; 		(setq current-project
;; 			  (buffer-substring-no-properties (match-beginning 1) (match-end 1)))
;; 		(message (format "Found project %s" current-project))
;; 		(setq moving nil))
;;
;; 	  ;; if we should still be moving
;; 	  (when moving
;; 		;; go back one line
;; 		(when (< 0 (forward-line -1))
;; 		  (setq moving nil))))
;;
;;
;; 	;; if we have a current project...
;; 	(when current-project
;;
;; 	  ;; setup the new buffer
;; 	  (message (format "Focusing on %s" current-project))
;; 	  (setq taskpaper-focus-buffer
;; 			(format "* Taskpaper Project Focus: %s *" current-project))
;;	  
;; 	  (if (get-buffer taskpaper-focus-buffer)
;; 		  (kill-buffer taskpaper-focus-buffer))
;; 	  (get-buffer-create taskpaper-focus-buffer)
;;
;; 	  (forward-line) ;; move one step (we're on the project line aleady)
;; 	  (set-buffer taskpaper-focus-buffer)
;; 	  (insert (format "%s:\n" current-project))
;; 	  (set-buffer this-buffer)
;; 	  ;; loop through the thing
;;
;; 	  (setq moving t)
;;
;; 	  (while moving
;;		
;; 		;; unless we're looking at another project, add it to the buffer
;; 		(if (looking-at "^\\(.+\\):[ \t]+*$")
;; 			(setq moving nil)
;; 		  (setq line (thing-at-point 'line))
;; 		  (set-buffer taskpaper-focus-buffer)
;; 		  (insert line))
;;		
;; 		;; keep going?
;; 		(set-buffer this-buffer)
;; 		(when moving
;; 		  (when (< 0 (forward-line))
;; 			(setq moving nil))))
;;
;; 	  ;; switch to the new buffer
;; 	  (switch-to-buffer taskpaper-focus-buffer)
;; 	  ;; mark it as read only... we don't save from here
;; 	  (setq buffer-read-only t)
;; 	  (goto-char 0)
;; 	  (forward-line)
;; 	  ;; use this mode
;; 	  (taskpaper-mode))))

(defun taskpaper-priority-increase ()
  "Increase the priority by one."
  (interactive)
  (taskpaper-priority-adjust 1))

(defun taskpaper-priority-decrease ()
  "Increase the priority by one."
  (interactive)
  (taskpaper-priority-adjust -1))

(defun taskpaper-priority-adjust (number)
  "Adjust the priority by NUMBER.
At the moment, this is only called by the increase/decrease functions.
However, I might add the ability to set the priority of an item at
 creation time."
  (interactive)
  (save-excursion
	(progn
	  ;; Go to the start of the line.
	  (beginning-of-line)

	  ;; Is there a priority already defined?
	  (if (looking-at ".*\\( ?@priority(\\([0-9]\\))\\).*")

		  ;; Make this a "let*" so we can set new-priority without warnings.
		  (let ((current-priority (string-to-number
								   (buffer-substring-no-properties
									(match-beginning 2)
									(match-end 2)))))
			;; Change this to be part of the "let*"
			(setq new-priority (+ number current-priority))

			(cond ((and (>= new-priority taskpaper-priority-min)
						(<= new-priority taskpaper-priority-max))
				   (progn
					 (delete-region (match-beginning 2) (match-end 2))
					 (goto-char (match-beginning 2))
					 (insert (number-to-string new-priority))))
				  ((< new-priority taskpaper-priority-min)
				   (delete-region (match-beginning 1) (match-end 1)))))
		(if (< number 0)
			(message "No priority to decrease")

		  ;; create a default priority
		  (bp/trim-line)
		  (end-of-line)
		  (insert " @priority(1)"))))))
		  
(provide 'taskpaper)
;;; taskpaper.el ends here
