(in-package :test6-tests)

(defparameter *login-credentials* nil)
; Taken from test2-tests
(defun create-random-string (&optional (n 10))
  (with-output-to-string (s)
    (dotimes (i n)
      (format s "~A" (code-char (+ 97  (random (- 122 97))))))))

; Taken from test2-tests
(defun create-random-email ()
  (format nil "~A~A@spamavert.com" (create-random-string) (get-universal-time)))

; Taken from test2-tests
(defun link-to-check-email (email)
  (cl-ppcre:register-groups-bind (email-name)
                                 ("(.*)@" email)
                                 (format nil "http://spamavert.com/mail/~A" email-name)))

; Taken from test2-tests
(defun open-last-mail-page (email)
  (loop do 
        (and 
          (handler-case  
            (progn 
              (do-open (link-to-check-email email))
              (do-wait-for-page-to-load 2000)
              (do-click-and-wait "css=.maillist>li:first")
              (do-wait-for-page-to-load 2000)
              t)
            (execution-error () (sleep 1))) 
          (return))))

; Taken from test2-tests
(defun extract-password-from-register-email-body (register-email-body)
  (cl-ppcre:register-groups-bind (password)
    ("\"([^\"]+)\"" register-email-body)
    password))

(def-test-suite authentication)

(deftest sends-email-on-register ()
  (with-selenium  
    (let ((random-email (create-random-email)))
      (do-click-and-wait "link=go to registration form") 
      (do-type "name=email" random-email) 
      (do-click-and-wait "name=submit") 
      (open-last-mail-page random-email)
      (let ((email-body (do-get-text "id=mail")))
        (is (cl-ppcre:scan "You have successfully registered" email-body))
        (setf *login-credentials* (list  random-email  (extract-password-from-register-email-body email-body))))
      (do-open *site-url*) 
      (do-wait-for-page-to-load 1000)
      (do-click-and-wait "link=Return to last page viewed"))))

(defmacro with-logged-in-user (&body body)
  `(progn 
     (do-wait-for-page-to-load 5000)
     (when (do-is-element-present "link=go to login form") 
       (logs-in))
     ,@body))

(deftest logs-in ()
  (with-selenium 
    (multiple-value-bind (email password) (get-credentials-for-login)
      (do-click-and-wait "link=go to login form")
      (do-type "name=email" email)
      (do-type "name=password" password)
      (do-click-and-wait "name=submit")
      (is (string-equal "People tested" (do-get-text "css=h1"))))))

(defun get-credentials-for-login ()
  (unless *login-credentials* 
    (sends-email-on-register))
  (apply #'values *login-credentials*))

(deftest cancels-log-in-process ()
  (with-selenium 
    (do-click-and-wait "link=go to login form")
    (do-click-and-wait "name=cancel")
    (is (string-equal "Test 6" (do-get-text "css=h1")))))

(deftest cancels-register-process ()
  (with-selenium 
    (do-click-and-wait "link=go to registration form")
    (do-click-and-wait "name=cancel")
    (is (string-equal "Test 6" (do-get-text "css=h1")))))
