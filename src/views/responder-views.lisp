(in-package :test6)

(defview responder-table-view (:type table :inherit-from '(:scaffold responder))
         (time-created :present-as (date :format  "%Y-%m-%d %H:%I"))
         (group :present-as text 
                :reader (lambda (item)
                          (let ((group (responder-first-group item)))
                            (when group 
                              (group-name group))))))

(defview new-responder-form-view (:type form :inherit-from '(:scaffold responder))
         (time-created :present-as hidden :writer (lambda (item)
                                                    (declare (ignore item)))))

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

(load "src/weblocks-bootstrap-typeahead.lisp")

(defview responder-form-view (:type form :inherit-from '(:scaffold responder))
         (time-created :present-as hidden :writer (lambda (item)
                                                    (declare (ignore item))))
         (group 
           :reader (lambda (responder)
                     (and (responder-first-group responder)
                          (group-name (responder-first-group responder))))
           :writer (lambda (value item)
                     (let* ((group (and value 
                                        (or 
                                          (first (find-by-values 'group :name value))
                                          (persist-object *default-store* (make-instance 'group :name value)))))
                            (old-connections (find-by-values 'responder-group :responder item)))
                       (mapcar #'destroy old-connections)
                       (when group
                         (persist-object *default-store* (make-instance 'responder-group :group group :responder item)))))
           :present-as (bootstrap-typeahead 
                         :choices (groups-to-choices 'group #'group-name))))
