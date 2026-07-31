set thisDir [file normalize [file dirname [info script]]]
set auto_path [linsert $auto_path 0 [file dirname $thisDir]]

# --sample08 - demo

package require Blend2d 1.3.2

set sfc [image create blend2d -format {500 500} ]
label .x -image $sfc ; pack .x

 # move origin at the surface center
$sfc applyTransform [Mtx::translation 250 250]

set stops {0.0 0xFFFFFFFF  0.5 0xFF5FAFDF  1.0 0xFFFFFFFF}

set gradient [BL::gradient CONIC {0 0 0} $stops]
$sfc fill all -style $gradient

set gradient [BL::gradient CONIC {0 0 0} $stops -matrix [Mtx::rotation 180 degrees]]
$sfc fill [BL::circle {0 0} 200] -style $gradient

set gradient [BL::gradient CONIC {0 0 0 16} $stops]
$sfc fill [BL::circle {0 0} 100] -style $gradient
