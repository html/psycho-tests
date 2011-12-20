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
    :depends-on (:weblocks)
    :components ((:file "test6")
     (:module conf
      :components ((:file "stores"))
      :depends-on ("test6"))
     (:module src 
      :components ((:file "init-session"))
      :depends-on ("test6" conf))))
