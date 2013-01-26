(defpackage #:test6-tests
  (:use :cl :test6 :weblocks-selenium-tests :selenium)
  (:documentation
   "Tests for test6 project"))

(in-package :test6-tests)

(defmacro with-selenium (&body body)
  `(let ((*site-url* "http://localhost:5555/test6"))
     (with-new-or-existing-selenium-session ,@body)))
