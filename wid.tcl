proc wbutton args {
	if { $::options(ttk_button) != 1 } {
		return [button {*}$args]
	}
	set w [lindex $args 0]
	if { $w == {} } {
		return
	}
	set a [lrange $args 1 end]
	set na {}
	set t {}
	catch { set t [dict get $a "-text"] }
	if { $t != {} } {
		lappend na {-text} $t
	}
	set t {}
	catch { set t [dict get $a "-textvariable"] }
	if { $t != {} } {
		lappend na {-textvariable} $t
	}
	set cmd {}
	catch { set cmd [dict get $a "-command"] }
	if { $cmd != {} } {
		lappend na {-command} $cmd
	}
	set wd {}
	catch { set wd [dict get $a "-width"] }
	if { $wd != {} } {
		lappend na {-width} $wd
	}
	ttk::button $w {*}$na 
}

proc wscrollbar args {
	if { $::options(ttk_scrollbar) != 1 } {
		return [scrollbar {*}$args]
	}
	set w [lindex $args 0]
	if { $w == {} } {
		return
	}
	set a [lrange $args 1 end]
	set o {}
	set cmd {}
	catch { set o [dict get $a "-orient"] }
	catch { set cmd [dict get $a "-command"] }
	set l {}
	lappend l $w
	if { $o != {} } {
		lappend l -orient $o
	}
	lappend l -command $cmd
	ttk::scrollbar {*}$l 
}

proc wentry args {
	if { $::options(ttk_entry) != 1 } {
		return [entry {*}$args]
	}
	set w [lindex $args 0]
	if { $w == {} } {
		return
	}
	set a [lrange $args 1 end]
	set t {}
	set wd {}
	catch { set t [dict get $a "-textvar"] }
	if { $t == {} } {
	catch { set t [dict get $a "-textvariable"] }
	}
	catch { set wd [dict get $a "-width"] }
	if { $t == {} } {
	return
	}
	set l $w 
	if { $wd != {} } {
	lappend l -width $wd
	}
	lappend l -textvar $t
	ttk::entry {*}$l
}

proc wlabel args {
	if { $::options(ttk_label) != 1 } {
		return [label {*}$args]
	}
	set w [lindex $args 0]
	if { $w == {} } {
		return
	}
	set a [lrange $args 1 end]
	set af {}
	foreach {key val} $a {
		set f {}
		append f [lsearch -all -inline $key "*color*"]
		append f [lsearch -all -inline $key "*foreground*"]
		append f [lsearch -all -inline $key "*background*"]
		append f [lsearch -all -inline $key "*thickness*"]
		if { $f == {} } {
			lappend af $key $val
		}
	}
	ttk::label $w {*}$af
}

proc wpanedwindow args {
	if { $::options(ttk_panedwindow) != 1 } {
		return [label {*}$args]
	}
	set w [lindex $args 0]
	if { $w == {} } {
		return
	}
	set a [lrange $args 1 end]
	set af {}
	foreach {key val} $a {
		set f {}
		append f [lsearch -all -inline $key "*color*"]
		append f [lsearch -all -inline $key "*foreground*"]
		append f [lsearch -all -inline $key "*background*"]
		append f [lsearch -all -inline $key "*thickness*"]
		if { $f == {} } {
			lappend af $key $val
		}
	}
	ttk::panedwindow $w {*}$af
}

proc wframe args {
	if { $::options(ttk_frame) != 1 } {
		return [label {*}$args]
	}
	set w [lindex $args 0]
	if { $w == {} } {
		return
	}
	set a [lrange $args 1 end]
	set af {}
	foreach {key val} $a {
		set f {}
		append f [lsearch -all -inline $key "*color*"]
		append f [lsearch -all -inline $key "*foreground*"]
		append f [lsearch -all -inline $key "*background*"]
		append f [lsearch -all -inline $key "*thickness*"]
		if { $f == {} } {
			lappend af $key $val
		}
	}
	ttk::frame $w {*}$af
}

proc ttk_style {} {
	if { $::tcl_platform(os) != {Darwin} } {
	source "./contrib/keramik/keramik.tcl"
	ttk::style theme use keramik 
	} elseif { [wm attributes . -isdark] } {
	source "./contrib/keramik_dark/keramik_dark.tcl"
	ttk::style theme use keramik_dark 
	} else {
	source "./contrib/keramik/keramik.tcl"
	ttk::style theme use keramik 
	}
}

ttk_style
