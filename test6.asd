(defpackage #:test6-asd
  (:use :cl :asdf))

(in-package :test6-asd)

(defsystem test6
    :name "test6"
    :version "0.3.2"
    :maintainer ""
    :author ""
    :licence ""
    :description "test6"
    :depends-on (:weblocks :drakma :cl-smtp :yaclml :weblocks-twitter-bootstrap-application :weblocks-mustache-template-form-view)
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
         (:file "show-profile-page")
         (:file "edit-testings")
         (:file "edit-groups"))
        :depends-on ("util"))
       (:module "model" :components 
        ((:file "user")
         (:file "test-result")
         (:file "responder")
         (:file "group")
         (:file "testing")
         (:file "responder-group")
         (:file "test-result-testing")))
       (:module "widgets" :components 
        ((:file "register-by-email")
         (:file "test-widget" :depends-on ("main-navigation"))
         (:file "responders-grid")
         (:file "check-widget")
         (:file "test-results-grid")
         (:file "main-navigation"))
        :depends-on ("select-presentation" "views" "util"))
         (:module "views" :components 
          ((:file "register-form-views")
           (:file "login-form-views")
           (:file "test-result" :depends-on ("responder-views"))
           (:file "responder-views"))
          :depends-on ("util" "validations" "model"))
           (:file "validations")
           (:file "select-presentation" :depends-on ("util")))
           :depends-on ("test6" conf "bass-darka"))
            (:file "bass-darka")))
