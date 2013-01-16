(in-package :test6)

(defun people-tested-nav-root-widget ()
  (first (widget-children (get-widget-by-id "people-tested-inner"))))

(defun edit-people-groups (&rest args)
  (do-widget  
    (people-tested-nav-root-widget)
    (lambda (&rest args)
      (with-yaclml 
        (<:h1 "People groups") 
        (render-widget (make-instance 'gridedit :data-class 'group))  
        (<:a :href "/people-tested" "Back"))))) 
