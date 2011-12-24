(in-package :test6)

(defview test-result-table-view 
         (:type table)
         (render-result :reader #'render-result)
         (owner 
           :label "Responder"
           :reader (lambda (item)
                     #+l(responder-name (test-result-owner item))))
         (time-created :present-as date))

(defview test-result-form-view (:type form :inherit-from '(:scaffold test-result))
         (time-created :present-as hidden)
         (group 
           :reader (checked-groups-reader 'test-result-testing 'test-result #'test-result-testing-testing)
           :writer (groups-writer 'testing 'test-result-testing #'test-result-testing-testing :test-result :testing)
           :parse-as checkboxes
           :present-as (checkboxes :choices (groups-to-choices 'testing #'testing-name))))
