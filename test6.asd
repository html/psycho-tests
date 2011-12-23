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
        ((:file "user")
         (:file "test-result")
         (:file "responder")
         (:file "group")
         (:file "testing")
         (:file "responder-group")))
       (:module "widgets" :components 
        ((:file "register-by-email")
         (:file "test-widget")
         (:file "responders-grid")))
       (:module "views" :components 
        ((:file "register-form-views")
         (:file "login-form-views")
         (:file "test-result")
         (:file "responder-views")))
         (:file "validations")
         (:file "select-presentation"))
       :depends-on ("test6" conf lib))
     (:module lib :components 
      ((:file "render-page-update")))))
