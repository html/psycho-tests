(in-package :test6)

(defwidget test-results-grid (responders-grid)
  ((groups-displayed :initarg :groups-displayed 
                     :initform (mapcar #'object-id (all-of 'testing))
                     :accessor responders-grid-groups-displayed)))
