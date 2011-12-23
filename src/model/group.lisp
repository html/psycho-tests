(in-package :test6)

(defclass group ()
  ((id)
   (name :initarg :name :initform nil :accessor group-name)))
