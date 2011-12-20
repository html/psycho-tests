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

(defmethod avatar-url ((obj user))
  (if (gravatar-connectedp obj)
    (gravatar-url (email obj))))

(defmethod small-avatar-url ((obj user))
  (if (gravatar-connectedp obj)
    (format nil "~A?size=35" (avatar-url obj))))

(defmethod name-or-anonymous-image (user)
  (if (name user)
    (format nil "<div style=\"margin-top:10px;font-weight:bold;\">~A</div>" (name user)) 
    (format nil "<img src=\"~A\" height=\"35\" width=\"100\"/>" (make-webapp-public-file-uri "/custom/images/anonymous_label.png"))))

(defmethod answered-questions-count (user)
  (find-by-value 'question 'user user :countp t))
