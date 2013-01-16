(in-package :test6)

(defwidget invisible-navigation (navigation)
           ())

(defmethod render-widget-body ((widget invisible-navigation) &rest args)
  (declare (ignore args)))

