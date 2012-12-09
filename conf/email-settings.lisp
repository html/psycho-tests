(in-package :test6)

(defmacro define-constant (name value &optional doc)
  `(defconstant ,name (if (boundp ',name) (symbol-value ',name) ,value)
                ,@(when doc (list doc))))

(define-constant +smtp-server+ "smtp.gmail.com")
(define-constant +email-from+ "olexiy.z@gmail.com")
(define-constant +email-authentication-data+ '("olexiy.z@gmail.com" "<password here>"))
