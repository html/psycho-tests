(in-package :test6)

(defview responder-table-view (:type table :inherit-from '(:scaffold responder)))

(defview new-responder-form-view (:type form :inherit-from '(:scaffold responder)))

(defview responder-form-view (:type form :inherit-from '(:scaffold responder))
         (group 
           :reader (lambda (obj)
                     (loop for i in (find-by-value 'responder-group 'responder obj) 
                           collect (write-to-string (slot-value (first (responder-group-group i)) 'id))))
           :writer 
           (lambda (value item)
             (when (slot-value item 'id)
               ; Connecting new groups
               (loop for i in value do 
                     (let ((group (find-by-value 'group 'id (parse-integer (format nil "~A" i)))))
                       (unless 
                         (find-by-values 'responder-group :group group :responder item)
                         (persist-object 
                           *default-store* 
                           (make-instance 'responder-group 
                                          :group group 
                                          :responder item)))))
               ; Removing unused groups
               (loop for i in (find-by-value 'responder-group 'responder item) do 
                     (unless 
                       (find 
                         (write-to-string (slot-value (first (responder-group-group i)) 'id))
                         value 
                         :test #'string=)
                       (destroy i)))))

           :parse-as checkboxes
           :present-as (checkboxes :choices (lambda (&rest args)
                                              (loop for i in (all-of 'group) collect (cons (group-name i) (slot-value i 'id)))))))
