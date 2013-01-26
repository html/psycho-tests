(in-package :hunchentoot)

(defun handle-static-file (pathname &optional content-type)
  "A function which acts like a Hunchentoot handler for the file
  denoted by PATHNAME.  Sends a content type header corresponding to
  CONTENT-TYPE or \(if that is NIL) tries to determine the content type
via the file's suffix."
(when (or (wild-pathname-p pathname)
          (not (fad:file-exists-p pathname))
          (fad:directory-exists-p pathname))
  ;; file does not exist
  (setf (return-code*) +http-not-found+)
  (abort-request-handler))
(let ((time (or (file-write-date pathname)
                (get-universal-time)))
      bytes-to-send)
  (setf (content-type*) (or content-type
                            (mime-type pathname)
                            "application/octet-stream")
        (header-out :last-modified) (rfc-1123-date time)
        (header-out :accept-ranges) "bytes")
  (with-open-file (file pathname
                        :direction :input
                        :element-type 'octet)
    (setf bytes-to-send (maybe-handle-range-header file)
          (content-length*) bytes-to-send)
    (handle-if-modified-since time)
    (let ((out (send-headers))
          (buf (make-array +buffer-length+ :element-type 'octet)))
      (loop
        (when (zerop bytes-to-send)
          (return))
        (let* ((chunk-size (min +buffer-length+ bytes-to-send)))
          (unless (eql chunk-size (read-sequence buf file :end chunk-size))
            (error "can't read from input file"))

          (when (string= "css" (pathname-type pathname))
            #+l(with-open-file (out "/home/oz/debug.txt" :direction :output :if-does-not-exist :create :if-exists :append)
                 (format out "~A~%" (and (boundp 'weblocks::*current-webapp*) weblocks::*current-webapp*))) 

            (setf buf (flexi-streams:string-to-octets 
                        (cl-ppcre:regex-replace-all 
                          "~" 
                          (flexi-streams:octets-to-string buf :external-format :utf-8)
                          "/test6")
                        :external-format :utf-8)))

          (write-sequence buf out :end chunk-size)
          (decf bytes-to-send chunk-size)))
      (finish-output out)))))
