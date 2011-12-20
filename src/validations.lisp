(in-package :test6)

(defun valid-emailp (email)
  (let ((original-email-regexp  "
    ^ # Start of string
 
   [0-9a-z] # First character
   [0-9a-z.+]+ # Middle characters
   [0-9a-z] # Last character
 
   @ # Separating @ character
 
   [0-9a-z] # Domain name begin
   [0-9a-z.-]+ # Domain name middle
   [0-9a-z] # Domain name end")
        (email-regexp "^[0-9a-z][0-9a-z.+]+[0-9a-z]@[0-9a-z][0-9a-z.-]+[0-9a-z]"))
    (cl-ppcre:scan email-regexp email)))

(defun email-satisfiesp (value)
  (or (valid-emailp value) (values nil "Please enter valid email")))

(defun user-email-uniqueness-satisfiesp (value)
  (let ((user-by-email (first (find-by-value 'user 'email value))))
    (if (and user-by-email (not (equal user-by-email (current-user))))
      (values  nil (format nil "email has already been taken, please register another one"))
      t)))

(defun registration-form-email-satisfiesp (value)
  (email-and-user-email-uniqueness-satisfiesp value))

(defun email-and-user-email-uniqueness-satisfiesp (value)
  (and (email-satisfiesp value) (user-email-uniqueness-satisfiesp value)))

(defun email-valid-and-belongs-to-real-userp (value)
  (and (valid-emailp value) (first (find-by-value 'user 'email value)) t))
