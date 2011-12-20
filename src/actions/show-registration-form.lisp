(in-package :test6)

(defun/cc show-registration-form (&rest args)
  (register-event "show-registration-form")
  (do-page 
    (make-instance 'register-by-email-widget 
                   :ui-state :form 
                   :form-view 'register-form-view 
                   :data-view 'register-data-view
                   :data (make-instance 'user))))

