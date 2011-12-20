(in-package :weblocks)

(defmethod render-page :around ((app weblocks-webapp))
  "Default page rendering template and protocol"
  ; Note, anything that precedes the doctype puts IE6 in quirks mode
  ; (format *weblocks-output-stream* "<?xml version=\"1.0\" encoding=\"utf-8\" ?>")
  (declare (special weblocks::*page-dependencies*))
  (pushnew (make-local-dependency :stylesheet "debug-toolbar") weblocks::*page-dependencies*)
  (pushnew (make-local-dependency :script "weblocks-debug") weblocks::*page-dependencies*)
  (let ((rendered-html (get-output-stream-string *weblocks-output-stream*))
        (all-dependencies (weblocks::timing "compact-dependencies"
                                            (weblocks::compact-dependencies 
                                              (append 
                                                (weblocks::webapp-application-dependencies)
                                                weblocks::*page-dependencies*)))))
    (with-html-output (*weblocks-output-stream* nil :prologue t)
                      (:html :xmlns "http://www.w3.org/1999/xhtml"
                             (:head
                               (:title (str (application-page-title app)))
                               (render-page-headers app)
                               (mapc #'render-dependency-in-page-head all-dependencies))
                             (:body 
                                    (render-page-body app rendered-html)
                                    (when (weblocks::weblocks-webapp-debug app)
                                      (render-debug-toolbar))
                                    (:div :id "ajax-progress" "&nbsp;"))))))
