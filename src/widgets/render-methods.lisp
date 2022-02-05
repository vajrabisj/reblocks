(defpackage #:reblocks/widgets/render-methods
  (:use #:cl)
  (:import-from #:reblocks/dependencies
                #:get-collected-dependencies
                #:get-dependencies
                #:push-dependencies
                #:render-in-ajax-response)
  (:import-from #:reblocks/widget
                #:get-css-classes-as-string
                #:get-html-tag
                #:render)
  (:import-from #:reblocks/request
                #:ajax-request-p)
  (:import-from #:reblocks/html
                #:with-html)
  (:import-from #:reblocks/widgets/dom
                #:dom-id)
  (:import-from #:log))
(in-package #:reblocks/widgets/render-methods)


(defmethod render (widget)
  "By default, widget rendered with a text, suggesting to define a rendering method."
  (let ((class-name (class-name (class-of widget))))
    (with-html
      (:p "Please, define:"
          (:pre (format nil
                        "(defmethod reblocks/widget:render ((widget ~a))
    (reblocks/html:with-html
        (:p \"My ~a widget\")))"
                        class-name
                        class-name))))))


(defmethod render :around (widget)
  "This function is intended for internal usage only.
   It renders widget with surrounding HTML tag and attributes."
  (check-type widget reblocks/widget:widget)
  (log:debug "Rendering widget" widget "with" (get-collected-dependencies))
  
  (let ((widget-dependencies (get-dependencies widget)))
    ;; Update new-style dependencies
    (push-dependencies widget-dependencies)
    
    (when (ajax-request-p)
      ;; Generate code to embed new dependencies into the page on the fly
      (mapc #'render-in-ajax-response
            widget-dependencies)))
  
  (with-html
    (:tag
     :name (get-html-tag widget)
     :class (get-css-classes-as-string widget)
     :id (dom-id widget)
     (call-next-method))))


