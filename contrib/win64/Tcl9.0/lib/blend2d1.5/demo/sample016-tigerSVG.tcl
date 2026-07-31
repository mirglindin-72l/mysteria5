#
# Blend2d - Tiger demo
#   using BL::Svgdoc
#

package require Blend2d 

set thisDir [file normalize [file dirname [info script]]]


# doPaint
# use global parameters:
#   TigerSVG  : the BL::Svgdoc instance
#   TigerRect : the bounding box (..rect!) of TigerSVG
#   SFC       : the BL::Surface
#   ZOOM        ZOOM is relative to the window (i.e. ZOOM 0.5 -> half window size)
#   ANGLE        ANGLE in degrees
proc doPaint {args} {
	 # ignore any arg  (added by trace or by widgets callbacks..)
	global SFC
	global ZOOM
	global ANGLE
	global TigerSVG
	global TigerRect

	lassign [$SFC size] WIDTH HEIGHT

	$SFC clear -style 0xFFCD0532

$SFC push
	$SFC configure -matrix [Mtx::translation [expr {$WIDTH/2}] [expr {$HEIGHT/2}]]

	lassign $TigerRect _ _ tdx tdy
	set s [expr {min( $WIDTH/$tdx , $HEIGHT/$tdy) * $ZOOM}]

	$SFC applyTransform [Mtx::scale $s]
	$SFC applyTransform [Mtx::rotation $ANGLE degrees]

	$SFC paint $TigerSVG -anchor CENTER
$SFC pop
}

proc BBoxToRect {bbox} {
	lassign $bbox x0 y0 x1 y1
	return [list $x0 $y0 [expr {$x1-$x0}] [expr {$y1-$y0}]]
}

proc ttkScaleWithLabel {w -label labelTxt args} {
	frame $w
	label $w.label -text $labelTxt
	ttk::scale $w.scale {*}$args
	pack $w.label $w.scale
}

# == MAIN =====
wm title . "\"Blend2d\" high performance 2D vector graphics engine - TclTk bindings"

set ANGLE 0.0  ;# degrees
set ZOOM 1.0

set SFC [image create blend2d -format {500 500}]

 # WARNING: remove any decoration from the container, or the <Configure> handler will resize the image indefinitely !
label .cvs -image $SFC -borderwidth 0 -padx 0 -pady 0
frame .controls

.controls configure  -width 200 -pady 20 -padx 10
pack .controls -side left -expand 0 -fill y
pack propagate .controls false

pack .cvs -expand 1 -fill both

 # these scale-widgets simply set the global vars ANGLE and ZOOM;
 # These variable are traced, so that each change will trigger a doPaint
ttkScaleWithLabel .controls.rotate -label Rotate -from 0 -to 360 -orient horizontal -variable ANGLE
ttkScaleWithLabel .controls.zoom   -label Zoom   -from 0.1 -to 8.0 -orient horizontal -variable ZOOM
foreach w [winfo children .controls] {
	pack $w
}

trace add variable ANGLE write doPaint
trace add variable ZOOM  write doPaint

bind .cvs <Configure> {
	set w %w
	set h %h
	$SFC reset
	$SFC configure -format [list $w $h]
	doPaint
}

 # ----------------------------------------------------------------

 # load the tiger-data
set TigerSVG [BL::Svgdoc new $thisDir/images/Ghostscript_Tiger.svg]
set TigerRect [BBoxToRect [$TigerSVG bbox]]

doPaint
