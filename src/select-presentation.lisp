(in-package :test6)

(defclass select-presentation (form-presentation)
  ((options :accessor select-presentation-options :initform nil :initarg :options)))


(defmethod print-view-field-value (value (presentation select-presentation) field view widget obj &rest args)
  value)

(defmethod render-view-field-value (value (presentation select-presentation)
                                          (field form-view-field) (view form-view) widget obj
                                          &rest args &key intermediate-values field-info &allow-other-keys)
  (declare (special *presentation-dom-id*))
  (with-yaclml
    (multiple-value-bind (intermediate-value intermediate-value-p)
      (form-field-intermediate-value field intermediate-values)
      (let ((value (if intermediate-value-p
                     intermediate-value
                     (apply #'print-view-field-value value presentation
                            field view widget obj args))))
        (<:select 
          :id *presentation-dom-id* 
          :name (if field-info
                  (attributize-view-field-name field-info)
                  (attributize-name (view-field-slot-name field)))
          (dolist (option (select-presentation-options presentation))
            (<:option :value (car option) (<:as-is (cadr option)))))))))
