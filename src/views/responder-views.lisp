(in-package :test6)

(defview responder-table-view (:type table :inherit-from '(:scaffold responder))
         (time-created :present-as (date :format  "%Y-%m-%d %H:%M"))
         (group :present-as text 
                :reader (lambda (item)
                          (let ((group (responder-first-group item)))
                            (when group 
                              (group-name group))))))

(defvar *name-taken-error*  "This name has already been taken")

(defview new-responder-form-view (:type form :inherit-from '(:scaffold responder))
         (name :satisfies (lambda (value)
                            (if (find-by-values 'responder :name value)
                              (values nil *name-taken-error*)
                              t)))
         (time-created :present-as hidden :writer #'time-created-writer))

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

(defvar *record-validating* nil)

(defmethod validate-form-view-field :around (slot-name object field view parsed-value)
  (let ((*record-validating* object))
    (call-next-method)))

(defview responder-form-view (:type form :inherit-from '(:scaffold responder))
         (time-created :present-as hidden :writer #'time-created-writer)
         (name :satisfies (lambda (value)
                            (declare (special *record-validating*))
                            (let ((records (remove *record-validating* (find-by-values 'responder :name value))))
                              (if records 
                                (values nil *name-taken-error*)
                                t))))
         (group 
           :reader (lambda (responder)
                     (and (responder-first-group responder)
                          (group-name (responder-first-group responder))))
           :writer (lambda (value item)
                     (let* ((group (and value 
                                        (or 
                                          (first (find-by-values 'group :name value))
                                          ; Ensuring filters correct (with new group)
                                          (let ((new-group (make-instance 'group :name value)))
                                            (mark-dirty (root-widget))  
                                            (prog1 
                                              (persist-object *default-store* new-group)
                                              (pushnew (object-id new-group) 
                                                       (responders-grid-groups-displayed 
                                                         (first (get-widgets-by-type 'responders-grid)))))))))
                            (old-connections (find-by-values 'responder-group :responder item)))
                       (mapcar #'destroy old-connections)
                       (when group
                         (persist-object *default-store* (make-instance 'responder-group :group group :responder item)))))
           :present-as (bootstrap-typeahead 
                         :choices (groups-to-choices 'group #'group-name))))
