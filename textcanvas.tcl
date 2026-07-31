proc tc_destroy {w} {
	set wtc "$w-canvas"
	destroy $wtc
}

proc tc_ins {w pos txt tags} {
	set wtc "$w-canvas"
	switch $pos {
	"end" {
		set coords {}
		catch { set coords $::tc($wtc,lastcoords) }
		if { $coords == {} } {
			set coords [list 0 0 $::tc($wtc,lw) ]
		}
		$wtc create text $coords -width $::tc($wtc,lw) -fill $::tc($wtc,fc) -text "$txt" -tags $tags
		return
	}
	default {
		log_puts "ERR" "tc_ins $w insert pos $pos not implemented"	
		return
	}
	}
}

proc tc_xvw {w pos} {
	set wtc "$w-canvas"
	switch $pos {
	}
}

proc tc_yvw {w pos} {
	set wtc "$w-canvas"
	switch $pos {
	}
}

proc tc_cnf {w tag opts} {
	set wtc "$w-canvas"

}

proc tc_bnd {w tag event action} {
	set wtc "$w-canvas"

}

proc textcanvas args {
	set w [lindex $args 0]
	set a [lrange $args 1 end]
	set wtc "$w-canvas"

	canvas $wtc {*}$a

	proc "::$w" args {
		if {[lindex $args 0] == "insert"} {
			tc_ins $w {*}[lrange $args 1 end]
		}	
		if {[lindex $args 0] == "xview"} {
			tc_xvw $w [lindex $args 1]	
		}	
		if {[lindex $args 0] == "yview"} {
			tc_yvw $w [lindex $args 1]	
		}	
		if {[lrange $args 0 1] == {tag configure} } {
			tc_cnf $w {*}[lrange $args 2 end]
		}	
		if {[lrange $args 0 1] == {tag bind} } {
			tc_bnd $w {*}[lrange $args 2 end]
		}	
	}
}
