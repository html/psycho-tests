(in-package :test6)

(defview responder-table-view (:type table :inherit-from '(:scaffold responder))
         (time-created :present-as (date :format  "%Y-%m-%d %H:%I")))

(defview new-responder-form-view (:type form :inherit-from '(:scaffold responder)))

(defmacro checked-groups-reader (group-class item-class group-accessor)
  `(lambda (obj)
     (loop for i in (find-by-value ,group-class ,item-class obj) 
           collect (write-to-string (slot-value (first (funcall ,group-accessor i)) 'id)))))

(defmacro groups-writer (group-class chain-class group-accessor item-key group-slot-name)
  `(lambda (value item)
     (when (slot-value item 'id)
       ; Connecting new groups
       (loop for i in value do 
             (let ((group (find-by-value ,group-class 'id (parse-integer (format nil "~A" i)))))
               (unless 
                 (find-by-values ,chain-class ,group-slot-name group ,item-key item)
                 (persist-object 
                   *default-store* 
                   (make-instance ,chain-class 
                                  :group group 
                                  ,item-key item)))))
       ; Removing unused groups
       (loop for i in (find-by-values ,chain-class ,item-key item) do 
             (unless 
               (find 
                 (write-to-string (slot-value (first (funcall ,group-accessor i)) 'id))
                 value 
                 :test #'string=)
               (destroy i))))))

(defmacro groups-to-choices (group-class name-accessor)
  `(lambda (&rest args)
     (loop for i in (all-of ,group-class) collect (cons (funcall ,name-accessor i) (slot-value i 'id)))))

(defview responder-form-view (:type form :inherit-from '(:scaffold responder))
         (group 
           :reader (checked-groups-reader 'responder-group 'responder #'responder-group-group)
           :writer (groups-writer 'group 'responder-group #'responder-group-group :responder :group)
           :parse-as checkboxes
           :present-as (checkboxes :choices (groups-to-choices 'group #'group-name))))
