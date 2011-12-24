(in-package :test6)

(defclass testing ()
  ((id)
   (name :initarg :name :initform nil :accessor testing-name)
   (time-created :initform (get-universal-time))))
