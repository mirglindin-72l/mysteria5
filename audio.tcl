###
# of portaudio wrapper in critcl
# we need reading portions to buffer
# and playing portions from buffer
# later we can try using opus
#

# record to fifo, packetize out
# put packets to fifo, play

####
# with portaudio we've succeeded more than expected, have background recording with writing
# into a TCL channel
#
# with opus we've succeeded, but not too much, and for now we are too lazy,
# we have a basic wrapper with encoding buffers of PCM into length-prepended opus packets
# and back, that's buffer into buffer, chan to buffer, buffer to chan, chan to chan
# we don't have, while that would be convenient, or even better, combine with portaudio
# wrapper
#
# but perhaps not, network connections are unstable even with TCP and abstractions,
# thus writing to fifo and sending pieces forward is fine, especially since it's not too much
#
# start streams, start io
####

####
# endpoint state:
# deny 
# accept
# ring_in
# ring_out
# call
#
# media state:
# don't need that,
# just not send media traffic,
# meaning microphone off
#
# other:
# an address and port negotiated by signalling
# via normal messages, in i2p separate destination
#
# me:
# address and port on which we accept calls,
# in i2p separate destination, don't know
# what to do without i2p
#
# fifo:
# out fifo - from me to the other side, we read a portion from fifo, opus-encode it,
# send it, in fifo - from the other side to me, opus-decode it and write to fifo
#
# ###
#
# in short, we need a signaling protocol in the main one ; we also need a new kind of connections,
# resurrect rawsend and make it fit for i2p, that is, each peer listens on signaling (main) port
# and on media port, while with i2p we register a separate destination and send it while
# signaling, might also send some short token as a basic defense against random datagrams
# to kill our ears to media destination while having a call
#
# meaning that we need at least some dialog similar to SIP invite,ringing,ok,ok,etc
#
# that's tomorrow, i'm falling asleep 
# that is, in the morning, tomorrow is already here
#
####

####
#
# "PHONE RING me/id/dest/mdest" -> other/id/dest (repeat)
# me/id/dest <-
# 	"PHONE OK other/id/dest/mdest" (take, to call state) (once)
# 	or "PHONE BACK other/id/dest" (wait, confirms ringing) (once)
# 	or "PHONE NO other/id/dest" (decline, stops dialogue) (once)
# ...
# me/mdest <-> other/mdest
# ...
# "PHONE DOWN me/id/dest/mdest" -> other/id/dest (once, doesn't need answer)
# me/id/dest <- "PHONE DOWN other/id/dest/mdest" (once, doesn't need answer)
#
####

set ::cur(audio,state) "deny"
set ::cur(audio,peerid) {}
set ::cur(audio,host) {}
set ::cur(audio,port) {}
set ::cur(audio,mhost) {}
set ::cur(audio,mport) {}

proc audio_send {q} {
	set now [clock microseconds]
	set last {}
	catch {
	set last $::cur(audio,last)
	}
	if { $last != {} && [expr {$now-$last}] < 500 } {
		#return
	}
	set ::cur(audio,last) [clock microseconds]
	if { $q == {} } {
		log_puts "ERR" "audio_send q not supplied"
		return
	}
	if { [eof $q] } {
		log_puts "ERR" "audio_send q eof"
		return
	}
	#if { [fblocked $q] } {
	#	log_puts "ERR" "audio_send q blocked"
	#	return
	#}
	log_puts "ALL" "audio_send"
	set data {}
	catch { set data [read $q] }
	if { $data != {} } {
		set host $::cur(audio,mhost)
		set port $::cur(audio,mport)
		log_puts "ALL" "audio_send host $host port $port"
		if { [lindex [array get ::transports "i2p,enable"] end] == 1 } {
			after idle [list i2p_msend $host [::opus::enc $data 48000 1]]
		}
	} else {
		log_puts "ERR" "audio_send no data"
	}
}

proc audio_recv {data} {
	log_puts "ALL" "audio_recv"
	if { $::cur(audio,in,fifo) == {} } {
		return
	}
	puts -nonewline $::cur(audio,in,fifo) [::opus::dec $data 48000 1]
	flush $::cur(audio,in,fifo)
}

proc audio_start {host port} {
	catch { destroy .w_audio_call }
	catch { destroy .w_audio_ring }
	log_puts "ALL" "audio_start"
	if { $host == {} || $port == {} } {
		log_puts "ERR" "audio_start empty host or port"
		return
	}
	set ::cur(audio,mhost) $host 
	set ::cur(audio,mport) $port
	set ::cur(audio,in,fifo) [tcl::chan::fifo_fix]	
	set ::cur(audio,out,fifo) [tcl::chan::fifo_fix]
	#set ::cur(audio,in,fifo) [::queue::queue]	
	#set ::cur(audio,out,fifo) [::queue::queue]
	#set ::cur(audio,in,fifo) [tcl::chan::myrb]	
	#set ::cur(audio,out,fifo) [tcl::chan::myrb]
	#fconfigure $::cur(audio,in,fifo) -translation binary -buffering none -blocking 0
	#fconfigure $::cur(audio,out,fifo) -translation binary -buffering none -blocking 0
	fconfigure $::cur(audio,in,fifo) -translation binary -buffering none -blocking 1
	fconfigure $::cur(audio,out,fifo) -translation binary -buffering none -blocking 1
	set ::cur(audio,state) "call" 
	#set ::cur(audio,schedule) [after 1000 audio_run]
	set ::cur(audio,schedule) [after 480 audio_run]
	# dangerous
	::pa::init 48000 1
	::pa::rec_chan $::cur(audio,out,fifo)
	::pa::play_chan $::cur(audio,in,fifo)
	::pa::rec_start
	::pa::play_start
	# event handler
	#fileevent $::cur(audio,out,fifo) readable [list audio_send $::cur(audio,out,fifo)]
}

proc audio_run {} {
	if { $::cur(audio,state) != "call" } {
		log_puts "ERR" "state not call, need to stop everything"
		catch { destroy .w_audio_run }
		return
	} 
	if { [winfo exists .w_audio_run] == 0 } {
		show_audio_run
	}
	catch {after cancel $::cur(audio,schedule)}
	#set ::cur(audio,schedule) [after 1000 audio_run]
	set ::cur(audio,schedule) [after 480 audio_run]
	after idle [list audio_send $::cur(audio,out,fifo)]
}

proc show_audio_run {} {
	set w .w_audio_run
	if { [winfo exists $w] == 1 } {
		return
	}
	toplevel $w
	wm title $w "Call"
	pack [panedwindow "$w.p" -ori vert] -fill both -expand 1
	"$w.p" add [frame "$w.t"] -stretch never
	pack [label "$w.t.l" -text "Call" -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) -font $::options(font) ] -fill both -side left
	"$w.p" add [frame "$w.b"] -stretch never
	pack [wbutton "$w.b.d" -text "stop" -activebackground $::options(hilightcolor) -activeforeground $::options(basecolor) -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor)  -font $::options(font) -command "after idle audio_end; destroy $w"] -fill both -side left
}

proc show_audio {} {
	set w .w_audio
	if { [winfo exists $w] == 1 } {
		return
	}
	toplevel $w
	wm title $w "Phone"
	pack [panedwindow "$w.p" -ori vert]
	"$w.p" add [frame "$w.t"] -stretch never
	pack [label "$w.t.l" -text "Phone" -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) -font $::options(font) ] -fill both -side left
	"$w.p" add [frame "$w.e"] -stretch never
	pack [wentry "$w.e.i" -textvariable ::audiopeerid -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) -selectforeground $::options(basecolor) -selectbackground $::options(hilightcolor) -font $::options(font) -width 24 ] -fill both -side left 
	"$w.p" add [frame "$w.e0"] -stretch never
	pack [label "$w.e0.i" -textvariable ::audiopeerid -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) -font $::options(font) -width 24 ] -fill both -side left 
	"$w.p" add [frame "$w.e1"] -stretch never
	pack [label "$w.e1.h" -textvariable ::audiohost -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) -font $::options(font) -width 24 ] -fill both -side left 
	"$w.p" add [frame "$w.e2"] -stretch never
	pack [label "$w.e2.p" -textvariable ::audioport -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) -font $::options(font) -width 24 ] -fill both -side left
	"$w.p" add [frame "$w.b"] -stretch never
	pack [wbutton "$w.b.p" -text "+p" -activebackground $::options(hilightcolor) -activeforeground $::options(basecolor) -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor)  -font $::options(font) -command "audio_paste_contact"] -fill both -side right
	pack [label "$w.b.s" -textvariable ::cur(audio,state) -activebackground $::options(hilightcolor) -activeforeground $::options(basecolor) -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor)  -font $::options(font) ] -fill both -side right
	pack [wbutton "$w.b.t" -text "toggle" -activebackground $::options(hilightcolor) -activeforeground $::options(basecolor) -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor)  -font $::options(font) -command "audio_toggle"] -fill both -side right
	pack [wbutton "$w.b.c" -text "call" -activebackground $::options(hilightcolor) -activeforeground $::options(basecolor) -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor)  -font $::options(font) -command {audio_ring $::audiopeerid}] -fill both -side right
}

proc audio_ring {peerid} {
	log_puts "ALL" "audio_ring"
	if { [lindex [array get ::transports "i2p,enable"] end] != 1 } {
		return
	}
	if { $peerid == {} } {
		log_puts "ERR" "audio_ring empty peerid"
		return
	}
	set peers {}
	foreach {key val} [array get ::peerstore "$peerid*"] {
		lappend peers $val
	}
	set peers [lsort -unique $peers]
	set s [split [lindex $peers 0] {:}]
	set ::cur(audio,peerid) $peerid 
	ml_genc [lindex $s 0] [lindex $s 1] [lindex $s 2] "PHONE 0 RING $::me(id) $::cur(i2p,dest) $::cur(i2p,mdest)" 0
	set ::cur(audio,state) ring_out
	show_audio_call [lindex $s 0] 
}

proc audio_ok {} {
	log_puts "ALL" "audio_ok"
	if { [lindex [array get ::transports "i2p,enable"] end] != 1 } {
		return
	}
	catch { destroy .w_audio_ring }
	ml_genc $::cur(audio,peerid) $::cur(audio,host) $::cur(audio,port) "PHONE 0 OK $::me(id) $::cur(audio,host) $::cur(i2p,mdest)" 0
	set ::cur(audio,state) call
	after idle [list audio_start $::cur(audio,mhost) $::cur(audio,mport)]
}

proc audio_no {} {
	log_puts "ALL" "audio_no"
	if { [lindex [array get ::transports "i2p,enable"] end] != 1 } {
		return
	}
	catch { destroy .w_audio_ring }
	ml_genc $::cur(audio,peerid) $::cur(audio,host) $::cur(audio,port) "PHONE 0 NO $::me(id) $::cur(audio,host)" 0
	set ::cur(audio,state) deny 
}

proc audio_down {} {
	log_puts "ALL" "audio_down"
	if { [lindex [array get ::transports "i2p,enable"] end] != 1 } {
		return
	}
	catch { destroy .w_audio_call }
	catch { destroy .w_audio_ring }
	ml_genc $::cur(audio,peerid) $::cur(audio,host) $::cur(audio,port) "PHONE 0 DOWN $::me(id) $::cur(audio,host)" 0
	if ( $::cur(audio,state) == call ) {
		after idle audio_end
	}
	set ::cur(audio,state) deny 
}

proc audio_dialog {r a} {
	if { $::cur(audio,state) == "deny" } {
		log_puts "ERR" "audio_dialog in deny state, no methods accepted"
		return
	}
	if { $::cur(audio,state) == "accept" && $r != "RING" } {
		log_puts "ERR" "audio_dialog in accept state, method $r not accepted"
		return
	}
	if { $::cur(audio,state) == "ring_in" && ( $r != "RING" && $r != "DOWN" ) } {
		log_puts "ERR" "audio_dialog in ring_in state, method $r not accepted"
		return
	}
	if { $::cur(audio,state) == "ring_out" && $r == "RING" } {
		log_puts "ERR" "audio_dialog in ring_out state, method $r not accepted"
		return
	}
	if { $::cur(audio,state) == "call" && $r != "DOWN" } {
		log_puts "ERR" "audio_dialog in call state, method $r not accepted"
		return
	}
	switch $r {
	"RING" {
		log_puts "ALL" "audio_dialog RING $a"
		set ::cur(audio,host) [lindex $a 1]
		set ::cur(audio,port) 0
		set ::cur(audio,mhost) [lindex $a 2]
		set ::cur(audio,mport) 0
		ml_genc $::cur(audio,peerid) $::cur(audio,host) $::cur(audio,port) "PHONE 0 BACK $::me(id) $::cur(audio,host) $::cur(audio,mhost)" 0
		set ::cur(audio,state) ring_in
		after idle show_audio_ring
	}
	"BACK" {
		log_puts "ALL" "audio_dialog BACK"
		# nothing yet for ringback
		audio_back
	}
	"OK" {
		log_puts "ALL" "audio_dialog OK $a"
		set ::cur(audio,mhost) [lindex $a 2]
		set ::cur(audio,mport) 0
		set ::cur(audio,state) call
		after idle [list audio_start $::cur(audio,mhost) $::cur(audio,mport)]
	}
	"NO" {
		log_puts "ALL" "audio_dialog NO"
		catch {after cancel $::cur(audio,schedule)}
		set ::cur(audio,state) deny
	}
	"DOWN" {
		log_puts "ALL" "audio_dialog DOWN"
		set ::cur(audio,host) {} 
		set ::cur(audio,port) {}
		set ::cur(audio,mhost) {}
		set ::cur(audio,mport) {}
		set ::cur(audio,state) deny
		catch {after cancel $::cur(audio,schedule)}
		after idle audio_end
	}
	default {
		log_puts "ERR" "audio_dialog unknown method"
	}
	}
}

proc show_audio_call {peerid} {
	set w .w_audio_call
	if { [winfo exists $w] == 1 } {
		return
	}
	toplevel $w
	wm title $w "Calling"
	pack [panedwindow "$w.p" -ori vert]
	"$w.p" add [frame "$w.t"] -stretch never
	pack [label "$w.t.l" -text "Calling" -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) -font $::options(font) ] -fill both -side left
	"$w.p" add [frame "$w.b"] -stretch never
	pack [wbutton "$w.b.d" -text "cancel" -activebackground $::options(hilightcolor) -activeforeground $::options(basecolor) -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor)  -font $::options(font) -command "after idle audio_end ; destroy $w"] -fill both -side left
	pack [wbutton "$w.b.a" -text "repeat" -activebackground $::options(hilightcolor) -activeforeground $::options(basecolor) -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor)  -font $::options(font) -command "audio_ring $peerid ; destroy $w"] -fill both -side right
	
}

proc audio_back {} {
	log_puts "ALL" "audio_back"
	if { $::cur(audio,state) != 1 && $::cur(audio,state) != 0 } {
		log_puts "ERR" "state not 0 and not 1"
		return
	}
	if { [winfo exists .w_audio_ring] == 0 } {
		show_audio_ring
	}
	set ::cur(audio,state) ring_in
	log_puts "ALL" "ringing..."
	catch {after cancel $::cur(audio,schedule)}
	set ::cur(audio,schedule) [after 3000 audio_ring]
}

proc show_audio_ring {} {
	set w .w_audio_ring
	if { [winfo exists $w] == 1 } {
		return
	}
	toplevel $w
	wm title $w "Ringing"
	pack [panedwindow "$w.p" -ori vert]
	"$w.p" add [frame "$w.t"] -stretch never
	pack [label "$w.t.l" -text "Ringing" -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) -font $::options(font) ] -fill both -side left
	"$w.p" add [frame "$w.b"] -stretch never
	pack [wbutton "$w.b.d" -text "decline" -activebackground $::options(hilightcolor) -activeforeground $::options(basecolor) -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor)  -font $::options(font) -command "audio_no ; destroy $w"] -fill both -side left
	pack [wbutton "$w.b.a" -text "start" -activebackground $::options(hilightcolor) -activeforeground $::options(basecolor) -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor)  -font $::options(font) -command "audio_ok ; destroy $w"] -fill both -side right
}

proc audio_end {} {
	log_puts "ALL" "audio_end"
	catch { destroy .w_audio_call }
	catch { destroy .w_audio_ring }
	if { $::cur(audio,state) != "call" } {
		log_puts "ERR" "state not call"
	}
	catch {
	fconfigure $::cur(audio,out,fifo) -blocking 0
	fconfigure $::cur(audio,in,fifo) -blocking 0
	}
	catch {
	close $::cur(audio,out,fifo)
	close $::cur(audio,in,fifo)
	}
	::pa::rec_end
	::pa::play_end
	::pa::term
	set ::cur(audio,out,fifo) {}
	set ::cur(audio,in,fifo) {}
	set ::cur(audio,host) {}
	set ::cur(audio,port) {}
	set ::cur(audio,state) "deny" 
	set ::cur(audio,schedule) {}
}

proc audio_toggle {} {
	if { $::cur(audio,state) == "deny" } {
		set ::cur(audio,state) "accept"
	} elseif { $::cur(audio,state) == "accept" } {
		set ::cur(audio,state) "deny"
	}
}

proc audio_paste_contact {} {
	log_puts "ALL" "audio_paste_contact"
	set contact {}
	catch {
	set contact [clipboard get]
	}
	set c [contact_to_dict $contact]
	set peerid {}
	catch {
	set peerid [dict get $c peerid]
	}
	if { $peerid == {} || $peerid == $::me(id) } {
		return
	}
	set ::audiopeerid $peerid
	return
}
