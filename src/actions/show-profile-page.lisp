(in-package :test6)

(defun/cc show-profile-page (&rest args)
  (require-login nil 
    (register-event "show-profile-page")
    (do-page 
      (list 
        (lambda (&rest args)
          (with-yaclml
            (<:div :style "float:right"
                   (<:as-is (render-inline-link *logout-action* "Logout"))) 
            (<:img :src (avatar-url (current-user)))))))))


