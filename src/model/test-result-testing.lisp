(in-package :test6)

(defclass test-result-testing ()
  ((id)
   (test-result :accessor test-result-testing-test-result :initarg :test-result :initform nil)
   (testing :accessor test-result-testing-testing :initarg :group :initform nil)))
