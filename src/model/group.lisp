(in-package :test6)

(defclass group ()
  ((id)
   (name :initarg :name :initform nil :accessor group-name)
   (owner :initarg :owner :initform nil :accessor group-owner)))

(defmethod persist-object :before (store (obj group) &key)
  (setf (group-owner obj) (current-user)))
