(in-package :test6)


(defclass responder ()
  ((id)
   (name :initform nil :accessor responder-name :initarg :name)
   (time-created :initform (get-universal-time) :accessor responder-time-created)))


(defmethod groups-ids ((obj responder))
  (mapcar #'object-id (mapcar #'first (mapcar #'responder-group-group (find-by-value 'responder-group 'responder obj)))))
