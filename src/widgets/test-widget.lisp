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
                               (persist-object 
                                 *default-store*
                                 (make-instance 'test-result 
                                                :value 
                                                (loop for i from 1 to 75 
                                                      collect (slot-value 
                                                                (dataform-data form) 
                                                                (intern (format nil "QUESTION-~A" i))))))
                               (redirect (make-action-url "my-profile") :defer nil))
                 :form-view (eval `(defview-anon 
                                     (:type form :persistp nil)
                                     ,@(get-view-fields-by-test-questions))))) 

(defun test-action (&rest args)
  (do-page (make-test-widget)))
