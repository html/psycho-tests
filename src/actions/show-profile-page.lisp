(in-package :test6)


(defun render-grid-with-group-filter (&key grid group-class edit-groups-url edit-groups-action-title title-callback)
  (let ((responders-grid-widget grid))
    (with-yaclml
      (<:div :class "badges"
             (dolist (i (current-user-groups group-class))
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
             (when (and edit-groups-url edit-groups-action-title)
               (<:div :class "outer-badge edit-link"
                    (<:a :href edit-groups-url (<:as-is edit-groups-action-title)))))
      (<:div :style "clear:both")))) 

(defun make-testing-results-page (&rest args)
  (let ((grid (make-instance 'test-results-grid 
                             :allow-add-p nil
                             :on-query (lambda (grid sort some  &rest args &key countp) 
                                         (let ((records (find-by 'test-result 
                                                                 (lambda (item)
                                                                   (equal 
                                                                     (slot-value (test-result-owner item) 'owner)
                                                                     (current-user)))
                                                                 :order-by sort 
                                                                 :range some)))
                                           (if countp 
                                             (length records)
                                             records)))
                             :data-class 'test-result 
                             :drilldown-type :data
                             :item-data-view 'test-result-data-view
                             :item-form-view 'test-result-form-view
                             :view 'test-result-table-view)))
    (setf (pagination-items-per-page (dataseq-pagination-widget grid)) 5)
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
                                   (if (weblocks-utils:first-by-values 'responder :owner (current-user))
                                     (<:a :href (make-webapp-uri "/testing-results/do-test") :class "btn btn-primary"
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
                     :navigation-class 'invisible-navigation)))

(defun make-people-tested-page ()
  (let ((grid (make-instance 'responders-grid 
                             :data-class 'responder 
                             :view 'responder-table-view 
                             :new-item-form-view 'new-responder-form-view
                             :item-form-view 'responder-form-view)))
    (make-navigation 
      "people-tested-inner"
      (list "!!"
            (make-instance 
              'composite :widgets 
              (list 
                (lambda (&rest args)
                  (with-yaclml 
                    (<:div :style "float:right"
                           (<:as-is (render-inline-link *logout-action* "Logout"))) 
                    (<:h1 "People tested"))
                  (render-grid-with-group-filter 
                    :edit-groups-action-title "Edit groups"
                    :edit-groups-url (make-webapp-uri "/people-tested/edit-groups")
                    :title-callback #'group-name
                    :group-class 'group
                    :grid grid))
                grid)) nil)
      (list "Edit groups" #'edit-people-groups "edit-groups")
      :navigation-class 'invisible-navigation)))

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
          (list "" (lambda (&rest args)
                     (redirect (make-webapp-uri "people-tested") :defer nil)) nil)
          (list "People tested" (make-people-tested-page) "people-tested")
          (list "Testing results" (make-testing-results-page) "testing-results")
          :navigation-class 'main-navigation)))))


