(in-package :test6)


(defwidget check-button (widget)
  ((state :initform :unchecked :initarg :state)
   (state-callbacks :initform nil :initarg :state-callbacks :accessor check-button-state-callbacks)
   (title :initarg :title :accessor check-button-title :initform "Check button without title")))

(defmethod change-state-action ((widget check-button))
  (make-action 
    (lambda (&rest args)
      (let ((new-state 
              (if (equal (slot-value widget 'state) :unchecked)
                :checked 
                :unchecked)))
        (setf (slot-value widget 'state) new-state)
        (when (getf (check-button-state-callbacks widget) new-state)
          (funcall (getf (check-button-state-callbacks widget) new-state) widget))))))

(defmethod render-widget-body ((widget check-button) &rest args)
  (render-link 
    (change-state-action widget)
    (check-button-title widget)
    :class (format nil "state-~A" (string-downcase (slot-value widget 'state)))))

(defwidget check-button-with-group-id (check-button)
  ((group-id :initarg :group-id)))
