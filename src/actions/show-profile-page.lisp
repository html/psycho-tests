(in-package :test6)


(defun render-grid-with-group-filter (&key grid group-class edit-groups-action edit-groups-action-title title-callback)
  (let ((responders-grid-widget grid))
    (with-yaclml
      (<:div :class "badges"
             (dolist (i (all-of group-class))
               (<:div :class "outer-badge"
                      (render-widget 
                        (make-instance 'check-button-with-group-id 
                                       :group-id (object-id i)
                                       :title (funcall title-callback i) 
                                       :state :checked 
                                       :state-callbacks (list 
                                                          :checked (lambda (widget)
                                                                     (pushnew (object-id i) (responders-grid-groups-displayed responders-grid-widget))) 
                                                          :unchecked (lambda (widget) 
                                                                       (setf (responders-grid-groups-displayed responders-grid-widget)
                                                                             (remove 
                                                                               (slot-value widget 'group-id) 
                                                                               (responders-grid-groups-displayed responders-grid-widget)))))))))
             (<:div :class "outer-badge"
                    (render-widget 
                      (make-instance 'check-button 
                                     :title "Ungrouped" 
                                     :state :checked 
                                     :state-callbacks (list 
                                                        :checked (lambda (&rest args)
                                                                   (setf (responders-grid-display-ungroupedp responders-grid-widget) t))
                                                        :unchecked (lambda (&rest args)
                                                                     (setf (responders-grid-display-ungroupedp responders-grid-widget) nil))))))
             (when (and edit-groups-action edit-groups-action-title)
               (<:div :class "outer-badge edit-link"
                    (render-link edit-groups-action edit-groups-action-title))))
      (<:div :style "clear:both")))) 

(defwidget testing-results-navigation (navigation)
           ())

(defmethod render-widget-body ((widget testing-results-navigation) &rest args)
  (declare (ignore args)))

(defun make-testing-results-page (&rest args)
  (let ((grid (make-instance 'test-results-grid 
                             :allow-add-p nil
                             :data-class 'test-result 
                             :drilldown-type :data
                             :item-data-view 'test-result-data-view
                             :item-form-view 'test-result-form-view
                             :view 'test-result-table-view)))
    (make-navigation "add-test-nav"
                     (list "!!"  
                           (make-instance 
                             'composite :widgets
                             (list 
                               (lambda (&rest args)
                                 (with-yaclml
                                   (<:div :style "float:right"
                                          (<:as-is (render-inline-link *logout-action* "Logout"))) 
                                   (<:h1 "Results of testing")
                                   (if (weblocks-utils:first-of 'responder)
                                     (<:a :href "/testing-results/do-test" :class "btn btn-primary"
                                          (<:i :class "icon-plus-sign icon-white")
                                          (<:as-is "&nbsp;Add test result"))
                                     (<:div :class "alert"
                                            "Please add some people to database to begin testings"))
                                   (<:div :class "clearfix")
                                   (<:br)))
                               grid))
                           nil)
                     (list 
                       "Do test"
                       (make-instance 'funcall-widget 
                                      :fun-designator #'test-action)
                       "do-test")
                     :navigation-class 'testing-results-navigation)))

(defun make-people-tested-page ()
  (let ((grid (make-instance 'responders-grid 
                             :data-class 'responder 
                             :view 'responder-table-view 
                             :new-item-form-view 'new-responder-form-view
                             :item-form-view 'responder-form-view)))
    (make-instance 
      'composite :widgets 
      (list 
        (lambda (&rest args)
          (with-yaclml 
            (<:div :style "float:right"
                   (<:as-is (render-inline-link *logout-action* "Logout"))) 
            (<:h1 "People tested"))
          (render-grid-with-group-filter 
            :title-callback #'group-name
            :group-class 'group
            :grid grid))
        grid))))

(defun show-profile-page (&rest args)
  (require-login nil 
    (register-event "show-profile-page")
    (do-page 
      (list 
        (lambda (&rest args)
          (with-yaclml 
            (<:br)))
        (make-navigation 
          "left-menu" 
          (list "People tested" (make-people-tested-page) "people-tested")
          (list "Testing results" (make-testing-results-page) "testing-results")
          :navigation-class 'main-navigation)))))


