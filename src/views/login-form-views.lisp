(in-package :test6)

(defview login-form-view (:type form :persistp nil
                              :inherit-from 'default-login-view
                              :buttons '((:submit . "Login") :cancel)
                              :caption "Login"
                              :focusp t)
         (password :requiredp t
                   :present-as (password :max-length 40)
                   :writer (lambda (pwd obj)
                             (setf (slot-value obj 'password)
                                   (hash-password pwd)))))
