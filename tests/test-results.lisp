(in-package :test6-tests)

(def-test-suite test-results)

(defun open-test (&optional type)
  (ensure-at-least-one-responder-exists)
  (do-click-and-wait "link=Testing results")
  (is (cl-ppcre:scan "testing-results$" (do-get-location)))
  (do-click-and-wait "link=Add test result")
  (is (cl-ppcre:scan "testing-results/do-test$" (do-get-location)))
  ; XXX This should not be
  (do-open-and-wait (do-get-location))
  (do-click-and-wait type)
  (do-open-and-wait (do-get-location))

  (do-click-and-wait type)

  ; XXX This should not be
  (do-open-and-wait (do-get-location)))

(deftest adds-bass-darka-test-result() 
         (with-selenium 
           (with-logged-in-user 
             (open-test "name=bass-darka")
             (do-click-and-wait "name=submit")
             (is (string= "Results of testing" (do-get-text "css=h1"))))))

(defun check-all-radios-for-conflict-style-test ()
  (loop for i from 1 to 35 do 
        (do-click (format nil "css=.question-~A input:nth(~A)" i (random 5)))))

(deftest adds-conflict-style-test-result ()
  (with-selenium 
    (with-logged-in-user 
      (open-test "name=conflict-style")
      (check-all-radios-for-conflict-style-test)
      (do-click-and-wait "name=submit")
      (is (string= "Results of testing" (do-get-text "css=h1"))))))

(deftest cancels-test ()
  (with-selenium 
    (with-logged-in-user 
      (open-test "name=conflict-style")
      (do-click-and-wait "name=cancel")
      (is (string= "Results of testing" (do-get-text "css=h1"))))))
