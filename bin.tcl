# write and read string: len + data
# similarly convert to binary and back

proc w_wide {n c} {
	catch {
	set nf {Wu}
	set tw [binary format $nf $n]
	puts -nonewline $c $tw
	} result
	log_puts "ALL" "w_wide $result"
}

proc w_num {n c} {
	catch {
	set nf {Iu}
	set tw [binary format $nf $n]
	puts -nonewline $c $tw
	} result
	log_puts "ALL" "w_num $result"
}

proc w_short {n c} {
	catch {
	set nf {Su}
	set tw [binary format $nf $n]
	puts -nonewline $c $tw
	} result
	log_puts "ALL" "w_short $result"
}

proc short2bin {n} {
	set ret {}
	catch {
	set nf {Su}
	set ret [binary format $nf $n]
	}
	return $ret
}

proc w_byte {b c} {
	catch {
	set bf {cu}
	set tw [binary format $bf $b]
	puts -nonewline $c $tw
	} result
	log_puts "ALL" "w_byte $result"
}

proc r_wide {c} {
	catch {
	set nl {}
	set bl [read $c 8]
	binary scan $bl Wu nl
	} result
	log_puts "ALL" "r_wide $result"
	return $nl
}

proc r_num {c} {
	catch {
	set nl {}
	set bl [read $c 4]
	binary scan $bl Iu nl
	} result
	log_puts "ALL" "r_num $result"
	return $nl
}

proc r_short {c} {
	catch {
	set nl {}
	set bl [read $c 2]
	binary scan $bl Su nl
	} result
	log_puts "ALL" "r_short $result"
	return $nl
}

proc bin2short {b} {
	set ret {}
	catch {
	set nf {Su}
	binary scan $b $nf ret
	}
	return $ret
}

proc r_byte {c} {
	catch {
	set nl {}
	set bl [read $c 1]
	binary scan $bl cu nl
	} result
	log_puts "ALL" "r_byte $result"
	return $nl
}

proc w_str {s c} {
	catch {
	set sf {Iua*}
	set sc [encoding convertto utf-8 $s]
	set sl [string length $sc]
	set tw [binary format $sf $sl $sc]
	puts -nonewline $c $tw
	} result	
}

proc str2bin {s} {
	set ret {}
	catch {
	set sf {Iua*}
	set sc [encoding convertto utf-8 $s]
	set sl [string length $sc]
	set ret [binary format $sf $sl $sc]
	} result
	return $ret
}

proc r_str {c} {
	set s {}
	catch {
	set sl {}
	set bl [read $c 4]
	binary scan $bl Iu sl
	if { $sl == {} } {
		return
	}
	set bs [read $c $sl]
	set s [encoding convertfrom utf-8 $bs]
	} result
	return $s
}

proc bin2str {b} {
	set s {}
	catch {
	set sl {}
	set sf {Iua*}
	binary scan $b $sf sl bs
	set s [encoding convertfrom utf-8 $bs]
	} result
	return $s
}

proc w_dict {d c} {
	set keys [dict keys $d]
	w_str [llength $keys] $c
	foreach key $keys {
		w_str $key $c
		w_str [dict get $d $key] $c
	}
}

proc dict2bin {d} {
	set b {}
	set c [tcl::chan::variable $b]
	w_dict $d $c
	close $c
	return $b
}

proc r_dict {c} {
	set d {}
	set len [r_str $c]
	for { set i 0 } { $i < $len } { incr i } {
		set key [r_str $c]
		set value [r_str $c]
		dict set d $key $value 
	}
	return $d
}

proc bin2dict {b} {
	set c [tcl::chan::string $b]
	set d [r_dict $c]
	close $c
	return $d
}

proc w_list {l c} {
	set len [llength $l]
	w_short $len $c
	foreach i $l {
		w_str $i $c
	}
}

proc list2bin {l} {
	set ret {}
	set len [llength $l]
	append ret [short2bin $len]
	foreach i $l {
		append ret [str2bin $i]
	}
	return $ret
}

proc r_list {c} {
	set l {}
	set len [r_short $c]
	for { set i 0 } { $i < $len } { incr i } {
		lappend l [r_str $c]	
	}
	return $l
}

proc bin2list {b} {
	set len {}
	set data {}
	set ret {}
	binary scan $b {Sua*} len data
	set cur 0
	set rest $data
	for {set i 0} {$i < $len} {incr i 1} {
		set l {}
		binary scan $rest {Iu} l
		set str {} 
		binary scan $rest "Iua${l}a*" l str rest 
	       	lappend ret $str	
		set cur $l
	} 
	return $ret
}

proc w_req {msg c} {
	log_puts "ALL" "w_req [string range $msg 0 63]..."
	set m [lindex [split $msg { }] 0]
	set s [lindex [split $msg { }] 1]
	set r [lindex [split $msg { }] 2]
	set a [lrange [split $msg { }] 3 end]
	fconfigure $c -blocking 1
	catch {
	# ubyte for number 55, protocol magic
	w_byte 55 $c
	# ushort for port, protocol magic
	w_short $::options(myport) $c
	# string (ushort and then that many bytes) for method  
	w_str $m $c
	# uwide (it's taken from epoch, but wrapping around doesn't hurt us) for sid 
	w_wide $s $c
	# string (ushort and then that many bytes) for reply 
	w_str $r $c
	# list of strings (number of keys, for each ushort and then that many bytes) for reply args 
	w_list $a $c
	# concluding 111 magic
	w_byte 111 $c
	flush $c
	}
	fconfigure $c -blocking 0
}

proc r_req {c} {
	set begin {}
	set port {}
	set m {}
	set s {}
	set r {}
	set a {}
	set end {}
	fconfigure $c -blocking 1
	catch {
	set begin [r_byte $c]
	set port [r_short $c]
	set m [r_str $c]
	set s [r_wide $c]
	set r [r_str $c]
	set a [r_list $c]
	set end [r_byte $c]
	}
	fconfigure $c -blocking 0
	if { $begin == 101 } {
		log_puts "ERR" "r_req start conn magic in common handler"
		return
	}
	if { $begin != 55 || $end != 111 } {
		log_puts "ERR" "r_req wrong message: begin->$begin m->$m s->$s r->[string range $r 0 31]... a->[string range $a 0 31]... end->$end"
		return
	}
	log_puts "ALL" "r_req good message"
	return [list $port $m $s $r {*}$a]
}


