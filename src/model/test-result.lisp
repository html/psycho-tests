(in-package :test6)

(defclass test-result ()
  ((id)
   (value :initarg :value)
   (cached-result :initform nil)
   (owner :accessor test-result-owner :initform nil :initarg :owner)
   (test-type :initform :bass-darka :initarg :test-type)
   (time-created 
     :accessor test-result-time-created 
     :initform nil 
     :initarg :time-created)))

(defmethod render-result ((model test-result))
  (render-particular-result model (slot-value model 'test-type)))

(defmethod render-particular-result ((model test-result) (test-type (eql :conflict-style)))
  (yaclml:with-yaclml-output-to-string 
    (<:b "Стиль поведінки у конфлікті") (<:hr)
    (let* ((points-groups-names (list 
                                  "Черепаха (ухиляння)"
                                  "Акула (суперництво)"
                                  "Плюшевий ведмедик (пристосування)"
                                  "Лисиця (компроміс)"
                                  "Сова (співробітництво)"))
           (points (loop for j from 0 to 4 collect 
                         (loop for k from j to 35 by 5 sum (or 
                                                             (nth k (slot-value model 'value))
                                                             0))))
           (max-points-number (apply #'max points)))
      (loop for i in points-groups-names
            for j in points do
            (<:span :style (when (= j max-points-number)
                             "font-weight:bold;color:red;")
              (<:as-is i)
              " - "
              (<:as-is j)
              (<:br))))))

(defmethod render-particular-result ((model test-result) (test-type (eql :bass-darka)))
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
              (<:b "Тест Басса Дарки")
              (<:hr)
              (loop for i in bass-darka-test::*qualities* do 
                    (<:as-is (format nil "~A ~A" (cdr (assoc i translations-ua)) (bass-darka-test::calculate i (mapcar #'not (mapcar #'null (slot-value model 'value))))))
                    (<:br)
                    
                    )) 
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
  (declare (ignore obj)))
