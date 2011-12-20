(defpackage #:test6
  (:use :cl :weblocks
        :f-underscore :anaphora)
  (:import-from :hunchentoot #:header-in
    #:set-cookie #:set-cookie* #:cookie-in
    #:user-agent #:referer)
  (:documentation
   "A web application based on Weblocks."))

(in-package :test6)

(export '(start-test6 stop-test6))

;; A macro that generates a class or this webapp

(defwebapp test6
    :prefix "/" 
    :description "test6: A new application"
    :init-user-session 'test6::init-user-session
    :autostart nil                   ;; have to start the app manually
    :ignore-default-dependencies nil ;; accept the defaults
    :debug t
    )   

;; Top level start & stop scripts

(defun start-test6 (&rest args)
  "Starts the application by calling 'start-weblocks' with appropriate arguments."
  (apply #'start-weblocks args)
  (start-webapp 'test6))

(defun stop-test6 ()
  "Stops the application by calling 'stop-weblocks'."
  (stop-webapp 'test6)
  (stop-weblocks))
