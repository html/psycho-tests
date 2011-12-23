(in-package :test6)


(defclass responder ()
  ((id)
   (name :initform nil :accessor responder-name :initarg :name)))
