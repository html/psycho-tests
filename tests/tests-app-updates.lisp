(in-package :test6)

(start-webapp 
  'test6
  :prefix "/test6"
  :dependencies (list 
                  (make-instance 'stylesheet-dependency :url "/test6/pub/stylesheets/main.css")
                  (make-instance 'script-dependency :url "/test6/pub/scripts/weblocks-jquery.js")
                  (make-instance 'script-dependency :url "/test6/pub/scripts/jquery-seq.js")))
