;;;(require 'sgml)

(defvar html-doctype-decl
  "<!DOCTYPE HTML PUBLIC \"-//connolly hal.com//DTD WWW HTML 1.9//EN\">")

(defvar html-body-element
  '(H1 H2 H3 H4 H5 H6 DL UL OL ADDRESS BLOCKQUOTE PRE XMP LISTING))

(defun html-update ()
  (interactive)
  (html-maybe-add-doctype)
  (html-infer-p-tags)
  )

(defun html-maybe-add-doctype ()
  (goto-char (point-min))
  (cond ((looking-at "<!DOCTYPE") ;; nothing
	 )
	((looking-at "<!SGML") ;; nothing
	 )
	(t (insert html-doctype-decl)
	   (insert "\n"))
	)
  )

(defun html-infer-p-tags ()
  (goto-char (point-min))
  (while (re-search-forward (concat sgml-etago-gi sgml-tagc sgml-s) nil t)
    (let ((gi (sgml-make-name (match-beginning 1) (match-end 1)))
	  )
      (if (and (or (eq gi 'TITLE) (member gi html-body-element))
	       ;; @@ comment will screw this up, resulting in extra <P>'s,
	       ;; for example, an extra <P> will be inserted before the
	       ;; coment in the following:
	       ;; <h1>header</h1>
	       ;; <!-- comment hides <P> tag from this thing -->
	       ;; <p>
	       ;;
	       (not (or (looking-at sgml-stago-gi)
			(looking-at sgml-etago-gi)))
	       )
	  (insert "<P>")
	)
      )
    )
  )
