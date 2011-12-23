(in-package :test6)

(defclass responder-group ()
  ((id)
   (responder :accessor responder-group-responder :initarg :responder :initform nil)
   (group :accessor responder-group-group :initarg :group :initform nil)))
