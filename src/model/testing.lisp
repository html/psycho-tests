(in-package :test6)

(defclass testing ()
  ((name :initarg :name :initform nil :accessor testing-name)
   (time-created :initform (get-universal-time))))
