(in-package :test6)

(defwidget test-results-grid (responders-grid)
  ((groups-displayed :initarg :groups-displayed 
                     :initform nil
                     :accessor responders-grid-groups-displayed)))
