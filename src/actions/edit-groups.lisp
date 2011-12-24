(in-package :test6)

(defun edit-people-groups (&rest args)
  (do-page 
    (lambda (&rest args)
      (with-yaclml 
        (<:h1 "People groups")) 
      (render-widget (make-instance 'gridedit :data-class 'group))
      (render-link #'show-profile-page "Back to main")))) 
