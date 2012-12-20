(in-package :test6)

(defun login-successfull-p (email password)
  (let* ((user (first (find-by-value 'user 'email email)))
         (user-password-hash (if user (password-hash user)))
         (hash-of-submitted-password password))
    (when (and user-password-hash (string-equal user-password-hash hash-of-submitted-password)) 
      (setf (%current-user) user)
      (register-event "logged-in" :user (object->simple-plist user))
      user)))

(defun/cc show-login-form (&rest args)
  (do-page 
    (make-instance 'login 
                   :on-login (lambda (login-widget object) 
                               (if (login-successfull-p 
                                     (slot-value object 'email)
                                     (slot-value object 'password))
                                 (redirect (make-action-url "my-profile"))
                                 #+l(flash-message *main-page-flash* "You have successfully logged in !"))) 
                   :view 'login-form-view) ))

