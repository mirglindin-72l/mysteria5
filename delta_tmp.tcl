package require cksum
source "./log.tcl"
proc delta {f t} {
	set flines [split $f "\n"]
	set tlines [split $t "\n"]
	set flen [llength $flines]
	set tlen [llength $tlines]

	array set f_n2h ""
	array set t_n2h ""

	for { set c 0 } { $c < $flen } { incr c 1 } {
		set hash [::crc::cksum [lindex $flines $c]]
		set f_n2h($c) $hash
	}

	for { set c 0 } { $c < $tlen } { incr c 1 } {
		set hash [::crc::cksum [lindex $tlines $c]]
		set t_n2h($c) $hash
	}

	set ret {}

	set fs 0
	set ts 0
	set fe $flen 
	set te $tlen

	array set vec {}

	while { $fs < $fe && $ts < $te } {

	### first two loops will do if
	### I can't do an ugly diff kind,
	### to at least save some space
	### on duplicating edits

	### clear equal lines before
	#while { $fs < $fe && $ts < $te } {
	#	set fhash $f_n2h($fs) 
	#	set thash $t_n2h($ts) 
	#	if { $fhash != $thash } {
	#		### no change - no need to add to delta 
	#		### otherwise break
	#		break
	#	}
	#	incr fs 1
	#	incr ts 1
	#}

	### clear equal lines after
	#while { $fs < $fe && $ts < $te } {
	#	set fhash $f_n2h($fe) 
	#	set thash $t_n2h($te) 
	#	if { $fhash != $thash } {
	#		### no change - no need to add to delta 
	#		### otherwise break
	#		break
	#	}
	#	incr fe -1
	#	incr te -1
	#}

	### try to reproduce diff algorithm
	### we already have two vectors
	### 
	### I'd rather just take a differing point in vector,
	### some number as max "hair" to check,
	### and loop over the other vector to find and eliminate a matching
	### piece, but then I'd need to store number of equal lines
	###
	
	set tmp_sf [expr {$fe-$fs}]
	set tmp_st [expr {$te-$ts}]
	set tmp_max 1024
	set tmp [::tcl::mathfunc::min $tmp_sf $tmp_st $tmp_max]

	### get candidates
	for { set c 0 } { $c < $tmp } { incr c 1 } {
		set fc [expr {$fs}]
		set tc [expr {$ts+$c}] 
		if { $f_n2h($fc) == $t_n2h($tc) } {
			set tmp2 [expr {min($tmp-$c,$tmp)}]
			set cc 0
			while { $cc < $tmp2 } {
				set fc_cc [expr {$fc+$cc}]
				set tc_cc [expr {$tc+$cc}]
				if { $f_n2h($fc_cc) != $t_n2h($tc_cc) } {
					break	
				}
				incr cc 1
			}
			set vec($fc,$tc) $cc
		}
	}

	incr fs 1
	incr ts 1

	###

	}

	### sort descending by size of equal piece
	set sorted_by_len [lsort -decreasing -integer -stride 2 -index 1 [array get vec]]

	set clear {}
	foreach {k l} $sorted_by_len {
		set p_fs [lindex [split $k {,}] 0]
		set p_ts [lindex [split $k {,}] 1]
		lappend clear $p_fs $p_ts $l
	}
	set clear_sorted [lsort -increasing -integer -stride 3 -index 0 $clear]

	array set clear_unique {}
	set clear_unique(0) [list 0 0 0] 
	set clear_unique($flen) [list $flen $tlen 0] 
	foreach {p_fs p_ts l} $clear_sorted {
		set clear_unique($p_fs) [list $p_fs $p_ts $l]
	}

	###
	log_puts "ALL" "###"
	log_puts "ALL" "Source from:"
	log_puts "ALL" $f
	log_puts "ALL" "###"
	log_puts "ALL" "Source to:"
	log_puts "ALL" $t
	log_puts "ALL" "###"
	log_puts "ALL" "Diff: "
	set fc 0
	set tc 0
	foreach {k v} [lsort -increasing -integer -stride 2 -index 0 [array get clear_unique]] {
		set ldel {}
		set ladd {}
		set p_fs [lindex $v 0]
		set p_ts [lindex $v 1]
		set p_l [lindex $v 2]
		set del 0
		set add 0
		foreach line [lrange $flines $fc $p_fs] {
			append ldel "-$line\n"
			incr del 1
		}
		foreach line [lrange $tlines $tc $p_ts] {
			append ladd "+$line\n"
			incr add 1
		}
		if { $del > 0 } {
			append ret "d $del f $p_fs t $p_ts\n"
			append ret $ldel
		}
		if { $add > 0 } {
			append ret "a $add f $p_fs t $p_ts\n"
			append ret $ladd
		}
		set fc [expr {$p_fs+$p_l}]
		set tc [expr {$p_ts+$p_l}]
	}
	log_puts "ALL" $ret
	log_puts "ALL" "###"
	return $ret
}

proc apply_delta {f p} {
	log_puts "ALL" "apply_delta"
	set flines [split $f "\n"]
	set flen [llength $flines]
	set plines [split $p "\n"]
	set tlines {}
	set ret {}

	set fs 0
	linsert plines 0 "a 0 f 0 t 0"
	lappend plines "a 0 f $flen t $flen"
	set num 0
	while 1 {
		if { $plines == {} } {
			break	
		}
		set cmd [lpop plines 0]
		log_puts "ALL" "cmd $cmd"
		set mode [string trim [string index $cmd 0]]
		switch $mode {
		"d" {
			set num [dict get $cmd d]
			set tfs [expr "[dict get $cmd f]-$num+1"]
		}
		"a" {
			set num [dict get $cmd a]
			set tfs [expr "[dict get $cmd f]"]
		}
		"" {
			log_puts "ALL" "continue"
			continue
		}
		default {
			log_puts "ERR" "mode $mode , break"
			break
		}
		}
		while { $fs < $tfs } {
			lappend tlines [lindex $flines $fs]
			incr fs 1
		}
		for { set c 0 } { $c < $num } { incr c 1 } {
			set cmd [lpop plines 0]
			set p [string index $cmd 0]
			set data [string range $cmd 1 end]
			if { $mode == "d" && $p == "-" } {
				if { $data != [lindex $flines $fs] } {
					log_puts "ERR" "delete $data != [lindex $flines $fs]"
				}
				incr fs 1
			} elseif { $mode == "a" && $p == "+" } {
				lappend tlines $data
			} else {
				log_puts "ERR" "error $cmd"
			}
		}
	}
	set ret [join $tlines "\n"]
	log_puts "ALL" $ret
	return $ret
}

proc test_delta {} {
set t0 {}
append t0 "qwe" 
append t0 "\n" 
append t0 "rty" 
append t0 "\n" 
append t0 "rty" 
append t0 "\n" 
append t0 "asd" 
append t0 "\n" 
append t0 "fgh" 
append t0 "\n" 
append t0 "zxc" 
append t0 "\n" 
append t0 "vbn" 
append t0 "\n" 
append t0 "iop" 
append t0 "\n" 
set t1 {}
append t1 "fgh" 
append t1 "\n" 
append t1 "qwe" 
append t1 "\n" 
append t1 "rty" 
append t1 "\n" 
append t1 "asd" 
append t1 "\n" 
append t1 "fgh" 
append t1 "\n" 
append t1 "vbn" 
append t1 "\n" 
append t1 "iop" 
append t1 "\n" 
append t1 "bnm" 
append t1 "\n" 

set t2 "cool0\ncool1\ncool2\nnotcool\ncool3\ncool4\ncool5\n"
set t3 "cool0\nnotcool\ncool1\ncool2\ncool3\ncool4\ncool5\n"

#set d01 [delta $t0 $t1]
#set d23 [delta $t2 $t3]
set d1 [delta "" $t1]
set d3 [delta "" $t3]
#set t1n [apply_delta $t0 $d01]
#set t3n [apply_delta $t2 $d23]
set t1n [apply_delta "" $d1]
set t3n [apply_delta "" $d3]
if { $t1n == $t1 && $t3n == $t3 } {
	log_puts "ALL" "test successful"
} else {
	log_puts "ALL" "test failed"
	log_puts "ALL" "t1:\n$t1"
	log_puts "ALL" "t1n:\n$t1n"
	log_puts "ALL" "test failed"
	log_puts "ALL" "t3:\n$t3"
	log_puts "ALL" "t3n:\n$t3n"
}
}

#test_delta
