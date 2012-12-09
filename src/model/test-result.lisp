(in-package :test6)

(defclass test-result ()
  ((id)
   (value :initarg :value)
   (cached-result :initform nil)
   (owner :accessor test-result-owner :initform nil :initarg :owner)
   (time-created 
     :accessor time-created 
     :initform (get-universal-time))))

(defmethod render-result ((model test-result))
  (let ((translations 
          (list 
            (cons 'bass-darka-test::physical "Physical agression")
            (cons 'bass-darka-test::indirect "Indirect agression")
            (cons 'bass-darka-test::irritability "Irritability")
            (cons 'bass-darka-test::negativity "Negativity")
            (cons 'bass-darka-test::resentment "Resentment")
            (cons 'bass-darka-test::suspicion "Suspicion")
            (cons 'bass-darka-test::verbal "Verbal agression")
            (cons 'bass-darka-test::guilt "Guilt")))
        (translations-ua 
          (list 
            (cons 'bass-darka-test::physical "Фізична агресія")
            (cons 'bass-darka-test::indirect "Непряма агресія")
            (cons 'bass-darka-test::irritability "Роздратування")
            (cons 'bass-darka-test::negativity "Негативізм")
            (cons 'bass-darka-test::resentment "Образа")
            (cons 'bass-darka-test::suspicion "Підозрілість")
            (cons 'bass-darka-test::verbal "Вербальна агресія")
            (cons 'bass-darka-test::guilt "Відчуття вини")))
        (clean-result (mapcar #'not (mapcar #'null (slot-value model 'value)))))
    (format nil "~A ~A"
            (yaclml:with-yaclml-output-to-string
              (loop for i in bass-darka-test::*qualities* do 
                    (<:br)
                    (<:as-is (format nil "~A ~A" (cdr (assoc i translations-ua)) (bass-darka-test::calculate i (mapcar #'not (mapcar #'null (slot-value model 'value)))))))) 
            (yaclml:with-yaclml-output-to-string 
              (<:hr)
              (<:div 
                "Ворожість - " 
                (<:as-is (write-to-string 
                           (+ (bass-darka-test::calculate 'bass-darka-test::resentment clean-result) (bass-darka-test::calculate 'suspicion clean-result)))))
              (<:div 
                "Агресивність - " 
                (<:as-is (write-to-string 
                           (+ 
                             (bass-darka-test::calculate 'bass-darka-test::physical clean-result)
                             (bass-darka-test::calculate 'bass-darka-test::irritability clean-result)
                             (bass-darka-test::calculate 'bass-darka-test::verbal clean-result))))
                ))))) 

(defmethod groups-ids ((obj test-result))
  (mapcar #'object-id (mapcar #'test-result-testing-test-result (find-by-value 'test-result-testing 'test-result obj))))
