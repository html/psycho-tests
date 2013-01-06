(in-package :test6)

(defwidget grid-separated-form-views (gridedit)
  ((new-item-form-view 
     :initform nil 
     :initarg :new-item-form-view 
     :accessor grid-separated-form-views-new-item-form-view)))

(defmethod dataedit-create-new-item-widget ((grid grid-separated-form-views))
  (make-instance 'dataform
                 :data (make-instance (dataseq-data-form-class grid))
                 :class-store (dataseq-class-store grid)
                 :ui-state :form
                 :on-cancel (lambda (obj)
                              (declare (ignore obj))
                              (dataedit-reset-state grid)
                              (throw 'annihilate-dataform nil))
                 :on-success (lambda (obj)
                               (safe-funcall (dataedit-on-add-item grid) grid (dataform-data obj))
                               (safe-funcall (dataedit-on-add-item-completed grid) grid (dataform-data obj))
                               (when (or (dataedit-mixin-flash-message-on-first-add-p grid)
                                         (> (dataseq-data-count grid) 1))
                                 (flash-message (dataseq-flash grid)
                                                (format nil "Added ~A."
                                                        (humanize-name (dataseq-data-class grid)))))
                               (dataedit-reset-state grid)
                               (throw 'annihilate-dataform nil))
                 :data-view (dataedit-item-data-view grid)
                 :form-view (grid-separated-form-views-new-item-form-view grid)))

(defmacro groups-filter ()
  `(lambda (grid sort some  &rest args &key countp) 
     (let* ((display-ungrouped-p (responders-grid-display-ungroupedp grid))
            (groups-displayed (responders-grid-groups-displayed grid))
            (items (weblocks-utils:find-by 
                     (dataseq-data-class grid)
                     (lambda (item)
                       (defun any-group-matches (groups1 groups2)
                         (loop for i in groups2 
                               do (if (find i groups1 :test #'string=)
                                    (return-from any-group-matches t))))
                       (let ((groups-ids (groups-ids item)))
                         (if groups-ids

                           (progn
                             (format t "Groups displayed ~A Groups ids ~A ~A~%" 
                                     (mapcar #'write-to-string groups-displayed)
                                     (mapcar #'write-to-string groups-ids)
                                     (any-group-matches 
                                       (mapcar #'write-to-string groups-displayed) 
                                       (mapcar #'write-to-string groups-ids)))
                             (any-group-matches 
                               (mapcar #'write-to-string groups-displayed) 
                               (mapcar #'write-to-string groups-ids)))
                           display-ungrouped-p)))
                     :order-by sort))) 
       (if countp 
         (length items)
         items))))

(defwidget responders-grid (grid-separated-form-views)
  ((groups-displayed :initarg :groups-displayed 
                     :initform (mapcar #'object-id (all-of 'group))
                     :accessor responders-grid-groups-displayed)
   (display-ungroupedp :initarg :display-ungrouped-p :initform t :accessor responders-grid-display-ungroupedp))
  (:default-initargs 
   :on-query (groups-filter)))

(defwidget responders-grid-dataform (dataform)
  ())

(defmethod render-dataform-form ((obj responders-grid-dataform) data view &rest args)
  (apply #'render-object-view
         data view
         :method :post
         :action (make-action (lambda (&key submit cancel save-data &allow-other-keys)
                                (catch 'annihilate-dataform
                                       (let (break-out)
                                         (when (or submit save-data)
                                           (multiple-value-bind (success errors)
                                             (apply #'dataform-submit-action obj data args)
                                             (if success
                                               (progn
                                                 (mark-dirty obj :propagate t)
                                                 (safe-funcall (dataform-on-success obj) obj)
                                                 (setf break-out t))
                                               (progn
                                                 (setf (slot-value obj 'weblocks::validation-errors) errors)
                                                 (setf (slot-value obj 'weblocks::intermediate-form-values)
                                                       (apply #'request-parameters-for-object-view
                                                              view args))))))
                                         (when cancel
                                           (safe-funcall (dataform-on-cancel obj) obj)
                                           (setf break-out t))
                                         (when break-out
                                           (setf (slot-value obj 'weblocks::validation-errors) nil)
                                           (setf (slot-value obj 'weblocks::intermediate-form-values) nil)
                                           (setf (dataform-ui-state obj) :data))))
                                (when save-data 
                                  (test-action))))
         :validation-errors (slot-value obj 'weblocks::validation-errors)
         :intermediate-values (slot-value obj 'weblocks::intermediate-form-values)
         :widget obj
         :form-view-buttons (data-editor-form-buttons obj)
         args))

(defmethod dataedit-create-new-item-widget :around ((grid responders-grid))
  (make-instance 'responders-grid-dataform
                 :data (make-instance (dataseq-data-form-class grid))
                 :class-store (dataseq-class-store grid)
                 :ui-state :form
                 :on-cancel (lambda (obj)
                              (declare (ignore obj))
                              (dataedit-reset-state grid)
                              (throw 'annihilate-dataform nil))
                 :on-success (lambda (obj)
                               (safe-funcall (dataedit-on-add-item grid) grid (dataform-data obj))
                               (safe-funcall (dataedit-on-add-item-completed grid) grid (dataform-data obj))
                               (when (or (dataedit-mixin-flash-message-on-first-add-p grid)
                                         (> (dataseq-data-count grid) 1))
                                 (flash-message (dataseq-flash grid)
                                                (format nil "Added ~A."
                                                        (humanize-name (dataseq-data-class grid)))))
                               (dataedit-reset-state grid)
                               (throw 'annihilate-dataform nil))
                 :data-view (dataedit-item-data-view grid)
                 :form-view (grid-separated-form-views-new-item-form-view grid)))

