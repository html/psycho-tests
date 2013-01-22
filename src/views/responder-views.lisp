(in-package :weblocks)

(defmethod render-form-view-buttons :around ((view form-view) obj widget &rest args &key form-view-buttons &allow-other-keys)
  (declare (ignore obj args))

  ;(return-normal-value-when-theme-not-used render-form-view-buttons)

  (flet ((find-button (name)
           (arnesi:ensure-list
             (if form-view-buttons
               (find name form-view-buttons
                     :key (lambda (item)
                            (car (arnesi:ensure-list item))))
               (find name (form-view-buttons view)
                     :key (lambda (item)
                            (car (arnesi:ensure-list item))))))))
    (with-html
      (:div :class "submit control-group"
        (:div :class "controls"
         (loop for i in (form-view-buttons view) do 
               (let* ((button-key (car (arnesi:ensure-list i)))
                      (button-label (if (listp i) (cdr i) (humanize-name button-key))))
                 (render-button 
                   (cond 
                     ((equal button-key :submit) *submit-control-name*)
                     ((equal button-key :cancel) *cancel-control-name*)
                     (t button-key)) 
                   :class (cond 
                            ((equal button-key :submit) "submit btn btn-primary")
                            ((equal button-key :cancel) "btn submit cancel")
                            (t "btn submit"))
                   :value button-label))))))))

(in-package :test6)

(load "src/weblocks-bootstrap-typeahead.lisp")

(defmacro groups-to-choices (group-class name-accessor)
  `(lambda (&rest args)
     (loop for i in (current-user-groups ,group-class) collect (cons (funcall ,name-accessor i) (slot-value i 'id)))))

(defun responder-group-writer (value item)
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

(defun responder-group-reader (responder)
  (and (responder-first-group responder)
       (group-name (responder-first-group responder))))

(load "src/weblocks-table-view-with-ordered-fields.lisp")

(defview responder-table-view (:type advanced-table :inherit-from '(:scaffold responder)
                               :fields-order '(:id :name :group :time-created))
         (id :label "#" :order-weight 10)
         (time-created :present-as (date :format  "%Y-%m-%d %H:%M"))
         (group :present-as text 
                :reader (lambda (item)
                          (let ((group (responder-first-group item)))
                            (when group 
                              (group-name group))))
                :allow-sorting-p t)
         (owner :present-as hidden))

(defvar *name-taken-error*  "This name has already been taken")

(defview new-responder-form-view (:type form :inherit-from '(:scaffold responder) 
                                        :buttons '((:submit . "Save") (:save-data . "Save and start test" ) :cancel))
         (name :satisfies (lambda (value)
                            (if (find-by-values 'responder :name value :owner (current-user))
                              (values nil *name-taken-error*)
                              t)))
         (group 
           :reader #'responder-group-reader
           :writer #'responder-group-writer
           :present-as (bootstrap-typeahead 
                         :choices (groups-to-choices 'group #'group-name)))
         (time-created :present-as hidden :writer #'time-created-writer)
         (owner 
           :present-as hidden
           :reader (lambda (&rest args)
                     (declare (ignore args)))
           :writer (lambda (value item)
                     (setf (slot-value item 'owner) (current-user)))))

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

(defvar *record-validating* nil)

(defmethod validate-form-view-field :around (slot-name object field view parsed-value)
  (let ((*record-validating* object))
    (call-next-method)))

(defview responder-form-view (:type form :inherit-from '(:scaffold responder))
         (time-created :present-as hidden :writer #'time-created-writer)
         (name :satisfies (lambda (value)
                            (declare (special *record-validating*))
                            (let ((records (remove *record-validating* (find-by-values 'responder :name value :owner (current-user)))))
                              (if records 
                                (values nil *name-taken-error*)
                                t))))
         (group 
           :reader #'responder-group-reader
           :writer #'responder-group-writer
           :present-as (bootstrap-typeahead 
                         :choices (groups-to-choices 'group #'group-name)))
         (owner :present-as hidden :writer (lambda (value item)
                                             (declare (ignore value item)))))
