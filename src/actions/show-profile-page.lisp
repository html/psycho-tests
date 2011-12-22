(in-package :test6)

(defun/cc show-profile-page (&rest args)
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
          (render-widget (make-instance 'datagrid :data-class 'test-result :view 'test-result-table-view))
          (with-yaclml 
            (<:h1 "People tested"))
          (render-widget (make-instance 'datagrid :data-class 'responder :view 'responder-table-view)))))))


