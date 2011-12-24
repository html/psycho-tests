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
             (<:div :class "outer-badge edit-link"
                    (render-link edit-groups-action edit-groups-action-title)))
      (<:div :style "clear:both")) 
    (render-widget responders-grid-widget))) 

(defun show-profile-page (&rest args)
  (require-login nil 
                 (register-event "show-profile-page")
                 (do-page 
                   (list 
                     (lambda (&rest args)
                       (with-yaclml
                         (<:div :style "float:right"
                                (<:as-is (render-inline-link *logout-action* "Logout"))) 
                         (<:as-is (render-inline-link "test" "Add test result"))
                         (<:h1 "Results of testing"))
                       (render-grid-with-group-filter 
                         :title-callback #'testing-name
                         :edit-groups-action #'edit-testings
                         :edit-groups-action-title "Edit testings"
                         :group-class 'testing
                         :grid (make-instance 'test-results-grid 
                                              :data-class 'test-result 
                                              :item-form-view 'test-result-form-view
                                              :view 'test-result-table-view))
                       (with-yaclml 
                         (<:h1 "People tested"))

                       (render-grid-with-group-filter 
                         :title-callback #'group-name
                         :edit-groups-action #'edit-people-groups
                         :group-class 'group
                         :edit-groups-action-title "Edit groups"
                         :grid (make-instance 'responders-grid 
                                              :data-class 'responder 
                                              :view 'responder-table-view 
                                              :new-item-form-view 'new-responder-form-view
                                              :item-form-view 'responder-form-view)
                         ))))))


