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

(defwidget responders-grid (grid-separated-form-views)
  ())

