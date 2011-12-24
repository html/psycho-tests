(in-package :test6)

(defun edit-testings (&rest args)
  (do-page 
    (lambda (&rest args)
      (with-yaclml 
        (<:h1 "Testings")) 
      (render-widget (make-instance 'gridedit :data-class 'testing))
      (render-link #'show-profile-page "Back to main")))) 
