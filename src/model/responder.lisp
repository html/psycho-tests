(in-package :test6)


(defclass responder ()
  ((id)
   (name :initform nil :accessor responder-name :initarg :name)
   (time-created :initform (get-universal-time) :accessor responder-time-created)))


(defmethod groups-ids ((obj responder))
  (mapcar #'object-id (mapcar #'responder-group-group (find-by-value 'responder-group 'responder obj))))

(defmethod responder-first-group ((obj responder))
  (let ((r-group (first (find-by-value 'responder-group 'responder obj))))
    (and r-group (responder-group-group r-group))))
