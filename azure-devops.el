;;; json-pointer.el --- JSON pointer implementation in Emacs Lisp

;; Copyright (C) 2019 by Tatu Lahtela

;; Author: Tatu Lahtela <lahtela@iki.fi>
;; URL: https://github.com/ration/azure-devops.el
;; Version: 0.01

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

;; Azure devops operations in Emacs

;;; Code:

(setq azure-devops-work-items-query "")
(setq azure-devops-wiq-url "")
(setq azure-devops-access-token "")
(setq azure-devops-user "")
(setq azure-devops-work-items-query-id "")

(require 'json)
(load-file "./json-pointer.el")

(defun azure-devops-rest-get (url username password)
  (let ((url-request-method "GET")
        (url-request-extra-headers `(("Authorization" . ,(concat "Basic " (base64-encode-string (concat username ":" password) 1))))))
    (with-current-buffer (url-retrieve-synchronously url)
      (setf (point) url-http-end-of-headers)
      (json-read))))

(defun azure-devops-get-open-ticket(id)
  "Get ticket information with given iD"
  (let ((json (azure-devops-rest-get (concat azure-devops-work-items-query id) azure-devops-user azure-devops-access-token)))
    json))
	    
(defun azure-devops-query-work-items (id)
  (let ((json (azure-devops-rest-get (concat azure-devops-wiq-url id) azure-devops-user azure-devops-access-token)))
    (let ((ids (mapcar 'cdr (mapcar 'car (cdr (assoc 'workItems json))))))
      (mapcar (lambda (x) (azure-devops-get-open-ticket (number-to-string x))) ids)
  )))

(defun org-generate-azure-devops-tickets ()
  "Generate org task items for current tickts in devops"
  (interactive)
  (dolist (json (azure-devops-query-work-items azure-devops-work-items-query-id))
    (insert (format "* TODO %s\n\n%s\n\n" (json-pointer-get json "/fields/System\.Title") (json-pointer-get json "/_links/html/href")))))

(provide 'org-generate-azure-devops-tickets)



