(in-package :test6)

(defwidget register-by-email-widget(dataform)
  ((email :initarg :email)))

(defmethod dataform-on-cancel ((obj register-by-email-widget))
  (lambda (&rest args)
    (register-event "cancel-registration")
    (answer obj)))

(defmethod dataform-on-success ((obj register-by-email-widget))
  (lambda (&rest args) 
    (generate-and-send-password-to-user (dataform-data obj))))

(defun generate-and-send-password-to-user (user)
  (let* ((password (random-password (get-universal-time)))
         (email (email user)))

    (setf (password-hash user) (md5-hex password))
    (setf (gravatar-connectedp user) (has-gravatar-p (email user)))

    (send-registration-email email password)
    (persist-object *default-store* user)))

(defun send-registration-email (email password)
  (send-email 
    (format nil "You have successfully registered. Please use your email (~A) and password \"~a\" for login." 
            email password) email))

(defmethod render-dataform-data-buttons ((obj register-by-email-widget) data)
  (declare (ignore data))
  (with-html
    (:div :class "submit"
     (render-link 
       (f_% (answer obj))
       "Return to last page viewed")
     (when (and (dataform-allow-close-p obj)
                (dataform-on-close obj))
       (str "&nbsp;")
       (render-link (make-action
                      (f_% (funcall (dataform-on-close obj) obj)))
                    "Close"
                    :class "close")))))
