(in-package :test6)

(defview register-form-view 
         (:type form 
          :persistp nil 
          :caption "Register")
         (name :requiredp nil)
         (email :requiredp t :satisfies #'registration-form-email-satisfiesp))

(defview register-data-view 
         (:type data 
          :caption "Registration completed")
         (email))
