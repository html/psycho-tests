(defpackage #:test6-tests-asd
  (:use :cl :asdf))

(in-package :test6-tests-asd)

(defsystem test6-tests
     :name "test6-tests"
     :version "0.1.0"
     :maintainer "Olexiy Zamkoviy"
     :author "Olexiy Zamkoviy"
     :licence "LLGPL"
     :description "test6-tests"
     :depends-on (:test6 :weblocks-selenium-tests)
     :components 
     ((:file "test6-tests")
      (:module tests :depends-on ("test6-tests")
       :components 
       ((:file "tests-app-updates")
        (:file "authentication")
        (:file "responders" :depends-on ("authentication"))
        (:file "test-results" :depends-on ("authentication" "responders"))
        (:file "all-tests" :depends-on ("test-results" "authentication" "responders"))))))
