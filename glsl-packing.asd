(defsystem :glsl-packing
  :description "calculate std140/std420 layout for a glsl UBO/SSBO"
  :license "MIT"
  :author "Bart Botta <00003b at gmail.com>"
  :depends-on (alexandria)
  :serial t
  :components ((:file "glsl-packing")))
