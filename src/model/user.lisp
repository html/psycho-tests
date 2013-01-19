(in-package :test6)

(defclass user()
  ((id :documentation "this is automatically assigned by cl-prevalence
       when we persist the post object")
   (email
     :initarg :email
     :accessor email
     :type string)
   (name 
     :initarg :name 
     :accessor name)
   (password-hash :accessor password-hash)
   (gravatar-connectedp 
     :accessor gravatar-connectedp 
     :initarg :gravatar-connectedp)
   (time-created :initform (get-universal-time))))

