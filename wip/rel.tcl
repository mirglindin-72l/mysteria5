set ::options(rel_main) 127.0.0.1:12345 
set ::options(rel_ctlport) 23456
set ::options(rel_pass) {} 
set ::cur(rel,state) {}
set ::cur(rel,dest) {}
set ::cur(rel,lastcheck) 0

# similarly to i2p will use ::cur(rel,$relay,queue,$mid)
# for storing messages pending delivery to destination
# and
#  ::cur(rel,r2p,$relay) $p
#  ::cur(rel,p2r,$p) $relay
#  ::cur(rel,r2s,$relay) $s
#  ::cur(rel,s2r,$s) $relay

proc rel_send {dest tmp msg} {
	if { $dest == $::cur(rel,dest) } {
		return
	}
	log_puts "ALL" "rel_send dest $dest"
	set name [lindex [split $dest {@}] 0]
	set rhostport [lindex [split $dest {@}] 1]
	set rhost [lindex [split $rhostport {:}] 0]
	set rport [lindex [split $rhostport {:}] 0]
	if { $name == {} || $rhost == {} } {
		log_puts "ERR" "rel_send empty name or host"
		return
	}
	if { $rport == {} } {
		log_puts "ERR" "rel_send empty port, set to default 12345"
		set port 12345
	}
	set mid "[crypto_cksum -hex $msg]-[clock seconds]"
	log_puts "ALL" "rel_send QUEUE $msg to $dest"
	set ::cur(rel,${rhost}:${rport},queue,$mid) $msg
	after idle [list rel_checkqueue]
	log_puts "ALL" "rel_send end"
}

proc rel_checkqueue {} {
	set last $::cur(rel,lastcheck)
	if { [expr "[clock microseconds]-$last"] < 2500 } {
		return
	}
	set ::cur(rel,lastcheck) [clock microseconds]
	log_puts "ALL" "rel_checkqueue"
	set msg_ks [array names ::cur "rel,*,queue,*"]
	set relays {}
	foreach msg_k $msg_ks {
		set relay [lindex [split $msg_k {,}] 1]
		lappend relays $dst
	}
	set relays [lsort -unique $relays]
	foreach relay $relays {
		set chans [array names ::cur "rel,r2s,$relay"]
		foreach k $chans {
			log_puts "ALL" "rel_checkqueue SOCK $k"
			set c $::cur(k)
			set relays [lsearch -all -inline -not -exact $relays $relay]
			log_puts "ALL" "rel_checkqueue SOCK $k DST $dst"
			if { [eof $c] } {
				log_puts "ALL" "rel_checkqueue SOCK $k s $c eof"
				rel_stop_client $relay
				continue
			}
			if { [fblocked $c] } {
				log_puts "ALL" "rel_checkqueue SOCK $k s $c blocked"
				continue
			}
			foreach {mk msg} [array get ::cur "rel,$relay,queue,*"] {
				log_puts "ALL" "rel_checkqueue OUT $msg to $dst"
				set ::cur(rel,$relay,last) [clock seconds]	
				puts $c $msg
				catch { flush $c }
				log_puts "ALL" "rel_checkqueue SENT"
				array unset ::cur $mk
			}
		}
	}
	foreach relay $relays {
		log_puts "ALL" "rel_checkqueue NEW RELAY $relay"
		after idle [list rel_start_client $relay]
	}
	return
}

proc rel_handler {c relay} {
	log_puts "ALL" "rel_handler"
	set msg {}
	if { [eof $c] } {
		log_puts "ERR" "rel_handler $c EOF close"
		rel_stop_client $relay
		after 60000 rel_start
		return
	} elseif { [fblocked $c] } {
		log_puts "ERR" "rel_handler $c blocked"
		return
	} else {
		log_puts "ERR" "rel_handler $c processing"
		catch { gets $c msg }
	}
	if { $msg == {} } {
		log_puts "ERR" "rel_handler $c empty msg"
		return
	}
	log_puts "ALL" "rel_handler $c msg $msg"
	set msg [string trimleft $msg]
	set l [split $msg " "]
	if { $l == {} } {
		return
	}
	set frompeer [lpop l 0]
	set data [lpop l 0]
	rel_recv $c ${frompeer}@${relay} $data
	log_puts "ALL" "rel_handler end"
	return $ret
}

proc rel_recv {c dest msg} {
	log_puts "ALL" "rel_recv start"
	if { $dest == {} } {
		log_puts "ERR" "rel_recv empty dest"
		return
	}
	if { $msg == {} } {
		log_puts "ERR" "rel_recv empty msg"
		return
	}
	log_puts "ALL" "rel_recv IN $msg FROM $dest"
	set rs {}
	lappend rs {*}[str_req "rel/${dest} 0" $msg 1]
	log_puts "ALL" "rel_recv RS $rs"
	foreach r $rs {
		if { $r == -1 || $r == {} } {
			continue
		}
		log_puts "ALL" "rel_recv R OUT $r TO $dest"
		rel_send $dest 0 $r
		log_puts "ALL" "rel_recv R PUT"
	}
	log_puts "ALL" "rel_recv end"
	return
}

proc rel_start {} {
	log_puts "ALL" "rel_start start"
	if { $::cur(net,on) != 1 } {
		log_puts "ERR" "rel_start networking not enabled, return"
		return
	}
	set p [rel_start_client $::options(rel_main)]
	if { $p == {} } {
		log_puts "ERR" "rel_start failed to start Rikki for main relay"
		after 60000 rel_start
		return
	}
	log_puts "ALL" "rel_start PIPE $p"
	set ::cur(rel,state) "start"
	log_puts "ALL" "rel_start end"
	return
}

proc rel_start_client {relay} {
	log_puts "ALL" "rel_start_client start"
	if { $::cur(net,on) != 1 } {
		log_puts "ERR" "rel_start_client networking not enabled, return"
		return
	}
	set host [lindex [split $relay {:}] 0]
	set port [lindex [split $relay {:}] 1]
	if { $host == {} || $port == {} } {
		log_puts "ERR" "rel_start_client host $host or port $port empty, return"
		return
	}
	set path {../nag/rikki}
	log_puts "ALL" "rel_start_client open pipe $path -host $host -port $port -ctlport $::options(rel_ctlport) -id $::me(id)"
	set p {}
	catch {
	set p [open "|$path -host $host -port $port -ctlport $::options(rel_ctlport) -id $::me(id)"]
	} res
	if { $p == {} } {
		log_puts "ERR" "rel_start_client open pipe failed"
		return
	} else {
		log_puts "ERR" "rel_start_client open pipe res: $res"
		return
	}
	set ::cur(rel,r2p,$relay) $p 
	set ::cur(rel,p2r,$p) $relay 
	after 1000 [list rel_start_client_conn $relay]
	log_puts "ALL" "rel_start_client end"
	return $p
}

proc rel_start_client_conn {relay} {
	log_puts "ALL" "rel_start_client_conn start"
	if { $::cur(net,on) != 1 } {
		log_puts "ERR" "rel_start_client_conn networking not enabled, return"
		return
	}
	set c {}
	catch {
	set c [socket 127.0.0.1 $::options(rel_ctlport)]
	}
	if { $c == {} } {
		log_puts "ERR" "rel_start_client_conn connect to Rikki failed"
		return
	}
	set ::cur(rel,r2s,$relay) $c 
	set ::cur(rel,s2r,$c) $relay 
	fileevent $c readable [list rel_handler $c $relay]
	log_puts "ALL" "rel_start_client_conn end"
	return
}

proc rel_stop_client {relay} {
	log_puts "ALL" "rel_stop_client start"
	catch { set s $::cur(rel,r2s,$relay) }
	catch { set p $::cur(rel,r2p,$relay) }
	array unset ::cur "rel,*,$relay"
	array unset ::cur "rel,s2r,$s"
	array unset ::cur "rel,p2r,$p"
	catch { close $s }
	catch { close $p }
	log_puts "ALL" "rel_stop_client end"
	return
}

proc rel_end {} {
	log_puts "ALL" "rel_end start"
	set chans [array names ::cur "rel,r2s,$relay"]
	set relays {}
	foreach ch $chans {
		lappend relays [lindex [split $ch {,}] end]
	}
	foreach $relays {
		rel_stop_client $relay
	}
	array unset ::cur "rel,*"
	set ::cur(rel,state) ""
	log_puts "ALL" "rel_end end"
	return
}

proc rel_copy_dest {} {
	log_puts "ALL" "rel_copy_dest start"
	log_puts "ALL" "rel_copy_dest end"
	return
}

proc rel_paste_dest {} {
	log_puts "ALL" "rel_paste_dest start"
	log_puts "ALL" "rel_paste_dest end"
	return
}

set ::transports(rel,send) "rel_send"
set ::transports(rel,start) "rel_start"
set ::transports(rel,end) "rel_end"
set ::transports(rel,copy) "rel_copy_dest"
set ::transports(rel,paste) "rel_paste_dest ; sol \$::formhost \$::formport"
set ::transports(rel,enable) 1
