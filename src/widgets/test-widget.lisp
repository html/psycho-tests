(in-package :weblocks)

(defmethod render-view-field :around ((field form-view-field) (view form-view)
			      widget (presentation radio-presentation) value obj 
			      &rest args &key validation-errors field-info &allow-other-keys)
  (declare (special *presentation-dom-id*))

  ;(return-normal-value-when-theme-not-used render-view-field)

  (let* ((attributized-slot-name (if field-info
                                   (attributize-view-field-name field-info)
                                   (attributize-name (view-field-slot-name field))))
	 (validation-error (assoc field validation-errors))
	 (field-class (concatenate 'string (arnesi:aif attributized-slot-name attributized-slot-name "")
				   (when validation-error " item-not-validated") " control-group row-fluid"))
         (*presentation-dom-id* (gen-id)))
    (with-html
      (:div :class field-class
       (:label :class (format nil 
                              "~A control-label span6"(attributize-presentation
                                                  (view-field-presentation field)))
               :for *presentation-dom-id*
               (:span :class "slot-name"
                (:span :class "extra"
                 (unless (cl-containers:empty-p (view-field-label field))
                   (str (view-field-label field))
                   (str ":&nbsp;"))
                 (let ((required-indicator (weblocks::form-view-field-required-indicator field)))
                   (when (and (form-view-field-required-p field)
                              required-indicator)
                     (htm (:em :class "required-slot text-warning"
                           (if (eq t required-indicator)
                             (str *default-required-indicator*)
                             (str required-indicator))
                           (str "&nbsp;"))))))))
       (:div :class (format nil "span6 controls ~A" (when validation-error "warning"))
        (apply #'render-view-field-value
               value presentation
               field view widget obj
               :field-info field-info
               args)
        (when validation-error
          (htm (:p :class "help-inline"
                (str (format nil "~A" (cdr validation-error)))))))))))

(in-package :test6)

(defun get-test-questions ()
  (with-open-file (str "test-data.txt")
    (loop for line = (read-line str nil) 
          while line 
          collect (string-trim '(#\Space #\Tab #\Newline) line))))


(defun get-view-fields-by-test-questions ()
  (loop for i in (get-test-questions) 
        for j from 1 
        collect (list (intern (format nil "QUESTION-~A" j)) :present-as 'checkbox :label i)))

(defun get-conflict-style-test-questions ()
  (with-open-file (str "conflict-style-test-data.txt")
    (loop for line = (read-line str nil) 
          while line 
          collect (string-trim '(#\Space #\Tab #\Newline) line))))

(defun get-choices-captions ()
  (with-open-file (str "conflict-style-choices-captions.txt")
    (loop for line = (read-line str nil) 
          while line 
          collect (string-trim '(#\Space #\Tab #\Newline) line))))

(defun get-view-fields-for-conflict-test ()
  (let ((choices (get-choices-captions)))
    (loop for i in (get-conflict-style-test-questions)
          for j from 1
          collect `(,(intern (format nil "QUESTION-~A" j)) 
                    :present-as (radio 
                                  :choices 
                                  (list ,@(loop for i from 5 downto 1 for j in choices 
                                                collect `(cons ,j ,i)))) 
                    :requiredp t
                    :required-indicator nil
                    :label ,i))))

(mustache:defmustache test-view 
                      (yaclml:with-yaclml-output-to-string 
                        (<:h1 "Test")
                        "{{{form-validation-summary}}}"
                        (<:div 
                          (<:ul :class "unstyled test-list" "{{{form-body}}}"))
                        (<:div "{{{form-view-buttons}}}")))

(defun dataform-data-to-value-for-bass-darka-test (data)
  (loop for i from 1 to 75 
        collect (slot-value 
                  data
                  (intern (format nil "QUESTION-~A" i)))))

(defun dataform-data-to-value-for-conflict-style-test (data)
  (loop for i from 1 to 35 
        collect (parse-integer 
                  (slot-value 
                  data
                  (intern (format nil "QUESTION-~A" i))))))

(defun nav-root-widget ()
  (first (widget-children (get-widget-by-id "add-test-nav"))))

(defun/cc do-choice-without-modal (msg choices &key (method :post) (css-class "") (title "Select Option"))
          (let* ((pane (nav-root-widget)))
            (do-widget 
              pane
              (make-widget
                (metatilities:curry (ecase method
                                      (:get #'weblocks::render-choices-get)
                                      (:post #'weblocks::render-choices-post))
                                    msg choices)))))

(defun make-add-test-form (choice)
  (make-instance 
    'simpleform 
    :on-success (lambda (form)
                  (let ((responder 
                          (first (find-by-value 'responder 'id (parse-integer (slot-value (dataform-data form) 'responder))))))
                    (persist-object 
                      *default-store*
                      (make-instance 'test-result 
                                     :test-type choice
                                     :owner responder
                                     :time-created (get-universal-time)
                                     :value (funcall 
                                              (if (equal choice :bass-darka)
                                                #'dataform-data-to-value-for-bass-darka-test 
                                                #'dataform-data-to-value-for-conflict-style-test) 
                                              (dataform-data form))))) 
                  (setf (dataform-ui-state form) :form)
                  (answer #'test-action t)
                  (redirect "/testing-results"))
    :on-cancel (lambda (form)
                 (answer #'test-action nil)
                 (redirect "/testing-results")
                 (throw 'annihilate-dataform nil))
    :dom-class (string-downcase choice)
    :form-view (eval 
                 `(defview-anon 
                    (:type mustache-template-form 
                     :template #'test-view
                     :persistp nil)
                    (responder :present-as (select :options (loop for i in (find-by-values 'responder :owner (current-user))
                                                                  collect (list (object-id i) (responder-name i)))) 
                               :requiredp t
                               :satisfies (lambda (value)
                                            (find-by-value 'responder 'id (parse-integer value))))
                    ,@(if (equal choice :bass-darka)
                        (get-view-fields-by-test-questions)
                        (get-view-fields-for-conflict-test))))))

(defun/cc test-action  (&rest args)
  (let ((choice (do-choice-without-modal "Please choose test type" (list :bass-darka 
                                                             :conflict-style 
                                                             ) :css-class "modal fade in")))
    (do-widget (nav-root-widget) (make-add-test-form choice))))
