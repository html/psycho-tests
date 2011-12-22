(in-package :test6)

(defview test-result-table-view 
         (:type table)
         (render-result :reader #'render-result)
         (time-created :present-as date))
