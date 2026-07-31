proc canvas_end {w} {
	$w yview moveto 1
}
proc canvas_par {w body color tags} {
	set last {}
	catch {
	set last $::cur(canvas,$w,last)
	}
	if { $last == {} } {
		set last 0
	} else {
		incr last 1
	}
	set ::cur(canvas,$w,last) $last
	set hide [lsearch -all -inline -exact $tags hide]
	lappend tags "text" "tid:$last"
	set wid [$w cget -width]
	set hei [$w cget -height]
	set gap 4
	$w yview moveto 1
	if { $hide == {} } {
	$w create text [list [expr $gap-2] [expr $gap-2]] -anchor nw -text $body -width [expr {$wid-$gap*2}] -fill black -tags $tags
	$w create text [list [expr $gap+2] [expr $gap+2]] -anchor nw -text $body -width [expr {$wid-$gap*2}] -fill black -tags $tags
	$w create text [list [expr $gap-2] [expr $gap+2]] -anchor nw -text $body -width [expr {$wid-$gap*2}] -fill black -tags $tags
	$w create text [list [expr $gap+2] [expr $gap-2]] -anchor nw -text $body -width [expr {$wid-$gap*2}] -fill black -tags $tags
	$w create text [list $gap $gap] -anchor nw -text $body -width [expr {$wid-$gap*2}] -fill $color -tags $tags
	set b [$w bbox "tid:$last"]
	set by [lindex $b 1]
	set bh [lindex $b 3]
	set toscroll [expr {$bh-$by+$gap*2}]
	$w move "tid:$last" 0 $toscroll 
	$w move "text" 0 "-$toscroll"
	$w configure -scrollregion [$w bbox "text"]
	} else {
	$w create text [list $gap $gap] -anchor nw -text $body -width [expr {$wid-$gap*2}] -fill $color -tags $tags -state hidden
	set b [$w bbox "tid:$last"]
	set by [lindex $b 1]
	set bh [lindex $b 3]
	set toscroll [expr {$bh-$by+$gap*2}]
	$w move "tid:$last" 0 $toscroll 
	$w move "text" 0 "-$toscroll"
	$w configure -scrollregion [$w bbox "text"]
	}
}
proc canvas_bgi {w img} {
	$w delete "bgi"
	set wid [$w cget -width]
	set hei [$w cget -height]
	lappend tags "bgi"
	$w create image [list 0 -$hei] -anchor nw -image $img -tags $tags
} 

proc canvas_del {w} {
	$w delete "text"
}

proc canvas_tags {tags} {
	set color {}
	set rtags {}
	foreach tag $tags {
		switch $tag {
			"red" {
				set color {#c06060}
			}
			"green" {
				set color {#60c060}
			}
			"blue" {
				set color {#6060c0}
			}
			"yellow" {
				set color {#c09060}
			}
			"magenta" {
				set color {#c060c0}
			}
			"cyan" {
				set color {#6090c0}
			}
			"white" {
				set color {#cccccc}
			}
			"gray" {
				set color {#666666}
			}
			"black" {
				set color {#000000}
			}
			default {
				lappend rtags $tag
			}
		}
	}
	if { $color == {} } {
		set color white
	}
	return [list $color $rtags]
}

proc canvas_click {w x y tag} {
	set lx [$w canvasx $x]
	set ly [$w canvasy $y]
	if { $lx == {} || $ly == {} } {
		return
	}
	set i [$w find closest $lx $ly 20]
	if { $i == {} } {
		log_puts "ERR" "canvas_click no item"
		return
	}
	set tags [$w itemcget $i -tags]
	log_puts "ALL" "canvas_click tags $tags"
	set tid [lindex [split [lsearch -all -inline $tags "tid:*"] {:}] end]
	if { $tid == {} } {
		return
	}
	set htid "tid:[expr {$tid-1}]"
	set hi [lindex [$w find withtag $htid] end]
	set htags [$w itemcget $hi -tags]
	set hcheck0 [lsearch -all -inline -exact $htags hide]
	set hcheck1 [lsearch -all -inline -exact $htags $tag]
	log_puts "ALL" "canvas_click htags $htags"
	set ret {}
	if { $hcheck0 != {} && $hcheck1 != {} } {
		log_puts "ALL" "canvas_click htid $htid hi $hi ret [string range $ret 0 40]"
		set ret [$w itemcget $hi -text]
	} else {
		log_puts "ALL" "canvas_click tid $tid i $i ret [string range $ret 0 40]"
		set ret [$w itemcget $i -text]
	}
	return $ret
}

#proc canvas_test {} {
#	set w .c
#
#	toplevel $w
#	wm title $w "Canvas test"
#	pack [panedwindow "$w.p" -ori ver] -fill both -expand 1
#	$w.p add [frame $w.m] -stretch always
#	pack [canvas $w.m.c -width 800 -height 600] -fill both -side left
#
#	set path "test.png"
#	set c [open $path r]
#	fconfigure $c -translation binary -buffering none
#	set data [read $c]
#	close $c
#	set img [image create photo -format PNG -data $data]
#	canvas_bgi $w.m.c $img
#	foreach num {1 2 3 4 5 6 7 8 9 10 11 12 13} {
#		canvas_par $w.m.c "$num YOUR BUNNY WROTE:" {*}[canvas_tags {green spewer}]
#		canvas_par $w.m.c "$num Lorem ipsum dolor sit amet some shit some fish some grease some butts test test test I'm tired and depressed and afraid for everyone's lives and why the hell would you all think I'm evil or even not, I'm doing things to not lose my mind over fear ; anyway, please be well, I really hope you're well, I have no reason to think you're not, no real one anyway, though, just no VK activity, well, who would have it.\n" {*}[canvas_tags {white bullshit}]
#	}
#	after 1000 [list canvas_del $w.m.c]
#}
#
#canvas_test

proc ctext args {
	set w [lindex $args 0]
	set args [lrange $args 1 end]
	dict unset args {-wrap}
	dict unset args {-padx}
	dict unset args {-pady}
	dict unset args {-font}
	set xscrollc {}
	set yscrollc {}
	catch {
	set xscrollc [dict get args {-xscrollc}]
	}
	catch {
	set yscrollc [dict get args {-yscrollc}]
	}
	if { $xscrollc != {} } {
		dict set args {-xscrollcommand} $xscrollc
	}
	if { $yscrollc != {} } {
		dict set args {-yscrollcommand} $yscrollc
	}
	dict set args {-width} 800
	dict set args {-height} 600
	dict set args {-yscrollincrement} 20
	dict set args {-xscrollincrement} 20
	set wc "$w-c"
	pack [label $w -text "$w"] -fill both -expand 1 -side left
	set id [canvas $wc {*}$args]

	set simg {}
	catch { set simg $::cur(canvas,bgi) }		
	if { $simg == {} } { 
		set path [file join "." "contrib" "bg.png"]
		set c [open $path r]
		fconfigure $c -translation binary -buffering none
		set data [read $c]
		close $c
		set img [image create photo -format PNG -data $data]
		set simg [image create photo -format PNG]
		$simg copy $img -to 0 0 1920 1080
		image delete $img
		set ::cur(canvas,bgi) $simg
	}
	
	canvas_bgi $wc $simg

	proc "::$w" {a0 {a1 {}} {a2 {}} {a3 {}} {a4 {}} {a5 {}} {a6 {}} {a7 {}} {a8 {}} {a9 {}} {a10 {}}} {
		set wc "[lindex [info level 0] 0]-c"
		set a [list $a0 $a1 $a2 $a3 $a4 $a5 $a6 $a7 $a8 $a9 $a10]
		set a [lsearch -inline -all -exact -not $a {}]
		switch [lindex $a 0] {
			"insert" {
				set pos [lindex $a 1]	
				if { $pos == "end" } {
					canvas_par $wc [lindex $a 2] {*}[canvas_tags [lindex $a 3]]
					canvas_end $wc
				} else {
					#set b [$wc bbox "tid:$pos"]
					#set bh [lindex $b 3]
					canvas_par $wc [lindex $a 2] {*}[canvas_tags [lindex $a 3]]
					canvas_end $wc
				}
			}
			"tag" {
				set op [lindex $a 1]
				if { $op == "bind" } {
					$wc bind [lindex $a 2] [lindex $a 3] [lindex $a 4]
				}
			}
			"delete" {
				set start [lindex $a 1]	
				set end [lindex $a 2]	
				if { $start == "1.0" && $end == "end" } {
					canvas_del $wc
				}
			}
			"yview" {
				$wc yview {*}[lrange $a 1 end]
			}
			"xview" {
				$wc xview {*}[lrange $a 1 end]
			}
			"image" {
				set op [lindex $a 1]
				set pos [lindex $a 2]
				set la [lrange $a 3 end]
				set img [dict get $la {-image}]	
				if { $op == "create" } {
					set whei [$wc cget -height]
					set ihei [image height $img]
					set last {}
					catch {
						set last $::cur(canvas,$wc,last)
					}
					if { $last == {} } {
						set last 0
					}
					set b [$wc bbox "tid:$last"]
					set bh [lindex $b 3]
					if { $bh == {} } {
						set by 0
					}
					incr last 1
					set ::cur(canvas,$wc,last) $last
					$wc create image [list 0 $bh] -anchor nw -image $img -tags "text img:$img tid:$last"
					$wc move "text" 0 "-$ihei"
					canvas_end $wc
				}
			}
			"index" {
				if { [lindex $a 1] == "end" } {
					set last {}
					catch {
						set last $::cur(canvas,$w,last)
					}
					if { $last != {} } {
						return $last
					} else {
						return 0
					}
				}
			}
			default {
				return	
			}
		}
	}
	return $id
}

#vwait forever

