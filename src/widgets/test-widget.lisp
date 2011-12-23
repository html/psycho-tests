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


(defun make-test-widget ()
  (make-instance 'simpleform 
                 :on-success (lambda (form)
                               (let ((responder 
                                       (first (find-by-value 'responder 'id (parse-integer (slot-value (dataform-data form) 'responder))))))
                                 (persist-object 
                                   *default-store*
                                   (make-instance 'test-result 
                                                  :owner responder
                                                  :value 
                                                  (loop for i from 1 to 75 
                                                        collect (slot-value 
                                                                  (dataform-data form) 
                                                                  (intern (format nil "QUESTION-~A" i))))))) 
                               (redirect (make-action-url "my-profile") :defer nil))
                 :form-view (eval 
                              `(defview-anon 
                                 (:type form :persistp nil)
                                 (responder :present-as (select :options (loop for i in (all-of 'responder)
                                                                               collect (list (slot-value i 'id) (responder-name i)))) 
                                            :requiredp t
                                            :satisfies (lambda (value)
                                                         (find-by-value 'responder 'id (parse-integer value))))
                                 ,@(get-view-fields-by-test-questions))))) 

(defun test-action (&rest args)
  (do-page (make-test-widget)))
