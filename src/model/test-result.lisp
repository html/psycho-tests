(in-package :test6)

(defclass test-result ()
  ((id)
   (value :initarg :value)
   (owner :accessor test-result-owner :initform nil :initarg :owner)
   (time-created 
     :accessor time-created 
     :initform (get-universal-time))))

(defmethod render-result ((model test-result))
  "Rendered result must be here")

(defmethod groups-ids ((obj test-result))
  (mapcar #'object-id (mapcar #'test-result-testing-test-result (find-by-value 'test-result-testing 'test-result obj))))
