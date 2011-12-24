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
            (items (find-by-predicate 
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
                           display-ungrouped-p)))))) 
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
                 

