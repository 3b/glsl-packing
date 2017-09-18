(in-package #:glsl-packing)

;; some convenience functions for translating from glsl-style names to
;; expanded types

(defparameter *base-types*
  (alexandria:plist-hash-table
   `(:void (:void)
     :bool (:bool)
     :float16 (:float 16)
     :float32 (:float 32)
     :float64 (:float 64)
     :float (:float 32)
     :double (:float 64)
     :int (:int 32)
     :uint (:uint 32)
     ,@(loop for b in `(8 16 32 64)
             collect (alexandria:format-symbol :keyword "INT~a" b)
             collect `(:int ,b)
             collect (alexandria:format-symbol :keyword "UINT~a" b)
             collect `(:uint ,b))
     ,@(loop for i from 2 to 4
             collect (alexandria:format-symbol :keyword "BVEC~a" i)
             collect `(:vec (:bool) ,i)
             collect (alexandria:format-symbol :keyword "IVEC~a" i)
             collect `(:vec (:int 32) ,i)
             collect (alexandria:format-symbol :keyword "UVEC~a" i)
             collect `(:vec (:uint 32) ,i)
             append (loop for b in `(8 16 64)
                          collect (alexandria:format-symbol :keyword
                                                            "I~aVEC~a" b i)
                          collect `(:vec (:int ,b) ,i)
                          collect (alexandria:format-symbol :keyword
                                                            "U~aVEC~a" b i)
                          collect `(:vec (:uint ,b) ,i))
             collect (alexandria:format-symbol :keyword "F16VEC~a" i)
             collect `(:vec (:float 16) ,i)
             collect (alexandria:format-symbol :keyword "VEC~a" i)
             collect `(:vec (:float 32) ,i)
             collect (alexandria:format-symbol :keyword "DVEC~a" i)
             collect `(:vec (:float 64) ,i))
     :mat2 (:mat (:float 32) 2 2)
     :mat3 (:mat (:float 32) 3 3)
     :mat4 (:mat (:float 32) 4 4)
     :dmat2 (:mat (:float 64) 2 2)
     :dmat3 (:mat (:float 64) 3 3)
     :dmat4 (:mat (:float 64) 4 4)
     ,@ (loop for r from 2 to 4
              append (loop for c from 2 to 4
                           collect (alexandria:format-symbol :keyword
                                                             "F16MAT~aX~a" c r)
                           collect `(:mat (:float 16) ,c ,r)
                           collect (alexandria:format-symbol :keyword
                                                             "MAT~aX~a" c r)
                           collect `(:mat (:float 32) ,c ,r)
                           collect (alexandria:format-symbol :keyword
                                                             "DMAT~aX~a" c r)
                           collect `(:mat (:float 64) ,c ,r)))
        ;; treating sampler types as uint64 for now...
        ,@ (loop for s in '(:sampler-1d :sampler-2d :sampler-3d :sampler-cube
                            :sampler-1d-shadow :sampler-2d-shadow
                            :sampler-cube-shadow :sampler-cube-array
                            :sampler-cube-array-shadow :sampler-2d-rect
                            :sampler-2d-rect-shadow :sampler-1d-array
                            :sampler-2d-array :sampler-1d-array-shadow
                            :sampler-2d-array-shadow :sampler-buffer
                            :sampler-2d-ms :sampler-2d-ms-array
                            :isampler-1d :isampler-2d :isampler-3d
                            :isampler-cube :isampler-cube-array
                            :isampler-2d-rect :isampler-1d-array
                            :isampler-2d-array :isampler-buffer
                            :isampler-2d-ms :isampler-2d-ms-array
                            :usampler-1d :usampler-2d :usampler-3d
                            :usampler-cube :usampler-cube-array
                            :usampler-2d-rect :usampler-1d-array
                            :usampler-2d-array :usampler-buffer
                            :usampler-2d-ms :usampler-2d-ms-array)
                 collect s
                 collect '(:uint 64)))))

(defun expand-glsl-type (type &key (default type))
  (etypecase type
    (type-description
     type)
    (cons
     (list* :array
            (expand-glsl-type (first type))
            (if (eql (second type) :*)
                '*
                (second type))
            (cddr type)))
    (symbol
     (gethash type *base-types* default))))

(defun expand-glsl-types (slots)
  "Expand glsl types like :vec4 to style expected by pack-structs in
list of slot definitions. Types of the form (TYPE X) are treated as
arrays, with dimension X, where * or :* means unspecified size."
  (loop for (name type . rest) in slots
        collect (list* name (expand-glsl-type type) rest)))
