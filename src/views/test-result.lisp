(in-package :test6)

(defview test-result-table-view 
         (:type table)
         (render-result :reader #'render-result)
         (owner 
           :label "Responder"
           :reader (lambda (item)
                          (responder-name (test-result-owner item))))
         (time-created :present-as date))
