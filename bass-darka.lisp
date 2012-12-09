(defpackage #:bass-darka-test
  (:use :cl))

(in-package :bass-darka-test)


(defvar *qualities* '(physical indirect irritability negativity resentment suspicion verbal guilt))
(defvar *answers-ratings* 
  '(
    physical (1 25 31 41 48 55 62 68)
    physical-reverse (9 7)

    indirect (2 10 18 34 42 56 63)
    indirect-reverse (26 49)

    irritability (3 19 27 43 50 57 64 72)
    irritability-reverse (11 35 69)
    
    negativity (4 12 20 28)
    negativity-reverse (36)

    resentment (5 13 21 29 37 44 51 58)

    suspicion (6 14 22 30 38 45 52 59)
    suspicion-reverse (33 66 74 75)

    verbal (7 15 23 31 46 53 60 71 73)
    verbal-reverse (33 66 74 75)

    guilt (8 16 24 32 40 47 54 61 67)))


(defun calculate (quality test-data)
  (let ((data (getf *answers-ratings* quality))
        (reverse-data (getf *answers-ratings* (intern (format nil "~A-REVERSE" (string quality))))))
    (loop for i in test-data for j from 1 if  (or 
                                                (and i (find j data))
                                                (and (not i) (find j reverse-data)))
          counting j)))

(defun do-tests ()
  (let ((test-data 
          (list nil nil nil nil nil t t t nil t t t nil t t nil t nil t nil nil nil nil t nil t nil t t nil t nil nil t t t nil t t t nil t nil t nil t nil nil nil nil nil nil nil t nil nil nil nil nil nil t nil nil t t nil nil nil t t t nil nil t t)
          ))
    (loop for i in *qualities* do 
          (format t "~A ~A~%" i (calculate i test-data))))) 
