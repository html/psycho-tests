(in-package :test6)

(defvar *debug-auto-login* nil)
(defparameter *logout-action* "logout")

(defmacro %current-user ()
  `(webapp-session-value *authentication-key*))

(defun current-user ()
  (or (%current-user) 
      (and *debug-auto-login*  
           (prog1  
             (setf (webapp-session-value *authentication-key*) 
                   (values 
                     (first  (find-persistent-objects *default-store* 'user)) t))))))

(defun current-user-groups (group-class)
  (find-by-values group-class :owner (current-user)))

(defun/cc logout-action (&rest args)
          (register-event "logged-out" :user (object->simple-plist (current-user)))
          (logout)
          (redirect "/?action=main"))

(defun main-action (&rest args)
  (do-page 
    (lambda (&rest args)
      (with-yaclml 
        (<:div :class "container"
               (<:br)
               (<:div :class "hero-unit"
                      (<:h1 (<:as-is "Test&nbsp;6")) 
                      (<:p
                        (<:br) 
                        (<:as-is "Hello, you are on test6 - application for editing and organizing psychological tests")) 
                        (<:br) 
                        (<:br) 
                        (render-link #'show-registration-form  "go to registration form" :class "btn btn-primary btn-large") 
                        (<:as-is " or ") 

                        (render-link #'show-login-form  "go to login form" :class "btn btn-primary btn-large")))))))

;; Define callback function to initialize new sessions
(defun init-user-session (comp)
  (let ((permanent-actions 
          `(("my-profile" show-profile-page)
            (,*logout-action* logout-action)
            ("main" main-action)
            ("test" test-action))))
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
                                  (current-user)
                                  (redirect (make-action-url "my-profile") :defer nil)))))
                    :title "Test" 
                    "Login")))))

(setf (symbol-function 'weblocks::render-debug-toolbar) #'render-debug-toolbar)
