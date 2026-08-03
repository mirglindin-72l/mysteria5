# this concerns connecting to an I2P SAM bridge, maintaining connection,
# sending messages to peers with I2P addresses, and processing received messages
# at this point I have a huge suspicion that perhaps protocol should be part of peer description
# right now I'm not indicating TCP or UDP port (because that was supposed to be decided in favor of some
# one protocol), but with I2P - perhaps a prefix will do

# whether to run i2p
set ::options(run_i2p) 1
# port of SAM locally
set ::options(i2p_port) 7656
# peer sockets to keep
set ::options(i2p_num) 4 
# socket of SAM connection
set ::cur(i2p,sock) {}
set ::cur(i2p,msock) {}
# state of SAM session
set ::cur(i2p,state) {}
set ::cur(i2p,mstate) {}
# my I2P destination
set ::cur(i2p,dest) {}
set ::cur(i2p,mdest) {}
# my I2P private key
set ::cur(i2p,key) {}
set ::cur(i2p,mkey) {}
# session ID (just to keep it,
# we have one session with SAM) 
set ::cur(i2p,session) {}
set ::cur(i2p,msession) {}
set ::cur(i2p,lastcheck) 0

# will use ::cur(i2p,$dest,queue,$mid) , 
# an array of messages pending delivery to destination 
# will use
# 	::cur(i2p,datasock,$s,state)  
#	::cur(i2p,datasock,$s,dest)
# for peer sockets, state is hello, accept, stream

proc i2p_load {} {
	log_puts "ALL" "i2p_load start"
	set k {dest key mdest mkey}
	set path [file join $::filepath "i2p.dat" ]
	set d [get_bin $path $k]
	catch {
	set ::cur(i2p,dest) [dict get $d dest]
	set ::cur(i2p,key) [dict get $d key]
	set ::cur(i2p,mdest) [dict get $d mdest]
	set ::cur(i2p,mkey) [dict get $d mkey]
	}
	log_puts "ALL" "i2p_load end"
	return	
}

proc i2p_save {} {
	log_puts "ALL" "i2p_save start"
	set path [file join $::filepath "i2p.dat" ]
	set kv [list dest $::cur(i2p,dest) key $::cur(i2p,key) mdest $::cur(i2p,mdest) mkey $::cur(i2p,mkey)]
	save_bin $path $kv
	log_puts "ALL" "i2p_save end"
	return
}

proc i2p_start {} {
	log_puts "ALL" "i2p_start start"
	catch {
	set ::cur(i2p,sock) [socket 127.0.0.1 $::options(i2p_port)]
	}
	if { $::cur(i2p,sock) == {} } {
		log_puts "ERR" "i2p_start failed to connect to SAM at port $::options(i2p_port)"
		after 60000 i2p_start
		return
	}
	set c $::cur(i2p,sock)
	log_puts "ALL" "i2p_start SOCK $c"

	set ::cur(i2p,state) "hello"
	fileevent $c readable [list i2p_handler $c]
	puts $c "HELLO VERSION MIN=3.1 MAX=3.1"
	flush $c
	fconfigure $c -blocking 0

	log_puts "ALL" "i2p_start SOCK $c sent hello"

	after 60000 [list i2p_check]
	log_puts "ALL" "i2p_start end"
	return
}

proc i2p_check {} {
	log_puts "ALL" "i2p_check start"
	if { $::cur(i2p,state) == "hello" } {
		log_puts "ERR" "i2p_check kill i2p"
		i2p_end
		i2p_mend
		after 60000 i2p_start
	}	
	log_puts "ALL" "i2p_check end"
	return
}

proc i2p_mstart {} {
	log_puts "ALL" "i2p_mstart start"
	catch {
	set ::cur(i2p,msock) [socket 127.0.0.1 $::options(i2p_port)]
	}
	if { $::cur(i2p,msock) == {} } {
		log_puts "ERR" "i2p_mstart failed to connect to SAM at port $::options(i2p_port)"
		after 60000 i2p_mstart
		return
	}
	set c $::cur(i2p,msock)
	log_puts "ALL" "i2p_mstart SOCK $c"

	set ::cur(i2p,mstate) "hello"
	fileevent $c readable [list i2p_mhandler $c]
	puts $c "HELLO VERSION MIN=3.1 MAX=3.1"
	flush $c
	#fconfigure $c -blocking 0

	log_puts "ALL" "i2p_mstart SOCK $c sent hello"

	after 60000 [list i2p_mcheck]
	log_puts "ALL" "i2p_mstart end"
	return
}

proc i2p_mcheck {} {
	log_puts "ALL" "i2p_mcheck start"
	if { $::cur(i2p,mstate) == "hello" } {
		log_puts "ERR" "i2p_mcheck kill i2p"
		i2p_end
		i2p_mend
		after 60000 i2p_start
	}	
	log_puts "ALL" "i2p_mcheck end"
	return
}

proc i2p_start_data {dest} {
	log_puts "ALL" "i2p_start_data start"
	if { $::cur(i2p,state) != "ready" && $dest == {} } {
		log_puts "ALL" "i2p_start_data not ready, schedule expect socket to future"
		after 5000 [list i2p_start_data {}]
		return	
	} elseif { $::cur(i2p,state) != "ready" && $dest != {} } {
		log_puts "ALL" "i2p_start_data not ready, do not open connect socket"
		return	
	}
	set c {}
	catch {
	set c [socket 127.0.0.1 $::options(i2p_port)]
	}
	if { $c == {} } {
		log_puts "ERR" "i2p_start_data failed to connect to SAM at port $::options(i2p_port)"
		return
	}
	log_puts "ALL" "i2p_start_data SOCK $c DEST $dest"
	set ::cur(i2p,datasock,$c,dest) $dest
	set ::cur(i2p,datasock,$c,state) "hello"
	set ::cur(i2p,datasock,$c,last) [clock seconds]
	fileevent $c readable [list i2p_handler_data $c]
	puts $c "HELLO VERSION MIN=3.1 MAX=3.1"
	flush $c
	fconfigure $c -blocking 0
	
	log_puts "ALL" "i2p_start_data SOCK $c sent hello"

	after 60000 [list i2p_check_data $c]
	log_puts "ALL" "i2p_start_data end"
	return
}

proc i2p_check_data {c} {
	log_puts "ALL" "i2p_check_data start"
	set state {}
	catch {
	set state ::cur(i2p,datasock,$c,state)
	}
	if { $state == "hello" } {
		log_puts "ERR" "i2p_check_data kill socket $c"
		array unset ::cur "i2p,datasock,$c,*"
		catch { close $c }
	}
	log_puts "ALL" "i2p_check_data end"
	return
}

proc i2p_end {} {
	log_puts "ALL" "i2p_end start"
	catch { close $::cur(i2p,sock) }
	set ::cur(i2p,state) {}
	set ::cur(i2p,sock) {}
	set ::cur(i2p,session) {}
	array unset ::cur "i2p,*,queue,*"
	foreach k [array names ::cur "i2p,datasock,*,state"] {
		set c [lindex [split $k {,}] 2]
		catch { close $c }
	}
	array unset ::cur "i2p,datasock,*"
	log_puts "ALL" "i2p_end end" 
	return
}

proc i2p_mend {} {
	log_puts "ALL" "i2p_mend start"
	catch { close $::cur(i2p,msock) }
	set ::cur(i2p,mstate) {}
	set ::cur(i2p,msock) {}
	set ::cur(i2p,msession) {}
	log_puts "ALL" "i2p_mend end" 
	return
}

proc i2p_handler {c} {
	log_puts "ALL" "i2p_handler"
	set msg {}
	if { [eof $c] } {
		log_puts "ERR" "i2p_handler $c EOF close"
		i2p_end
		after 60000 i2p_start
		return
	} elseif { [fblocked $c] } {
		log_puts "ERR" "i2p_handler $c blocked"
		return
	} else {
		log_puts "ERR" "i2p_handler $c processing"
		catch { gets $c msg }
	}
	if { $msg == {} } {
		log_puts "ERR" "i2p_handler $c empty msg"
		return
	}
	set cmd1 [lindex $msg 0]
	set cmd2 [lindex $msg 1]
	log_puts "ALL" "i2p_handler $c msg $msg"
	# if connection to SAM was accepted, and dest is present, create session, else generate dest 
	if { $cmd1 == "HELLO" && $cmd2 == "REPLY" && $::cur(i2p,state) == "hello" } {
		if { [lindex $msg 2] == "RESULT=OK" } {
			log_puts "ALL" "i2p_handler reply to hello, proceed"
			if { $::cur(i2p,key) == {} || $::cur(i2p,dest) == {} } {
				log_puts "ALL" "i2p_handler have no dest and key, generate"
				puts $::cur(i2p,sock) "DEST GENERATE SIGNATURE_TYPE=7"
				flush $::cur(i2p,sock)
				set ::cur(i2p,state) "generate"
			} else {
				log_puts "ALL" "i2p_handler already have dest and key, create session"
				set ::cur(i2p,state) "create"
				set sid "[crypto_cksum -hex $::cur(i2p,key)]-[clock microseconds]" 
				set ::cur(i2p,session) $sid
				puts $::cur(i2p,sock) "SESSION CREATE STYLE=STREAM ID=${sid} DESTINATION=${::cur(i2p,key)} i2cp.leaseSetEncType=6,4"
				flush $::cur(i2p,sock)
			}
		} else {
			log_puts "ALL" "i2p_handler something went wrong"
			i2p_end
			i2p_mend
			after 60000 i2p_start
		}
	}
	if { $cmd1 == "DEST" && $cmd2 == "REPLY" && $::cur(i2p,state) == "generate" } {
		log_puts "ALL" "i2p_handler reply to generate, saving dest and key"
		foreach term [lrange $msg 2 end] {
			if { [string range $term 0 3] == "PUB=" } {
				log_puts "ALL" "i2p_handler saving dest"
				set ::cur(i2p,dest) [string range $term 4 end]
			}
			if { [string range $term 0 4] == "PRIV=" } {
				log_puts "ALL" "i2p_handler saving key"
				set ::cur(i2p,key) [string range $term 5 end]
			}
		}
		if { $::cur(i2p,key) != {} && $::cur(i2p,dest) != {} } {
			log_puts "ALL" "i2p_handler saved dest and key, create session"
			i2p_save
			set ::cur(i2p,state) "create"
			set sid "[crypto_cksum -hex $::cur(i2p,key)]-[clock microseconds]" 
			set ::cur(i2p,session) $sid
			puts $::cur(i2p,sock) "SESSION CREATE STYLE=STREAM ID=${sid} DESTINATION=${::cur(i2p,key)} i2cp.leaseSetEncType=6,4"
			flush $::cur(i2p,sock)
		} else {
			log_puts "ALL" "i2p_handler something went wrong"
			i2p_end
			i2p_mend
			after 60000 i2p_start
		}
	}
	if { $cmd1 == "SESSION" && $cmd2 == "STATUS" && $::cur(i2p,state) == "create" } {
		if { [lindex $msg 2] == "RESULT=OK" } {
			log_puts "ALL" "i2p_handler successfully created session, spawn data sockets"
			set ::cur(i2p,state) "ready"
			for { set i 0 } { $i < $::options(i2p_num) } { incr i 1 } {
				i2p_start_data {}
			}
			after 60000 i2p_maintain_data
			i2p_mstart
		} else {
			log_puts "ALL" "i2p_handler something went wrong"
			i2p_end
			i2p_mend
			after 60000 i2p_start
		}
	}
	log_puts "ALL" "i2p_handler $c return"
	return
}

proc i2p_mhandler {c} {
	log_puts "ALL" "i2p_mhandler"
	set msg {}
	if { [eof $c] } {
		log_puts "ERR" "i2p_mhandler $c EOF close"
		i2p_mend
		return
	} elseif { [fblocked $c] } {
		log_puts "ERR" "i2p_mhandler $c blocked"
		return
	} else {
		log_puts "ERR" "i2p_mhandler $c processing"
		catch { gets $c msg }
	}
	if { $msg == {} } {
		log_puts "ERR" "i2p_mhandler $c empty msg"
		return
	}
	set cmd1 [lindex $msg 0]
	set cmd2 [lindex $msg 1]
	log_puts "ALL" "i2p_mhandler $c msg $msg"
	# if connection to SAM was accepted, and dest is present, create session, else generate dest 
	if { $cmd1 == "HELLO" && $cmd2 == "REPLY" && $::cur(i2p,mstate) == "hello" } {
		if { [lindex $msg 2] == "RESULT=OK" } {
			log_puts "ALL" "i2p_mhandler reply to hello, proceed"
			if { $::cur(i2p,mkey) == {} || $::cur(i2p,mdest) == {} } {
				log_puts "ALL" "i2p_mhandler have no mdest and mkey, generate"
				puts $::cur(i2p,msock) "DEST GENERATE SIGNATURE_TYPE=7"
				flush $::cur(i2p,msock)
				set ::cur(i2p,mstate) "generate"
			} else {
				log_puts "ALL" "i2p_mhandler already have mdest and mkey, create session"
				set ::cur(i2p,mstate) "create"
				set sid "[crypto_cksum -hex $::cur(i2p,mkey)]-[clock microseconds]" 
				set ::cur(i2p,msession) $sid
				puts $::cur(i2p,msock) "SESSION CREATE STYLE=RAW ID=${sid} DESTINATION=${::cur(i2p,mkey)} i2cp.leaseSetEncType=6,4"
				flush $::cur(i2p,msock)
			}
		} else {
			log_puts "ALL" "i2p_mhandler something went wrong"
			i2p_mend
		}
	}
	if { $cmd1 == "DEST" && $cmd2 == "REPLY" && $::cur(i2p,mstate) == "generate" } {
		log_puts "ALL" "i2p_mhandler reply to generate, saving mdest and mkey"
		foreach term [lrange $msg 2 end] {
			if { [string range $term 0 3] == "PUB=" } {
				log_puts "ALL" "i2p_mhandler saving mdest"
				set ::cur(i2p,mdest) [string range $term 4 end]
			}
			if { [string range $term 0 4] == "PRIV=" } {
				log_puts "ALL" "i2p_mhandler saving key"
				set ::cur(i2p,mkey) [string range $term 5 end]
			}
		}
		if { $::cur(i2p,mkey) != {} && $::cur(i2p,mdest) != {} } {
			log_puts "ALL" "i2p_mhandler saved mdest and mkey, create session"
			i2p_save
			set ::cur(i2p,mstate) "create"
			set sid "[crypto_cksum -hex $::cur(i2p,mkey)]-[clock microseconds]" 
			set ::cur(i2p,msession) $sid
			puts $::cur(i2p,msock) "SESSION CREATE STYLE=RAW ID=${sid} DESTINATION=${::cur(i2p,mkey)} i2cp.leaseSetEncType=6,4"
			flush $::cur(i2p,msock)
		} else {
			log_puts "ALL" "i2p_mhandler something went wrong"
			i2p_mend
		}
	}
	if { $cmd1 == "SESSION" && $cmd2 == "STATUS" && $::cur(i2p,mstate) == "create" } {
		if { [lindex $msg 2] == "RESULT=OK" } {
			log_puts "ALL" "i2p_mhandler successfully created session"
			set ::cur(i2p,mstate) "ready"
			fconfigure $::cur(i2p,msock) -blocking 1
		} else {
			log_puts "ALL" "i2p_mhandler something went wrong"
			i2p_mend
		}
	}
	if { $cmd1 == "RAW" && $cmd2 == "RECEIVED" && $::cur(i2p,mstate) == "ready" } {
		log_puts "ALL" "i2p_mhandler RAW in"
		set s [lindex $msg 2]
		if { [string range $s 0 4] == "SIZE=" } {
			set dlen [string range $s 5 end]
		} else {
			log_puts "ERR" "i2p_mhandler RAW in - wrong format $msg"
			return
		}
		#fconfigure $::cur(i2p,msock) -translation auto -buffering line -blocking 0
		set data [read $::cur(i2p,msock) $dlen]
		#fconfigure $::cur(i2p,msock) -translation auto -buffering line -blocking 0
		i2p_mrecv $data
	}
	log_puts "ALL" "i2p_mhandler $c return"
	return
}

proc i2p_handler_data {c} {
	log_puts "ALL" "i2p_handler_data"
	set msg {}
	set state {}
	set dest {}
	if { [eof $c] } {
		log_puts "ERR" "i2p_handler_data $c EOF close"
		array unset ::cur "i2p,datasock,$c,*"
		catch { close $c }
		return
	} elseif { [fblocked $c] } {
		log_puts "ERR" "i2p_handler_data $c blocked"
		return	
	} else {
		log_puts "ERR" "i2p_handler_data $c processing"
		catch { gets $c msg }
		catch { set state $::cur(i2p,datasock,$c,state) }
		catch { set dest $::cur(i2p,datasock,$c,dest) }
	}
	if { $msg == {} } {
		log_puts "ERR" "i2p_handler_data $c message empty"
		return	
	}
	set ::cur(i2p,datasock,$c,last) [clock seconds]
	if { $state == "expect" } {
		log_puts "ALL" "i2p_handler_data $c incoming connection"
		log_puts "ALL" "i2p_handler_data $c expect it to be dest: $msg"
		set ::cur(i2p,datasock,$c,dest) $msg
		set ::cur(i2p,datasock,$c,state) "stream"
		fconfigure $c -translation binary -buffering full -blocking 1
		after idle [list i2p_checkqueue]
	}
	if { $state == "stream" } {
		log_puts "ALL" "i2p_handler_data $c message in stream state"
		i2p_recv $c $dest $msg
	}
	log_puts "ALL" "i2p_handler_data $c msg $msg"
	set cmd1 [lindex $msg 0]
	set cmd2 [lindex $msg 1]
	if { $cmd1 == "HELLO" && $cmd2 == "REPLY" && $::cur(i2p,datasock,$c,state) == "hello" } {
		if { [lindex $msg 2] == "RESULT=OK" } {
			log_puts "ALL" "i2p_handler_data $c got ok to hello"
			if { $::cur(i2p,key) == {} || $::cur(i2p,dest) == {} } {
				log_puts "ERR" "i2p_handler_data somehow we lack dest and key, abort"
				array unset ::cur "i2p,datasock,$c,*"
				catch { close $c }
			}
			set dest {}
			catch {
			set dest $::cur(i2p,datasock,$c,dest)
			}
			log_puts "ALL" "i2p_handler_data $c vars [array get ::cur i2p,datasock,$c,*]"
			if { $dest == {} } {
				log_puts "ALL" "i2p_handler_data $c listening socket to state accept"
				set ::cur(i2p,datasock,$c,state) "accept"
				puts $c "STREAM ACCEPT ID=${::cur(i2p,session)}"
				flush $c
			} else {
				log_puts "ALL" "i2p_handler_data $c outgoing socket to state connect"
				set ::cur(i2p,datasock,$c,state) "connect"
				puts $c "STREAM CONNECT ID=${::cur(i2p,session)} DESTINATION=$dest" 
				flush $c
				after 10000 [list i2p_handler_data_retry $c 2 2]
			}
		} else {
			log_puts "ALL" "i2p_handler_data $c hello failed"
			array unset ::cur "i2p,datasock,$c,*"
			catch { close $c }
			return
		}
	}
	if { $cmd1 == "STREAM" && $cmd2 == "STATUS" && $::cur(i2p,datasock,$c,state) == "accept" } {
		log_puts "ALL" "i2p_handler_data $c got message in state accept"
		if { [lindex $msg 2] == "RESULT=OK" } {
			log_puts "ALL" "i2p_handler_data $c succeeded in getting into state expect"
			set ::cur(i2p,datasock,$c,state) "expect"
		} else {
			log_puts "ALL" "i2p_handler_data $c something went wrong"
			array unset ::cur "i2p,datasock,$c,*"
			catch { close $c }
			return
		}
	}
	if { $cmd1 == "STREAM" && $cmd2 == "STATUS" && $::cur(i2p,datasock,$c,state) == "connect" } {
		log_puts "ALL" "i2p_handler_data $c got message in state connect"
		if { [lindex $msg 2] == "RESULT=OK" } {
			log_puts "ALL" "i2p_handler_data $c our connection was accepted"
			set ::cur(i2p,datasock,$c,state) "stream"
			fconfigure $c -translation binary -buffering full -blocking 1
			after idle [list i2p_checkqueue]
		} else {
			log_puts "ALL" "i2p_handler_data $c something went wrong"
			array unset ::cur "i2p,datasock,$c,*"
			catch { close $c }
			return
		}
	}
	log_puts "ALL" "i2p_handler_data $c return"
	return
}

proc i2p_handler_data_retry {c base attempts} {
	set dest {}
	catch {
	set dest $::cur(i2p,datasock,$c,dest)
	}
	set state {}
	catch {
	set state $::cur(i2p,datasock,$c,state)
	}
	if { $state == "connect" && $dest != {} && $attempts > 0 } {
		log_puts "ERR" "i2p_handler_data_retry $c still in state connect, retry"
		puts $c "STREAM CONNECT ID=${::cur(i2p,session)} DESTINATION=$dest" 
		flush $c
		after [expr {10000*((1+$base)/(1+$attempts))}] [list i2p_handler_data_retry $c $base [expr {$attempts-1}]]
	} elseif { $attempts <= 0 } {
		array unset ::cur "i2p,datasock,$c,*"
		catch { close $c }
	}
}

proc i2p_maintain_data {} {
	log_puts "ALL" "i2p_maintain_data start"
	catch { after cancel $::cur(i2p,datasock,cleanup) }
	set now [clock seconds]
	set l_expect {}
	set l_stream {}
	set l_connect {}
	set l_accept {}
	set n_expect 0
	set n_stream 0
	set n_connect 0
	set n_accept 0
	set del {}
	foreach {k v} [array get ::cur "i2p,datasock,*,state"] {
		set l [split $k {,}]
		set c [lindex $l 2]
		if { $c == {} } {
			continue
		}
		switch $v {
		"expect" {
			lappend l_expect $c
			incr n_expect 1	
		}
		"stream" {
			lappend l_stream $c
			incr n_stream 1	
		}
		"connect" {
			lappend l_connect $c
			incr n_connect 1
		}
		"accept" {
			lappend l_accept $c
			incr n_accept 1	
		}
		}
	}
	if { $n_expect > $::options(i2p_num) } {
		foreach c $l_expect {
			set last $::cur(i2p,datasock,$c,last)
			if { $last < [expr {$now-60}] } {
			lappend del $c
			}
		}
	}
	if { $n_stream > $::options(i2p_num) } {
		foreach c $l_stream {
			set last $::cur(i2p,datasock,$c,last)
			if { $last < [expr {$now-300}] } {
			lappend del $c
			}
		}
	}
	if { $n_connect > $::options(i2p_num) } {
	foreach c $l_connect {
		set last $::cur(i2p,datasock,$c,last)
		if { $last < [expr {$now-120}] } {
			lappend del $c
		}
	}
	}
	foreach d $del {
		array unset ::cur "i2p,datasock,$d,*"
		catch { close $d }
	}
	for { set i $n_accept } { $i < $::options(i2p_num) } { incr i 1 } {
		i2p_start_data {}		
	}
	after 60000 i2p_maintain_data
	log_puts "ALL" "i2p_maintain_data end"
}

proc i2p_send {dst msg} {
	if { $dst == $::cur(i2p,dest) } {
		return
	}
	set msg $msg
	set mid "[crypto_cksum -hex $msg]-[clock seconds]"
	log_puts "ALL" "i2p_send QUEUE $msg TO $dst"
	set ::cur(i2p,$dst,queue,$mid) $msg
	after idle [list i2p_checkqueue]
	return
}

proc i2p_checkqueue {} {
	set last $::cur(i2p,lastcheck)
	if { [clock microseconds] - $last < 2500 } {
		return
	}
	set ::cur(i2p,lastcheck) [clock microseconds]
	log_puts "ALL" "i2p_checkqueue"
	# get all needed destinations
	set msg_ks [array names ::cur "i2p,*,queue,*"]
	set dsts {}
	foreach msg_k $msg_ks {
		set dst [lindex [split $msg_k {,}] 1]
		lappend dsts $dst
	}
	set dsts [lsort -unique $dsts]
	# first, send through established streams
	set cdsts [array names ::cur "i2p,datasock,*,dest"]
	foreach k $cdsts {
		log_puts "ALL" "i2p_checkqueue SOCK $k" 
		set dst $::cur($k)
		set dsts [lsearch -all -inline -not -exact $dsts $dst]
		log_puts "ALL" "i2p_checkqueue SOCK $k DST $dst" 
		set c [lindex [split $k {,}] 2]
		if { [eof $c] } {
			log_puts "ALL" "i2p_checkqueue SOCK $k s $c blocked" 
			array unset ::cur "i2p,datasock,$c,*"
			catch { close $c }
			continue
		}
		if { [fblocked $c] } {
			log_puts "ALL" "i2p_checkqueue SOCK $k s $c blocked" 
			continue
		}
		set state $::cur(i2p,datasock,$c,state)
		log_puts "ALL" "i2p_checkqueue SOCK $k STATE $state" 
		if { $state != "stream" } {
			log_puts "ALL" "i2p_checkqueue SOCK $k skip" 
			continue
		}
		foreach {mk msg} [array get ::cur "i2p,$dst,queue,*"] {
			log_puts "ALL" "i2p_checkqueue OUT $msg TO $dst"
			set ::cur(i2p,datasock,$c,last) [clock seconds]
			puts $c $msg
			catch { flush $c }
			log_puts "ALL" "i2p_checkqueue SENT"
			array unset ::cur $mk
		}
	}
	foreach dst $dsts {
		log_puts "ALL" "i2p_checkqueue NEW DST $dst" 
		after idle [i2p_start_data $dst]
	}
	return
}

proc i2p_mrecv {data} {
	if { $data == {} } {
		log_puts "ERR" "i2p_mrecv empty msg"
		return	
	}
	catch {
	set data [unwrap $data]
	}
	log_puts "ALL" "i2p_mrecv LEN [string length $data]"
	after idle [list audio_recv $data]
	log_puts "ALL" "i2p_mrecv R DONE"
	return
}

proc i2p_msend {dst data} {
	if { $dst == {} || $data == {} } {
		log_puts "ERR" "i2p_msend empty dst or data"
		return
	}
	if { $dst == $::cur(i2p,mdest) } {
		return
	}
	if { [eof $::cur(i2p,msock)] } {
		log_puts "ERR" "i2p_msend eof"
		i2p_mend
		i2p_mstart
		return
	}
	if { [fblocked $::cur(i2p,msock)] } {
		log_puts "ERR" "i2p_msend blocked"
		return
	}
	set data [wrap $data]
	set len [string length $data]
	log_puts "ALL" "i2p_msend RAW LEN $len TO $dst"
	puts $::cur(i2p,msock) "RAW SEND DESTINATION=$dst SIZE=$len"
	#fconfigure $::cur(i2p,msock) -translation auto -buffering line -blocking 0
	puts $::cur(i2p,msock) $data
	flush $::cur(i2p,msock)
	#fconfigure $::cur(i2p,msock) -translation auto -buffering line -blocking 0
	return
}

proc i2p_recv {c dst msg} {
	log_puts "ALL" "i2p_recv $dst $msg"
	if { $dst == {} } {
		log_puts "ERR" "i2p_recv empty dst"
		return
	}
	if { $msg == {} } {
		log_puts "ERR" "i2p_recv empty msg"
		return	
	}
	log_puts "ALL" "i2p_recv IN $msg FROM $dst"
	set rs {}
	lappend rs {*}[str_req "$dst 0" $msg 0]
	log_puts "ALL" "i2p_recv RS $rs"
	foreach r $rs {
		if { $r == -1 || $r == {} } {
			continue
		}
		log_puts "ALL" "i2p_recv R OUT $r TO $dst"
		i2p_send $dst $r
		log_puts "ALL" "i2p_recv R PUT"
	}
	log_puts "ALL" "i2p_recv R DONE"
	return
}

proc i2p_copy_dest {} {
	log_puts "ALL" "i2p_copy_dest $::cur(i2p,dest)"
	clipboard clear
	clipboard append $::cur(i2p,dest)
	return
}

proc i2p_paste_dest {} {
	log_puts "ALL" "i2p_paste_dest"
	set s {}
	catch {
	set s [clipboard get]
	}
	set ::formhost $s
	set ::formport 0
	return
}

proc i2p_copy_mdest {} {
	log_puts "ALL" "i2p_copy_mdest $::cur(i2p,mdest)"
	clipboard clear
	clipboard append $::cur(i2p,mdest)
	return
}

proc i2p_paste_mdest {} {
	log_puts "ALL" "i2p_paste_dest"
	set s {}
	catch {
	set s [clipboard get]
	}
	set ::audiohost $s
	set ::audioport 0
	return
}

