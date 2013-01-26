(in-package :test6)

(defun people-tested-nav-root-widget ()
  (first (widget-children (get-widget-by-id "people-tested-inner"))))

(defview groups-edit-view (:type form
                           :inherit-from '(:scaffold group))
         (owner :present-as hidden))

(defview groups-table-view (:type table
                           :inherit-from '(:scaffold group))
         (owner :present-as hidden))

(defun edit-people-groups (&rest args)
  (do-widget  
    (people-tested-nav-root-widget)
    (lambda (&rest args)
      (with-yaclml 
        (<:h1 "People groups") 
        (render-widget 
          (make-instance 'gridedit 
                         :data-class 'group 
                         :item-form-view 'groups-edit-view
                         :view 'groups-table-view
                         :on-query (lambda (grid sort some  &rest args &key countp) 
                                     (let ((records 
                                             (find-by-values 'group 
                                                             :owner (current-user)
                                                             :order-by sort 
                                                             :range some)))
                                       (if countp 
                                         (length records)
                                         records)))))
        (<:a :href (make-webapp-uri "/people-tested") "Back")))))
