#+xcvb (module ())

(in-package #:cl-user)

(defpackage #:fare-matcher
  (:use #:xcvb-utils #:common-lisp)
  (:export #:match #:ifmatch #:ematch
	   #:_ ;;; #:*
	   #:like-when #:value #:of-type
	   #:slot* #:accessor* #:instance
	   ;;; #:quote #:when #:or #:and #:values
	   ;;; #:cons #:list #:list* #:vector #:satisfies
	   #:letm #:ifm
	   #:define-symbol-matcher
	   #:define-macro-matcher
	   #:define-function-matcher
	   #:define-constructor-matcher
	   #:define-varary-constructor-matcher
	   #:copy-symbol-matcher #:copy-symbol-and-matcher
	   #:copy-function-matcher #:copy-function-and-matcher
	   #:pattern-matcher
	   #:merge-matcher-variables
	   #:m%and #:m%fail #:m%when #:m%values)
  (:documentation
   "Lisp2-style Erlang/ML-like Pattern-Matcher for Common LISP")
  (:export))

(defpackage #:fare-clos-match
  #+openmcl (:shadowing-import-from #:ccl #:quit)
  (:use #:common-lisp #:fare-utils #:fare-matcher
        #+allegro #:aclmop
	#+cmu #:pcl #+sbcl #:sb-mop #+clisp :clos #+clozure #:ccl)
  (:export #:simple-load-form #:class-initarg-to-slot
	   #:instance))
