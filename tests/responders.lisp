(in-package :test6-tests)

(def-test-suite responders)

(defun ensure-at-least-one-responder-exists ()
  (unless (do-is-element-present "css=tbody tr")
    (adds-responder)))

(deftest adds-responder() 
         (with-selenium 
           (with-logged-in-user 
             (let ((name (create-random-string))
                   (group (create-random-string)))
               (do-click-and-wait "name=add") 
               (do-type "name=name" name) 
               (do-type "name=group" group) 
               (do-click-and-wait "name=submit") 
               (is (string= name (do-get-text "css=td.name"))) 
               (is (string= group (do-get-text "css=td.group")))))))

(deftest modifies-responder ()
  (with-selenium 
    (with-logged-in-user 
      (let ((new-name (create-random-string)))
        (do-click-and-wait "name=add")
        (ensure-at-least-one-responder-exists)
        (do-click-and-wait "css=tbody tr:first")
        (do-type "name=name" new-name)
        (do-click-and-wait "name=submit")
        (is (string= new-name (do-get-text "css=td.name")))))))
