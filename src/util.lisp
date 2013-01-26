(in-package :test6)

(defun register-event (&rest args)
  (declare (ignore args)))

(defun prevalence-poweredp ()
  (eq (class-name  (class-of *default-store*)) 'cl-prevalence:guarded-prevalence-system))

(defun find-by-value (class value-name value-value &key (test #'equal) order-by range countp)
  (let ((default-store-is-prevalence-powered-p (prevalence-poweredp)))
    (if default-store-is-prevalence-powered-p 
      (let ((data (find-persistent-objects *default-store* class :slot value-name :value value-value :test test :order-by order-by :range range)))
        (if countp 
          (length data)
          data)) 
      (find-by class (lambda (item) 
                       (and (slot-boundp item value-name) (funcall test (slot-value value-name item) value-value)))))))

(defun random-password (&rest tokens)
  (string-downcase  (subseq  (md5-hex (format nil "~{~A~^ ~}" tokens)) 0 (+ 7 (random 5)))))

; Stolen from hunchentoot
(defun md5-hex (string)
  "Calculates the md5 sum of the string STRING and returns it as a hex string."
  (string-downcase  
    (with-output-to-string (s)
      (loop for code across (md5:md5sum-sequence (coerce string 'simple-string))
            do (format s "~2,'0x" code)))))

(defun has-gravatar-p(email)
  (not (string= "\"User not found\"" 
                (flexi-streams:octets-to-string 
                  (drakma:http-request (format nil "http://gravatar.com/~A.json" (md5-hex email)))
                  :external-format :utf-8))))


(defun send-email-copy (host from to subject message 
                        &key ssl (port (if (eq :tls ssl) 465 25)) cc bcc reply-to extra-headers
                        html-message display-name authentication
                        attachments (buffer-size 256) (external-format :utf-8))
  (cl-smtp::send-smtp host from (cl-smtp::check-arg to "to") subject (cl-smtp::mask-dot message)
             :port port :cc (cl-smtp::check-arg cc "cc") :bcc (cl-smtp::check-arg bcc "bcc")
             :reply-to reply-to 
             :extra-headers extra-headers
             :html-message html-message
             :display-name display-name
             :authentication authentication
             :attachments (cl-smtp::check-arg attachments "attachments")
             :buffer-size (if (numberp buffer-size) 
                            buffer-size
                            256)
             :external-format external-format
             :ssl ssl))

(defun send-email (text &rest recipients)
  "Generic send SMTP mail with some TEXT to RECIEPIENTS"
  (send-email-copy +smtp-server+ +email-from+ recipients "" text :authentication +email-authentication-data+ :ssl :tls))

(defun object->simple-plist (object &rest filters)
  (loop for i in (sb-mop:class-direct-slots (find-class (class-name  (class-of object)))) append 
        (let* ((slot (sb-mop:slot-definition-name i))
               (value (if (slot-boundp object (sb-mop:slot-definition-name i))
                        (slot-value object (sb-mop:slot-definition-name i))
                        "Unbound")))
          (list slot (if (getf filters slot) (funcall (getf filters slot) value) value)))))

(defmacro require-login (message &body body)
  `(if 
     (authenticatedp)
     (progn
       ,@body)
     (error "not authenticated")))

(defun gravatar-url(email)
  (format nil "http://www.gravatar.com/avatar/~A" (md5-hex email)))

(defmacro with-yaclml (&body body)
  "A wrapper around cl-yaclml with-yaclml-stream macro."
  `(yaclml:with-yaclml-stream *weblocks-output-stream*
                              ,@body))
(defun render-inline-link (action label &key (ajaxp t) id class title render-fn)
  "Renders an action into a href link. If AJAXP is true (the
                                                          default), the link will be rendered in such a way that the action will
  be invoked via AJAX or will fall back to a regular request if
  JavaScript is not available. When the user clicks on the link the
  action will be called on the server.

  ACTION may be a function or a result of a call to MAKE-ACTION.
  ID, CLASS and TITLE represent their HTML counterparts.
  RENDER-FN is an optional function of one argument that is reponsible
  for rendering the link's content (i.e. its label). The default rendering
  function just calls PRINC-TO-STRING on the label and renders it
  without escaping."
  (let* ((action-code (function-or-action->action action))
         (url (make-action-url action-code))
         (return (yaclml:with-yaclml-output-to-string 
                   (<:a :id id :class class
                        :href url :onclick (when ajaxp
                                             (format nil "initiateAction(\"~A\", \"~A\"); return false;"
                                                     action-code (session-name-string-pair)))
                        :title title
                        (funcall (or render-fn (lambda (label)
                                                 (<:as-html (<:as-is (princ-to-string label)))))
                                 label)))))
    (log-link label action-code :id id :class class)
    return))

(defun dbg (&rest args)
  (error (format nil "~{~A~%~}" args)))

(defun destroy (obj)
  (delete-persistent-object *default-store* obj))

(defun destroy-all (cls)
  (mapcar #'destroy (all-of cls))) 

(defmacro with-yaclml (&body body)
  "A wrapper around cl-yaclml with-yaclml-stream macro."
  `(yaclml:with-yaclml-stream *weblocks-output-stream*
     ,@body))

(defmacro capture-weblocks-output (&body body)
  `(let ((*weblocks-output-stream* (make-string-output-stream)))
     ,@body 
     (get-output-stream-string *weblocks-output-stream*)))

(ps:defpsmacro eval-json (json)
  `(eval (ps:LISP (concatenate 'string "(" ,json ")"))))

(defun time-created-writer (value item)
  (with-slots (time-created) item
    (unless time-created
      (setf time-created (get-universal-time)))))


(defmethod render-view-field ((field table-view-field)
                              (view table-view)
                              widget
                              (presentation hidden-presentation)
                              value obj &rest args)
  (declare (ignore field view widget presentation value obj args)))

(defmethod render-view-field-header :around ((field table-view-field) 
                                             (view table-view) 
                                             widget 
                                             (presentation hidden-presentation) value obj &rest args))

(defmethod render-view-field-header :around ((field table-view-field) 
                                             (view table-view) 
                                             (widget datagrid) 
                                             (presentation hidden-presentation) value obj &rest args))

(defun load-in-current-package (p)
  (load (path-in-current-package p)))

(defun path-in-package (package p)
  (format 
    nil 
    "~A~A"
    (weblocks:asdf-system-directory package)
    p))

(defun path-in-current-package (p)
  (path-in-package (intern (package-name *package*) "KEYWORD") p))

(defun make-url (url)
  (format nil "~A~A" (webapp-prefix) url))

(load-in-current-package "src/hunchentoot-tilde-replace-filter.lisp")
