(in-package :test6)

(defvar *debug-auto-login* nil)
(defparameter *logout-action* "logout")

(defmacro %current-user ()
  `(webapp-session-value 'current-user))

(defun current-user ()
  (or (%current-user) 
      (and *debug-auto-login*  
           (prog1  
             (setf (%current-user) (first  (find-persistent-objects *default-store* 'user)))
             (setf (webapp-session-value *authentication-key*) (values (%current-user) t))))))

(defun authenticatedp ()
  (if *debug-auto-login*
    (current-user)
    (multiple-value-bind (auth-info success)
      (webapp-session-value *authentication-key*)
      (when success auth-info))))

(defun/cc logout-action (&rest args)
  (register-event "logged-out" :user (object->simple-plist (current-user)))
  (mark-dirty (root-widget))
  (logout)
  (redirect (make-action-url "main")))

(defun main-action (&rest args)
  (do-page 
    (lambda (&rest args)
      (render-link #'show-registration-form  "go to registration form")
      (render-link #'show-login-form  "go to login form"))))

;; Define callback function to initialize new sessions
(defun init-user-session (comp)
  (let ((permanent-actions 
          `(("my-profile" show-profile-page)
            (,*logout-action* logout-action)
            ("main" main-action))))
    (loop for i in permanent-actions do
          (apply #'weblocks::add-webapp-permanent-action (list*  'test6 i))))

  (main-action))

(defun render-debug-toolbar ()
  "When weblocks is started in debug mode, called on every request to
  present the user with a toolbar that aids development."
  (with-html
    (:div :class "debug-toolbar"
          (:div :style "float:left"
           (:a :href (make-action-url 
                       (make-action 
                         (lambda (&rest args)
                           (declare (ignore args))
                           (weblocks:reset-sessions)
                           (redirect (make-webapp-uri "/") :defer nil))
                         "debug-reset-sessions")) 
                    :title "Reset Sessions"
                    (:img :src (make-webapp-public-file-uri "images/reset.png")
                          :alt "Reset Sessions"))) 
          (:div :style "padding:5px;font-weight:bold;float:left;"
                (:a :href (make-action-url 
                            (function-or-action->action 
                              (lambda (&rest args)
                                (let ((*debug-auto-login* t))
                                  (current-user)))))
                    :title "Test" 
                    "Login")))))

(setf (symbol-function 'weblocks::render-debug-toolbar) #'render-debug-toolbar)
