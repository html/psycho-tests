(in-package :test6)

;;; Multiple stores may be defined. The last defined store will be the
;;; default.
(defstore *test6-store* :prevalence
  (merge-pathnames (make-pathname :directory '(:relative "data"))
       (asdf-system-directory :test6)))
