(in-package :test6)

(defun get-test-questions ()
  (with-open-file (str "test-data.txt")
    (loop for line = (read-line str nil) 
          while line 
          collect (string-trim '(#\Space #\Tab #\Newline) line))))


(defun get-view-fields-by-test-questions ()
  (loop for i in (get-test-questions) 
        for j from 1 
        collect (list (intern (format nil "QUESTION-~A" j)) :present-as 'checkbox :label i)))

(mustache:defmustache test-view 
                      (yaclml:with-yaclml-output-to-string 
                        (<:h1 "Test")
                        "{{{form-validation-summary}}}"
                        (<:div 
                          (<:ul :class "unstyled test-list" "{{{form-body}}}"))
                        (<:div "{{{form-view-buttons}}}")))

(defun/cc test-action (&rest args)
          (let ((choice (do-choice "Please choose test type" (list :bass-darka 
                                                                   ;:conflict-style 
                                                                   ) :css-class "modal fade in")))
            (do-page 
              (list 
                (lambda ()
                  (render-link "my-profile" "Back to main"))
                (make-instance 'simpleform 
                               :on-success (lambda (form)
                                             (let ((responder 
                                                     (first (find-by-value 'responder 'id (parse-integer (slot-value (dataform-data form) 'responder))))))
                                               (persist-object 
                                                 *default-store*
                                                 (make-instance 'test-result 
                                                                :test-type :bass-darka
                                                                :owner responder
                                                                :time-created (get-universal-time)
                                                                :value 
                                                                (loop for i from 1 to 75 
                                                                      collect (slot-value 
                                                                                (dataform-data form) 
                                                                                (intern (format nil "QUESTION-~A" i))))))) 
                                             (setf (dataform-ui-state form) :form)
                                             (redirect (make-action-url "my-profile") :defer nil))
                               :form-view (eval 
                                            `(defview-anon 
                                               (:type mustache-template-form 
                                                :template #'test-view
                                                :persistp nil)
                                               (responder :present-as (select :options (loop for i in (all-of 'responder)
                                                                                             collect (list (slot-value i 'id) (responder-name i)))) 
                                                          :requiredp t
                                                          :satisfies (lambda (value)
                                                                       (find-by-value 'responder 'id (parse-integer value))))
                                               ,@(get-view-fields-by-test-questions))))
                (lambda ()
                  (render-link "my-profile" "Back to main"))))))
