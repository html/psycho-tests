(defpackage #:test6-asd
  (:use :cl :asdf))

(in-package :test6-asd)

(defsystem test6
    :name "test6"
    :version "0.0.1"
    :maintainer ""
    :author ""
    :licence ""
    :description "test6"
    :depends-on (:weblocks :drakma :cl-smtp :yaclml)
    :components 
    ((:file "test6")
     (:module conf
      :components 
      ((:file "stores")
       (:file "email-settings"))
      :depends-on ("test6"))
     (:module src 
      :components 
      ((:file "init-session" :depends-on ("util" "views" "widgets" "model" "validations")) 
       (:file "util")
       (:module "actions" :components 
        ((:file "show-registration-form")
         (:file "show-login-form")
         (:file "show-profile-page"))
        :depends-on ("util"))
       (:module "model" :components 
        ((:file "user")))
       (:module "widgets" :components 
        ((:file "register-by-email")))
       (:module "views" :components 
        ((:file "register-form-views")
         (:file "login-form-views")))
       (:file "validations"))
       :depends-on ("test6" conf lib))
     (:module lib :components 
      ((:file "render-page-update")))))
