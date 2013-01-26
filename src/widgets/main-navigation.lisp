(in-package :test6)

(load-in-current-package "src/weblocks-mustache-yaclml-macros.lisp")
(load-in-current-package "src/weblocks-render-menu-extension.lisp")
(load-in-current-package "src/weblocks-twitter-bootstrap-tabs-mustache-templates.lisp")

(defwidget main-navigation (navigation)
           ())

(defmethod render-navigation-menu :around ((obj navigation) &rest args &key menu-args &allow-other-keys)
  (declare (ignore args))
  (apply #'render-menu-with-template (navigation-menu-items obj)
         :base (selector-base-uri obj)
         :selected-pane (static-selector-current-pane obj)
         :header (navigation-header obj)
         :container-id (dom-id obj)
         :empty-message "No navigation entries"
         :layout #'bootstrap-navigation-tabs-layout
         :item-layout #'bootstrap-navigation-tabs-item-layout
         menu-args))

(defmethod render-widget-body :before ((widget main-navigation) &rest args)
  (when (string= (request-uri-path) "/")
    (redirect (make-webapp-uri "/people-tested") :defer nil)))

