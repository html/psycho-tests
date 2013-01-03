(in-package :test6)

(defview test-result-table-view 
         (:type table)
         (render-result 
           :present-as html
           :reader #'render-result)
         (owner 
           :label "Responder"
           :reader (lambda (item)
                     (responder-name (test-result-owner item))))
         (owner-group 
           :label "Responder group"
           :reader (lambda (item)
                     (responder-group-name (test-result-owner item))))
         (time-created :present-as (date :format  "%Y-%m-%d %H:%M")))

(mustache:defmustache test-result-view 
                      (yaclml:with-yaclml-output-to-string 
                        (<:h1 
                          (<:as-is "{{{form-title}}}"))
                        (<:as-is "{{{form-validation-summary}}}")
                        (<:div :class "pull-left"
                               (<:as-is "{{{form-body}}}")) 
                        (<:div :class "pull-left" :style "padding-top:5px;"
                               (<:as-is "{{{form-view-buttons}}}"))))

(defview test-result-form-view (:type mustache-template-form
                                :template #'test-result-view)
         (time-created :present-as (date :format  "%Y-%m-%d %H:%M"))
         (owner :present-as hidden))

(defview test-result-data-view (:type data)
         (time-created :present-as (date :format  "%Y-%m-%d %H:%M"))
         (owner :present-as hidden))
