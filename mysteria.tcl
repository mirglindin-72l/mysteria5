package require critcl
package require tcllibc
package require Tcl
#package require sha1
#package require pki
#package require aes
#package require udp
package require Tk
#package require Trf
package require tcl::chan::events
package require tcl::chan::random
#package require tcl::chan::fifo
#package require tcl::chan::memchan
#package require memchan
#package require snack
#package require sound
#package require Img
#package require tdom
package require msgcat

source "./fifo_fix.tcl"
#source "./myrb.tcl"
source "./log.tcl"
source "./wrappers.tcl"
source "./bin.tcl"
#source "./tree.tcl"
source "./gfiles.tcl"
source "./audio.tcl"
source "./gr.tcl"
source "./wid.tcl"
source "./i2p.tcl"
source "./crypto.tcl"
source "./offline.tcl"
source "./mysm.tcl"
source "./canvas.tcl"
source "./doc.tcl"
source "./delta.tcl"
source "./msg.tcl"
source "./options.tcl"

# globals

set ::options(myport) {}
array set ::b {}
array set ::peerstore {}
array set ::valuestore {}
array set ::p {}
array set ::waitvalue {}
array set ::sources {}
array set ::contacts {}
array set ::headers {}
array set ::my_groups {}
array set ::groups {}
array set ::jgroups {}
array set ::group_to_sig {}
array set ::group_to_sigreq {}
array set ::person_to_sig {}
array set ::person_to_sigreq {}
array set ::file_by_hash {}
array set ::hash_by_file {}
array set ::dl_by_hash {}
array set ::dlstate_by_hash {}
array set ::dlaction_by_hash {}
array set ::buddies {}
array set ::statuses {}
array set ::tcp {}
array set ::tcp_fail {}
array set ::tcp_conn {}
array set ::gchatqueue {}
array set ::gchatcache {}
#array set ::lettercache {}
#array set ::bincache {}
set ::tcp_fail(count) 0 
set ::audio_state 0
set ::cur(main,group,h) {}
set ::cur(main,group,l) {}
set ::cur(main,person,h) {}
set ::cur(main,person,l) {}
set ::cur(play,running) {}
set ::cur(record,running) {}
set ::topline(main,l) {}
set ::topline(main,r) {}
set ::buddylist(main,l) {}
set ::buddylist(main,k) {}
set ::jgrouplist(main,l) {}
set ::jgrouplist(main,m) {}
set ::jgrouplist(main,i) {}
set ::jgrouplist(main,k) {}
array set ::keys {}
array set ::gnotices {}
set ::contactlist(main,l) {}
set ::contactlist(main,k) {}
set ::contactsearch {}
set ::grouplist(main,l) {}
set ::grouplist(main,k) {}
set ::groupsearch {}
set ::search {}
set ::searchfield(main) {}
set ::text {}
set ::last(wait) 0
set ::last(dl) 0
set ::last(chq) 0
set ::last(gchq) 0
set ::last(peer) 0
set ::tick [clock seconds] 
set ::filepath {}
array set ::msglist {}
#set ::options(default_chunksize) 65536
set ::options(default_chunksize) 16777216
set ::me(key) {}
set ::me(id) {}
set ::me(pubkey) {}
set ::me(nickname) {}
set ::me(contact) {}
set ::cur(main,mode) {}
set ::cur(net,on) 0
set ::cur(net,l) "net off"
set ::card(birthday) {}
set ::card(gender) {}
set ::card(country) {}
set ::card(city) {}
if { $::tcl_platform(os) == {Darwin} } {
	set ::options(font) {"Lucida Grande" 10}
	set ::options(listfont) {"Monaco" 10}
	set ::options(ttk_button) 1
	set ::options(ttk_scrollbar) 1
	set ::options(ttk_entry) 1
	set ::options(ttk_label) 1
	set ::options(ttk_panedwindow) 0
	set ::options(ttk_frame) 1
} else {
	set ::options(font) {"Sans" 10}
	set ::options(listfont) {"Monospace" 10}
	set ::options(ttk_button) 1
	set ::options(ttk_scrollbar) 1
	set ::options(ttk_entry) 1
	set ::options(ttk_label) 1
	set ::options(ttk_panedwindow) 0
	set ::options(ttk_frame) 1
}
set ::options(bordercolor) {#999999} 
set ::options(hilightcolor) {#666666}
set ::options(basecolor) {#cccccc}
#set ::options(bordercolor) {#909090} 
#set ::options(hilightcolor) {#606060}
#set ::options(basecolor) {#000000}
#set ::options(bordercolor) {#c00000} 
#set ::options(hilightcolor) {#303030}
#set ::options(basecolor) {#c0c000}
set ::random(seed) [clock microseconds]
set ::random(chan) {}
set ::options(plain_allowed) 0
set ::options(audio_enabled) 1
set ::options(linked_images) 1
set ::options(group_host_mode) 0
set ::options(gchat_sync_allowed) 1
set ::options(gchat_sync_days) 1
set ::options(line_th) 1
set ::options(hide_pane) false
set ::options(run_upnpc) 1
set ::options(locale) en
set ::recent(main) {}

# run

proc main args {
	wm withdraw .
	msg_set
	store_select
}

proc launch {} {
	log_puts "ALL" "Starting"

	set ::random(chan) [::tcl::chan::random $::random(seed)]
	fconfigure $::random(chan) -translation binary

	file mkdir $::filepath
	file mkdir [file join $::filepath "downloads"]
	file mkdir [file join $::filepath "temp"]
	file mkdir [file join $::filepath "chat"]
	file mkdir [file join $::filepath "gchat"]
	file mkdir [file join $::filepath "obj"]
	file mkdir [file join $::filepath "mlhdr"]
	file mkdir [file join $::filepath "mlphdr"]
	file mkdir [file join $::filepath "mlsrc"]
	file mkdir [file join $::filepath "doc"]

	read_ini
	write_ini

	load_id
	load_port
	load_contact
	load_peers
	load_buckets
	load_values
	load_contacts
	load_headers
	load_groups
	load_jgroups
	load_buddies
	load_sources
	load_files
	load_dls
	#load_keys
	load_sig

	net_toggle

	foreach {key group} [array get ::jgroups] {
		ml_replay $group
	}

	#set oneyear [expr "86400*365"]
	#archive_mlhdr $oneyear
	#archive_mlphdr $oneyear
	#archive_mailnews $oneyear

	check_waitvalues
	check_gchatqueue
	check_peers

	after 60000 [list net_update]
	
	every 1000 {
		set ::tick [clock seconds]
		if { !([winfo exists .m] || [winfo exists .b] || [winfo exists .g] || [winfo exists .startshield] || [winfo exists .sss]) } {
			write_all ; exit
		}
	}
	
	every 300000 {
		after 15000 [list send_my_status "O" "online"]
	}

	every 300000 {
		after idle [list write_all]
	}

	make_nmenu

	show

	vwait forever

	if { $::options(run_i2p) != 1 } {
		close $::ct
	} else {
		i2p_end
	}

	close $::log
} 

proc sys_upnpc {port} {
	log_puts "ALL" "sys_upnpc"
	if { $::options(run_upnpc) != 1 } {
		log_puts "ERR" "sys_upnpc disabled"
		return
	}
	catch {
	exec upnpc -r $port tcp
	} result
	log_puts "ALL" "sys_upnpc result $result"
}

proc net_update {} {
	sanitize_stores
	hash_files
	sc_setsources
	foreach {gid group} [array get ::jgroups] {
		sc_publishgroup $group
	}
	sc_publishcontact $::me(contact)
	check_waitvalues
	check_gchatqueue
	check_peers
	return
}

proc net_toggle {} {
	if { $::cur(net,on) != 1 } {
		set ::cur(net,on) 1
		set ::cur(net,l) "net on"
		if { $::options(run_i2p) != 1 } {
			log_puts "ALL" "listen port $::options(myport)"
			set ::ct [tcp_listen]
			sys_upnpc $::options(myport)
			set ::options(audio_enabled) 0
		} else {
			log_puts "ALL" "start I2P SAM session on port $::options(i2p_port)"
			set ::options(myport) 0
			i2p_load
			i2p_start
		}
	} else {
		set ::cur(net,on) 0
		set ::cur(net,l) "net off"
		if { $::options(run_i2p) != 1 } {
			close $::ct
		} else {
			i2p_end
			i2p_mend
		}
	}
}

proc store_select {} {
	if { [winfo exists .sss] == 1 } {
		return
	}
	set ::filepath [file join "." ".store"]
	set dirs [glob -nocomplain -type d -directory $::filepath *]
	set choice {}
	foreach dir $dirs {
		lappend choice [lindex [file split $dir] end]
	}
	if { $choice == "" } {
		lappend choice "default"
	} 
	toplevel .sss
	wm title .sss [::msgcat::mc "storesel_l"] 
	pack [panedwindow .sss.p -ori vert ]
	.sss.p add [wframe ".sss.l"] -stretch never
	pack [wlabel .sss.l.l -text "[::msgcat::mc storesel_l]:" -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) -font $::options(font) ] -fill both -side left 
	.sss.p add [wframe ".sss.c"] -stretch never
	pack [wentry .sss.c.e -textvar ::sel_store -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) -font $::options(font) ] -fill both -side left 
	set storemenu [tk_optionMenu .sss.c.c ::sel_store {*}$choice]
	$storemenu configure -font $::options(font) -activebackground $::options(hilightcolor) -activeforeground $::options(basecolor)
	.sss.c.c configure -font $::options(font) -activebackground $::options(hilightcolor) -activeforeground $::options(basecolor) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor)
	pack .sss.c.c -fill both -side left 
	.sss.p add [wframe ".sss.e"] -stretch never
	pack [wbutton .sss.e.c -text [::msgcat::mc "select"] -activebackground $::options(hilightcolor) -activeforeground $::options(basecolor) -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor)  -font $::options(font) -command {set ::filepath [file join $::filepath $::sel_store] ; after 1000 [list destroy .sss] ; launch}] -fill both -side right
}

proc write_all {} {
		log_puts "ALL" "write all"
		write_id
		write_port
		write_contact
		write_peers
		write_buckets
		write_values
		write_contacts
		write_headers
		write_groups
		write_jgroups
		write_buddies
		write_sources
		write_files
		write_dls
		#write_keys
		write_sig
}

proc every {ms body} {
	eval $body; after $ms [info level 0]
}

proc head_all {} {
	foreach {gid grp} [array get ::jgroups] {
		ml_grouphead $grp
	}
	foreach {hash contact} [array get ::buddies] {
		ml_personhead $contact
	}
}

proc show {} {
	set font(n) [lindex $::options(font) 0]
	set font(s) [lindex $::options(font) 1]
	set listfont(n) [lindex $::options(listfont) 0]
	set listfont(s) [lindex $::options(listfont) 1]

	font configure TkDefaultFont -family $font(n) -size $font(s)
	font configure TkTextFont -family $listfont(n) -size $listfont(s)
	font configure TkFixedFont -family $font(n) -size $font(s)
	font configure TkMenuFont -family $listfont(n) -size $listfont(s)

	::msgcat::mcload msg
	set locales [::msgcat::mcloadedlocales loaded]
	if { [lsearch -all -inline $locales $::options(locale)] == {} } {
		set ::options(locale) en
	}
	::msgcat::mclocale $::options(locale)

	wm withdraw .

	show_mail
	#show_buddylist
	#show_startshield
}

#proc archive_mlhdr {a} {
#	set thr [expr "[clock sec]-$a"]
#	set g [array names ::jgroups]
#	foreach grp $g {
#		set hdrs [lrange [ml_get_hdrs 365 mlhdr $grp] 2 end]
#		set nhdrs {}
#		set ohdrs {}
#		#log_puts "ALL" "hdrs $hdrs"
#		foreach hdr $hdrs {
#			set h [header_to_dict $hdr]
#			if { $h == "" } {
#				log_puts "ERR" "bad header $hdr"
#				continue
#			}
#			set epoch [dict get $h epoch]
#			log_puts "ALL" "epoch $epoch vs thr $thr"
#			if { $epoch > $thr } {
#				lappend nhdrs $hdr
#			} else {
#				#set hash [dict get $h hash]
#				#file rename [file join $::filepath "mailnews" "$hash" ] [file join $::filepath "mailnews" "archive" $hash ]
#				lappend ohdrs $hdr
#			}
#		}
#		file delete [file join $::filepath "mlhdr" "$grp.dat"]
#		ml_add_hdrs mlhdr $grp $nhdrs
#		ml_add_hdrs mlhdr "archive_$grp" $ohdrs
#	}
#}
#
#proc archive_mlphdr {a} {
#	set thr [expr "[clock sec]-$a"]
#	set p [array names ::peerstore]
#	foreach per $p {
#		set hdrs [lrange [ml_get_hdrs 365 mlphdr $per] 2 end]
#		set nhdrs {}
#		set ohdrs {}
#		log_puts "ALL" "hdrs $hdrs"
#		foreach hdr $hdrs {
#			set h [header_to_dict $hdr]
#			if { $h == "" } {
#				log_puts "ERR" "bad header $hdr"
#				continue
#			}
#			set epoch [dict get $h epoch]
#			log_puts "ALL" "epoch $epoch vs thr $thr"
#			if { $epoch > $thr } {
#				lappend nhdrs $hdr
#			} else {
#				#set hash [dict get $h hash]
#				#file rename [file join $::filepath "mailnews" "$hash" ] [file join $::filepath "mailnews" "archive" $hash ]
#				lappend ohdrs $hdr
#			}
#		}
#		file delete [file join $::filepath "mlphdr" "$per.dat"]
#		ml_add_hdrs mlphdr $per $nhdrs
#		ml_add_hdrs mlphdr "archive_$per" $ohdrs
#	}
#}
#
#proc archive_mailnews {a} {
#	set thr [expr "[clock sec]-$a"]
#	set files [glob -nocomplain -type f -directory [file join $::filepath "mailnews"] *]
#	foreach f $files {
#		log_puts "WARN" "file to check $f"
#		file stat $f statvar
#		set epoch $statvar(ctime)
#		if { $epoch > $thr } {
#			log_puts "WARN" "new enough"
#		} else {
#			log_puts "WARN" "old, moving to archive"
#			set af [file join $::filepath "mailnews" "archive" [lindex [file split $f] end]]
#			if { [file exists $af] == 0 } {
#				file rename $f $af
#			}
#		}
#	}
#}

proc sanitize_stores {} {
	foreach {key val} [array get ::sources] {
		array unset ::sources "$key"
		if { [regexp -all {:} $val] > 0 || [string length $val] != 64} {	
			continue
		} else {	
			array set ::sources [list "$key" "$val"]
		}
	}
	foreach {key val} [array get ::headers] {
		array unset ::headers "$key"
		if { [header_to_dict $val] == "" || [regexp -all {:} $val] < 11} {
			continue
		} else {
			array set ::headers [list "$key" "$val"]
		}
	}
	foreach {key val} [array get ::groups] {
		array unset ::groups "$key"
		if { [ml_groupdict $val] == "" } {
			continue
		} else {
			array set ::groups [list "$key" "$val"]
		}
	}
	foreach {key val} [array get ::contacts] {
		array unset ::contacts "$key"
		if { [contact_to_dict $val] == "" } {
			continue
		} else {
			array set ::contacts [list "$key" "$val"]
		}
	}
}

proc hash_files {} {
	log_puts "ALL" "hash files"
	foreach ldir {share downloads} {
		set dir [file join $::filepath $ldir ]
		if { [ file exists $dir ] == 0 } {
			file mkdir $dir
		}
		if { [ file isdirectory $dir ] == 0 } {
			log_puts "ERR" "ERR $dir is not a directory"
			return
		}
		foreach file [glob -nocomplain -directory $dir *] {
			if { [file isfile $file] == 1 } { 
			hash_file $file
			}
		}
	}
}

proc hash_file {file} {
	log_puts "ALL" "hashing $file"
	set d {}
	set file_e [wrap $file]
	dict set d name $file_e
	dict set d size [file size $file]
	if { [array names ::hash_by_file $file_e] != "" } {
		log_puts "WARN" "file $file already hashed"
		return
	}
	set data {}
	catch {
	set c [open $file r]
	fconfigure $c -translation binary
	set data [read $c]
	close $c
	} res
	if { $data == {} } {
		log_puts "ERR" "hash_file failed to read $file"
		return
	}
	set hash [ crypto_cksum -hex $data ]
	array set ::file_by_hash [list $hash $d]
	array set ::hash_by_file [list $file_e $hash]
	array set ::sources [list $hash $::me(id)]
	array set ::sources [list [crypto_cksum $hash] $::me(id)]
}

proc show_startshield {} {
	wm title . "[::msgcat::mc "Mysteria"] [clock microseconds]"
	set w ".startshield"
	pack [panedwindow $w -ori vert] -fill both
	$w add [wframe "$w.f"] -stretch never
	pack [wlabel "$w.f.l" -text [::msgcat::mc "Mysteria"] -font {Serif 18} ] -fill both
	pack [wlabel "$w.f.ll" -text [::msgcat::mc "shield_l"] -font {Serif 9} ] -fill both
	$w add [wframe "$w.b"] -stretch never
	pack [wbutton "$w.b.opt" -text [::msgcat::mc {Options}] -command {show_options} -font {Serif 9} -activebackground $::options(hilightcolor) -activeforeground $::options(basecolor) -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) ] -fill both 
	pack [wbutton "$w.b.gdir" -text [::msgcat::mc {GDirectory}] -command {show_group_directory} -font {Serif 9} -activebackground $::options(hilightcolor) -activeforeground $::options(basecolor) -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) ] -fill both 
	pack [wbutton "$w.b.cdir" -text [::msgcat::mc {Directory}] -command {show_directory} -font {Serif 9} -activebackground $::options(hilightcolor) -activeforeground $::options(basecolor) -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) ] -fill both 
	pack [wbutton "$w.b.mn" -text [::msgcat::mc {Mail/News}] -command {show_mail} -font {Serif 9} -activebackground $::options(hilightcolor) -activeforeground $::options(basecolor) -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) ] -fill both 
	#pack [wbutton "$w.b.ol" -text {Roster} -command {show_tree} -font {Serif 9} -activebackground $::options(hilightcolor) -activeforeground $::options(basecolor) -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) ] -fill both 
	pack [wbutton "$w.b.gl" -text [::msgcat::mc {Groups}] -command {show_grouplist} -font {Serif 9} -activebackground $::options(hilightcolor) -activeforeground $::options(basecolor) -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) ] -fill both 
	pack [wbutton "$w.b.bl" -text [::msgcat::mc {Buddies}] -command {show_buddylist} -font {Serif 9} -activebackground $::options(hilightcolor) -activeforeground $::options(basecolor) -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) ] -fill both 
	pack [wbutton "$w.b.gsig" -text [::msgcat::mc {GRequests}] -command {show_mygroups} -font {Serif 9} -activebackground $::options(hilightcolor) -activeforeground $::options(basecolor) -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) ] -fill both 
	pack [wbutton "$w.b.psig" -text [::msgcat::mc {Requests}] -command {show_reqmanager p *} -font {Serif 9} -activebackground $::options(hilightcolor) -activeforeground $::options(basecolor) -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) ] -fill both 
	pack [wbutton "$w.b.dls" -text [::msgcat::mc {Downloads}] -command {show_dlstate} -font {Serif 9} -activebackground $::options(hilightcolor) -activeforeground $::options(basecolor) -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) ] -fill both 
	pack [wbutton "$w.b.dbg" -text [::msgcat::mc {Debug}] -command {show_debug} -font {Serif 9} -activebackground $::options(hilightcolor) -activeforeground $::options(basecolor) -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) ] -fill both 
	pack [wbutton "$w.b.kill" -text [::msgcat::mc {Exit}] -command {write_all;exit} -font {Serif 9} -activebackground $::options(hilightcolor) -activeforeground $::options(basecolor) -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) ] -fill both 
	wm deiconify .
}

proc show_buddy_del {hash} {
	log_puts "ALL" "buddy del $hash request"
	if { [winfo exists .bd] == 1} {
		return
	}
	if { [llength $hash] > 1 } {
		return
	}
	set buddy [lindex [array get ::buddies $hash] 1]
	set b [contact_to_dict $buddy]
	toplevel .bd
	wm title .bd [::msgcat::mc "buddydel_t"] 
	pack [panedwindow .bd.p -ori vert] -fill both -expand 1
	.bd.p add [wframe .bd.p.f0]
	pack [wlabel .bd.p.f0.q -text [::msgcat::mc "buddydel_l" [dict get $b nickname] [dict get $b peerid] $hash"] -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) -font $::options(font) ] -fill both -side left
	.bd.p add [wframe .bd.p.f1]
	pack [wbutton .bd.p.f1.yes -text [::msgcat::mc "delete"] -activebackground $::options(hilightcolor) -activeforeground $::options(basecolor) -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor)  -font $::options(font) -command "array unset ::buddies $hash ; after 50 update_buddies ; destroy .bd ; destroy .bv"] -fill both -side right
	pack [wbutton .bd.p.f1.no -text [::msgcat::mc "cancel"] -activebackground $::options(hilightcolor) -activeforeground $::options(basecolor) -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor)  -font $::options(font) -command "destroy .bd"] -fill both -side right 
	
}

proc show_buddy_details {hash} {
	log_puts "ALL" "show_buddy_details $hash"
	if { [winfo exists .bv] == 1} {
		return
	}
	if { [llength $hash] != 1 } {
		return
	}
	set buddy [lindex [array get ::buddies $hash] 1]
	set b [contact_to_dict $buddy]

	append t "Nickname:\t [dict get $b nickname]\n"
	append t "Id:\t [dict get $b peerid]\n"
	append t "\n%%%\n\n"
	append t "Birthday:\t [dict get $b birthday]\n"
	append t "Sex:\t [dict get $b sex]\n"
	append t "Country:\t [dict get $b country]\n"
	append t "City:\t [dict get $b city]\n"
	append t "\n%%%\n\n"
	append t "Pubkey:\n[dict get $b pubkey]\n\n"
	append t "\n%%%\n\n"

	toplevel .bv
	wm title .bv [::msgcat::mc "buddyview_t"]
	pack [panedwindow .bv.p -ori vert] -fill both -expand 1
	.bv.p add [wframe .bv.p.f1]
	#pack [wbutton .bv.p.f1.c -text [::msgcat::mc "chat"]  -activebackground $::options(hilightcolor) -activeforeground $::options(basecolor) -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor)  -font $::options(font) -command "show_gchatwindow chat $hash"] -fill both -side left
	pack [wbutton .bv.p.f1.f -text [::msgcat::mc "files"]  -activebackground $::options(hilightcolor) -activeforeground $::options(basecolor) -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor)  -font $::options(font) -command "ml_personbrowse $buddy"] -fill both -side left
	#pack [wbutton .bv.p.f1.m -text [::msgcat::mc "mail"]  -activebackground $::options(hilightcolor) -activeforeground $::options(basecolor) -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor)  -font $::options(font) -command "set ::cur(main,mode) p ; show_editor $::buddies($hash)"] -fill both -side left
	if { $::options(audio_enabled) == 1 } {
		pack [wbutton .bv.p.f1.a -text [::msgcat::mc "call"] -activebackground $::options(hilightcolor) -activeforeground $::options(basecolor) -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor)  -font $::options(font) -command "set ::audiopeerid $hash ; show_audio"] -fill both -side left
	}
	#pack [wbutton .bv.p.f1.v -text [::msgcat::mc "exit"] -activebackground $::options(hilightcolor) -activeforeground $::options(basecolor) -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor)  -font $::options(font) -command "destroy .bv"] -fill both -side right
	pack [wbutton .bv.p.f1.x -text [::msgcat::mc "delete"]  -activebackground $::options(hilightcolor) -activeforeground $::options(basecolor) -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor)  -font $::options(font) -command "show_buddy_del $hash"] -fill both -side right 
	.bv.p add [wframe .bv.p.f0]
	pack [wlabel .bv.p.f0.t -text $t -wraplength 480 -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) -font $::options(listfont) -justify left ] -fill both -side right
}

proc chat_showoffer {hash body} {
	log_puts "ALL" "chat_showoffer $hash $body"
	array set ::buddies [list $hash $body]
	after 50 update_buddies
	if { [winfo exists .co] == 1} {
		return
	}
	set b [contact_to_dict $body]
	toplevel .co
	wm title .co [::msgcat::mc "chatoffer_t" [dict get $b nickname]]
	pack [panedwindow .co.p -ori vert] -fill both -expand 1
	.co.p add [wframe .co.b0]
	pack [wlabel .co.b0.ml -text "id: " -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) -font $::options(font) ] -fill both -side left 
	pack [wlabel .co.b0.m -text [dict get $b peerid] -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) -font $::options(font) -width 24 ] -fill both -side left 
	pack [wbutton .co.b0.v -text [::msgcat::mc "ok"] -activebackground $::options(hilightcolor) -activeforeground $::options(basecolor) -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor)  -font $::options(font) -command "after 50 update_buddies ; destroy .co"] -fill both -side right
	pack [wbutton .co.b0.x -text [::msgcat::mc "delete"] -activebackground $::options(hilightcolor) -activeforeground $::options(basecolor) -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor)  -font $::options(font) -command "array unset ::buddies $hash ; after 50 update_buddies ; destroy .co"] -fill both -side right 
	.co.p add [wframe .co.b1]
	pack [wlabel .co.b1.tl -text "Nickname: " -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) -font $::options(font)] -fill both -side left 
	pack [wlabel .co.b1.t -text [dict get $b nickname] -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) -font $::options(font) -width 24 ] -fill both -side right
	.co.p add [wframe .co.b2]
	pack [wlabel .co.b2.lage -text "Birthday: " -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) -font $::options(font) ] -fill both -side left
	pack [wlabel .co.b2.age -text [dict get $b birthday] -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) -font $::options(font) -width 24 ] -fill both -side right 
	.co.p add [wframe .co.b3]
	pack [wlabel .co.b3.lsex -text "Sex: " -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) -font $::options(font) ] -fill both -side left
	pack [wlabel .co.b3.sex -text [dict get $b sex] -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) -font $::options(font) -width 24 ] -fill both -side right
	.co.p add [wframe .co.b4]
	pack [wlabel .co.b4.lcountry -text "Country: " -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) -font $::options(font) ] -fill both -side left
	pack [wlabel .co.b4.country -text [dict get $b country] -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) -font $::options(font) -width 24 ] -fill both -side right
	.co.p add [wframe .co.b5]
	pack [wlabel .co.b5.lcity -text "City: " -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) -font $::options(font) ] -fill both -side left
	pack [wlabel .co.b5.city -text [dict get $b city] -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) -font $::options(font) -width 24 ] -fill both -side right
}

proc show_contactform {} {
	if { [winfo exists .cf] == 1} {
		return
	}
	toplevel .cf
	wm title .cf [::msgcat::mc "createcontact_t"]
	pack [panedwindow .cf.p -ori vert] -fill both -expand 1
	.cf.p add [wframe .cf.b0]
	pack [wlabel .cf.b0.ml -text "id: " -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) -font $::options(font) ] -fill both -side left 
	pack [wlabel .cf.b0.m -textvariable ::me(id) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) -font $::options(font) -width 24 ] -fill both -side left 
	pack [wbutton .cf.b0.v -text [::msgcat::mc "commit"] -activebackground $::options(hilightcolor) -activeforeground $::options(basecolor) -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor)  -font $::options(font) -command {sc_publishcontact [form_contact] ; destroy .cf}] -fill both -side right
	#pack [wbutton .cf.b0.x -text [::msgcat::mc "exit"] -activebackground $::options(hilightcolor) -activeforeground $::options(basecolor) -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor)  -font $::options(font) -command {destroy .cf}] -fill both -side right 
	.cf.p add [wframe .cf.b1]
	pack [wlabel .cf.b1.tl -text "Nickname: " -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) -font $::options(font)] -fill both -side left 
	pack [wentry .cf.b1.t -textvariable ::me(nickname) -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) -selectforeground $::options(basecolor) -selectbackground $::options(hilightcolor) -font $::options(font) -width 24 ] -fill both -side right
	.cf.p add [wframe .cf.b2]
	pack [wlabel .cf.b2.lage -text "Birthday: " -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) -font $::options(font) ] -fill both -side left
	pack [wentry .cf.b2.age -textvariable ::card(birthday) -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) -selectforeground $::options(basecolor) -selectbackground $::options(hilightcolor) -font $::options(font) -width 24 ] -fill both -side right 
	.cf.p add [wframe .cf.b3]
	pack [wlabel .cf.b3.lsex -text "Sex: " -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) -font $::options(font) ] -fill both -side left
	pack [wentry .cf.b3.sex -textvariable ::card(gender) -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) -selectforeground $::options(basecolor) -selectbackground $::options(hilightcolor) -font $::options(font) -width 24 ] -fill both -side right
	.cf.p add [wframe .cf.b4]
	pack [wlabel .cf.b4.lcountry -text "Country: " -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) -font $::options(font) ] -fill both -side left
	pack [wentry .cf.b4.country -textvariable ::card(country) -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) -selectforeground $::options(basecolor) -selectbackground $::options(hilightcolor) -font $::options(font) -width 24 ] -fill both -side right
	.cf.p add [wframe .cf.b5]
	pack [wlabel .cf.b5.lcity -text "City: " -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) -font $::options(font) ] -fill both -side left
	pack [wentry .cf.b5.city -textvariable ::card(city) -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) -selectforeground $::options(basecolor) -selectbackground $::options(hilightcolor) -font $::options(font) -width 24 ] -fill both -side right
}

proc show_directory {} {
	if { [winfo exists .d] == 1} {
		return
	}
	toplevel .d
	wm title .d [::msgcat::mc {Directory}]
	pack [panedwindow .d.p -ori vert ] -fill both -expand 1
	.d.p add [wframe ".d.e"]
	pack [wbutton .d.e.c -text [::msgcat::mc "create"] -activebackground $::options(hilightcolor) -activeforeground $::options(basecolor) -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor)  -font $::options(font) -command {show_contactform}] -fill both -side left 
	pack [wbutton .d.e.p -text [::msgcat::mc "publish"] -activebackground $::options(hilightcolor) -activeforeground $::options(basecolor) -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor)  -font $::options(font) -command {sc_publishcontact $::me(contact)}] -fill both -side left 
	pack [wentry .d.e.e -textvariable ::contactfield -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) -selectforeground $::options(basecolor) -selectbackground $::options(hilightcolor) -font $::options(listfont) ] -fill both -side left
	pack [wbutton .d.e.s -text [::msgcat::mc "search"] -activebackground $::options(hilightcolor) -activeforeground $::options(basecolor) -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor)  -font $::options(font) -command {
		.d.e.s configure -state disabled;
		.d.e.st configure -state normal;
		show_contacts [sc_get_contacts [prep_contact_keys $::contactfield]]
	}] -fill both -side right
	pack [wbutton .d.e.st -text [::msgcat::mc "stop"] -activebackground $::options(hilightcolor) -activeforeground $::options(basecolor) -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor)  -font $::options(font) -command {
		.d.e.s configure -state normal; 
		.d.e.st configure -state disabled;
		sc_stop $::contactsearch
	} -state disabled] -fill both -side right
	#pack [wbutton .d.e.o -text [::msgcat::mc "mail"] -activebackground $::options(hilightcolor) -activeforeground $::options(basecolor) -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor)  -font $::options(font) -command {set ::cur(main,mode) {p} ; set ::cur(main,person,h) [lindex $::contactlist(main,k) [lindex [.d.l.l index active] 0]] ; show_editor {}}] -fill both -side right
	#pack [wbutton .d.e.det -text [::msgcat::mc "detail"] -activebackground $::options(hilightcolor) -activeforeground $::options(basecolor) -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor)  -font $::options(font) -command {show_buddy_details [lindex $::contactlist(main,k) [lindex [.d.l.l index active] 0]]}] -fill both -side right
	pack [wbutton .d.e.cht -text [::msgcat::mc "add"] -activebackground $::options(hilightcolor) -activeforeground $::options(basecolor) -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor)  -font $::options(font) -command {chat_offer [chat_add [lindex $::contactlist(main,k) [lindex [.d.l.l index active] 0]]] ; destroy .d}] -fill both -side right
	#pack [wbutton .d.e.x -text [::msgcat::mc "exit"] -activebackground $::options(hilightcolor) -activeforeground $::options(basecolor) -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor)  -font $::options(font) -command {destroy .d}] -fill both -side right
	.d.p add [wframe ".d.l"]
	pack [wscrollbar .d.l.y -activebackground $::options(hilightcolor)  -troughcolor $::options(hilightcolor)  -command ".d.l.l yview"] -fill y -side right
	pack [listbox .d.l.l -listvariable ::contactlist(main,l) -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) -selectforeground $::options(basecolor) -selectbackground $::options(hilightcolor) -font $::options(listfont) -height 12 -yscrollc ".d.l.y set"] -fill both -expand 1 -side right
}

proc show_group_details {group} {
	if { [winfo exists .sgf] == 1} {
		return
	}
	if { $group == "" } {
		return
	}
	set g [ml_groupdict $group]
	toplevel .sgf
	wm title .sgf [::msgcat::mc "groupview_t"]
	pack [panedwindow .sgf.p -ori vert] -fill both -expand 1
	.sgf.p add [wframe .sgf.b1] -minsize 24 -stretch never
	if { [array get ::jgroups [dict get $g gid]] == "" } {
		pack [wbutton .sgf.b1.a -text [::msgcat::mc "add"]  -activebackground $::options(hilightcolor) -activeforeground $::options(basecolor) -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor)  -font $::options(font) -command "catch { set ::groups([dict get $g gid]) $group ; set ::jgroups([dict get $g gid]) $group ; ml_add_srcs [dict get $g gid] ${::me(id)} ;destroy .sgf ; after idle [list sc_publishcontact ${::me(contact)}] ; after idle [list ml_grouphead $group] }"] -fill both -side right
	} else {
		#pack [wbutton .sgf.b1.c -text [::msgcat::mc "chat"]  -activebackground $::options(hilightcolor) -activeforeground $::options(basecolor) -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor)  -font $::options(font) -command "show_gchatwindow gchat [dict get $g gid]"] -fill both -side left
		#pack [wbutton .sgf.b1.m -text [::msgcat::mc "mail"]  -activebackground $::options(hilightcolor) -activeforeground $::options(basecolor) -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor)  -font $::options(font) -command "show_gmailwindow [dict get $g gid]"] -fill both -side left
		pack [wbutton .sgf.b1.pub -text [::msgcat::mc "publish"]  -activebackground $::options(hilightcolor) -activeforeground $::options(basecolor) -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor)  -font $::options(font) -command "sc_publishgroup $group"] -fill both -side left
		pack [wbutton .sgf.b1.d -text [::msgcat::mc "delete"]  -activebackground $::options(hilightcolor) -activeforeground $::options(basecolor) -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor)  -font $::options(font) -command "array unset ::jgroups [dict get $g gid] ; destroy .sgf ; after idle [list ml_grouphead $group]"] -fill both -side right
	}
	.sgf.p add [wframe .sgf.b2] -minsize 24 -stretch never
	pack [wlabel .sgf.b2.lname -text "Name: " -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) -font $::options(font)] -fill both -side left 
	pack [wlabel .sgf.b2.name -text "[dict get $g name]" -wraplength 480 -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) -font $::options(listfont)] -fill both -side right 
	.sgf.p add [wframe .sgf.b3] -minsize 24 -stretch never
	pack [wlabel .sgf.b3.ldesc -text "Desc: " -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) -font $::options(font) ] -fill both -side left
	pack [wlabel .sgf.b3.desc -text "[dict get $g desc]" -wraplength 480 -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) -font $::options(listfont) ] -fill both -side right
	.sgf.p add [wframe .sgf.b4]
	pack [wlabel .sgf.b4.ldesc -text "Author peerID: " -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) -font $::options(font) ] -fill both -side left
	pack [wlabel .sgf.b4.desc -text "[dict get $g peerid]" -wraplength 480 -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) -font $::options(listfont) ] -fill both -side right
	.sgf.p add [wframe .sgf.b5]
	pack [wlabel .sgf.b5.ldesc -text "Author psig: " -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) -font $::options(font) ] -fill both -side left
	pack [wlabel .sgf.b5.desc -text "[wrap [dict get $g psig]]" -wraplength 480 -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) -font $::options(listfont) ] -fill both -side right
	.sgf.p add [wframe .sgf.b6]
	pack [wlabel .sgf.b6.lpkey -text "Public key: " -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) -font $::options(font) ] -fill both -side left
	.sgf.p add [wframe .sgf.b7]
	pack [wlabel .sgf.b7.pkey -text "[dict get $g pkey]" -wraplength 480 -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) -font $::options(listfont) ] -fill both -side right
	.sgf.p add [wframe .sgf.b8]
	pack [wlabel .sgf.b8.lgid -text "GID: " -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) -font $::options(font) ] -fill both -side left
	pack [wlabel .sgf.b8.gid -text "[dict get $g gid]" -wraplength 480 -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) -font $::options(listfont) ] -fill both -side right

	set rule {}
	catch {
		set rule [lindex [array get ::rule $gid] 1]
	}
	if { $rule == {} } {
		ml_replay $group
	}
### that's a ::rule editor, not active if we are not a mod
# after replay
	array unset ::sgf_sel "*"
	set gid [dict get $g gid]
	set mods [dict get [lindex [array get ::rule $gid] 1] mods]
	set users [dict get [lindex [array get ::rule $gid] 1] users]
	set srcs [lrange [ml_get_srcs [dict get $g gid]] 2 end]
	set l_obj {}
	foreach src $srcs {
		set contacts {}
		# nickname, id, enum button between mod, user and dash 
		foreach {key val} [array get ::contacts "[shawrap contact:$src]*"] {
			lappend contacts $val
		}
		set contacts [lsort -unique $contacts]
		set csorted {}
		foreach contact $contacts {
			set c [contact_to_dict $contact]
			if { $c != {} && [dict get $c sig] != {} } {
				set desc "[dict get $c nickname]:$src"
				set epoch [dict get $c epoch]
				lappend csorted $desc $epoch
			}
		}
		lappend csorted "#$src:$src" 0
		set csorted [lsort -decreasing -stride 2 -index end $csorted]
		set desc [lindex $csorted 0]
		set role nobody
		if { [lsearch -all -inline -exact $users $src] != {} || $users == "*" } {
			set role user 
		}
		if { [lsearch -all -inline -exact $mods $src] != {} } {
			set role mod
		}
		lappend l_obj $src $desc $role
	}
	.sgf.p add [wframe .sgf.b9] -minsize 24 -stretch never
	pack [wlabel .sgf.b9.l -text [::msgcat::mc "Sources of group: "] -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) -font $::options(font) ] -fill both -side left
	set choice {nobody user mod}
	foreach {src desc role} $l_obj {
		.sgf.p add [wframe .sgf.c_$src] -minsize 24 -stretch never
		pack [wlabel .sgf.c_$src.desc -text "$desc" -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) -font $::options(font) ] -side left
		if { [lsearch -all -inline $mods $::me(id)] != {} } {
			set e [tk_optionMenu .sgf.c_$src.role ::sgf_sel($gid,$src,role) {*}$choice]
			$e configure -font $::options(font) -activebackground $::options(hilightcolor) -activeforeground $::options(basecolor)
			.sgf.c_$src.role configure -font $::options(font) -activebackground $::options(hilightcolor) -activeforeground $::options(basecolor) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor)
			pack .sgf.c_$src.role -side right
			set ::sgf_sel($gid,$src,role) $role
		} else {
			pack [wlabel .sgf.c_$src.role -text "$role" -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) -font $::options(font) ] -side right
		}
	}
	proc rule_cmd {gid} {
		set nmods {}
		set nusers {}
		set srcs [lrange [ml_get_srcs $gid] 2 end]
		set gpeerid [dict get [ml_groupdict $::jgroups($gid)] peerid]
		foreach src [lsort -unique $srcs] {
			set role [lindex [array get ::sgf_sel "$gid,$src,role"] 1]
			switch $role {
				"mod" {
					lappend nusers $src
					lappend nmods $src
				}
				"user" {
					lappend nusers $src
				}
			}
		}
		lappend nmods $gpeerid
		set nmods [lsort -unique $nmods]
		lappend nusers $gpeerid
		set nusers [lsearch -all -inline -not -exact [lsort -unique $nusers] "*"]
		set rule {}
		dict set rule mods $nmods
		dict set rule users $nusers
		set ::rule($gid) $rule
		rule_send $gid
	}
	.sgf.p add [wframe .sgf.c] -minsize 24 -stretch never
	if { [lsearch -all -inline $mods $::me(id)] != {} } {
		pack [wbutton .sgf.c.s -text [::msgcat::mc "post control rule"] -activebackground $::options(hilightcolor) -activeforeground $::options(basecolor) -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) -font $::options(font) -command "rule_cmd $gid" ] -fill both -side right 
	}


###
}

proc show_groupform {} {
	if { [winfo exists .gf] == 1} {
		return
	}
	set commit_cmd {
		array set ::groups [list ${::gcard(gid)} $::g_group]
		array set ::jgroups [list ${::gcard(gid)} $::g_group]
		array set ::my_groups [list ${::gcard(gid)} [wrap $::g_key]]
		sc_publishgroup $::g_group	
		ml_add_srcs ${::gcard(gid)} $::me(id)
		ml_add_sigreq g ${::gcard(gid)} $::me(contact)
		set pkey [crypto_parse_priv $::g_key]
		set req [lindex [array get ::group_to_sigreq "${::gcard(gid)},${::me(id)}"] end]
		#set sig "$req:[wrap [crypto_sig $req $pkey]]"
		#array set ::group_to_sig [list "${::gcard(gid)},${::me(id)}" $sig]
		destroy .gf
		ml_grouphead $::g_group
		set ::cur(main,mode) {g}
		set ::cur(main,group,h) $::g_group 
		set ::cur(main,group,l) [dict get [ml_groupdict $::g_group] name]
		ml_showlist g [dict get [ml_groupdict $::g_group] gid]
	}
	toplevel .gf
	wm title .gf [::msgcat::mc "groupcreate_t"]
	pack [panedwindow .gf.p -ori vert] -fill both -expand 1
	.gf.p add [wframe .gf.b0] -minsize 24 -stretch never
	pack [wlabel .gf.b0.ml -text [::msgcat::mc "groupcreate_l"] -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) -font $::options(font) ] -fill both -side left 
	pack [wbutton .gf.b0.v -text [::msgcat::mc "commit"]  -activebackground $::options(hilightcolor) -activeforeground $::options(basecolor) -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor)  -font $::options(font) -command $commit_cmd] -fill both -side right
	pack [wbutton .gf.b0.g -text [::msgcat::mc "generate"]  -activebackground $::options(hilightcolor) -activeforeground $::options(basecolor) -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor)  -font $::options(font) -command {generate_group}] -fill both -side right
	.gf.p add [wframe .gf.b1] -minsize 24 -stretch never
	pack [wlabel .gf.b1.lname -text "Name: " -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) -font $::options(font)] -fill both -side left 
	pack [wentry .gf.b1.name -textvariable ::gcard(name) -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) -selectforeground $::options(basecolor) -selectbackground $::options(hilightcolor) -font $::options(listfont) -width 24 ] -fill both -side right
	.gf.p add [wframe .gf.b2] -minsize 24 -stretch never
	pack [wlabel .gf.b2.ldesc -text "Desc: " -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) -font $::options(font) ] -fill both -side left
	pack [wentry .gf.b2.desc -textvariable ::gcard(desc) -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) -selectforeground $::options(basecolor) -selectbackground $::options(hilightcolor) -font $::options(listfont) -width 24 ] -fill both -side right 
	.gf.p add [wframe .gf.b3]
	pack [wlabel .gf.b3.ldesc -text "peerID: " -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) -font $::options(font) ] -fill both -side left
	pack [wlabel .gf.b3.desc -textvariable ::me(id) -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) -font $::options(listfont) -width 24 ] -fill both -side right 
	.gf.p add [wframe .gf.b5]
	pack [wlabel .gf.b5.lkey -text "Key: " -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) -font $::options(font) ] -fill both -side left
	.gf.p add [wframe .gf.b6]
	pack [text .gf.b6.key -wrap word -yscrollc {.gf.b6.key_sb set} -height 12 -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) -font $::options(listfont) ] -fill both -expand 1 -side left
	pack [wscrollbar .gf.b6.key_sb -activebackground $::options(hilightcolor)  -troughcolor $::options(hilightcolor)  -command {.gf.b6.key yview}] -fill y -side right
	.gf.p add [wframe .gf.b7]
	pack [wlabel .gf.b7.lpkey -text "Public key: " -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) -font $::options(font) ] -fill both -side left
	.gf.p add [wframe .gf.b8]
	pack [wlabel .gf.b8.pkey -textvariable ::gcard(pkey) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) -font $::options(listfont) ] -fill both -side left
	.gf.p add [wframe .gf.b9]
	pack [wlabel .gf.b9.lgid -text "GID: " -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) -font $::options(font) ] -fill both -side left
	pack [wlabel .gf.b9.gid -textvariable ::gcard(gid) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) -font $::options(listfont) ] -fill both -side left
	proc generate_group {} {
		set key [.gf.b6.key get 1.0 end]
		set gkey {}
		catch {
		set gkey [crypto_parse_priv $key]
		}
		if { $gkey == "" } {
			set gkey [crypto_gen 1024]
			set key [crypto_exp_priv $gkey]
		}
		set gpkey [crypto_exp_pub $gkey]
		set gid [crypto_cksum -hex $gpkey]
		set psig [crypto_sig $::me(id) $gkey]
		set ::g_key $key
		set ::gcard(pkey) $gpkey
		set ::gcard(gid) $gid
		.gf.b6.key delete 1.0 end
		.gf.b6.key insert end $key
		set g {}
		dict set g gid ${::gcard(gid)}
		dict set g name [lindex [array get ::gcard name] end]
		dict set g desc [lindex [array get ::gcard desc] end]
		dict set g pkey ${::gcard(pkey)}
		dict set g epoch [clock seconds] 
		dict set g peerid $::me(id)
		dict set g psig $psig
		set ::g_group [ml_dictgroup $g]
	}
}

proc show_group_directory {} {
	if { [winfo exists .gd] == 1} {
		return
	}
	toplevel .gd
	wm title .gd [::msgcat::mc "groupdir_t"] 
	pack [panedwindow .gd.p -ori vert ] -fill both -expand 1
	.gd.p add [wframe ".gd.e"]
	pack [wbutton .gd.e.c -text [::msgcat::mc "create"]  -activebackground $::options(hilightcolor) -activeforeground $::options(basecolor) -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor)  -font $::options(font) -command {show_groupform}] -fill both -side left 
	pack [wentry .gd.e.e -textvariable ::groupfield(main) -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) -selectforeground $::options(basecolor) -selectbackground $::options(hilightcolor) -font $::options(listfont) ] -fill both -side left
	pack [wbutton .gd.e.s -text [::msgcat::mc "search"]  -activebackground $::options(hilightcolor) -activeforeground $::options(basecolor) -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor)  -font $::options(font) -command {
		.gd.e.s configure -state disabled;
		.gd.e.st configure -state normal;
		show_groups [sc_get_groups [prep_group_keys $::groupfield(main)]]
	}] -fill both -side right
	pack [wbutton .gd.e.st -text [::msgcat::mc "stop"]  -activebackground $::options(hilightcolor) -activeforeground $::options(basecolor) -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor)  -font $::options(font) -command {
		.gd.e.s configure -state normal; 
		.gd.e.st configure -state disabled;
		sc_stop $::groupsearch
	} -state disabled] -fill both -side right
	pack [wbutton .gd.e.o -text [::msgcat::mc "detail"]  -activebackground $::options(hilightcolor) -activeforeground $::options(basecolor) -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor)  -font $::options(font) -command {show_group_details [lindex $::grouplist(main,k) [lindex [.gd.l.l index active] 0]] ; destroy .gd}] -fill both -side right
	.gd.p add [wframe ".gd.l"]
	pack [wscrollbar .gd.l.y -activebackground $::options(hilightcolor)  -troughcolor $::options(hilightcolor)  -command ".gd.l.l yview"] -fill y -side right
	pack [listbox .gd.l.l -listvariable ::grouplist(main,l) -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) -selectforeground $::options(basecolor) -selectbackground $::options(hilightcolor) -font $::options(listfont) -height 12 -yscrollc ".gd.l.y set"] -fill both -expand 1 -side right
}

proc make_menu {w} {
	set m "$w.menu"
	set mc "$w.menu.menu"
	if { [winfo exists $m] == 1 } {
		return
	}
	if { [winfo exists $w] == 0 } {
		return
	}
	menu $m -activeforeground $::options(basecolor) -activebackground $::options(hilightcolor) -font $::options(font) 
	menu $mc -tearoff 0 -activeforeground $::options(basecolor) -activebackground $::options(hilightcolor) -font $::options(font)
	$m add cascade -menu $mc -label {menu}
	$mc add command -command {show_options} -label {options} 
	$mc add command -command {show_group_directory} -label {group directory} 
	$mc add command -command {show_directory} -label {directory} 
	$mc add command -command {show_mail} -label {news/mail} 
	#$mc add command -command {show_tree} -label {roster} 
	$mc add command -command {show_grouplist} -label {groups} 
	$mc add command -command {show_buddylist} -label {buddies} 
	$mc add command -command {show_mygroups} -label {my groups} 
	$mc add command -command {show_reqmanager p *} -label {my requests} 
	$mc add command -command {show_dlstate} -label {dlstate} 
	if { $::options(audio_enabled) == 1 } {
		$mc add command -command {show_audio} -label {audio} 
	}
	#$mc add command -command {show_files {}} -label {files} 
	$mc add command -command {show_debug} -label {debug} 
	#$mc add command -command "destroy $w" -label {exit} 
	$mc add command -command {write_all;exit} -label {kill} 
	$w configure -menu $m
}

proc make_nmenu {} {
	set m .nmenu
	if { [winfo exists $m] == 1 } {
		return
	}
	menu $m -tearoff 0 -activeforeground $::options(basecolor) -activebackground $::options(hilightcolor) -font $::options(font)
	$m add command -command {show_options} -label {options} 
	$m add command -command {show_group_directory} -label {group directory} 
	$m add command -command {show_directory} -label {directory} 
	$m add command -command {show_mail} -label {news/mail} 
	#$m add command -command {show_tree} -label {roster} 
	$m add command -command {show_grouplist} -label {groups} 
	$m add command -command {show_buddylist} -label {buddies} 
	$m add command -command {show_mygroups} -label {my groups} 
	$m add command -command {show_reqmanager p *} -label {my requests} 
	#$m add command -command {show_downloads} -label {downloads} 
	$m add command -command {show_dlstate} -label {dlstate} 
	if { $::options(audio_enabled) == 1 } {
		$m add command -command {show_audio} -label {audio} 
	}
	$m add command -command {show_debug} -label {debug} 
	$m add command -command {write_all;exit} -label {kill} 
}

proc ml_screen {mode id host port} {
	log_puts "ALL" "ml_screen host $host port $port"
	set found {}
	foreach peer [lsearch -all -inline [array get ::peerstore] "*:$host:$port:*"] {
		lappend found [lindex [split $peer {:}] 0]
	}
	#log_puts "ALL" "ml_screen found all $found"
	set found [lindex [lsort -unique $found] 0]
	log_puts "ALL" "ml_screen found unique $found"
	#set ret [ml_check_sig $mode $id $found 0]
	set ret [ml_check_inc $mode $id $found]
	log_puts "ALL" "ml_screen ret $ret"
	if { $ret != 0 } {
		set cfound [lsearch -all -inline [array get ::contacts] "$found:*"]
		log_puts "ALL" "ml_screen cfound $cfound len [llength $cfound]"
		if { [llength $cfound] > 0 } {
			foreach contact $cfound {
				#log_puts "ALL" "ml_screen contact $contact"
				log_puts "ALL" "ml_screen add sigreq mode $mode id $id contact $contact"
				ml_add_sigreq $mode $id $contact
			}
		} elseif { $found != {} } {
			set contact [latest_contact $found]
			if { $contact == {} } {
				set c {}
				dict set c nickname "#$found"
				dict set c peerid $found
				dict set c city {}
				dict set c country {}
				dict set c sex {}
				dict set c birthday {}
				dict set c epoch [clock seconds] 
				dict set c sig {} 
				dict set c pubkey [unwrap [lindex [split [lindex [array get ::peerstore $found] 1] {:}] 3]]
				set contact [dict_to_contact $c]
			}
			log_puts "ALL" "ml_screen add sigreq mode $mode id $id fallback contact $contact"
			ml_add_sigreq $mode $id $contact
		}
	} else {
		if { $mode == {p} } {
			array unset ::person_to_sigreq $::me(id),$found
		} elseif { $mode == {g} } {
			array unset ::group_to_sigreq $id,$found
		}	
	}
	return $ret
}

proc ml_check_inc {mode id peerid} {
	if { $mode == {p} } {
		set buddyhash [crypto_cksum [lsort [list $peerid $::me(id)]]]
		if { [array get ::buddies $buddyhash] != {} } {
			return 0
		} else {
			return 1
		}
	} elseif { $mode == {g} } {
		set group {}
		catch {
			set group $::jgroups($id)
		}
		if { $group == {} } {
			return 1
		}
		set rule {}
		catch {
			set rule $::rule($id)
		}
		if { $rule == {} } {
			ml_replay $group
		}
		set rule $::rule($id)
		set ret [rule_check_gchat $id [wrap "intruder:$peerid"]]
		if { $ret == "allow" } {
			return 0
		} else {
			return 1
		}
	} else {
		return 1	
	}
}

#proc ml_check_sig {mode id peerid check} {
#	log_puts "ALL" "ml_check_sig mode $mode id $id peerid $peerid"
#	if { $mode == {g} } {
#		set fsig [array get ::group_to_sig "$id,$peerid"]
#		if { $fsig == "" } {
#			log_puts "ERR" "no such sig $id,$peerid"
#			#sc_get_contacts [prep_contact_keys $peerid]
#			return -1
#		}
#		if { $check != 1 } {
#			return 0
#		}
#		set grp [array get ::groups "$id"]
#		set g [ml_groupdict $grp]
#		if { $g == "" } {
#			log_puts "ERR" "no such group"
#			return -1
#		}
#		set pkey [dict get $g pkey]
#		set tock [lrange [split $fsig {:}] 0 end-1]
#		set sig [unwrap [lindex [split $fsig {:}] end]]
#		set ver [crypto_ver $sig $tock [crypto_parse_pub $pkey]]
#		if { $ver == "false" } {
#			log_puts "ERR" "sigerr"
#			return -1
#		} else {
#			return 0
#		}
#	} elseif { $mode == {p} } {
#		set fsig [array get ::person_to_sig "${::me(id)},$peerid"]
#		if { $fsig == "" } {
#			log_puts "ERR" "no such sig ${::me(id)},$peerid"
#			#sc_get_contacts [prep_contact_keys $peerid]
#			return -1
#		}
#		if { $check != 1 } {
#			return 0
#		}
#		set pkey [crypto_exp_pub $::me(key)]
#		set tock [lrange [split $fsig {:}] 0 end-1]
#		set sig [unwrap [lindex [split $fsig {:}] end]]
#		set ver [crypto_ver $sig $tock [crypto_parse_pub $pkey]]
#		if { $ver == "false" } {
#			log_puts "ERR" "sigerr"
#			return -1
#		} else {
#			return 0
#		}
#	}
#	return -1
#} 

proc ml_add_sigreq {mode id contact} {
	if { $mode == {g} } {
		set c [contact_to_dict $contact]
		if { $c == "" } {
			return
		}
		set peerid [dict get $c peerid]
		array set ::group_to_sigreq [list "$id,$peerid" $contact]
	} elseif { $mode == {p} } {
		set c [contact_to_dict $contact]
		if { $c == "" } {
			return
		}
		set peerid [dict get $c peerid]
		array set ::person_to_sigreq [list "${::me(id)},$peerid" $contact]
	}
}

proc show_mygroups {} {
	if { [winfo exists .mg] == 1 } {
		return
	}
	toplevel .mg
	wm title .mg [::msgcat::mc "mygroups_t"] 
	pack [panedwindow .mg.p -ori vert -width 240] -fill both -expand 1
	.mg.p add [wframe ".mg.top"] -stretch never
	pack [wlabel .mg.top.l -text [::msgcat::mc "mygroups_l"] -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) -font $::options(font) ] -fill both -side left
	.mg.p add [wframe ".mg.l"] -stretch always 
	pack [wscrollbar .mg.l.y -activebackground $::options(hilightcolor)  -troughcolor $::options(hilightcolor)  -command "tl_yview 1 .mg.l.l"] -fill y -side right
	pack [listbox .mg.l.l -listvariable ::mygrouplist(l) -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) -selectforeground $::options(basecolor) -selectbackground $::options(hilightcolor) -font $::options(font) -height 12 -yscrollc ".mg.l.y set"] -fill both -expand 1 -side right
	.mg.p add [wframe ".mg.b"] -stretch never
	pack [wbutton .mg.b.sm -text [::msgcat::mc "Members"] -activebackground $::options(hilightcolor) -activeforeground $::options(basecolor) -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor)  -font $::options(font) -command {show_reqmanager g [lindex $::mygrouplist(i) [lindex [.mg.l.l index active] 0]]} ] -fill both -side right
	set ::mygrouplist(l) {}
	set ::mygrouplist(i) {}
	set ::mygrouplist(k) {}
	foreach {key val} [array get ::my_groups] {
		set d [ml_groupdict [lindex [array get ::groups "$key"] end]]
		if { $d == "" } {
			continue
		}
		set dis "[dict get $d name] <[dict get $d gid]>"
		lappend ::mygrouplist(l) $dis
		lappend ::mygrouplist(i) $key
		lappend ::mygrouplist(k) $val
	}
}

proc show_reqmanager {mode id} {
	set w .rm
	if { [winfo exists $w] == 1 } {
		return
	}
	if { $id == {} } {
		return
	}
	if { $mode == "g" && [array names ::jgroups "$id"] != {} } {
		ml_replay $::jgroups($id)
		set users [dict get $::rule($id) users]
		foreach user $users {
			array unset ::group_to_sigreq "$id,$user"
		}
		set contacts [array get ::group_to_sigreq "$id,*"]
	} elseif { $mode == "p" } {
		set users {}
		foreach buddyhash [array names ::buddies] {
			set contact $::buddies($buddyhash)
			set c [contact_to_dict $contact]
			if { $c == {} } {
				continue
			}
			lappend users [dict get $c peerid]
		}
		foreach user $users {
			array unset ::group_to_sigreq "$id,$user"
		}
		set contacts [array get ::person_to_sigreq "$::me(id),*"]
	} else {
		return
	}
	proc after_add {mode id} {
		sc_publishcontact $::me(contact)
		if { $mode == {g} } {
			set ::cur(main,mode) $mode
			ml_grouphead [lindex [array get ::jgroups $id] end]
		} elseif { $mode == {p} } {
			set ::cur(main,mode) $mode
			ml_personhead [lsearch -inline [array get ::buddies] "$id:*"]
		}
	}
	toplevel $w 
	wm title $w [::msgcat::mc "reqman_t" $mode $id]
	pack [panedwindow $w.p -ori vert] -fill both -expand 1
	$w.p add [wframe $w.t]
	pack [wlabel $w.t.l -text [::msgcat::mc "reqman_l" $mode $id] -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) -font $::options(font) ] -fill both -side left
	if { [llength $contacts] == 0 } {
	$w.p add [wframe $w.te]
	pack [wlabel $w.te.l -text [::msgcat::mc "reqman_e"] -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) -font $::options(font) ] -fill both -side right 
	}
	set i 0
	foreach {reqk contact} $contacts {
		set c [contact_to_dict $contact]
		if { $c == {} } {
			continue
		}
		set peerid [dict get $c peerid]
		set nickname [dict get $c nickname]
		if { $mode == {p} } {
			set buddyhash [crypto_cksum [lsort [list $peerid $::me(id)]]]
			if { [array names ::buddies "$buddyhash"] != {} } {
				continue	
			}
		}
		$w.p add [wframe "$w.b_$i"]
		pack [wlabel "$w.b_$i.l" -text "$nickname <$peerid>" -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) -font $::options(font) ] -fill both -side left
		if { $mode == "p" } {
			pack [wbutton "$w.b_$i.b" -text [::msgcat::mc "add_b"] -command "chat_add $contact ; array unset $reqk ; after_add $mode $id ; destroy $w.b_$i ; destroy $w"  -activebackground $::options(hilightcolor) -activeforeground $::options(basecolor) -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor)  -font $::options(font)] -fill both -side right
		} elseif { $mode == "g" } {
			pack [wbutton "$w.b_$i.b" -text [::msgcat::mc "add_g"] -command "rule_add_user $id $peerid ; array unset $reqk ; after_add $mode $id ; destroy $w.b_$i ; destroy $w"  -activebackground $::options(hilightcolor) -activeforeground $::options(basecolor) -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor)  -font $::options(font)] -fill both -side right
		}
		incr i 1
	}
}

#proc show_sigmanager {mode id} {
#	if { [winfo exists .sm] == 1 } {
#		return
#	}
#	if { $mode == {} } {
#		return
#	}
#	if { $id == {} } {
#		return
#	}
#	# sigreq is a contact, but we sign and check peerid:epoch
#	# sig is peerid:epoch:signature
#	proc ref_cmd {mode id} {
#	if { $mode == {g} } {
#		set grps [array get ::my_groups "$id"]
#		if { [llength $grps] == 0 } {	
#			log_puts "ERR" "Don't have key for group $id"
#			return
#		}
#		set ::sigmanlist($mode-$id,req,i) {}
#		set ::sigmanlist($mode-$id,req,c) {}
#		set ::sigmanlist($mode-$id,req,s) {}
#		set ::sigmanlist($mode-$id,req,l) {}
#		set ::sigmanlist($mode-$id,add,i) {}
#		set ::sigmanlist($mode-$id,add,c) {}
#		set ::sigmanlist($mode-$id,add,s) {}
#		set ::sigmanlist($mode-$id,add,l) {}
#		foreach {key value} [array get ::group_to_sigreq "$id,*"] {	
#			set c [contact_to_dict $value]
#			if { $c == "" } {
#				continue	
#			}
#			set nick [dict get $c nickname]
#			set peerid [dict get $c peerid]
#			set epoch [clock seconds]
#			if { [array get ::group_to_sig $key] == "" } {
#				lappend ::sigmanlist($mode-$id,req,i) "$key"
#				lappend ::sigmanlist($mode-$id,req,c) "$value"
#				lappend ::sigmanlist($mode-$id,req,s) "$peerid:$epoch"
#				lappend ::sigmanlist($mode-$id,req,l) "R $nick <$peerid>"
#			} else {
#				sc_publishcontact $value
#				lappend ::sigmanlist($mode-$id,add,i) "$key"
#				lappend ::sigmanlist($mode-$id,add,c) "$value"
#				lappend ::sigmanlist($mode-$id,add,s) "$peerid:$epoch"
#				lappend ::sigmanlist($mode-$id,add,l) "S $nick <$peerid>"
#			}
#		}
#	} elseif { $mode == {p} } {
#		set ::sigmanlist($mode-$id,req,i) {}
#		set ::sigmanlist($mode-$id,req,c) {}
#		set ::sigmanlist($mode-$id,req,s) {}
#		set ::sigmanlist($mode-$id,req,l) {}
#		set ::sigmanlist($mode-$id,add,i) {}
#		set ::sigmanlist($mode-$id,add,c) {}
#		set ::sigmanlist($mode-$id,add,s) {}
#		set ::sigmanlist($mode-$id,add,l) {}
#		foreach {key value} [array get ::person_to_sigreq "${::me(id)},*"] {
#			set c [contact_to_dict $value]
#			if { $c == "" } {
#				continue	
#			}
#			set nick [dict get $c nickname]
#			set peerid [dict get $c peerid]
#			set epoch [clock seconds]
#			if { [array get ::person_to_sig $key] == "" } {
#				lappend ::sigmanlist($mode-$id,req,i) "$key"
#				lappend ::sigmanlist($mode-$id,req,c) "$value"
#				lappend ::sigmanlist($mode-$id,req,s) "$peerid:$epoch"
#				lappend ::sigmanlist($mode-$id,req,l) "R $nick <$peerid>"
#			} else {
#				sc_publishcontact $value
#				lappend ::sigmanlist($mode-$id,add,i) "$key"
#				lappend ::sigmanlist($mode-$id,add,c) "$value"
#				lappend ::sigmanlist($mode-$id,add,s) "$peerid:$epoch"
#				lappend ::sigmanlist($mode-$id,add,l) "S $nick <$peerid>"
#			}
#		}
#	}
#	}
#
#	proc add_cmd {mode id} {
#		set i [lindex [.sm.req.l index active] 0]
#		if { $mode == {g} } {
#			set fid [lindex $::sigmanlist($mode-$id,req,i) $i]
#			catch {
#			log_puts "ALL" "group_to_sig add fid $fid"
#			set c [contact_to_dict [lindex $::sigmanlist($mode-$id,req,c) $i]]
#			log_puts "ALL" "group_to_sig add c $c"
#			set peerid [dict get $c peerid]
#			log_puts "ALL" "group_to_sig add peerid $peerid"
#			if { $peerid != {} } {
#				ml_add_srcs $id $peerid
#			}
#			}
#			if { [array get ::group_to_sig $fid] != "" } {
#				log_puts "ERR" "group_to_sig $fid already added"
#				return
#			}
#			set pkey [crypto_parse_priv [unwrap $::my_groups($id)]]
#			log_puts "ALL" "pkey $pkey s [lindex $::sigmanlist($mode-$id,req,s) $i]"
#			set sig "[lindex $::sigmanlist($mode-$id,req,s) $i]:[wrap [crypto_sig [lindex $::sigmanlist($mode-$id,req,s) $i] $pkey]]"
#			array set ::group_to_sig [list $fid $sig]
#		} elseif { $mode == {p} } {	
#			set fid [lindex $::sigmanlist($mode-$id,req,i) $i]
#			if { [array get ::person_to_sig $fid] != "" } {
#				log_puts "ERR" "person_to_sig $fid already added"
#				return
#			}
#			set pkey $::me(key)
#			set sig "[lindex $::sigmanlist($mode-$id,req,s) $i]:[wrap [crypto_sig [lindex $::sigmanlist($mode-$id,req,s) $i] $pkey]]"
#			array set ::person_to_sig [list $fid $sig]
#			catch {
#			chat_add [lindex $::sigmanlist($mode-$id,req,c) $i]	
#			}
#		}
#		ref_cmd $mode $id
#		sc_publishcontact $::me(contact)
#		if { $mode == {g} } {
#			set ::cur(main,mode) $mode
#			ml_grouphead [lindex [array get ::jgroups $id] end]
#		} elseif { $mode == {p} } {
#			set ::cur(main,mode) $mode
#			ml_personhead [lsearch -inline [array get ::buddies] "$id:*"]
#		}
#	}
#	
#	proc rem_cmd {mode id} {
#		set i [lindex [.sm.add.l index active] 0]
#		if { $mode == {g} } {
#			set fid [lindex $::sigmanlist($mode-$id,add,i) $i]
#			array unset ::group_to_sig $fid
#		} elseif { $mode == {p} } {
#			set fid [lindex $::sigmanlist($mode-$id,add,i) $i]
#			array unset ::person_to_sig $fid
#		}
#		ref_cmd $mode $id
#		sc_publishcontact $::me(contact)
#		if { $mode == {g} } {
#			set ::cur(main,mode) $mode
#			ml_grouphead [lindex [array get ::jgroups $id] end]
#		} elseif { $mode == {p} } {
#			set ::cur(main,mode) $mode
#			ml_personhead [lsearch -inline [array get ::buddies] "$id:*"]
#		}
#	}
#
#	# array names
#	#
#	#array set ::group_to_sig {}
#	#array set ::group_to_sigreq {}
#	#array set ::person_to_sig {}
#	#array set ::person_to_sigreq {}
#	#
#	toplevel .sm
#	wm title .sm "Signature manager {$mode} #$id"
#	pack [panedwindow .sm.p -ori vert -width 240] -fill both -expand 1
#	.sm.p add [wframe ".sm.top"] -stretch never
#	pack [wlabel .sm.top.l -text "mode: {$mode} | id: <$id>" -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) -font $::options(font) ] -fill both -side left
#	.sm.p add [wframe ".sm.req"] -stretch always 
#	pack [wscrollbar .sm.req.y -activebackground $::options(hilightcolor)  -troughcolor $::options(hilightcolor)  -command "tl_yview 1 .sm.req.l"] -fill y -side right
#	pack [listbox .sm.req.l -listvariable ::sigmanlist($mode-$id,req,l) -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) -selectforeground $::options(basecolor) -selectbackground $::options(hilightcolor) -font $::options(font) -height 12 -yscrollc ".sm.req.y set"] -fill both -expand 1 -side right
#	.sm.p add [wframe ".sm.add"] -stretch always 
#	pack [wscrollbar .sm.add.y -activebackground $::options(hilightcolor)  -troughcolor $::options(hilightcolor)  -command "tl_yview 1 .sm.add.l"] -fill y -side right
#	pack [listbox .sm.add.l -listvariable ::sigmanlist($mode-$id,add,l) -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) -selectforeground $::options(basecolor) -selectbackground $::options(hilightcolor) -font $::options(font) -height 12 -yscrollc ".sm.add.y set"] -fill both -expand 1 -side right
#	.sm.p add [wframe ".sm.cmd"] -stretch never
#	pack [wbutton .sm.cmd.rem -text "rem" -activebackground $::options(hilightcolor) -activeforeground $::options(basecolor) -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor)  -font $::options(font) -command "rem_cmd $mode $id" ] -fill both -side left
#	pack [wbutton .sm.cmd.add -text "add" -activebackground $::options(hilightcolor) -activeforeground $::options(basecolor) -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor)  -font $::options(font) -command "add_cmd $mode $id"] -fill both -side right
#	ref_cmd $mode $id
#}

proc show_grouplist {} {
	if { [winfo exists .g] == 1 } {
		return
	}
	toplevel .g
	wm title .g [::msgcat::mc "grouplist_t" $::options(myport) ${::me(id)}]
	make_menu .g	
	pack [panedwindow .g.p -ori vert -width 240] -fill both -expand 1
	.g.p add [wframe ".g.l"] -stretch always 
	pack [wscrollbar .g.l.y -activebackground $::options(hilightcolor)  -troughcolor $::options(hilightcolor)  -command "tl_yview 1 .g.l.l"] -fill y -side right
	pack [listbox .g.l.l -listvariable ::jgrouplist(main,l) -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) -selectforeground $::options(basecolor) -selectbackground $::options(hilightcolor) -font $::options(font) -height 12 -yscrollc ".g.l.y set"] -fill both -expand 1 -side right
	.g.p add [wframe ".g.mi"] -stretch never
	pack [wlabel .g.mi.mpl -text "<" -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) -font $::options(font) ] -fill both -side left
	pack [wlabel .g.mi.me -textvar ::me(id) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) -font $::options(font) ] -fill both -side left 
	pack [wlabel .g.mi.mpr -text ">" -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) -font $::options(font) ] -fill both -side left
	.g.p add [wframe ".g.me"] -stretch never
	pack [wlabel .g.me.l -textvar ::me(nickname) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) -font $::options(font) ] -fill both -expand 1 -side left
	.g.p add [wframe ".g.b"] -stretch never
	bind .g.l.l <1> {+ show_gchatwindow gchat [lindex $::jgrouplist(main,i) [lindex [.g.l.l nearest %y] 0]]}
	bind .g.l.l <3> {+ show_group_details [lindex [array get ::groups [lindex $::jgrouplist(main,i) [lindex [.g.l.l nearest %y] 0]]] end]}
	bind .g.me.l <1> {+ tk_popup .nmenu %X %Y}
	update_groups
}

proc show_buddylist {} {
	if { [winfo exists .b] == 1 } {
		return
	}
	toplevel .b
	wm title .b [::msgcat::mc $::options(myport) ${::me(id)}]
	make_menu .b
	pack [panedwindow .b.p -ori vert -width 240] -fill both -expand 1
	#.b.p add [wframe ".b.o"] -stretch never
	#pack [wbutton .b.o.nws -text "nws" -activebackground $::options(hilightcolor) -activeforeground $::options(basecolor) -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor)  -font $::options(font) -command {show_mail}] -fill both -side left 
	#pack [wbutton .b.o.sol -text "sol" -activebackground $::options(hilightcolor) -activeforeground $::options(basecolor) -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor)  -font $::options(font) -command {sol_store}] -fill both -side left 
	#pack [wbutton .b.o.dbg -text "dbg" -activebackground $::options(hilightcolor) -activeforeground $::options(basecolor) -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor)  -font $::options(font) -command {show_debug}] -fill both -side right
	#pack [wbutton .b.o.die -text "kill" -activebackground $::options(hilightcolor) -activeforeground $::options(basecolor) -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor)  -font $::options(font) -command {write_all;exit}] -fill both -side right 
	#.b.p add [wframe ".b.mn"] -stretch never
	#pack [wlabel .b.mn.mn -textvar ::me(nickname) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) -font $::options(font) ] -fill both -side left 
	#pack [wbutton .b.mn.ext -text "exit" -activebackground $::options(hilightcolor) -activeforeground $::options(basecolor) -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor)  -font $::options(font) -command {destroy .b}] -fill both -side right
	#pack [wbutton .b.mn.dir -textvariable ::me(nickname)  -activebackground $::options(hilightcolor) -activeforeground $::options(basecolor) -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor)  -font $::options(font) -command {tk_popup .b.menu.c 0 0}] -fill both -expand 1 -side right 
	.b.p add [wframe ".b.l"] -stretch always 
	pack [wscrollbar .b.l.y -activebackground $::options(hilightcolor)  -troughcolor $::options(hilightcolor)  -command "tl_yview 1 .b.l.l"] -fill y -side right
	pack [listbox .b.l.l -listvariable ::buddylist(main,l) -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) -selectforeground $::options(basecolor) -selectbackground $::options(hilightcolor) -font $::options(font) -height 12 -yscrollc ".b.l.y set"] -fill both -expand 1 -side right
	#pack [treectrl .b.l.tv -height 12 -yscrollc ".b.l.y set"] -fill both -expand 1 -side right
	.b.p add [wframe ".b.mi"] -stretch never
	pack [wlabel .b.mi.mpl -text "<" -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) -font $::options(font) ] -fill both -side left
	pack [wlabel .b.mi.me -textvar ::me(id) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) -font $::options(font) ] -fill both -side left 
	pack [wlabel .b.mi.mpr -text ">" -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) -font $::options(font) ] -fill both -side left
	.b.p add [wframe ".b.b"] -stretch never
	#pack [wbutton .b.b.cht -text "cht" -activebackground $::options(hilightcolor) -activeforeground $::options(basecolor) -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor)  -font $::options(font) -command {show_gchatwindow chat [lindex $::buddylist(main,k) [lindex [.b.l.l index active] 0]]}] -fill none -side right
	#pack [wbutton .b.b.eml -text "eml" -activebackground $::options(hilightcolor) -activeforeground $::options(basecolor) -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor)  -font $::options(font) -command {set ::cur(main,mode) {m} ; show_editor [lindex [array get ::buddies [lindex $::buddylist(main,k) [lindex [.b.l.l index active] 0]]] 1]}] -fill none -side right
	#pack [wbutton .b.b.del -text "del" -activebackground $::options(hilightcolor) -activeforeground $::options(basecolor) -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor)  -font $::options(font) -command {show_buddy_del [lindex $::buddylist(main,k) [lindex [.b.l.l index active] 0]]}] -fill both -side left
	#pack [wbutton .b.b.dir -text "dir" -activebackground $::options(hilightcolor) -activeforeground $::options(basecolor) -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor)  -font $::options(font) -command {show_directory}] -fill both -side left
	#pack [wbutton .b.b.dnl -text "dnl" -activebackground $::options(hilightcolor) -activeforeground $::options(basecolor) -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor)  -font $::options(font) -command {show_downloads}] -fill both -side left
	pack [wlabel .b.b.mn -textvar ::me(nickname) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) -font $::options(font) -justify left] -fill both -expand 1 -side left 
	#pack [wbutton .b.b.dtl -text "dtl" -activebackground $::options(hilightcolor) -activeforeground $::options(basecolor) -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor)  -font $::options(font) -command {
	#	show_buddy_details [lindex $::buddylist(main,k) [lindex [.b.l.l index active] 0]]
	#}] -fill none -side left
	pack [wlabel .b.b.bs -textvariable ::peernum -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) -font $::options(font) -justify right] -fill both -side right 
	bind .b.l.l <1> {+ show_gchatwindow chat [lindex $::buddylist(main,k) [lindex [.b.l.l nearest %y] 0]]}
	bind .b.l.l <3> {+ show_buddy_details [lindex $::buddylist(main,k) [lindex [.b.l.l nearest %y] 0]]}
	bind .b.b.mn <1> {+ tk_popup .nmenu %X %Y}
	update_buddies
}

proc show_gmailwindow {gid} {
	if { [llength $gid] > 1 || $gid == "" } {
		return
	}
	if { [winfo exists ".gm_$gid"] == 1 } {
		return
	}
	toplevel ".gm_$gid"	
	wm title ".gm_$gid" "Mail in group [string range [dict get [ml_groupdict [lindex [array get ::jgroups $gid] end]] name] 0 12] <$gid>"

	pack [panedwindow ".gm_$gid.p" -ori ver] -fill both -expand 1

	# that's for reading
	".gm_$gid.p" add [wframe ".gm_$gid.r"] -stretch never
	pack [wbutton ".gm_$gid.r.v" -text "read"  -activebackground $::options(hilightcolor) -activeforeground $::options(basecolor) -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor)  -font $::options(font) -command "gmail_msg_read $gid"] -fill both -side left
	#pack [wbutton ".gm_$gid.r.d" -text "delete" -activebackground $::options(hilightcolor) -activeforeground $::options(basecolor) -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor)  -font $::options(font) -command "gmail_deletebutton $gid"] -fill both -side left
	pack [wbutton ".gm_$gid.r.r" -text "reply"  -activebackground $::options(hilightcolor) -activeforeground $::options(basecolor) -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor)  -font $::options(font) -command "gmail_replybutton $gid"] -fill both -side left
	pack [wbutton ".gm_$gid.r.c" -text "compose"  -activebackground $::options(hilightcolor) -activeforeground $::options(basecolor) -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor)  -font $::options(font) -command "gmail_toggle_compose $gid"] -fill both -side left
	pack [wentry ".gm_$gid.r.i" -textvariable ::searchfield($gid) -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor)  -font $::options(listfont) ] -fill both -expand 1 -side left
	pack [wbutton ".gm_$gid.r.f" -text "f" -activebackground $::options(hilightcolor) -activeforeground $::options(basecolor) -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor)  -font $::options(font) -command "gmail_history_read $gid"] -fill both -side left

	# that's for composition
	".gm_$gid.p" add [wframe ".gm_$gid.c"] -stretch never -hide true
	pack [wbutton ".gm_$gid.c.s" -text "send"  -activebackground $::options(hilightcolor) -activeforeground $::options(basecolor) -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor)  -font $::options(font) -command "gmail_send $gid ; gmail_toggle_compose $gid ; gmail_history_read $gid"] -fill both -side left
	pack [wbutton ".gm_$gid.c.c" -text "cancel"  -activebackground $::options(hilightcolor) -activeforeground $::options(basecolor) -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor)  -font $::options(font) -command "gmail_toggle_compose $gid"] -fill both -side left
	pack [wlabel ".gm_$gid.c.l" -text "Subject:" -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor)  -font $::options(font) ] -fill both -side left
	pack [wentry ".gm_$gid.c.subject" -textvariable ::subject($gid) -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor)  -font $::options(listfont) ] -fill both -expand 1 -side left

	# list, hide when composing
	".gm_$gid.p" add [wframe ".gm_$gid.h"] -stretch always
	pack [wscrollbar ".gm_$gid.h.y" -activebackground $::options(hilightcolor)  -troughcolor $::options(hilightcolor)  -command ".gm_$gid.h.l yview"] -fill y -side right
	pack [listbox ".gm_$gid.h.l" -listvariable ::msglist($gid,l) -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) -selectforeground $::options(basecolor) -selectbackground $::options(hilightcolor) -font $::options(listfont) -yscrollc ".gm_$gid.h.y set" -height 10 ] -fill both -expand 1 -side right

	# that's for reading
	".gm_$gid.p" add [wframe ".gm_$gid.o"] -stretch always
	pack [wscrollbar ".gm_$gid.o.y" -activebackground $::options(hilightcolor)  -troughcolor $::options(hilightcolor)  -command ".gm_$gid.o.t yview"] -fill y -side right
	pack [text ".gm_$gid.o.t" -wrap word -yscrollc ".gm_$gid.o.y set" \
		-selectforeground {#6090c0} -selectbackground $::options(hilightcolor) \
		-highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) \
		-padx 5 -pady 3 -height 10 -width 80 -font $::options(listfont)] \
		-fill both -expand 1 -side right
	
	# that's for composition
	".gm_$gid.p" add [wframe ".gm_$gid.i"] -stretch always -hide true
	pack [wscrollbar ".gm_$gid.i.y" -activebackground $::options(hilightcolor)  -troughcolor $::options(hilightcolor)  -command ".gm_$gid.i.t yview"] -fill y -side right
	pack [text ".gm_$gid.i.t" -wrap word -yscrollc ".gm_$gid.i.y set" \
		-selectforeground {#6090c0} -selectbackground $::options(hilightcolor) \
		-highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) \
		-padx 5 -pady 3 -height 21 -width 80 -font $::options(listfont)] \
		-fill both -expand 1 -side right

	".gm_$gid.p" add [wframe ".gm_$gid.t"] -stretch never
	pack [wlabel ".gm_$gid.t.l" -text "${::me(nickname)} <[string range $::me(id) 0 15]...> in [string range [dict get [ml_groupdict [lindex [array get ::jgroups $gid] end]] name] 0 12] <[string range $gid 0 15]...>" -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) -font $::options(font)] -fill both -side left

	gmail_history_read $gid
	set cmdf [concat {+ click_window f} ".gm_$gid.o.t" $gid {%x %y}]
	set cmdh [concat {+ click_window h} ".gm_$gid.o.t" $gid {%x %y}]
	".gm_$gid.o.t" tag bind filelink <1> $cmdf
	".gm_$gid.o.t" tag bind headerlink <1> $cmdh
	bind ".gm_$gid.r.i" <Key-Return> "gmail_history_read $gid"
	bind ".gm_$gid.h.l" <Key-Return> "gmail_msg_read $gid"
}

proc gmail_toggle_compose {gid} {
	mail_toggle_compose_common ".gm_$gid"
}

proc mail_toggle_compose {hash} {
	mail_toggle_compose_common ".cm_$hash"
}

proc mail_toggle_compose_common {w} {
	if { [ "$w.p" panecget "$w.r" -hide ] } {
		"$w.p" paneconfigure "$w.r" -hide false
		"$w.p" paneconfigure "$w.c" -hide true
		"$w.p" paneconfigure "$w.o" -hide false
		"$w.p" paneconfigure "$w.h" -hide false
		"$w.p" paneconfigure "$w.i" -hide true
	} else {
		"$w.p" paneconfigure "$w.r" -hide true
		"$w.p" paneconfigure "$w.c" -hide false
		"$w.p" paneconfigure "$w.o" -hide true
		"$w.p" paneconfigure "$w.h" -hide true
		"$w.p" paneconfigure "$w.i" -hide false
	}
}

proc rule_send {gid} {
	set kfrom "[crypto_exp_pub $::me(key)]"
	set kto {}
	set hfrom $::me(id)
	set from "[string range $::me(nickname) 0 64] <$::me(id)>"
	set subject "<control message>"
	set epoch [clock seconds]
	set g [ml_groupdict $::jgroups($gid)]
	set group $gid
	set hto $gid
	set to "[string range [dict get $g name] 0 64] <$gid>" 
	set hsubject "<control message>"
	set type "gc"

	set body {}
	set mods {mods}
	set users {users}
	set rule [lindex [array get ::rule $gid] 1]
	foreach mod [dict get $rule mods] {
		append mods " $mod"
	}
	foreach user [dict get $rule users] {
		append users " $user"
	}

	append body "$mods\n"
	append body "$users\n"

	set whole {}
	append whole "From:\t$from\n"
	append whole "To:\t$to\n"
	append whole "Subject:\t$subject\n"
	append whole "Epoch:\t$epoch\n"
	append whole "\n"
	append whole "$body\n\n"

	log_puts "ALL" "Formed control message:"
	log_puts "ALL" $whole

	set whole [encoding convertto utf-8 $whole]	

	set len [string length $whole]
	set hash [crypto_cksum $whole]

	set h {}
	dict set h hash $hash 
	dict set h group $group
	dict set h len $len
	dict set h epoch $epoch
	dict set h from $hfrom
	dict set h to $hto 
	dict set h subject $hsubject
	dict set h type $type
	dict set h nickname $::me(nickname)
	dict set h kfrom $kfrom
	dict set h kto $kto 
	dict set h gsig {} 
	set header [dict_to_header $h] 

	log_puts "ALL" "Formed control message header:"
	log_puts "ALL" $header

	#set path [file join $::filepath "mailnews" $hash]
	#set fchan [open $path w]
	#fconfigure $fchan -translation binary
	#puts -nonewline $fchan $whole	
	#flush $fchan
	#close $fchan
	
	ml_add_eml all {} $whole

	ml_add_hdrs mlhdr $gid $header
	set gsrc [ml_get_srcs $hto]
	if { [lindex $gsrc 1] == 0 } {
		break
	}
	set peers [lrange $gsrc 2 end]
	foreach peer $peers {
		set speer [split $peer {:}]
		if { [lindex $speer 0] == $::me(id) } {
			continue
		}
		ml_genc [lindex $speer 0] [lindex $speer 1] [lindex $speer 2] "MAIL 0 DIG [list $hto 1 $header]" 0
	}
	after 500 [list ml_showlist g $hto]
}

proc gmail_send {gid} {
	set kfrom "[crypto_exp_pub $::me(key)]"
	set kto {}
	set hfrom $::me(id)
	set from "[string range $::me(nickname) 0 64] <$::me(id)>"
	set subject "[string range $::subject($gid) 0 64]"
	set epoch [clock seconds]

	set g [ml_groupdict $::jgroups($gid)]
	set group $gid
	set hto $gid
	set to "[string range [dict get $g name] 0 64] <$gid>" 
	set hsubject "[string range $::subject($gid) 0 64]"
	set type "g"

	#set body [string range [".gm_$gid.i.t" get 1.0 end] 0 4096]
	set body [".gm_$gid.i.t" get 1.0 end]

	set whole {}
	append whole "From:\t$from\n"
	append whole "To:\t$to\n"
	append whole "Subject:\t$subject\n"
	append whole "Epoch:\t$epoch\n"
	append whole "\n"
	append whole "$body\n\n"

	log_puts "ALL" "Formed message:"
	log_puts "ALL" $whole

	set whole [encoding convertto utf-8 $whole]	

	set len [string length $whole]
	set hash [crypto_cksum $whole]

	set h {}
	dict set h hash $hash 
	dict set h group $group
	dict set h len $len
	dict set h epoch $epoch
	dict set h from $hfrom
	dict set h to $hto 
	dict set h subject $hsubject
	dict set h type $type
	dict set h nickname $::me(nickname)
	dict set h kfrom $kfrom
	dict set h kto $kto 
	dict set h gsig {} 
	set header [dict_to_header $h] 
	log_puts "ALL" "Formed header:"
	log_puts "ALL" $header

	#set path [file join $::filepath "mailnews" $hash]
	#set fchan [open $path w]
	#fconfigure $fchan -translation binary
	#puts -nonewline $fchan $whole	
	#flush $fchan
	#close $fchan

	ml_add_eml all {} $whole

	ml_add_hdrs mlhdr $gid $header
	set ::subject($gid) {}
	".gm_$gid.i.t" delete 1.0 end
}

proc gmail_replybutton {gid} {
	set hlist_i [lindex [ ".gm_$gid.h.l" index active ] 0]
	set hdr [lindex [split $::msglist($gid,k)] $hlist_i ]
	if { $hdr == "" } {
		return
	}
	set h [header_to_dict $hdr]
	if { $h == "" } {
		return
	}
	set subj [dict get $h subject]
	gmail_toggle_compose $gid
	set ::subject($gid) "Re:$subj"
}

proc gmail_msg_read {gid} {
	set w ".gm_$gid.o.t"
	set hlist_i [lindex [ ".gm_$gid.h.l" index active ] 0]
	set hdr [lindex [split $::msglist($gid,k)] $hlist_i ]
	if { $hdr == "" } {
		log_puts "ERR" "no header"
		return
	}
	set h [header_to_dict $hdr]
	if { $h == "" } {
		log_puts "ERR" "bad header"	
		return
	}

	$w delete 1.0 end

	set hash [dict get $h hash]
	set type [dict get $h type]

	if { $type == "g" } {
		set body [ml_get_eml all $hash]
		set comment "group message"
	} elseif { $type == "gc" } {
		set body [ml_get_eml all $hash]
		set comment "group control message"
	} else {
		set body "oopsie"
		set comment "oopsie"
	}

	if { $body == -1 || $body == "" } {
		return
	}

	set body [encoding convertfrom utf-8 $body]	
	set lines [split $body "\n"]
	set from [lrange [lindex $lines 0] 1 end]
	set to [lrange [lindex $lines 1] 1 end]
	set subject [lrange [lindex $lines 2] 1 end]
	set epoch [lindex $lines 3]
	set bodylines [lrange $lines 5 end]
	$w tag configure red -foreground {#c06060} 
	$w tag configure cyan -foreground {#6090c0}
	$w tag configure blue -foreground {#6060c0}
	$w tag configure headerlink -foreground {#6060c0} -underline true
	$w tag configure grouplink -foreground {#6060c0} -underline true
	$w tag configure filelink -foreground {#6060c0} -underline true
	$w tag configure attachlink -foreground {#c06060} -underline true
	$w tag configure yellow -foreground {#c09060}
	$w tag configure magenta -foreground {#c060c0}
	$w tag configure hide -elide true
	#$w insert end "Comment: $comment\n" {red}
	#$w insert end "   Sent: [clock format [dict get $h epoch] -format {%Y-%m-%d %H:%M:%S}]\n" {red}
	$w insert end "[::msgcat::mc m_comment]: $comment ; [clock format [dict get $h epoch] -format {%Y-%m-%d %H:%M:%S}]\n" {red}
	$w insert end "[::msgcat::mc m_from]: $from\n" {cyan m_from}
	#$w insert end "[::msgcat::mc m_to]: $to\n" {cyan}
	$w insert end "[::msgcat::mc m_subject]: $subject\n" {cyan}
	$w insert end "\n"

	disp_text $w $bodylines

	set ::recent(main) [lsort -unique [lrange $::recent(main) end-100 end]]
	lappend ::recent(main) $hdr
}

proc gmail_history_read {gid} {
	ml_replay [lindex [array get ::jgroups $gid] end]
	set ::msglist($gid,l) {}
	set ::msglist($gid,k) {}
	log_puts "ALL" "filling gmail_header_list"
	set sf {}
	catch { set sf [lindex $::searchfield($gid) end] }
	if { $sf != "" } {
		set reg [string map {{ } {.*}} $sf]
	} else {
		set reg {.*}
	}
	log_puts "ALL" "regex is $reg"
	set sorted {}
	foreach hdr [lrange [ml_get_hdrs 31 mlhdr $gid] 2 end] {
		set h [header_to_dict $hdr]	
		if { $h == "" } {
			continue
		}
		if { [regexp $reg $h] == 0 } {
			continue	
		}
		set t "[clock format [dict get $h epoch] -format {%Y-%m-%d %H:%M:%S}] | [string range [dict get $h from] 0 3] | [string range [dict get $h nickname] 0 11] | [string range [dict get $h hash] 0 3] | [string range [dict get $h subject] 0 31] ([dict get $h len])"
		lappend sorted $t $hdr [dict get $h epoch]
	}
	foreach {title hdr epoch} [lsort -decreasing -stride 3 -index end $sorted] {
		lappend ::msglist($gid,l) $title
		lappend ::msglist($gid,k) $hdr
	}
}

proc show_gchatwindow {p id} {
	if { [llength $id] > 1 || $id == "" } {
		return
	}
	if { [winfo exists ".g_$id"] == 1 } {
		return
	}
	switch $p {
	"gchat" {
		#if { $::cur(main,mode) != {g} } {
		#	#return
		#	set ::cur(main,mode) {g}
		#}
		#ml_grouphead $::jgroups($id)
		array unset ::gnotices "$p,$id*"
		set sources [lrange [ml_get_srcs $id] 2 end]
		set "::ml_src_$id" {}
		foreach src $sources {
			if { $src == "*" } { continue }
			set nickname {}
			set s_sort {}
			set contacts [array get ::contacts "[shawrap contact:$src]*"]
			foreach contact $contacts {
				set c [contact_to_dict $contact]
				if { $c != "" && [dict get $c peerid] == $src && [dict get $c sig] != {} } {
					set nickname [dict get $c nickname]
					set epoch [dict get $c epoch]
					lappend s_sort "$nickname" $epoch
				}
			}
			lappend s_sort "n/a" 0
			set nickname [lindex [lsort -integer -stride 2 -index 1 -decreasing $s_sort] 0]
			lappend "::ml_src_$id" "$nickname <$src>"
		}
		set gpeerid [dict get [ml_groupdict $::jgroups($id)] peerid]
		#if { $gpeerid == $::me(id) } {
		#	set comment "(owner)"
		#} else {
		#	set comment "(member)"
		#}
		set "::ml_comment_$id" [disp_rule $id $::me(id)]
		set wtitle [::msgcat::mc "gchatwin_t" [string range [dict get [ml_groupdict [lindex [array get ::jgroups $id] end]] name] 0 12] $id]
		set wline "${::me(nickname)} <[string range $::me(id) 0 15]...> -> [string range [dict get [ml_groupdict [lindex [array get ::jgroups $id] end]] name] 0 12] <[string range $id 0 15]...>"
		set wtwid 60
		set pp "g"
	}
	"chat" {
		#if { $::cur(main,mode) != {p} } {
		#	set ::cur(main,mode) {p}
		#	#return
		#}
		#ml_personhead $::buddies($id)
		array unset ::gnotices "$p,$id*"
		after 50 update_buddies
		set "::ml_comment_$id" "personal" 
		set wtitle [::msgcat::mc "chatwin_t" [dict get [contact_to_dict [lindex [array get ::buddies $id] 1]] nickname] [dict get [contact_to_dict [lindex [array get ::buddies $id] 1]] peerid]]
		set wline "${::me(nickname)} <[string range $::me(id) 0 15]...> -> [dict get [contact_to_dict [lindex [array get ::buddies $id] 1]] nickname] <[string range [dict get [contact_to_dict [lindex [array get ::buddies $id] 1]] peerid] 0 15]...>"
		set wtwid 80
		set pp "p"
	}
	default {
		return
	}
	}
	toplevel ".g_$id"
	wm title ".g_$id" "$wtitle" 
	pack [panedwindow ".g_$id.p" -ori ver] -fill both -expand 1
	".g_$id.p" add [wframe ".g_$id.t"] -stretch never
	pack [wlabel ".g_$id.t.l" -text "$wline" -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) -font $::options(font)] -fill both -side left
	pack [wlabel ".g_$id.t.r" -textvar "::ml_comment_$id" -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) -font $::options(font)] -fill both -side right
	".g_$id.p" add [panedwindow ".g_$id.l" -ori hor] -stretch always
	".g_$id.l" add [wframe ".g_$id.o"] -stretch always
	pack [wscrollbar ".g_$id.o.y" -activebackground $::options(hilightcolor)  -troughcolor $::options(hilightcolor)  -command ".g_$id.o.t yview"] -fill y -side right
	pack [text ".g_$id.o.t" -wrap word -yscrollc ".g_$id.o.y set" \
		-selectforeground {#6090c0} -selectbackground $::options(hilightcolor) \
		-highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) \
		-padx 5 -pady 3 -height 18 -width $wtwid -font $::options(font)] \
		-fill both -expand 1 -side right
	if { $p == "gchat" } {
	".g_$id.l" add [wframe ".g_$id.m"] -stretch always
		pack [wscrollbar ".g_$id.m.ys" -activebackground $::options(hilightcolor)  -troughcolor $::options(hilightcolor)  -command ".g_$id.m.ls yview"] -fill y -side right
		pack [listbox ".g_$id.m.ls" -listvariable "::ml_src_$id" -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) -selectforeground $::options(basecolor) -selectbackground $::options(hilightcolor) -font $::options(font) -yscrollc ".g_$id.m.ys set" -width 20 ] -fill both -expand 1 -side right
	}
	#".g_$id.p" add [wframe ".g_$id.i"] -stretch never
	#pack [wbutton ".g_$id.i.s" -text "send" -activebackground $::options(hilightcolor) -activeforeground $::options(basecolor) -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor)  -font $::options(font) -command "gchat_sendbutton gchat $id"] -fill both -side right
	#pack [wscrollbar ".g_$id.i.y" -activebackground $::options(hilightcolor)  -troughcolor $::options(hilightcolor)  -command ".g_$id.i.t yview"] -fill y -side right
	#pack [text ".g_$id.i.t" -wrap word -yscrollc ".g_$id.i.y set" \
	#	-selectforeground {#6090c0} -selectbackground $::options(hilightcolor) \
	#	-highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) \
	#	-padx 5 -pady 3 -height 4 -width 80 -font $::options(font)] \
	#	-fill both -expand 1 -side right
	#".g_$id.p" add [panedwindow ".g_$id.bl" -ori ver] -stretch always
	".g_$id.p" add [wframe ".g_$id.r"] -stretch never -hide true
	pack [wbutton ".g_$id.r.f" -text [::msgcat::mc "file"]  -activebackground $::options(hilightcolor) -activeforeground $::options(basecolor) -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor)  -font $::options(font) -command "show_fileoffer $pp $id"] -fill both -side right 
	pack [wbutton ".g_$id.r.in" -text [::msgcat::mc "insert"]  -activebackground $::options(hilightcolor) -activeforeground $::options(basecolor) -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor)  -font $::options(font) -command "insert_single_file $pp $id"] -fill both -side right 
	#pack [wbutton ".g_$id.r.img" -text [::msgcat::mc "image"] -activebackground $::options(hilightcolor) -activeforeground $::options(basecolor) -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor)  -font $::options(font) -command "insert_inline_image $pp $id"] -fill both -side right 
	pack [wbutton ".g_$id.r.limg" -text [::msgcat::mc "image"] -activebackground $::options(hilightcolor) -activeforeground $::options(basecolor) -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor)  -font $::options(font) -command "insert_linked_image $pp $id"] -fill both -side right 
	#pack [wbutton ".g_$id.r.rec" -text [::msgcat::mc "voice"] -activebackground $::options(hilightcolor) -activeforeground $::options(basecolor) -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor)  -font $::options(font) -command ""] -fill both -side right 
	pack [wbutton ".g_$id.r.lrec" -text [::msgcat::mc "voice"] -activebackground $::options(hilightcolor) -activeforeground $::options(basecolor) -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor)  -font $::options(font) -command ""] -fill both -side right 
	pack [wbutton ".g_$id.r.grp" -text [::msgcat::mc "group"] -activebackground $::options(hilightcolor) -activeforeground $::options(basecolor) -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor)  -font $::options(font) -command "show_insertgroup $pp $id"] -fill both -side right 
	pack [wbutton ".g_$id.r.hdr" -text [::msgcat::mc "letter"] -activebackground $::options(hilightcolor) -activeforeground $::options(basecolor) -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor)  -font $::options(font) -command "show_recent $pp $id none"] -fill both -side right 
	".g_$id.p" add [wframe ".g_$id.b"] -stretch never
	pack [wentry ".g_$id.b.i" -textvariable ::entry($p,$id) -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor)  -font $::options(font) ] -fill both -expand 1 -side left
	set ::entry($p,$id) {}
	pack [wbutton ".g_$id.b.s" -text [::msgcat::mc "send"]  -activebackground $::options(hilightcolor) -activeforeground $::options(basecolor) -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor)  -font $::options(font) -command "gchat_sendbutton $p $id"] -fill both -side right
	pack [wbutton ".g_$id.b.a" -text [::msgcat::mc "+"]  -activebackground $::options(hilightcolor) -activeforeground $::options(basecolor) -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor)  -font $::options(font) -command "gchat_toggle $p $id"] -fill both -side right
	#bind ".g_$id.r.rec" <ButtonPress-1> "record_voice_start .g_$id" 
	#bind ".g_$id.r.rec" <ButtonRelease-1> "record_voice_end ; insert_inline_voice $pp $id"
	bind ".g_$id.r.lrec" <ButtonPress-1> "record_voice_start .g_$id" 
	bind ".g_$id.r.lrec" <ButtonRelease-1> "record_voice_end ; insert_linked_voice $pp $id"
	gchat_history_read $p $id
	if { $::options(gchat_sync_allowed) == 1 } {
		log_puts "ALL" "schedule SYNC request for group sync"
		set lmids {}
		catch { set lmids [gchat_history_ids $p $id $::options(gchat_sync_days) {}] } res
		if { $lmids != {} } {
			after 1000 [list gchat_send $p $id $::me(id) {} "SYNC" $lmids]
		}
	}
	set cmd_f "+ click_window f .g_$id.o.t $id %x %y"
	set cmd_v "+ click_window rec .g_$id.o.t $id %x %y"
	set cmd_lv "+ click_window lrec .g_$id.o.t $id %x %y"
	set cmd_li "+ click_window limg .g_$id.o.t $id %x %y"
	set cmd_g "+ click_window gr .g_$id.o.t $id %x %y"
	set cmd_h "+ click_window h .g_$id.o.t $id %x %y"
	".g_$id.o.t" tag configure hide -elide true
	".g_$id.o.t" tag configure blue -foreground {#6060c0} -font {Sans 9}
	".g_$id.o.t" tag configure red -foreground {#c06060} -font {Sans 9}
	".g_$id.o.t" tag configure cyan -foreground {#60c0c0} -font {Sans 9}
	".g_$id.o.t" tag configure green -foreground {#60c060} -font {Sans 9}
	".g_$id.o.t" tag configure yellow -foreground {#c0c060} -font {Sans 9}
	".g_$id.o.t" tag configure magenta -foreground {#c060c0} -font {Sans 9}
	".g_$id.o.t" tag configure ok -foreground {#6060c0} -font {Sans 9}
	".g_$id.o.t" tag configure no -foreground {#c06060} -font {Sans 9}
	".g_$id.o.t" tag configure refuse -foreground {#c06060} -font {Sans 9}
	".g_$id.o.t" tag bind filelink <1> $cmd_f
	".g_$id.o.t" tag bind inline_voice <1> $cmd_v
	".g_$id.o.t" tag bind voicelink <1> $cmd_lv
	".g_$id.o.t" tag bind imagelink <1> $cmd_li
	".g_$id.o.t" tag bind grouplink <1> $cmd_g
	".g_$id.o.t" tag bind headerlink <1> $cmd_h
	#bind ".g_$id.i.t" <Key-Return> "gchat_sendbutton $p $id"
	bind ".g_$id.b.i" <Key-Return> "gchat_sendbutton $p $id"
}

proc dl_add_voice {w req buddyhash} {
	if { $w == {} || $req == {} } {
		return
	}

	set r [dl_reqdict $req]
	set hash [dict get $r filehash]
	set name [dict get $r filename]
	set dur [lindex [split $name {_}] 1]
	dl_del $hash
	dl_add $req $buddyhash {} [list play_voice_start $w $dur]
	after idle [list dl_start $hash]
}

proc dl_add_image {w req buddyhash} {
	if { $w == {} || $req == {} } {
		return
	}

	set r [dl_reqdict $req]
	set hash [dict get $r filehash]
	dl_del $hash
	dl_add $req $buddyhash {} [list insert_image $w [$w index end] "Image"]
	after idle [list dl_start $hash]
}

proc insert_image {w pos name data} {
	if { [winfo exists $w] == 0 && [winfo exists "$w-c"] == 0 } {
		log_puts "ERR" "insert_image no such window $w"
		return
	}
	if { $data == {} } {
		log_puts "ERR" "insert_image no data"
		return
	}

	set id [crypto_cksum $data]

	set img {}
	if { [array names ::cur "img,$id"] == {} } {
		set img [image create photo -format PNG -data $data]
		set ::cur(img,$id) $img
	} else {
		set img $::cur(img,$id)
	}

	set wid [image width $img]
	set hei [image height $img]

	set factor {}
	catch {
	set factor [expr "($wid*1.0)/(1.0*[winfo width $w] - 8.0)"]
	}
	if { $factor == {} } {
		set factor 1
	}
	set nwid [expr "(1.0*$wid)/$factor"]
	set nhei [expr "(1.0*$hei)/$factor"]

	catch { image delete $::cur(img,$id,s) }
	set simg [image create photo -format PNG]
	set ::cur(img,$id,s) $simg
	log_puts "ALL" "insert_image factor $factor"

	if { $factor > 1.1 } {
		set f [expr {int(ceil($factor-0.05))}]
		$simg copy $img -subsample $f $f 
	} elseif { $factor < 0.9} {
		set f [expr {int(ceil(1.0/($factor+0.05)))}]
		$simg copy $img -zoom $f $f
	} else {
		$simg copy $img
	}
	#::imgscale::imgscale $img $nwid $nhei $simg

	set imgdesc "LIMG $name, res: ${wid}x${hei} :"

	#$w insert $pos "\n"
	$w image create $pos -image $simg -padx 4 -pady 4
	#$w insert $pos "$imgdesc\n" {magenta}

	return
}

proc show_filedialog {req buddyhash} {
	#if { [winfo exists .fd] == 1 || $header == "" } {
	#	return
	#}
	if { [winfo exists .fd] == 1 || $req == "" } {
		return
	}
	#log_puts "ALL" "header $header"
	#set h [header_to_dict $header]
	#log_puts "ALL" "dict $h"
	#set name [encoding convertfrom utf-8 [::base64::decode [dict get $h subject]]]
	#set chunksize [dict get $h chunksize]
	#set chunks [dict get $h chunks]
	#set size [expr {$chunks*$chunksize}]
	#set hash [dict get $h hash]
	log_puts "ALL" "req $req"
	set r [dl_reqdict $req]
	log_puts "ALL" "r $r"
	if { $r == "" } {
		return
	}
	if { $buddyhash == "" } {
		set buddyhash "{}"
	}
	set name [dict get $r filename]
	set hash [dict get $r filehash]
	set size [dict get $r len]
	toplevel .fd
	wm title .fd [::msgcat::mc "filedialog_t"] 
	pack [panedwindow .fd.p -ori vert] -fill both -expand 1
	.fd.p add [wframe .fd.t] -stretch always
	pack [wlabel .fd.t.t -text [::msgcat::mc "filedialog_l" $name $hash $size] -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) -font $::options(font) ] -fill both -side left
	.fd.p add [wframe .fd.b] -stretch never 
	pack [wbutton .fd.b.c -text [::msgcat::mc "cancel"] -activebackground $::options(hilightcolor) -activeforeground $::options(basecolor) -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor)  -font $::options(font) -command "destroy .fd"] -fill both -side left
	pack [wbutton .fd.b.o -text [::msgcat::mc "ok"] -activebackground $::options(hilightcolor) -activeforeground $::options(basecolor) -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor)  -font $::options(font) -command "dl_add $req $buddyhash {} {}; destroy .fd ; show_dlstate"] -fill both -side right 
}

proc show_dlstate {} {
	if { [winfo exists .dls] == 1 } {
		return
	}
	toplevel .dls
	wm title .dls [::msgcat::mc "Downloads"]
	pack [panedwindow .dls.p -ori vert] -fill both -expand 1
	.dls.p add [wframe .dls.t] -stretch never 
	#pack [wbutton .dls.t.x -text [::msgcat::mc "exit"] -activebackground $::options(hilightcolor) -activeforeground $::options(basecolor) -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor)  -font $::options(font) -command "destroy .dls"] -fill both -side left 
	.dls.p add [wframe .dls.l] -stretch always
	pack [wscrollbar .dls.l.y -activebackground $::options(hilightcolor)  -troughcolor $::options(hilightcolor)  -command "tl_yview 6 .dls.l.n .dls.l.s .dls.l.p .dls.l.h .dls.l.b .dls.l.st"] -fill y -side right
	pack [listbox .dls.l.n -listvariable ::dlstate_list(name) -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) -selectforeground $::options(basecolor) -selectbackground $::options(hilightcolor) -font $::options(font) -height 24 -width 32 -yscrollc ".dls.l.y set"] -fill both -expand 1 -side left
	pack [listbox .dls.l.s -listvariable ::dlstate_list(size) -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) -selectforeground $::options(basecolor) -selectbackground $::options(hilightcolor) -font $::options(font) -height 24 -width 10 -yscrollc ".dls.l.y set"] -fill y -side left
	pack [listbox .dls.l.p -listvariable ::dlstate_list(perc) -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) -selectforeground $::options(basecolor) -selectbackground $::options(hilightcolor) -font $::options(font) -height 24 -width 6 -yscrollc ".dls.l.y set"] -fill y -side left
	pack [listbox .dls.l.h -listvariable ::dlstate_list(hash) -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) -selectforeground $::options(basecolor) -selectbackground $::options(hilightcolor) -font $::options(font) -height 24 -width 12 -yscrollc ".dls.l.y set"] -fill y -side left
	#pack [listbox .dls.l.b -listvariable ::dlstate_list(buddy) -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) -selectforeground $::options(basecolor) -selectbackground $::options(hilightcolor) -font $::options(font) -height 24 -width 12 -yscrollc ".dls.l.y set"] -fill y -side left
	pack [listbox .dls.l.st -listvariable ::dlstate_list(state) -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) -selectforeground $::options(basecolor) -selectbackground $::options(hilightcolor) -font $::options(font) -height 24 -width 8 -yscrollc ".dls.l.y set"] -fill y -side left
	.dls.p add [wframe .dls.b] -stretch never 
	pack [wbutton .dls.b.start -text [::msgcat::mc "start"] -activebackground $::options(hilightcolor) -activeforeground $::options(basecolor) -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor)  -font $::options(font) -command {dl_start [lindex $::dlstate_list(hash) [lindex [.dls.l.n index active] 0]]}] -fill both -side right
	pack [wbutton .dls.b.stop -text [::msgcat::mc "stop"] -activebackground $::options(hilightcolor) -activeforeground $::options(basecolor) -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor)  -font $::options(font) -command {dl_stop [lindex $::dlstate_list(hash) [lindex [.dls.l.n index active] 0]]}] -fill both -side right
	pack [wbutton .dls.b.delete -text [::msgcat::mc "delete"] -activebackground $::options(hilightcolor) -activeforeground $::options(basecolor) -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor)  -font $::options(font) -command {dl_del [lindex $::dlstate_list(hash) [lindex [.dls.l.n index active] 0]]}] -fill both -side right
	update_dlstate
}

proc update_dlstate {} {
	if { [winfo exists .dls] == 0 } {
		return
	}
	set ::dlstate {}
	set ::dlstate_list(name) {}
	set ::dlstate_list(size) {}
	set ::dlstate_list(perc) {}
	set ::dlstate_list(hash) {}
	set ::dlstate_list(buddy) {}
	set ::dlstate_list(state) {}
	foreach {hash detail} [array get ::dl_by_hash] {
		set size [dict get $detail len]
		set top $::dlstate_by_hash($hash,top)
		if { $top >= $size } {
			set top $size
		}
		set buddyhash [lindex [array get ::dlstate_by_hash $hash,buddy] end]
		lappend ::dlstate_list(name) [dict get $detail filename]
		lappend ::dlstate_list(size) $size
		lappend ::dlstate_list(perc) "[expr {int((100.0*$top)/(1.0*$size))}]%"
		lappend ::dlstate_list(hash) $hash
		if { $buddyhash != {} } {
			lappend ::dlstate_list(buddy) [dict get [contact_to_dict $::buddies($buddyhash)] nickname]
		} else {
			lappend ::dlstate_list(buddy) "-" 
		}
		lappend ::dlstate_list(state) $::dlstate_by_hash($hash,state)
	}
	after 1000 update_dlstate
}

proc tl_yview args {
	set num [lindex $args 0]	
	set lists [lrange $args 1 $num]	
	set a [lrange $args [expr {$num+1}] end]
	foreach l $lists {
		$l yview {*}$a
	}
}

proc show_fileoffer {mode hash} {
	if {[winfo exists .fo] == 1} {
		return
	}
	toplevel .fo
	wm title .fo [::msgcat::mc "fileoffer_t"]
	pack [panedwindow .fo.p -ori vert] -fill both -expand 1
	.fo.p add [wframe .fo.t] -stretch never
	switch $mode {
		"g" {
			set txt [::msgcat::mc "fileoffer_lc" $mode $hash]
		}
		"p" {
			set txt [::msgcat::mc "fileoffer_lc" $mode $hash]
		}
		"e" {
			set txt [::msgcat::mc "fileoffer_lm"]
		}
		"w" {
			set txt [::msgcat::mc "fileoffer_lm"]
		}
		default {
			destroy .fo
			return	
		}
	}
	pack [wlabel .fo.t.l -text "$txt" -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) -font $::options(font) ] -fill both -side left
	.fo.p add [wframe .fo.ll] -stretch never
	pack [wlabel .fo.ll.name -text "name" -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) -font $::options(font) ] -fill both -expand 1 -side left 
	pack [wlabel .fo.ll.size -text "size" -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) -font $::options(font) -width 8 ] -fill y -side left
	pack [wlabel .fo.ll.hash -text "hash" -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) -font $::options(font) -width 12 ] -fill y -side left
	.fo.p add [wframe .fo.l] -stretch always
	pack [listbox .fo.l.name -listvariable ::fo_name -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) -selectforeground $::options(basecolor) -selectbackground $::options(hilightcolor) -font $::options(font) -yscrollc ".fo.l.y set"] -fill both -expand 1 -side left
	pack [listbox .fo.l.size -listvariable ::fo_size -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) -selectforeground $::options(basecolor) -selectbackground $::options(hilightcolor) -font $::options(font) -yscrollc ".fo.l.y set" -width 8] -fill y -side left
	pack [listbox .fo.l.hash -listvariable ::fo_hash -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) -selectforeground $::options(basecolor) -selectbackground $::options(hilightcolor) -font $::options(font) -yscrollc ".fo.l.y set" -width 12] -fill y -side left
	pack [wscrollbar .fo.l.y -activebackground $::options(hilightcolor)  -troughcolor $::options(hilightcolor)  -command {tl_yview 3 .fo.l.name .fo.l.size .fo.l.hash}] -fill y -side right
	.fo.p add [wframe .fo.b] -stretch never
	pack [wbutton .fo.b.s -text [::msgcat::mc "send"]  -activebackground $::options(hilightcolor) -activeforeground $::options(basecolor) -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor)  -font $::options(font) -command "send_fileoffer $mode $hash; destroy .fo"] -fill both -side right

	set ::fo_name {}
	set ::fo_size {}
	set ::fo_hash {}
	set ::fo_header {}
	foreach {fhash details} [array get ::file_by_hash] {
		array set ::sources [list $fhash $::me(id)]
		set name [unwrap [dict get $details name]]
		set size [dict get $details size]
		lappend ::fo_name $name
		lappend ::fo_size $size
		lappend ::fo_hash $fhash
		set r {}
		dict set r filehash $fhash
		dict set r filename $name
		dict set r offset 0
		dict set r len $size
		lappend ::fo_header "[dl_dictreq $r]"
	}
	proc send_fileoffer {mode hash} {
		if { $hash == {} && $mode != {e} } {
			return
		}
		set notice "FILE [lindex $::fo_name [lindex [.fo.l.name index active] 0]] ([lindex $::fo_size [lindex [.fo.l.name index active] 0]]) <[lindex $::fo_header [lindex [.fo.l.name index active] 0]]>"
		if { $mode == {p} } {
			gchat_notice chat $hash $notice
		} elseif { $mode == {g} } {
			gchat_notice gchat $hash $notice
		} elseif { $mode == {e} } {
			.e.x.t insert end "\n$notice\n" {blue filelink}	
		} elseif { $mode == {w} } {
			$hash insert end "\n$notice\n" {blue filelink}	
		}
	}
}	

proc insert_single_file {mode id} {
	set filename [tk_getOpenFile]
	if { $filename != "" && [file exists $filename] } { 
		hash_file $filename
	} else {
		return
	}
	set hash [lindex [array get ::hash_by_file [wrap $filename]] end]
	log_puts "ALL" "hash $hash"
	set details [lindex [array get ::file_by_hash $hash] end]
	log_puts "ALL" "details $details"
	set name [lindex [file split [unwrap [dict get $details name]]] end]
	set size [dict get $details size]
	set r {}
	dict set r filehash $hash
	dict set r filename $name
	dict set r offset 0
	dict set r len $size
	set req [dl_dictreq $r]
	if { $req == "" } {
		return
	}
	set notice "FILE $name ($size) <$req>"
	if { $mode == {p} } {
			gchat_notice chat $id $notice
	} elseif { $mode == {g} } {
			gchat_notice gchat $id $notice
	} elseif { $mode == {e} } {
			.e.x.t insert end "\n$notice\n" {blue filelink}	
	} elseif { $mode == {w} } {
			$id insert end "\n$notice\n" {blue filelink}	
	}
}

proc attach_file {w} {
	set filename [tk_getOpenFile]
	set data {}
	if { $filename != "" && [file exists $filename] } { 
		hash_file $filename
		set f [open $filename r]
		fconfigure $f -translation binary
		set data [read $f]
		close $f
	} else {
		log_puts "ERR" "attach_file failed to read file"
		return
	}
	set hash [lindex [array get ::hash_by_file [wrap $filename]] end]
	set details [lindex [array get ::file_by_hash $hash] end]
	set name [lindex [file split [unwrap [dict get $details name]]] end]
	set size [dict get $details size]
	if { $size >= [expr {1024*1024*24}] } {
		log_puts "ERR" "attach_file bigger than 24mb, not attaching"
		return
	}
	set vnotice "ATTACH $name ($size) "
	set dnotice "<[wrap $data]>"
	$w insert end "\n"
	$w insert end "$vnotice" {red attachlink}
	$w insert end "$dnotice" {hide red attachlink}
	$w insert end "\n"
}

proc insert_inline_image {mode id} {
	#set types {
	#	{{GIF} {.gif}}
	#	{{GIF} {.GIF}}
	#	{{PNG} {.png}}
	#	{{PNG} {.PNG}}
	#	{{JPG} {.jpg}}
	#	{{JPG} {.JPG}}
	#	{{JPG} {.jpeg}}
	#	{{JPG} {.JPEG}}
	#}
	set types {
		{{PNG} {.png}}
		{{PNG} {.PNG}}
	}
	set filename [tk_getOpenFile -filetypes $types]
	if { $filename == "" || ![file exists $filename] } { 
		return
	} else {
		hash_file $filename
	}
	set name [lindex [file split $filename] end]
	log_puts "ALL" "reading $filename"
	set f [open $filename r]
	fconfigure $f -translation binary -buffering none
	set data [read $f]
	close $f
	log_puts "ALL" "have read $filename"
	set size [string length $data]
	if { $size > [expr "1024*1024*8"] } {
		log_puts "ERR" "bigger than 8 mb, not sending"
		return
	}
	set notice "IMG $name ($size) <[binary encode base64 $data]>"
	log_puts "ALL" "formed notice $name ($size) <...>"
	if { $mode == {p} } {
			gchat_notice chat $id $notice
	} elseif { $mode == {g} } {
			gchat_notice gchat $id $notice
	} elseif { $mode == {e} } {
			.e.x.t insert end "\nIMG $name ($size) " {blue inline_image}	
			.e.x.t insert end "<[binary encode base64 $data]>" {hide blue inline_image}	
			.e.x.t insert end "\n" {blue inline_image}	
	}
}

proc insert_linked_image {mode id} {
	set types {
		{{PNG} {.png}}
		{{PNG} {.PNG}}
	}
	set filename [tk_getOpenFile -filetypes $types]
	if { $filename == "" || ![file exists $filename] } { 
		return
	} else {
		hash_file $filename
	}
	set name [lindex [file split $filename] end]
	log_puts "ALL" "reading $filename"
	set f [open $filename r]
	fconfigure $f -translation binary -buffering none
	set data [read $f]
	close $f
	log_puts "ALL" "have read $filename"
	set size [string length $data]
	if { $size > [expr "1024*1024*8"] } {
		log_puts "ERR" "bigger than 8 mb, not sending"
		return
	}
	log_puts "ALL" "formed notice $name ($size) <...>"
	set hash [lindex [array get ::hash_by_file [wrap $filename]] end]
	log_puts "ALL" "hash $hash"
	set details [lindex [array get ::file_by_hash $hash] end]
	log_puts "ALL" "details $details"
	set name [lindex [file split [unwrap [dict get $details name]]] end]
	set size [dict get $details size]
	set r {}
	dict set r filehash $hash
	dict set r filename $name
	dict set r offset 0
	dict set r len $size
	set req [dl_dictreq $r]
	if { $req == "" } {
		return
	}
	set notice "LIMG $name ($size) <$req>"
	if { $mode == {p} } {
			gchat_notice chat $id $notice
	} elseif { $mode == {g} } {
			gchat_notice gchat $id $notice
	} elseif { $mode == {e} } {
			.e.x.t insert end "\n$notice\n" {blue imagelink}	
	} elseif { $mode == {w} } {
			$id insert end "\n$notice\n" {blue imagelink}	
	}
}

proc record_voice_start {w} {
	if { $::cur(record,running) == 1 } {
		record_voice_end
	}
	set ::cur(record,start) [clock seconds]
	set ::cur(record,data) {}
	set ::cur(record,chan) [open "tmprec.raw" w+]
	#set ::cur(record,chan) [tcl::chan::memchan]
	#set ::cur(record,chan) [tcl::chan::fifo_fix]
	#set ::cur(record,chan) [::queue::queue]
	fconfigure $::cur(record,chan) -translation binary -buffering full -blocking 0
	::pa::init 48000 1
	::pa::rec_chan $::cur(record,chan)
	::pa::rec_start
	set ::cur(record,schedule) [after 300000 record_voice_end]
	set ::cur(record,running) 1
	after idle [list record_voice_run $w]
}

proc record_voice_run {w} {
	if { $::cur(record,running) == 0 } {
		return
	}
	if { $w == {} } {
		record_voice_end
		return
	}
	if { ![winfo exists $w] } {
		record_voice_end
		return
	}
	after 1000 [list record_voice_run $w]
}

proc record_voice_end {} {
	if { $::cur(record,running) == 0 } {
		return
	}
	catch { after cancel $::cur(record,schedule) }
	set c $::cur(record,chan)
	log_puts "ALL" "record_voice_end ::pa::rec_end"
	::pa::rec_end
	log_puts "ALL" "record_voice_end ::pa::rec_end done"
	log_puts "ALL" "record_voice_end ::pa::term"
	::pa::term
	log_puts "ALL" "record_voice_end ::pa::term done"
	flush $c
	seek $c 0
	log_puts "ALL" "record_voice_end encode to opus"
	set ::cur(record,data) [::opus::enc [read $c] 48000 1]
	log_puts "ALL" "record_voice_end close"
	catch { close $c }
	catch { file delete "tmprec.raw" }
	log_puts "ALL" "record_voice_end close done"
	set ::cur(record,chan) {}
	set ::cur(record,schedule) {}
	set ::cur(record,running) 0
	set ::cur(record,end) [clock seconds]
}

proc play_voice_start {w dur data} {
	log_puts "ALL" "play_voice_start w $w dur $dur data len [string length $data]"
	if { $::cur(play,running) == 1 } {
		play_voice_end
	}
	if { !($dur > 0) || $dur == {} } {
		play_voice_end
		return	
	}
	set ::cur(play,start) [clock seconds] 
	set ::cur(play,dur) $dur
	set ::cur(play,chan) [open "tmprec.raw" w+]
	#set ::cur(play,chan) [tcl::chan::memchan]
	#set ::cur(play,chan) [tcl::chan::fifo_fix]
	#set ::cur(play,chan) [::queue::queue]
	fconfigure $::cur(play,chan) -translation binary -buffering full -blocking 0
	puts -nonewline $::cur(play,chan) [::opus::dec $data 48000 1]
	seek $::cur(play,chan) 0
	::pa::init 48000 1
	::pa::play_chan $::cur(play,chan)
	::pa::play_start
	set ::cur(play,schedule) [after [expr {$dur*1000}] play_voice_end]
	set ::cur(play,running) 1
	after idle [list play_voice_run $w]
}

proc play_voice_run {w} {
	if { $::cur(play,running) == 0 } {
		return
	}
	if { $w == {} } {
		play_voice_end
		return
	}
	if { ![winfo exists $w] } {
		play_voice_end
		return
	}
	if { ![winfo exists .play] } {
		set ::cur(play,line) {}
		show_play_voice
	} else { 
		set dur $::cur(play,dur)
		set now [clock seconds]
		set elapsed [expr {$now-$::cur(play,start)}] 
		set ::cur(play,line) "[expr {${elapsed}/60}]m[expr {${elapsed}%60}]s/[expr {${dur}/60}]m[expr {${dur}%60}]s" 
	}
	after 1000 [list play_voice_run $w]
}

proc show_play_voice {} {
	set w .play
	if { [winfo exists $w] } {
		return
	}
	toplevel $w
	wm title $w [::msgcat::mc "play_t"] 
	pack [panedwindow $w.p -ori vert] -fill both -expand 1
	$w.p add [wframe $w.t0]
	pack [wlabel $w.t0.t -text [::msgcat::mc "play_l"] -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) -font $::options(font) ] -fill both -side left
	$w.p add [wframe $w.t1]
	pack [wlabel $w.t1.l -textvariable ::cur(play,line) -width 24 -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) -font $::options(font) ] -fill both -side right 
	$w.p add [wframe $w.t2]
	pack [wbutton $w.t2.b -text [::msgcat::mc "stop"] -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) -font $::options(font) -command "play_voice_end" ] -fill both -side right
}

proc play_voice_end {} {
	catch { destroy .play }
	if { $::cur(play,running) == 0 } {
		return
	}
	catch { after cancel $::cur(play,schedule) }
	set c $::cur(play,chan)
	log_puts "ALL" "play_voice_end ::pa::play_end"
	::pa::play_end
	log_puts "ALL" "play_voice_end ::pa::play_end done"
	log_puts "ALL" "play_voice_end ::pa::term"
	::pa::term
	log_puts "ALL" "play_voice_end ::pa::term done"
	log_puts "ALL" "play_voice_end close"
	catch { close $c }
	catch { file delete "tmprec.raw" }
	log_puts "ALL" "play_voice_end close done"
	set ::cur(play,schedule) {}
	set ::cur(play,chan) {}
	set ::cur(play,dur) {}
	set ::cur(play,running) 0
}

proc insert_inline_voice {mode id} {
	set data $::cur(record,data)
	if { $data == {} } {
		log_puts "ERR" "empty voice record, not sending"
		return
	}
	set ::cur(record,data) {}
	set dur [expr {$::cur(record,end)-$::cur(record,start)}]
	set ::cur(record,start) {}
	set ::cur(record,end) {}
	set size [string length $data]
	set name "Audio"
	if { $size > [expr "1024*1024*8"] } {
		log_puts "ERR" "bigger than 8 mb, not sending"
		return
	}
	set notice "REC $dur ($size) <[binary encode base64 $data]>"
	log_puts "ALL" "formed notice $name ($size) <...>"
	if { $mode == {p} } {
		gchat_notice chat $id $notice
	} elseif { $mode == {g} } {
		gchat_notice gchat $id $notice
	} elseif { $mode == {e} } {
		.e.x.t insert end "\nREC $dur ($size) <" {magenta inline_voice}	
		.e.x.t insert end "[binary encode base64 $data]" {hide magenta inline_voice}
		.e.x.t insert end ">\n" {magenta inline_voice}	
	}
}

proc insert_linked_voice {mode id} {
	set data $::cur(record,data)
	if { $data == {} } {
		log_puts "ERR" "empty voice record, not sending"
		return
	}
	set ::cur(record,data) {}
	set dur [expr {$::cur(record,end)-$::cur(record,start)}]
	set ::cur(record,start) {}
	set ::cur(record,end) {}
	set size [string length $data]
	if { $size > [expr "1024*1024*8"] } {
		log_puts "ERR" "bigger than 8 mb, not sending"
		return
	}
	set filename [file join $::filepath "share" "voice_${dur}_[clock microseconds].ropus"]
	set f [open $filename w]
	fconfigure $f -translation binary -buffering none
	puts -nonewline $f $data
	close $f
	if { $filename == "" || ![file exists $filename] } { 
		return
	} else {
		hash_file $filename
	}
	set hash [lindex [array get ::hash_by_file [wrap $filename]] end]
	log_puts "ALL" "hash $hash"
	set details [lindex [array get ::file_by_hash $hash] end]
	log_puts "ALL" "details $details"
	set fname [lindex [file split [unwrap [dict get $details name]]] end]
	set size [dict get $details size]
	set r {}
	dict set r filehash $hash
	dict set r filename $fname
	dict set r offset 0
	dict set r len $size
	set req [dl_dictreq $r]
	if { $req == "" } {
		return
	}
	set name "Audio $dur"
	set notice "LREC $name ($size) <$req>"
	log_puts "ALL" "formed notice $name ($size) <$req>"
	if { $mode == {p} } {
		gchat_notice chat $id $notice
	} elseif { $mode == {g} } {
		gchat_notice gchat $id $notice
	} elseif { $mode == {e} } {
		.e.x.t insert end "\n$notice\n" {blue voicelink}
	} elseif { $mode == {w} } {
		$id insert end "\n$notice\n" {blue voicelink}
	}
}

proc show_debug {} {
	if { [winfo exists .p] == 1 } {
		return
	}
	toplevel .p
	wm title .p {Debug console}
	pack [panedwindow .p.p -ori vert] -fill both -expand 1
	.p.p add [wframe .p.x0] -minsize 24 -stretch never
	grid [wlabel .p.x0.lmp -textvar ::options(myport) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) -font $::options(font) ] -sticky nsew -columnspan 1 -rowspan 1 -column 1 -row 0
	grid [wlabel .p.x0.lme -textvar ::me(id) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) -font $::options(font) ] -sticky nsew -columnspan 3 -rowspan 1 -column 2 -row 0
	.p.p add [wframe .p.x1] -stretch always
	grid [wframe .p.x1.p ] -sticky nsew -columnspan 1 -rowspan 10 -column 0 -row 0
	grid [wlabel .p.x1.p.t -text "processes" -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) -font $::options(font) ] -sticky nsew -columnspan 1 -rowspan 1 -column 0 -row 0
	grid [listbox .p.x1.p.l -listvariable ::p_l -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) -selectforeground $::options(basecolor) -selectbackground $::options(hilightcolor) -font $::options(font) ] -sticky nsew -columnspan 1 -rowspan 10 -column 0 -row 1 
	grid [wframe .p.x1.b ] -sticky nsew -columnspan 1 -rowspan 10 -column 1 -row 0
	grid [wlabel .p.x1.b.t -text "buckets" -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) -font $::options(font) ] -sticky nsew -columnspan 1 -rowspan 1 -column 0 -row 0
	grid [listbox .p.x1.b.l -listvariable ::dbg(b,l) -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) -selectforeground $::options(basecolor) -selectbackground $::options(hilightcolor) -font $::options(font) ] -sticky nsew -columnspan 1 -rowspan 10 -column 0 -row 1
	grid [wframe .p.x1.ps ] -sticky nsew -columnspan 1 -rowspan 10 -column 2 -row 0
	grid [wlabel .p.x1.ps.t -text "peerstore" -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) -font $::options(font) ] -sticky nsew -columnspan 1 -rowspan 1 -column 0 -row 0
	grid [listbox .p.x1.ps.l -listvariable ::dbg(peerstore,l) -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) -selectforeground $::options(basecolor) -selectbackground $::options(hilightcolor) -font $::options(font) ] -sticky nsew -columnspan 1 -rowspan 10 -column 0 -row 1
	grid [wframe .p.x1.vs ] -sticky nsew -columnspan 1 -rowspan 10 -column 3 -row 0
	grid [wlabel .p.x1.vs.t -text "valuestore" -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) -font $::options(font) ] -sticky nsew -columnspan 1 -rowspan 1 -column 0 -row 0
	grid [listbox .p.x1.vs.l -listvariable ::dbg(valuestore,l) -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) -selectforeground $::options(basecolor) -selectbackground $::options(hilightcolor) -font $::options(font) ] -sticky nsew -columnspan 1 -rowspan 10 -column 0 -row 1
	grid [wframe .p.x1.vc ] -sticky nsew -columnspan 1 -rowspan 10 -column 4 -row 0
	grid [wlabel .p.x1.vc.t -text "contacts" -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) -font $::options(font) ] -sticky nsew -columnspan 1 -rowspan 1 -column 0 -row 0
	grid [listbox .p.x1.vc.l -listvariable ::dbg(contacts,l) -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) -selectforeground $::options(basecolor) -selectbackground $::options(hilightcolor) -font $::options(font) ] -sticky nsew -columnspan 1 -rowspan 10 -column 0 -row 1
	grid [wframe .p.x1.vh ] -sticky nsew -columnspan 1 -rowspan 10 -column 5 -row 0
	grid [wlabel .p.x1.vh.t -text "headers" -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) -font $::options(font) ] -sticky nsew -columnspan 1 -rowspan 1 -column 0 -row 0
	grid [listbox .p.x1.vh.l -listvariable ::dbg(headers,l) -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) -selectforeground $::options(basecolor) -selectbackground $::options(hilightcolor) -font $::options(font) ] -sticky nsew -columnspan 1 -rowspan 10 -column 0 -row 1
	grid [wframe .p.x1.vw ] -sticky nsew -columnspan 1 -rowspan 10 -column 6 -row 0
	grid [wlabel .p.x1.vw.t -text "waitvalue" -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) -font $::options(font) ] -sticky nsew -columnspan 1 -rowspan 1 -column 0 -row 0
	grid [listbox .p.x1.vw.l -listvariable ::dbg(waitvalue,l) -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) -selectforeground $::options(basecolor) -selectbackground $::options(hilightcolor) -font $::options(font) ] -sticky nsew -columnspan 1 -rowspan 10 -column 0 -row 1
	.p.p add [wframe .p.x2] -minsize 24 -stretch never
	grid [wlabel .p.x2.brl_h -text {host} -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) -font $::options(font) ] -sticky nsew -columnspan 1 -rowspan 1 -column 0 -row 0 
	grid [wlabel .p.x2.brl_p -text {port} -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) -font $::options(font) ] -sticky nsew -columnspan 1 -rowspan 1 -column 1 -row 0
	grid [wlabel .p.x2.brl_k -text {key} -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) -font $::options(font) ] -sticky nsew -columnspan 1 -rowspan 1 -column 2 -row 0
	grid [wlabel .p.x2.brl_v -text {value} -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) -font $::options(font) ] -sticky nsew -columnspan 1 -rowspan 1 -column 3 -row 0
	grid [wentry .p.x2.brt_h -textvariable ::formhost -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) -selectforeground $::options(basecolor) -selectbackground $::options(hilightcolor) -font $::options(font) ] -sticky nsew -columnspan 1 -rowspan 1 -column 0 -row 1 
	grid [wentry .p.x2.brt_p -textvariable ::formport -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) -selectforeground $::options(basecolor) -selectbackground $::options(hilightcolor) -font $::options(font) ] -sticky nsew -columnspan 1 -rowspan 1 -column 1 -row 1
	grid [wentry .p.x2.brt_k -textvariable ::formkey -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) -selectforeground $::options(basecolor) -selectbackground $::options(hilightcolor) -font $::options(font) ] -sticky nsew -columnspan 1 -rowspan 1 -column 2 -row 1
	grid [wentry .p.x2.brt_v -textvariable ::formvalue -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) -selectforeground $::options(basecolor) -selectbackground $::options(hilightcolor) -font $::options(font) ] -sticky nsew -columnspan 1 -rowspan 1 -column 3 -row 1
	.p.p add [wframe .p.x3] -minsize 24 -stretch never
	grid [wbutton .p.x3.br -text "sol" -command {sol $::formhost $::formport} -activebackground $::options(hilightcolor) -activeforeground $::options(basecolor) -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor)  -font $::options(font) ] -sticky nsew -columnspan 1 -rowspan 1 -column 0 -row 0
	grid [wbutton .p.x3.bp -text "ping" -command {str_start [str_create PING $::formhost $::formport none none]} -activebackground $::options(hilightcolor) -activeforeground $::options(basecolor) -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor)  -font $::options(font) ] -sticky nsew -columnspan 1 -rowspan 1 -column 1 -row 0
	grid [wbutton .p.x3.bs -text "store" -command {str_start [str_create STORE $::formhost $::formport $::formkey $::formvalue]} -activebackground $::options(hilightcolor) -activeforeground $::options(basecolor) -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor)  -font $::options(font) ] -sticky nsew -columnspan 1 -rowspan 1 -column 2 -row 0
	grid [wbutton .p.x3.bfn -text "find_node" -command {str_start [str_create FIND_NODE $::formhost $::formport $::formkey none]} -activebackground $::options(hilightcolor) -activeforeground $::options(basecolor) -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor)  -font $::options(font) ] -sticky nsew -columnspan 1 -rowspan 1 -column 3 -row 0
	grid [wbutton .p.x3.bfv -text "find_value" -command {str_start [str_create FIND_VALUE $::formhost $::formport $::formkey none]} -activebackground $::options(hilightcolor) -activeforeground $::options(basecolor) -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor)  -font $::options(font) ] -sticky nsew -columnspan 1 -rowspan 1 -column 4 -row 0
	grid [wbutton .p.x3.ss -text "sol_store" -command {sol_store} -activebackground $::options(hilightcolor) -activeforeground $::options(basecolor) -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor)  -font $::options(font) ] -sticky nsew -columnspan 1 -rowspan 1 -column 5 -row 0
	#grid [wbutton .p.x3.hf -text "hash_files" -command {hash_files} -activebackground $::options(hilightcolor) -activeforeground $::options(basecolor) -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor)  -font $::options(font) ] -sticky nsew -columnspan 1 -rowspan 1 -column 5 -row 0
	if { $::options(run_i2p) == 1 } {
	grid [wbutton .p.x3.i2c -text "copy_i2p_dest" -command {i2p_copy_dest} -activebackground $::options(hilightcolor) -activeforeground $::options(basecolor) -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor)  -font $::options(font) ] -sticky nsew -columnspan 1 -rowspan 1 -column 6 -row 0
	grid [wbutton .p.x3.i2p -text "paste_i2p_dest" -command {i2p_paste_dest} -activebackground $::options(hilightcolor) -activeforeground $::options(basecolor) -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor)  -font $::options(font) ] -sticky nsew -columnspan 1 -rowspan 1 -column 7 -row 0
	}
	update_widgets
}

proc show_mail {} {
	if { [winfo exists .m] == 1 } {
		return
	}
	toplevel .m
	wm title .m  [::msgcat::mc "mail_t" $::options(myport) $::me(nickname) $::me(id)]
	make_menu .m
	make_nmenu

	set detail_cmd {
		if { $::cur(main,mode) == {p} } {
			set l_b [array get ::buddies]
			set l_bn [lsearch $l_b $::cur(main,person,h)]
			set l_hash [lindex $l_b [expr {$l_bn-1}]]
			show_buddy_details $l_hash 
		} elseif { $::cur(main,mode) == {g} } {
			show_group_details $::cur(main,group,h) 	
		}
	}

	set browse_cmd {
		if { $::cur(main,mode) == {p} } {
			ml_personbrowse $::cur(main,person,h)
		}
	}

	set chat_cmd {
		if { $::cur(main,mode) == {p} && $::cur(main,person,h) != "" } {
			set l_b [array get ::buddies]
			set l_bn [lsearch $l_b $::cur(main,person,h)]
			set l_hash [lindex $l_b [expr {$l_bn-1}]]
			show_gchatwindow chat $l_hash 
		} elseif { $::cur(main,mode) == {g} && $::cur(main,group,h) != "" } {
			set l_gid [dict get [ml_groupdict $::cur(main,group,h)] gid]
			show_gchatwindow gchat $l_gid
		}
	}

	set doc_cmd {
		if { $::cur(main,mode) == {g} && $::cur(main,group,h) != "" } {
			set l_gid [dict get [ml_groupdict $::cur(main,group,h)] gid]
			show_doc_list mlhdr $l_gid
		}
	
	}
	
	set mail_cmd {
		if { $::cur(main,mode) == {g} && $::cur(main,group,h) != "" } {
			set gid [dict get [ml_groupdict $::cur(main,group,h)] gid]
			show_gmailwindow $gid
		}
	}

	set gr_cmd {
		if { $::cur(main,mode) == {g} && $::cur(main,group,h) != "" } {
			show_gredit [clock microseconds] {} {}
		}
	}

	set reply_cmd {
		if { $::cur(main,mode) == {m} } {	
			show_editor [mail_header_to_contact [lindex $::msglist(main,k) [lindex [.m.x.ls index active] 0]]]
			set ::parent(main) [lindex $::msglist(main,k) [lindex [.m.x.ls index active] 0]]
		} elseif { $::cur(main,mode) == {p} && $::cur(main,person,h) != "" } {	
			if { [.m.p panecget .m.x -hide] } {
				set ::subject(main) "Re:[dict get [header_to_dict $::cur(main,header)] subject]"
				set ::parent(main) $::cur(main,header)
			} else {
				set ::subject(main) "Re:[dict get [header_to_dict [lindex $::msglist(main,k) [lindex [.m.x.ls index active] 0]]] subject]";
				set ::parent(main) [lindex $::msglist(main,k) [lindex [.m.x.ls index active] 0]]
			}
			show_editor {}
		} elseif { $::cur(main,mode) == {g} && $::cur(main,group,h) != "" } {	
			if { [.m.p panecget .m.x -hide] } {
				set ::subject(main) "Re:[dict get [header_to_dict $::cur(main,header)] subject]"
				set ::parent(main) $::cur(main,header)
			} else {
				set ::subject(main) "Re:[dict get [header_to_dict [lindex $::msglist(main,k) [lindex [.m.x.ls index active] 0]]] subject]";
				set ::parent(main) [lindex $::msglist(main,k) [lindex [.m.x.ls index active] 0]]
			}
			show_editor {}
		} elseif { $::cur(main,mode) == {n} } {
			set ::cur(main,mode) {n};
			set ::subject(main) "Re:[dict get [header_to_dict [lindex $::msglist(main,k) [lindex [.m.x.ls index active] 0]]] subject]";
			set ::parent(main) [lindex $::msglist(main,k) [lindex [.m.x.ls index active] 0]]
			show_editor [mail_header_to_contact [lindex $::msglist(main,k) [lindex [.m.x.ls index active] 0]]]
		}
	}

	set emit_cmd {
		if { $::cur(main,mode) == {m} } {
			set ::subject(main) {}
			set ::parent(main) {}
			show_editor {}
		} elseif { $::cur(main,mode) == {p} && $::cur(main,person,h) != "" } {
			set ::subject(main) {}
			set ::parent(main) {}
			show_editor {}
		} elseif { $::cur(main,mode) == {g} && $::cur(main,group,h) != "" } {
			set ::subject(main) {}
			set ::parent(main) {}
			show_editor {}
		} elseif { $::cur(main,mode) == {n} }  {
			set ::cur(main,mode) {n};
			set ::subject(main) {}
			set ::parent(main) {}
			show_editor {}	
		}
	}

	set delete_cmd {
		if { $::cur(main,mode) == {p} || $::cur(main,mode) == {g} } {	
			if { [.m.p panecget .m.x -hide] && $::cur(main,header) != {} } {
				set hash [dict get [header_to_dict $::cur(main,header)] hash]
			} else {
				set hash [dict get [header_to_dict [lindex $::msglist(main,k) [lindex [.m.x.ls index active] 0]]] hash]
			}
			set choice [tk_dialog .mdd [::msgcat::mc "mdel_t"] [::msgcat::mc "mdel_l" $hash] {} 0 [::msgcat::mc "cancel"] [::msgcat::mc "ok"]]
			if { $choice == 1 } {
				ml_add_del $hash
				.m.p paneconfigure .m.x -hide false
				.m.p paneconfigure .m.f -hide $::options(hide_pane) 
			}
		}
	}

	set search_cmd {
		if { $::cur(main,mode) == {m} } {
			.m.b.gtr configure -state disabled;
			.m.b.gtrs configure -state normal;
			show_headers [sc_get_headers [prep_header_keys [build_personal_filter]]]
		} elseif { $::cur(main,mode) == {n} && $::searchfield(main) != {} }  {
			.m.b.gtr configure -state disabled;
			.m.b.gtrs configure -state normal;
			show_headers [sc_get_headers [prep_header_keys $::searchfield(main)]]
		} elseif { $::cur(main,mode) == {g} && $::cur(main,group,h) != {} }  {
			ml_grouphead $::cur(main,group,h)
		} elseif { $::cur(main,mode) == {p} && $::cur(main,person,h) != {} }  {
			ml_personhead $::cur(main,person,h)
		}
	}

	set stop_cmd {
		.m.b.gtr configure -state normal
		.m.b.gtrs configure -state disabled
		sc_stop $::search
	}

	set filter_cmd {
		if { $::cur(main,mode) == {g} && $::cur(main,group,h) != {} } {
			ml_showlist g [dict get [ml_groupdict $::cur(main,group,h)] gid]
		} elseif { $::cur(main,mode) == {p} && $::cur(main,person,h) != {} } {
			ml_showlist p [dict get [contact_to_dict $::cur(main,person,h)] peerid]
		}
	}

	set read_cmd {
		if { $::cur(main,mode) == {m} || $::cur(main,mode) == {n} } {
			show_text [sc_ask [lindex $::msglist(main,k) [lindex [.m.x.ls index active] 0]]]
		} elseif { $::cur(main,mode) == {g} || $::cur(main,mode) == {p} } {
			set ::cur(main,header) [lindex $::msglist(main,k) [lindex [.m.x.ls index active] 0]]
			ml_showmsg .m.f.t $::cur(main,header)
			if { [.m.p panecget .m.x -hide] } {
				.m.p paneconfigure .m.x -hide false
				.m.p paneconfigure .m.f -hide $::options(hide_pane)
			} else {
				.m.p paneconfigure .m.f -hide false
				.m.p paneconfigure .m.x -hide $::options(hide_pane)
			}
			set ::recent(main) [lsort -unique [lrange $::recent(main) end-100 end]]
			lappend ::recent(main) $::cur(main,header)
		}
	}

	set toggle_tools {
			if { [.m.p panecget .m.s -hide] } {
				.m.p paneconfigure .m.s -hide false
				.m.p paneconfigure .m.ee -hide false
			} else {
				.m.p paneconfigure .m.s -hide true 
				.m.p paneconfigure .m.ee -hide true
			}
	}

	pack [panedwindow .m.p -ori vert] -fill both -expand 1
	#.m.p add [wframe .m.igc] -stretch never
	#pack [wlabel .m.igc.line -textvar ::topline(main,l) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) -font $::options(font) ] -fill both -side left 
	.m.p add [wframe .m.b] -minsize 24 -stretch never
	pack [wbutton .m.b.gt -text [::msgcat::mc "read"]  -activebackground $::options(hilightcolor) -activeforeground $::options(basecolor) -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor)  -font $::options(font) -command $read_cmd] -fill both -side left
	pack [wbutton .m.b.grr -text [::msgcat::mc "reply"]  -activebackground $::options(hilightcolor) -activeforeground $::options(basecolor) -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor)  -font $::options(font) -command "$reply_cmd ; $filter_cmd" ] -fill both -side left
	pack [wbutton .m.b.vn -text [::msgcat::mc "compose"]  -activebackground $::options(hilightcolor) -activeforeground $::options(basecolor) -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor)  -font $::options(font) -command $emit_cmd] -fill both -side left
	pack [wbutton .m.b.del -text [::msgcat::mc "delete"]  -activebackground $::options(hilightcolor) -activeforeground $::options(basecolor) -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor)  -font $::options(font) -command "$delete_cmd ; $filter_cmd" ] -fill both -side left
	pack [wlabel .m.b.sep1 -text " " -width 1 -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) -font $::options(font) ] -side left 
	pack [wbutton .m.b.scs -text [::msgcat::mc "p"]  -activebackground $::options(hilightcolor) -activeforeground $::options(basecolor) -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor)  -font $::options(font) -command {show_contact_selection}] -fill both -side left
	pack [wbutton .m.b.sgs -text [::msgcat::mc "g"]  -activebackground $::options(hilightcolor) -activeforeground $::options(basecolor) -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor)  -font $::options(font) -command {show_group_selection}] -fill both -side left
	#pack [wbutton .m.b.sms -text "m"  -activebackground $::options(hilightcolor) -activeforeground $::options(basecolor) -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor)  -font $::options(font) -command {set ::cur(main,mode) {m} }] -fill both -side left
	#pack [wbutton .m.b.sns -text "n"  -activebackground $::options(hilightcolor) -activeforeground $::options(basecolor) -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor)  -font $::options(font) -command {set ::cur(main,mode) {n} }] -fill both -side left
	pack [wlabel .m.b.sep2 -text " " -width 1 -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) -font $::options(font) ] -side left 
	pack [wbutton .m.b.chat -text [::msgcat::mc "chat"]  -activebackground $::options(hilightcolor) -activeforeground $::options(basecolor) -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor)  -font $::options(font) -command $chat_cmd] -fill both -side left
	pack [wbutton .m.b.doc -text [::msgcat::mc "doc"]  -activebackground $::options(hilightcolor) -activeforeground $::options(basecolor) -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor)  -font $::options(font) -command $doc_cmd] -fill both -side left
	#pack [wbutton .m.b.dl -text "dl" -activebackground $::options(hilightcolor) -activeforeground $::options(basecolor) -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor)  -font $::options(font) -command {show_dlstate}] -fill both -side left
	#pack [wbutton .m.b.dbg -text "dbg" -activebackground $::options(hilightcolor) -activeforeground $::options(basecolor) -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor)  -font $::options(font) -command {show_debug}] -fill both -side left
	#pack [wbutton .m.b.mail -text "mail" -activebackground $::options(hilightcolor) -activeforeground $::options(basecolor) -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor)  -font $::options(font) -command $mail_cmd] -fill both -side left
	#pack [wbutton .m.b.gr -text "gr" -activebackground $::options(hilightcolor) -activeforeground $::options(basecolor) -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor)  -font $::options(font) -command $gr_cmd] -fill both -side left
	#pack [wbutton .m.b.browse -text "browse" -activebackground $::options(hilightcolor) -activeforeground $::options(basecolor) -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor)  -font $::options(font) -command $browse_cmd] -fill both -side left
	#pack [wbutton .m.b.detail -text "i" -activebackground $::options(hilightcolor) -activeforeground $::options(basecolor) -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor)  -font $::options(font) -command $detail_cmd] -fill both -side left
	pack [wlabel .m.b.sep3 -text " " -width 1 -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) -font $::options(font) ] -side left 
	pack [wbutton .m.b.recent -text [::msgcat::mc "recent"] -activebackground $::options(hilightcolor) -activeforeground $::options(basecolor) -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor)  -font $::options(font) -command "show_recent none none none"] -fill both -side left
	#pack [wlabel .m.b.menu -text "menu"  -activebackground $::options(hilightcolor) -activeforeground $::options(basecolor) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor)  -font $::options(font) ] -fill both -side right
	pack [wbutton .m.b.gtr -text [::msgcat::mc "gather"]  -activebackground $::options(hilightcolor) -activeforeground $::options(basecolor) -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor)  -font $::options(font) -command $search_cmd] -fill both -side right
	pack [wbutton .m.b.net -text [::msgcat::mc "net"]  -activebackground $::options(hilightcolor) -activeforeground $::options(basecolor) -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor)  -font $::options(font) -command "net_update"] -fill both -side right
	#pack [wbutton .m.b.gtrs -text [::msgcat::mc "stop"]  -activebackground $::options(hilightcolor) -activeforeground $::options(basecolor) -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor)  -font $::options(font) -command $stop_cmd] -fill both -side right
	pack [wlabel .m.b.sep0 -text " " -width 1 -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) -font $::options(font) ] -side right
	pack [wbutton .m.b.upd -text [::msgcat::mc "filter"]  -activebackground $::options(hilightcolor) -activeforeground $::options(basecolor) -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor)  -font $::options(font) -command $filter_cmd] -fill both -side right
	pack [wentry .m.b.g -textvariable ::searchfield(main) -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) -selectforeground $::options(basecolor) -selectbackground $::options(hilightcolor) -font $::options(font) -width 20 ] -fill both -side right
	pack [wlabel .m.b.sep4 -text " " -width 1 -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) -font $::options(font) ] -side right
	.m.p add [wframe .m.igc] -stretch never
	#pack [wentry .m.igc.g -textvariable ::searchfield(main) -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) -selectforeground $::options(basecolor) -selectbackground $::options(hilightcolor) -font $::options(font) -width 12 ] -fill both -side left
	#pack [wbutton .m.igc.upd -text "f"  -activebackground $::options(hilightcolor) -activeforeground $::options(basecolor) -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor)  -font $::options(font) -command $filter_cmd] -fill both -side left
	#pack [wbutton .m.igc.cba -text "+p" -width 2 -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) -font $::options(font) -command {add_copied_contact} ] -side right
	#pack [wbutton .m.igc.cbc -text "^p" -width 2 -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) -font $::options(font) -command {copy_contact} ] -side right
	#pack [wbutton .m.igc.cbga -text "+g" -width 2 -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) -font $::options(font) -command {add_copied_group} ] -side right
	#pack [wbutton .m.igc.cbgc -text "^g" -width 2 -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) -font $::options(font) -command {copy_group} ] -side right
	pack [wbutton .m.igc.togg -text "+" -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) -font $::options(font) -command "$toggle_tools" ] -side right
	pack [wlabel .m.igc.sep0 -text " " -width 1 -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) -font $::options(font) ] -side right
	pack [wbutton .m.igc.detail -text [::msgcat::mc "i"] -activebackground $::options(hilightcolor) -activeforeground $::options(basecolor) -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor)  -font $::options(font) -command $detail_cmd] -fill both -side right
	#pack [wlabel .m.igc.sep1 -text " " -width 1 -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) -font $::options(font) ] -side right
	#pack [wbutton .m.igc.chat -text [::msgcat::mc "chat"]  -activebackground $::options(hilightcolor) -activeforeground $::options(basecolor) -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor)  -font $::options(font) -command $chat_cmd] -fill both -side right
	#pack [wbutton .m.igc.doc -text [::msgcat::mc "doc"]  -activebackground $::options(hilightcolor) -activeforeground $::options(basecolor) -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor)  -font $::options(font) -command $doc_cmd] -fill both -side right
	pack [wlabel .m.igc.mr -text ">" -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) -font $::options(font) ] -fill both -side right 
	pack [wlabel .m.igc.line_r -textvar ::topline(main,r) -width 40 -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) -font $::options(font) ] -fill both -side right
	pack [wlabel .m.igc.ml -text "<" -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) -font $::options(font) ] -fill both -side right
	pack [wlabel .m.igc.line -textvar ::topline(main,l) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) -font $::options(font) ] -fill both -side left
	.m.p add [wframe .m.x] -minsize 24 -stretch always
	pack [wscrollbar .m.x.y -activebackground $::options(hilightcolor)  -troughcolor $::options(hilightcolor)  -command "tl_yview 1 .m.x.ls"] -fill y -side right
	pack [listbox .m.x.ls -listvariable ::msglist(main,l) -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) -selectforeground $::options(basecolor) -selectbackground $::options(hilightcolor) -font $::options(listfont) -width 60 -height 20 -yscrollc ".m.x.y set"] -fill both -expand 1 -side right
	#.m.p add [wframe .m.d] -stretch always
	#pack [wscrollbar .m.d.y -activebackground $::options(hilightcolor)  -troughcolor $::options(hilightcolor)  -command ".m.d.l yview"] -fill y -side right
	#pack [listbox .m.d.l -listvariable ::dllist -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) -selectforeground $::options(basecolor) -selectbackground $::options(hilightcolor) -font $::options(listfont) -height 3 -yscrollc ".m.d.y set"] -fill both -expand 1 -side right
	.m.p add [wframe .m.f] -minsize 24 -stretch always -hide $::options(hide_pane) 
	pack [wscrollbar .m.f.y -activebackground $::options(hilightcolor)  -troughcolor $::options(hilightcolor)  -command ".m.f.t yview"] -fill y -side right
	pack [text .m.f.t -wrap word -yscrollc ".m.f.y set" \
		-selectforeground {#6090c0} -selectbackground $::options(hilightcolor) \
		-padx 5 -pady 3 -height 20 -width 60 -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) -font $::options(listfont)] \
		-fill both -expand 1 -side right
	.m.p add [wframe .m.s] -minsize 24 -stretch never -hide true
	pack [wbutton .m.s.cbm -text [::msgcat::mc "^ me"] -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) -font $::options(font) -command {copy_my_contact} ] -side right
	pack [wlabel .m.s.sep0 -text " " -width 1 -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) -font $::options(font) ] -side right
	pack [wbutton .m.s.cba -text [::msgcat::mc "+ (p)"] -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) -font $::options(font) -command {add_copied_contact} ] -side right
	pack [wbutton .m.s.cbc -text [::msgcat::mc "^ (p)"] -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) -font $::options(font) -command {copy_contact} ] -side right
	pack [wlabel .m.s.sep1 -text " " -width 1 -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) -font $::options(font) ] -side right
	pack [wbutton .m.s.cbga -text [::msgcat::mc "+ (g)"] -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) -font $::options(font) -command {add_copied_group} ] -side right
	pack [wbutton .m.s.cbgc -text [::msgcat::mc "^ (g)"] -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) -font $::options(font) -command {copy_group} ] -side right
	pack [wlabel .m.s.sep2 -text " " -width 1 -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) -font $::options(font) ] -side right
	pack [wbutton .m.s.imp -text [::msgcat::mc "imp"] -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) -font $::options(font) -command {show_importer} ] -side right
	pack [wbutton .m.s.exp -text [::msgcat::mc "exp"] -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) -font $::options(font) -command {show_exporter} ] -side right
	pack [wlabel .m.s.sep3 -text " " -width 1 -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) -font $::options(font) ] -side right
	pack [wbutton .m.s.opt -text [::msgcat::mc "opt"] -activebackground $::options(hilightcolor) -activeforeground $::options(basecolor) -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor)  -font $::options(font) -command {show_options}] -fill both -side left
	pack [wbutton .m.s.reqs -text [::msgcat::mc "req (p)"] -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) -font $::options(font) -command {show_reqmanager p *} ] -side left
	pack [wbutton .m.s.greqs -text [::msgcat::mc "req (g)"] -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) -font $::options(font) -command {show_mygroups} ] -side left
	pack [wbutton .m.s.dl -text [::msgcat::mc "dl"] -activebackground $::options(hilightcolor) -activeforeground $::options(basecolor) -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor)  -font $::options(font) -command {show_dlstate}] -fill both -side left
	pack [wbutton .m.s.dbg -text [::msgcat::mc "dbg"] -activebackground $::options(hilightcolor) -activeforeground $::options(basecolor) -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor)  -font $::options(font) -command {show_debug}] -fill both -side left
	.m.p add [wframe .m.ee] -minsize 24 -stretch never -hide true
	if { $::options(run_i2p) == 1 } {
	pack [wlabel .m.ee.eedl -text "[::msgcat::mc i2p_dest]: " -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) -font $::options(font) ] -fill both -side left
	pack [wlabel .m.ee.eed -textvar ::cur(i2p,dest) -width 40 -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) -font $::options(font) ] -fill both -side left
	pack [wbutton .m.ee.eep -text [::msgcat::mc "add copied peer"] -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) -font $::options(font) -command {i2p_paste_dest ; sol $::formhost $::formport} ] -side right
	pack [wbutton .m.ee.eec -text [::msgcat::mc "copy my dest"] -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) -font $::options(font) -command {i2p_copy_dest} ] -side right
	}
	.m.p add [wframe .m.i] -minsize 24 -stretch never
	if { $::options(run_i2p) == 1 } {
	pack [wlabel .m.i.eesl -text "i2p: " -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) -font $::options(font) ] -fill both -side left
	pack [wlabel .m.i.ees -textvar ::cur(i2p,state) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) -font $::options(font) ] -fill both -side left
	if { $::options(audio_enabled) == 1 } {
	pack [wlabel .m.i.eem -textvar ::cur(i2p,mstate) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) -font $::options(font) ] -fill both -side left
	}
	} else {
	pack [wlabel .m.i.lm -text "[::msgcat::mc port]: " -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) -font $::options(font) ] -fill both -side left
	pack [wlabel .m.i.lmp -textvar ::options(myport) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) -font $::options(font) ] -fill both -side left
	}
	pack [wlabel .m.i.lmode -text " | [::msgcat::mc mode]: " -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) -font $::options(font) ] -fill both -side left
	pack [wlabel .m.i.lmodel -text "{" -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) -font $::options(font) ] -fill both -side left
	pack [wlabel .m.i.lmodev -textvar ::cur(main,mode) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) -font $::options(font) ] -fill both -side left
	pack [wlabel .m.i.lmoder -text "}" -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) -font $::options(font) ] -fill both -side left
	pack [wbutton .m.i.net -textvariable ::cur(net,l) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) -font $::options(font) -command {net_toggle} ] -side right
	pack [wlabel .m.i.mr -text ">" -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) -font $::options(font) ] -fill both -side right 
	pack [wlabel .m.i.lme -textvar ::me(id) -width 40 -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) -font $::options(font) ] -fill both -side right
	pack [wlabel .m.i.ml -text "<" -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) -font $::options(font) ] -fill both -side right
	pack [wlabel .m.i.lmn -textvar ::me(nickname) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) -font $::options(font) ] -fill both -side right 

	set cmd_s [concat {+ click_window s .m.f.t none %x %y}]
	set cmd_f [concat {+ click_window f .m.f.t none %x %y}]
	set cmd_h [concat {+ click_window h .m.f.t none %x %y}]
	set cmd_a [concat {+ click_window a .m.f.t none %x %y}]
	set cmd_g [concat {+ click_window g .m.f.t none %x %y}]
	set cmd_ge [concat {+ click_window ge .m.f.t none %x %y}]
	set cmd_gr [concat {+ click_window gr .m.f.t none %x %y}]
	set cmd_rec [concat {+ click_window rec .m.f.t none %x %y}]
	set cmd_lrec [concat {+ click_window lrec .m.f.t none %x %y}]
	set cmd_img [concat {+ click_window img .m.f.t none %x %y}]
	set cmd_limg [concat {+ click_window limg .m.f.t none %x %y}]
	set cmd_mysm [concat {+ click_window mysm .m.f.t none %x %y}]
	set cmd_doc [concat {+ click_window doc .m.f.t none %x %y}]

	.m.f.t tag bind searchlink <1> $cmd_s
	.m.f.t tag bind filelink <1> $cmd_f
	.m.f.t tag bind headerlink <1> $cmd_h
	.m.f.t tag bind attachlink <1> $cmd_a
	.m.f.t tag bind gr_scheme <1> $cmd_g
	.m.f.t tag bind gr_scheme <3> $cmd_ge
	.m.f.t tag bind grouplink <1> $cmd_gr
	.m.f.t tag bind inline_voice <1> $cmd_rec
	.m.f.t tag bind voicelink <1> $cmd_lrec
	.m.f.t tag bind inline_image <1> $cmd_img
	.m.f.t tag bind imagelink <1> $cmd_limg
	.m.f.t tag bind doclink <1> $cmd_doc
	.m.f.t tag bind mysm <1> $cmd_mysm

	#bind .m.b.menu <1> {+ tk_popup .nmenu %X %Y}
	bind .m.igc.line <3> {+ tk_popup .nmenu %X %Y}
	bind .m.igc.ml <3> {+ tk_popup .nmenu %X %Y}
	bind .m.igc.line_r <3> {+ tk_popup .nmenu %X %Y}
	bind .m.igc.mr <3> {+ tk_popup .nmenu %X %Y}
	bind .m.igc <3> {+ tk_popup .nmenu %X %Y}
	
	bind .m.x.ls <Key-Return> $read_cmd
	bind .m.x.ls <Double-1> $read_cmd
}

proc mail_header_to_contact {header} {
	set h [header_to_dict $header]
	dict set c peerid [dict get $h from]
	dict set c pubkey [dict get $h kfrom]
	dict set c nickname [dict get $h nickname]
	dict set c birthday {}
	dict set c sex {}
	dict set c country {}
	dict set c city {}
	dict set c epoch [clock seconds] 
	dict set c sig {}
	set contact [dict_to_contact $c]
	return $contact
}

proc show_group_selection {} {
	if { [winfo exists .sgs] == 1} {
		log_puts "ERR" "ERR window exists"
		return
	}
	set choose_cmd {
		set grp [lindex $::jgrouplist(main,k) [lindex [.sgs.f.l index active] 0]]
		if { $grp != "" } {
			set ::cur(main,mode) {g}
			set ::cur(main,group,h) $::jgroups([lindex $::jgrouplist(main,k) [lindex [.sgs.f.l index active] 0]])
			set ::cur(main,group,l) [dict get [ml_groupdict $::cur(main,group,h)] name]
			ml_showlist g [dict get [ml_groupdict $::cur(main,group,h)] gid]
		}
		destroy .sgs
	}
	toplevel .sgs
	wm title .sgs [::msgcat::mc "groupsel_t"]
	pack [panedwindow .sgs.p -ori vert] -fill both -expand 1
	.sgs.p add [wframe .sgs.b]
	pack [wbutton .sgs.b.n -text [::msgcat::mc "create"]  -activebackground $::options(hilightcolor) -activeforeground $::options(basecolor) -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor)  -font $::options(font) -command {show_groupform ; destroy .sgs}] -fill both -side left 
	pack [wbutton .sgs.b.c -text [::msgcat::mc "choose"]  -activebackground $::options(hilightcolor) -activeforeground $::options(basecolor) -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor)  -font $::options(font) -command $choose_cmd ] -fill both -side right
	pack [wbutton .sgs.b.d -text [::msgcat::mc "detail"]  -activebackground $::options(hilightcolor) -activeforeground $::options(basecolor) -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor)  -font $::options(font) -command {catch { show_group_details $::jgroups([lindex $::jgrouplist(main,k) [lindex [.sgs.f.l index active] 0]])}} ] -fill both -side right
	pack [wbutton .sgs.b.a -text [::msgcat::mc "dir"]  -activebackground $::options(hilightcolor) -activeforeground $::options(basecolor) -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor)  -font $::options(font) -command {destroy .sgs ; show_group_directory} ] -fill both -side right
	pack [wbutton .sgs.b.x -text [::msgcat::mc "cancel"]  -activebackground $::options(hilightcolor) -activeforeground $::options(basecolor) -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor)  -font $::options(font) -command {destroy .sgs} ] -fill both -side left
	.sgs.p add [wframe .sgs.f]
	pack [wscrollbar .sgs.f.y -activebackground $::options(hilightcolor)  -troughcolor $::options(hilightcolor)  -command ".sgs.f.l yview"] -fill y -side right
	pack [listbox .sgs.f.l -listvariable ::jgrouplist(main,m) -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) -selectforeground $::options(basecolor) -selectbackground $::options(hilightcolor) -font $::options(listfont) -width 60 -height 12 -yscrollc ".sgs.f.y set"] -fill both -expand 1 -side right
	#update_groups
	set ::jgrouplist(main,k) {}
	set ::jgrouplist(main,m) {}
	foreach {k v} [array get ::jgroups] {
		set b [ml_groupdict $v]
		if { $b == "" } {
			continue	
		}
		set bm "[clock format [dict get $b epoch] -format {%Y-%d-%m %H:%M:%S}] | [string range [dict get $b gid] 0 3] | [dict get $b name]"
		lappend ::jgrouplist(main,k) $k
		lappend ::jgrouplist(main,m) $bm 
	}	
	bind .sgs.f.l <Key-Return> $choose_cmd
}

proc show_contact_selection {} {
	if { [winfo exists .scs] == 1} {
		log_puts "ERR" "ERR window exists"
		return
	}
	set choose_cmd {
		set ::cur(main,person,h) $::buddies([lindex $::buddylist(main,k) [lindex [.sbs.f.l index active] 0]]) ;
		set ::cur(main,person,l) [dict get [contact_to_dict $::cur(main,person,h)] nickname] ;
		if {$::cur(main,person,h) != ""} {
			set ::cur(main,mode) {p}
			ml_showlist p [dict get [contact_to_dict $::cur(main,person,h)] peerid]
		}
		destroy .sbs
	}
	set detail_cmd {
		set hash [lindex $::buddylist(main,k) [lindex [.sbs.f.l index active] 0]] ;
		show_buddy_details $hash
	}
	toplevel .sbs
	wm title .sbs [::msgcat::mc "buddysel_t"] 
	pack [panedwindow .sbs.p -ori vert] -fill both -expand 1
	.sbs.p add [wframe .sbs.b]
	#pack [wbutton .sbs.b.n -text "create" -activebackground $::options(hilightcolor) -activeforeground $::options(basecolor) -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor)  -font $::options(font) -command {show_contactform ; destroy .scs}] -fill both -side left 
	pack [wbutton .sbs.b.c -text [::msgcat::mc "choose"]  -activebackground $::options(hilightcolor) -activeforeground $::options(basecolor) -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor)  -font $::options(font) -command $choose_cmd ] -fill both -side right
	pack [wbutton .sbs.b.d -text [::msgcat::mc "detail"]  -activebackground $::options(hilightcolor) -activeforeground $::options(basecolor) -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor)  -font $::options(font) -command $detail_cmd ] -fill both -side right
	pack [wbutton .sbs.b.a -text [::msgcat::mc "dir"]  -activebackground $::options(hilightcolor) -activeforeground $::options(basecolor) -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor)  -font $::options(font) -command {destroy .sbs ; show_directory} ] -fill both -side right
	pack [wbutton .sbs.b.x -text [::msgcat::mc "cancel"]  -activebackground $::options(hilightcolor) -activeforeground $::options(basecolor) -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor)  -font $::options(font) -command {destroy .sbs} ] -fill both -side left
	.sbs.p add [wframe .sbs.f]
	pack [wscrollbar .sbs.f.y -activebackground $::options(hilightcolor)  -troughcolor $::options(hilightcolor)  -command ".sbs.f.l yview"] -fill y -side right
	pack [listbox .sbs.f.l -listvariable ::buddylist(main,m) -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) -selectforeground $::options(basecolor) -selectbackground $::options(hilightcolor) -font $::options(listfont) -width 60 -height 12 -yscrollc ".sbs.f.y set"] -fill both -expand 1 -side right
	update_buddies
	set ::buddylist(main,k) {}
	set ::buddylist(main,m) {}
	foreach {k v} [array get ::buddies] {
		set b [contact_to_dict $v]
		if { $b == "" } {
			continue	
		}
		set bm "[clock format [dict get $b epoch] -format {%Y-%d-%m %H:%M:%S}] | [string range [dict get $b peerid] 0 3] | [dict get $b nickname]"
		lappend ::buddylist(main,k) $k
		lappend ::buddylist(main,m) $bm 
	}	
	bind .sbs.f.l <Key-Return> $choose_cmd
}

proc show_editor {contact} {
	if { $::cur(main,mode) == "g" && [llength $::cur(main,group,h)] == 0 } {
		show_group_selection
	}
	if { $::cur(main,mode) == "p" && [llength $::cur(main,person,h)] == 0 } {
		show_contact_selection
	}
	if { $::cur(main,mode) == "m" && [llength $contact] == 0} {
		log_puts "ERR" "ERR no contact : got $contact"
		show_contact_selection
	}
	
	if { [winfo exists .e] == 1} {
		log_puts "ERR" "ERR window exists"
		return
	}

	if { $::cur(main,mode) == "m" } {
		set ::card(main) $contact
	} elseif { $::cur(main,mode) == "p" } {
		set ::card(main) $::cur(main,person,h)
	} else {
		set ::card(main) {}
	}

	set last [string last "Re:Re:" $::subject(main) ]
	if { $last > 0 } {
		set ::subject(main) [string range $::subject(main) $last end]
	}

	set toggle_cmd {
	if { [ ".e.p" panecget ".e.h" -hide ] } {
		".e.p" paneconfigure ".e.h" -hide false
		".e.p" paneconfigure ".e.ti" -hide false
	} else {
		".e.p" paneconfigure ".e.h" -hide true
		".e.p" paneconfigure ".e.ti" -hide true
	}
	}

	toplevel .e
	wm title .e [::msgcat::mc "editor_t"] 
	pack [panedwindow .e.p -ori vert] -fill both -expand 1
	.e.p add [wframe .e.b0] -minsize 24 -stretch never
	pack [wlabel .e.b0.ml -text [::msgcat::mc m_from] -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) -font $::options(font) -justify right] -fill both -side left 
	pack [wlabel .e.b0.m -text "$::me(nickname) <$::me(id)>" -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) -font $::options(font) -justify left] -fill both -side left 
	.e.p add [wframe .e.b1] -minsize 24 -stretch never
	pack [wlabel .e.b1.tl -text [::msgcat::mc m_to] -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) -font $::options(font) -justify right] -fill both -side left 
	if { $::cur(main,mode) == "m" && $::card(main) != "" } {
		set ::to(main) [dict get [contact_to_dict $::card(main)] nickname]
		append ::to(main) { <}
		append ::to(main) [dict get [contact_to_dict $::card(main)] peerid]
		append ::to(main) {> }
		pack [wlabel .e.b1.t -text $::to(main) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) -font $::options(font) -width 60 ] -fill both -expand 1 -side left 
	} elseif { $::cur(main,mode) == "p" && $::card(main) != "" } {
		set ::to(main) [dict get [contact_to_dict $::card(main)] nickname]
		append ::to(main) { <}
		append ::to(main) [dict get [contact_to_dict $::card(main)] peerid]
		append ::to(main) {> }
		pack [wlabel .e.b1.t -text $::to(main) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) -font $::options(font) -width 60 ] -fill both -expand 1 -side left
	} elseif { $::cur(main,mode) == "g" } {
		set ::to(main) [dict get [ml_groupdict $::cur(main,group,h)] name]
		append ::to(main) { <}
		append ::to(main) [dict get [ml_groupdict $::cur(main,group,h)] gid]
		append ::to(main) {> }
		pack [wlabel .e.b1.t -text $::to(main) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) -font $::options(font) -width 60 ] -fill both -expand 1 -side left
	} else {
		set ::cur(main,mode) {n}
		pack [wentry .e.b1.t -textvariable ::to(main) -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) -selectforeground $::options(basecolor) -selectbackground $::options(hilightcolor) -font $::options(listfont) -width 60 ] -fill both -expand 1 -side left 
	}
	.e.p add [wframe .e.b2] -minsize 24 -stretch never
	pack [wlabel .e.b2.sl -text [::msgcat::mc m_subject] -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) -font $::options(font) -justify right] -fill both -side left
	pack [wentry .e.b2.s -textvariable ::subject(main) -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) -selectforeground $::options(basecolor) -selectbackground $::options(hilightcolor) -font $::options(listfont) -width 60] -fill both -expand 1 -side left
	if { $::parent(main) != "" } {
		set ph [header_to_dict $::parent(main)]
		if { $ph == {} } {
			break
		} 
		set ps "[dict get $ph subject] <[dict get $ph hash]>"
		.e.p add [wframe .e.b3]
		pack [wlabel .e.b3.sl -text [::msgcat::mc m_parent] -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) -font $::options(font) -justify right] -fill both -side left
		pack [wlabel .e.b3.s -text "$ps" -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) -font $::options(font) -width 60] -fill both -expand 1 -side left 
	}
	.e.p add [wframe .e.x] -stretch always
	pack [wscrollbar .e.x.y -activebackground $::options(hilightcolor)  -troughcolor $::options(hilightcolor)  -command ".e.x.t yview"] -fill y -side right
	pack [text .e.x.t -wrap word -yscrollc ".e.x.y set" \
		-selectforeground {#6090c0} -selectbackground $::options(hilightcolor) \
		-padx 5 -pady 3 -height 12 -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) -font $::options(listfont)] \
		-fill both -expand 1 -side right
	.e.p add [wframe .e.h] -minsize 24 -stretch never -hide true
	pack [wbutton .e.h.i -text [::msgcat::mc "e_filepick"]  -activebackground $::options(hilightcolor) -activeforeground $::options(basecolor) -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor)  -font $::options(font) -command "insert_single_file e none"] -fill both -side left 
	pack [wbutton .e.h.a -text [::msgcat::mc "e_fileindex"]  -activebackground $::options(hilightcolor) -activeforeground $::options(basecolor) -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor)  -font $::options(font) -command "show_fileoffer e none" ] -fill both -side left
	pack [wbutton .e.h.limg -text [::msgcat::mc "image"]  -activebackground $::options(hilightcolor) -activeforeground $::options(basecolor) -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor)  -font $::options(font) -command "insert_linked_image e {}"] -fill both -side right 
	pack [wbutton .e.h.lrec -text [::msgcat::mc "voice"]  -activebackground $::options(hilightcolor) -activeforeground $::options(basecolor) -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor)  -font $::options(font) -command "insert_linked_voice e {}"] -fill both -side right 
	pack [wbutton .e.h.l -text [::msgcat::mc "e_letter"]  -activebackground $::options(hilightcolor) -activeforeground $::options(basecolor) -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor)  -font $::options(font) -command "show_recent e none none" ] -fill both -side left
	pack [wbutton .e.h.grp -text [::msgcat::mc "e_group"]  -activebackground $::options(hilightcolor) -activeforeground $::options(basecolor) -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor)  -font $::options(font) -command "show_insertgroup e none" ] -fill both -side left
	.e.p add [wframe .e.ti] -hide true
	pack [wbutton .e.ti.g -text [::msgcat::mc "e_gr"]  -activebackground $::options(hilightcolor) -activeforeground $::options(basecolor) -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor)  -font $::options(font) -command "show_gredit [clock microseconds] {} .e.x.t" ] -fill both -side right
	pack [wbutton .e.ti.mysm -text [::msgcat::mc "mysm"]  -activebackground $::options(hilightcolor) -activeforeground $::options(basecolor) -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor)  -font $::options(font) -command "show_mysm [clock microseconds] {} .e.x.t" ] -fill both -side right
	#pack [wbutton .e.ti.at -text "inline file" -activebackground $::options(hilightcolor) -activeforeground $::options(basecolor) -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor)  -font $::options(font) -command "attach_file .e.x.t"] -fill both -side right 
	#pack [wbutton .e.ti.img -text "inline image"  -activebackground $::options(hilightcolor) -activeforeground $::options(basecolor) -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor)  -font $::options(font) -command "insert_inline_image e {}"] -fill both -side right 
	#pack [wbutton .e.ti.rec -text "inline voice"  -activebackground $::options(hilightcolor) -activeforeground $::options(basecolor) -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor)  -font $::options(font) -command {}] -fill both -side right 
	.e.p add [wframe .e.t] -minsize 24 -stretch never
	if { $::cur(main,mode) == {p} } {
		pack [wbutton .e.t.v -text [::msgcat::mc "commit"]  -activebackground $::options(hilightcolor) -activeforeground $::options(basecolor) -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor)  -font $::options(font) -command {ml_add_hdrs mlphdr [dict get [contact_to_dict $::cur(main,person,h)] peerid] [form_message] ; destroy .e } ] -fill both -side right
	} elseif { $::cur(main,mode) == {g} } {
		pack [wbutton .e.t.v -text [::msgcat::mc "commit"]  -activebackground $::options(hilightcolor) -activeforeground $::options(basecolor) -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor)  -font $::options(font) -command {ml_add_hdrs mlhdr [dict get [ml_groupdict $::cur(main,group,h)] gid] [form_message] ; destroy .e } ] -fill both -side right
	} elseif { $::cur(main,mode) == {m} || $::cur(main,mode) == {n} } {
		pack [wbutton .e.t.v -text [::msgcat::mc "commit"] -activebackground $::options(hilightcolor) -activeforeground $::options(basecolor) -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor)  -font $::options(font) -command {sc_out [form_message ] ; destroy .e } ] -fill both -side right
	} else {
		pack [wbutton .e.t.v -text [::msgcat::mc "commit"]  -activebackground $::options(hilightcolor) -activeforeground $::options(basecolor) -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor)  -font $::options(font) -command {form_message ; destroy .e } ] -fill both -side right
	}
	pack [wbutton .e.t.h -text [::msgcat::mc "+"]  -activebackground $::options(hilightcolor) -activeforeground $::options(basecolor) -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor)  -font $::options(font) -command $toggle_cmd ] -fill both -side right
	#bind .e.ti.rec <ButtonPress-1> "record_voice_start .e" 
	#bind .e.ti.rec <ButtonRelease-1> "record_voice_end ; insert_inline_voice e {}"
	bind .e.h.lrec <ButtonPress-1> "record_voice_start .e" 
	bind .e.h.lrec <ButtonRelease-1> "record_voice_end ; insert_linked_voice e {}"
	.e.x.t tag configure red -foreground {#c06060} 
	.e.x.t tag configure cyan -foreground {#60c0c0}
	.e.x.t tag configure blue -foreground {#6060c0}
	.e.x.t tag configure yellow -foreground {#c0c060}
	.e.x.t tag configure magenta -foreground {#c060c0}
	.e.x.t tag configure hide -elide true
	.e.x.t tag configure inline_voice -foreground {#c060c0} -underline true
	.e.x.t tag configure inline_image -foreground {#c060c0} -underline true
	.e.x.t tag configure mysm -foreground {#60c060} -underline true
	.e.x.t tag configure filelink -foreground {#6060c0} -underline true
	.e.x.t tag configure imagelink -foreground {#c060c0} -underline true
	.e.x.t tag configure grouplink -foreground {#6060c0} -underline true
	.e.x.t tag configure attachlink -foreground {#c06060} -underline true
	.e.x.t tag configure headerlink -foreground {#6060c0} -underline true
	.e.x.t tag configure searchlink -foreground {#6060c0} -underline true
	if { $::parent(main) != "" && $::cur(main,mode) == {g} } {
		set ph [header_to_dict $::parent(main)]
		if { $ph == {} } {
			break
		} 
		set body [encoding convertfrom utf-8 [ml_get_eml all [dict get $ph hash]]]
		set bodylines [split $body "\n"]
		set from [lindex $bodylines 0]
		set first [string first ":" $from]
		set from [string trim [string range $from $first+1 end]]
		#set to [lindex $bodylines 1]
		#set first [string first ":" $to]
		#set to [string trim [string range $to $first+1 end]]
		.e.x.t insert end "$from wrote:\n" {magenta}
		set lines [lrange $bodylines 5 end]
		foreach line $lines {
			set lfirst [lindex [split [string range $line 0 20] { }] 0]
			if { $lfirst == "HDR" || $lfirst  == "FILE" || $lfirst == "IMG" || $lfirst == "REC" || $lfirst == "ATTACH" || $lfirst == "GRP" } {
				set line "[string tolower [lindex [string range $line 0 250] 0]]://<...>"
			}
			.e.x.t insert end "> [string range $line 0 250]\n" {magenta}
		}
		.e.x.t yview end
	}
}

proc load_id {} {
	set path [file join $::filepath "key"]
	if {[ file exists $path ] == 0} {
		set ::me(key) [crypto_gen 1024]
		set ::me(id) [crypto_cksum [crypto_exp_pub $::me(key)]]
		set ::me(pubkey) [wrap [crypto_exp_pub $::me(key)]]
	} else {
		set fchan [open $path r]
		fconfigure $fchan -translation binary
		set data [read $fchan]
		set ::me(key) [crypto_parse_priv $data]
		set ::me(id) [crypto_cksum [crypto_exp_pub $::me(key)]]
		set ::me(pubkey) [wrap [crypto_exp_pub $::me(key)]]
		close $fchan
	}	

	set path [file join $::filepath "nickname"]
	if {[ file exists $path ] == 0} {
		set r [expr "[clock microseconds]%8"]
		set ns [list "Ethereal Sapphire" "Weird Vulture" "Water Dragon" "Sunshine Emerald" "Stratagus" "Domesticus" "Sacellarius" "Just a guy"]
		set ::me(nickname) [lindex $ns $r]
	} else {
		set fchan [open $path r]
		fconfigure $fchan -translation binary
		gets $fchan ::me(nickname)
		close $fchan
	}
}

proc load_port {} {
	set path [file join $::filepath "port"]
	if {[ file exists $path ] == 0} {
		set ::options(myport) [expr "1234+([clock microseconds])%50000"]
	} else {
		set fchan [open $path r]
		fconfigure $fchan -translation binary
		gets $fchan ::options(myport)
		close $fchan	
	}
}

proc write_id {} {
	set path [file join $::filepath "key"]
	set fchan [open $path w]
	fconfigure $fchan -translation binary
	puts -nonewline $fchan [crypto_exp_priv $::me(key)]
	close $fchan
	set path [file join $::filepath "nickname"]
	set fchan [open $path w]
	fconfigure $fchan -translation binary
	puts -nonewline $fchan $::me(nickname)
	close $fchan
}

proc write_port {} {
	set path [file join $::filepath "port"]
	set fchan [open $path w]
	fconfigure $fchan -translation binary
	puts -nonewline $fchan $::options(myport)
	close $fchan
}

proc load_contact {} {
	set path [file join $::filepath "contact"]
	if {[ file exists $path ] == 0} {
		set ::me(contact) [form_contact]
	} else {
		set fchan [open $path r]
		fconfigure $fchan -translation binary
		gets $fchan ::me(contact)
		close $fchan
	}
}

proc write_contact {} {
	set path [file join $::filepath "contact"]
	set fchan [open $path w]
	fconfigure $fchan -translation binary
	puts -nonewline $fchan $::me(contact)
	close $fchan
}

proc load_peers {} {
	#set path [file join $::filepath "nodes"]
	set path [file join $::filepath "nodes.dat"]
	if {[ file exists $path ] == 0} {
		return
	}
	#set line {}
	#set fchan [open $path r]
	#fconfigure $fchan -translation binary
	#while {[gets $fchan line] >= 0} {
	#	if {$line == "" } {
	#		log_puts "ERR" "ERR peers empty line"
	#		continue
	#	} 
	#	log_puts "ALL" "load_peers line $line"
	#	set pkey [lindex $line 0]
	#	set peer [lindex $line 1]
	#	set host [lindex [split $peer {:}] 1]
	#	set port [lindex [split $peer {:}] 2]
	#	set pub [lindex [split $peer {:}] 3]
	#	set key [lindex [split $peer {:}] 0]
	#	if { $peer == "" || $host == "" || $port == "" || $key == "" || $pub == "" } {
	#		log_puts "ERR" "ERR load empty peer $peer"
	#		continue
	#	}
	#	array set ::peerstore [list $pkey $peer]
	#}
	#close $fchan
	set data [find_bin $path {} {} {} {}]
	foreach {pkey peer} $data {
		if { $pkey == "" || $peer == "" } {
			log_puts "ERR" "ERR peers empty line"
			continue
		} 
		set key [lindex [split $peer {:}] 0]
		set host [lindex [split $peer {:}] 1]
		set port [lindex [split $peer {:}] 2]
		set pub [lindex [split $peer {:}] 3]
		if { $pub == "" || $peer == "" || $host == "" || $port == "" || $key == "" } {
			log_puts "ERR" "ERR load empty peer $peer"
			continue
		}
		array set ::peerstore [list $pkey $peer]
	}
}

proc load_buckets {} {
	set path [file join $::filepath "buckets"]
	if {[ file exists $path ] == 0} {
		return
	}
	set line {}
	set fchan [open $path r]
	fconfigure $fchan -translation binary
	while {[gets $fchan line] >= 0} {
		set pkey [lindex [split $line { }] 0]
		set pval [lindex [split $line { }] 1]
		array set ::b [list $pkey $pval]
	}
	close $fchan
}

proc load_values {} {
	set path [file join $::filepath "values"]
	if {[ file exists $path ] == 0} {
		return
	}
	set line {}
	set fchan [open $path r]
	fconfigure $fchan -translation binary
	while {[gets $fchan line] >= 0} {
		set pkey [lindex [split $line { }] 0]
		set pval [lrange [split $line { }] 1 end]
		if { [expr "[clock microseconds]%7"] != 0 } {
			array set ::valuestore [list $pkey $pval]
		}
	}
	close $fchan
}

proc load_contacts {} {
	set path [file join $::filepath "contacts"]
	if {[ file exists $path ] == 0} {
		return
	}
	set line {}
	set fchan [open $path r]
	fconfigure $fchan -translation binary
	while {[gets $fchan line] >= 0} {
		set pkey [lindex [split $line { }] 0]
		set pval [lrange [split $line { }] 1 end]
		log_puts "ALL" "pkey $pkey pval $pval"
		array set ::contacts [list $pkey $pval]
	}
	close $fchan
}

proc load_headers {} {
	set path [file join $::filepath "headers"]
	if {[ file exists $path ] == 0} {
		return
	}
	set line {}
	set fchan [open $path r]
	fconfigure $fchan -translation binary
	while {[gets $fchan line] >= 0} {
		set pkey [lindex [split $line { }] 0]
		set pval [lindex [split $line { }] 1]
		array set ::headers [list $pkey $pval]
	}
	close $fchan
}

proc load_groups {} {
	set path [file join $::filepath "groups"]
	if {[ file exists $path ] == 0} {
		return
	}
	set line {}
	set fchan [open $path r]
	fconfigure $fchan -translation binary
	while {[gets $fchan line] >= 0} {
		set pkey [lindex [split $line { }] 0]
		set pval [lindex [split $line { }] 1]
		array set ::groups [list $pkey $pval]
	}
	close $fchan
	set path [file join $::filepath "my_groups"]
	if {[ file exists $path ] == 0} {
		return
	}
	set line {}
	set fchan [open $path r]
	fconfigure $fchan -translation binary
	while {[gets $fchan line] >= 0} {
		set pkey [lindex [split $line { }] 0]
		set pval [lindex [split $line { }] 1]
		array set ::my_groups [list $pkey $pval]
	}
	close $fchan
}

proc load_jgroups {} {
	set path [file join $::filepath "jgroups"]
	if {[ file exists $path ] == 0} {
		return
	}
	set line {}
	set fchan [open $path r]
	fconfigure $fchan -translation binary
	while {[gets $fchan line] >= 0} {
		set pkey [lindex [split $line { }] 0]
		set pval [lrange [split $line { }] 1 end]
		array set ::jgroups [list $pkey $pval]
		after 5000 [list ml_add_srcs $pkey $::me(id)]
		array set ::sources [list $pkey $::me(id)]
		after 5000 [list sc_publishgroup $pval]
		ml_add_sigreq g $pkey $::me(contact)
	}
	close $fchan
}

proc load_sources {} {
	set path [file join $::filepath "sources"]
	if {[ file exists $path ] == 0} {
		return
	}
	set line {}
	set fchan [open $path r]
	fconfigure $fchan -translation binary
	while {[gets $fchan line] >= 0} {
		set pkey [lindex [split $line { }] 0]
		set pval [lindex [split $line { }] 1]
		array set ::sources [list $pkey $pval]
	}
	close $fchan
}

proc load_buddies {} {
	set path [file join $::filepath "buddies"]
	if {[ file exists $path ] == 0} {
		return
	}
	set line {}
	set fchan [open $path r]
	fconfigure $fchan -translation binary
	while {[gets $fchan line] >= 0} {
		set pkey [lindex [split $line { }] 0]
		set pval [lindex [split $line { }] 1]
		log_puts "ALL" "load buddy $pkey $pval"
		array set ::buddies [list $pkey $pval]
		array set ::contacts [list $pkey $pval]
	}
	close $fchan
}

proc load_files {} {
	set path [file join $::filepath "file_by_hash"]
	if {[ file exists $path ] == 0} {
		return
	}
	set line {}
	set fchan [open $path r]
	fconfigure $fchan -translation binary
	while {[gets $fchan line] >= 0} {
		set pkey [lindex [split $line { }] 0]
		set pval [lrange [split $line { }] 1 end]
		log_puts "ALL" "load file_by_hash $pkey $pval"
		array set ::file_by_hash [list $pkey $pval]
	}
	close $fchan

	set path [file join $::filepath "hash_by_file"]
	if {[ file exists $path ] == 0} {
		return
	}
	set line {}
	set fchan [open $path r]
	fconfigure $fchan -translation binary
	while {[gets $fchan line] >= 0} {
		set pkey [lindex [split $line { }] 0]
		set pval [lrange [split $line { }] 1 end]
		log_puts "ALL" "load hash_by_file $pkey $pval"
		array set ::hash_by_file [list $pkey $pval]
	}
	close $fchan
}

proc load_dls {} {
	set path [file join $::filepath "dl_by_hash"]
	if {[ file exists $path ] == 0} {
		return
	}
	set line {}
	set fchan [open $path r]
	fconfigure $fchan -translation binary
	while {[gets $fchan line] >= 0} {
		set pkey [lindex [split $line { }] 0]
		set pval [lrange [split $line { }] 1 end]
		log_puts "ALL" "load dl_by_hash $pkey $pval"
		array set ::dl_by_hash [list $pkey $pval]
	}
	close $fchan

	set path [file join $::filepath "dlstate_by_hash"]
	if {[ file exists $path ] == 0} {
		return
	}
	set line {}
	set fchan [open $path r]
	fconfigure $fchan -translation binary
	while {[gets $fchan line] >= 0} {
		set pkey [lindex [split $line { }] 0]
		set pval [lrange [split $line { }] 1 end]
		log_puts "ALL" "load dlstate_by_hash $pkey $pval"
		array set ::dlstate_by_hash [list $pkey $pval]
	}
	close $fchan
}

proc load_keys {} {
	set path [file join $::filepath "keys"]
	if {[ file exists $path ] == 0} {
		return
	}
	set line {}
	set fchan [open $path r]
	fconfigure $fchan -translation binary
	while {[gets $fchan line] >= 0} {
		set pkey [lindex [split $line { }] 0]
		set pval [lrange [split $line { }] 1 end]
		log_puts "ALL" "load keys $pkey $pval"
		array set ::keys [list $pkey $pval]
	}
	close $fchan
}

proc write_peers {} {
	#set path [file join $::filepath "nodes"]
	set path [file join $::filepath "nodes.dat"]
	#set fchan [open $path w]
	#fconfigure $fchan -translation binary
	#foreach {name peer} [array get ::peerstore] {
	#	if { $peer == "" } {
	#		log_puts "ERR" "ERR write empty peer"
	#		continue
	#	}
	#	if {[regexp -all {:} $peer] != 3} {
	#		log_puts "ERR" "ERR malformed peer $peer"	
	#		continue
	#	}
	#	puts $fchan "$name $peer"
	#}
	#close $fchan
	set data {}
	foreach {pkey peer} [array get ::peerstore] {
		if { $pkey == "" || $peer == "" } {
			log_puts "ERR" "ERR peers empty line"
			continue
		} 
		set key [lindex [split $peer {:}] 0]
		set host [lindex [split $peer {:}] 1]
		set port [lindex [split $peer {:}] 2]
		set pub [lindex [split $peer {:}] 3]
		if { $pub == "" || $peer == "" || $host == "" || $port == "" || $key == "" } {
			log_puts "ERR" "ERR load empty peer $peer"
			continue
		}
		lappend data $pkey $peer	
	}
	save_bin $path $data
}

proc write_buckets {} {
	set path [file join $::filepath "buckets"]
	set fchan [open $path w]
	fconfigure $fchan -translation binary
	foreach {key val} [array get ::b] {
		puts $fchan "$key $val"
	}
	close $fchan
}

proc write_values {} {
	set path [file join $::filepath "values"]
	set fchan [open $path w]
	fconfigure $fchan -translation binary
	foreach {key val} [array get ::valuestore] {
		puts $fchan "$key $val"
	}
	close $fchan
}

proc write_contacts {} {
	set path [file join $::filepath "contacts"]
	set fchan [open $path w]
	fconfigure $fchan -translation binary
	foreach {key val} [array get ::contacts] {
		puts $fchan "$key $val"
	}
	close $fchan
}

proc write_headers {} {
	set path [file join $::filepath "headers"]
	set fchan [open $path w]
	fconfigure $fchan -translation binary
	foreach {key val} [array get ::headers] {
		puts $fchan "$key $val"
	}
	close $fchan
}

proc write_groups {} {
	set path [file join $::filepath "groups"]
	set fchan [open $path w]
	fconfigure $fchan -translation binary
	foreach {key val} [array get ::groups] {
		puts $fchan "$key $val"
	}
	close $fchan
	set path [file join $::filepath "my_groups"]
	set fchan [open $path w]
	fconfigure $fchan -translation binary
	foreach {key val} [array get ::my_groups] {
		puts $fchan "$key $val"
	}
	close $fchan
}

proc write_jgroups {} {
	set path [file join $::filepath "jgroups"]
	set fchan [open $path w]
	fconfigure $fchan -translation binary
	foreach {key val} [array get ::jgroups] {
		puts $fchan "$key $val"
	}
	close $fchan
}

proc write_sources {} {
	set path [file join $::filepath "sources"]
	set fchan [open $path w]
	fconfigure $fchan -translation binary
	foreach {key val} [array get ::sources] {
		puts $fchan "$key $val"
	}
	close $fchan
}

proc write_buddies {} {
	set path [file join $::filepath "buddies"]
	set fchan [open $path w]
	fconfigure $fchan -translation binary
	foreach {key val} [array get ::buddies] {
		puts $fchan "$key $val"
	}
	close $fchan
}

proc write_files {} {
	set path [file join $::filepath "file_by_hash"]
	set fchan [open $path w]
	fconfigure $fchan -translation binary
	foreach {key val} [array get ::file_by_hash] {	
		puts $fchan "$key $val"
	}
	close $fchan

	set path [file join $::filepath "hash_by_file"]
	set fchan [open $path w]
	fconfigure $fchan -translation binary
	foreach {key val} [array get ::hash_by_file] {	
		puts $fchan "$key $val"
	}
	close $fchan
}

proc write_dls {} {
	set path [file join $::filepath "dl_by_hash"]
	set fchan [open $path w]
	fconfigure $fchan -translation binary
	foreach {key val} [array get ::dl_by_hash] {	
		if { $val == {} } {
			continue
		}
		puts $fchan "$key $val"
	}
	close $fchan

	set path [file join $::filepath "dlstate_by_hash"]
	set fchan [open $path w]
	fconfigure $fchan -translation binary
	foreach {key val} [array get ::dlstate_by_hash] {	
		if { $val == {} } {
			continue
		}
		puts $fchan "$key $val"
	}
	close $fchan
}

proc write_keys {} {
	set path [file join $::filepath "keys"]
	set fchan [open $path w]
	fconfigure $fchan -translation binary
	foreach {key val} [array get ::keys] {	
		puts $fchan "$key $val"
	}
	close $fchan
}

proc write_sig {} {
	foreach kind [list person_to_sig person_to_sigreq group_to_sig group_to_sigreq] {
		set path [file join $::filepath "$kind"]
		set fchan [open $path w]
		fconfigure $fchan -translation binary
		foreach {key val} [array get "::$kind"] {	
			puts $fchan "$key $val"
		}
		close $fchan
	}
}

proc load_sig {} {
	foreach kind [list person_to_sig person_to_sigreq group_to_sig group_to_sigreq] {
		set path [file join $::filepath "$kind"]
		if { [file exists $path] == 0 } {
			continue
		}
		set fchan [open $path r]
		fconfigure $fchan -translation binary
		while {[gets $fchan line] >= 0} {
			set pkey [lindex [split $line { }] 0]
			set pval [lrange [split $line { }] 1 end]
			log_puts "ALL" "load keys $pkey $pval"
			array set "::$kind" [list $pkey $pval]
		}
		close $fchan
	}
	foreach {key val} [array get ::my_groups] {
		if { [array get ::group_to_sigreq "$key,${::me(id)}"] == "" } {
			set req [lindex [array get ::group_to_sigreq "$key,${::me(id)}"] end]
			ml_add_sigreq g $key $::me(contact) 
			set pkey [crypto_parse_priv [unwrap $val]]
			set sig "$req:[wrap [crypto_sig $req $pkey]]"
			array set ::group_to_sig [list "$key,${::me(id)}" $sig]
		}
	}
}

proc form_message {} {
	
	#set kfrom "[crypto_exp_pub $::me(key)]"
	set kfrom {} 
	set kto {} 
	set hfrom $::me(id)
	set from "[string range $::me(nickname) 0 64] <$::me(id)>"
	set subject "[string range $::subject(main) 0 64]"
	set epoch [clock seconds]

	if { $::card(main) != "" && $::cur(main,mode) == "m" } {
		set c [contact_to_dict $::card(main)]
		set pubkey [crypto_parse_pub [dict get $c pubkey]]
		log_puts "ALL" "forming message to contact $c"
		set group {}
		set hto "[dict get $c peerid]"
		set to "[string range [dict get $c nickname] 0 64] <[dict get $c peerid]>"
		set hsubject "hidden"
		set type "m"
	} elseif { $::cur(main,person,h) != "" && $::cur(main,mode) == "p" } {
		set p [contact_to_dict $::cur(main,person,h)]
		set pubkey [crypto_parse_pub [dict get $p pubkey]]
		log_puts "ALL" "forming message to person $p"
		set group {} 
		set hfrom $::me(id)
		set hto [dict get $p peerid]
		set to "[string range [dict get $p nickname] 0 64] <[dict get $p peerid]>" 
		set hsubject "[string range $::subject(main) 0 64]"
		set type "p"
	} elseif { $::cur(main,group,h) != "" && $::cur(main,mode) == "g" } {
		set g [ml_groupdict $::cur(main,group,h)]
		log_puts "ALL" "forming message to group $g"
		set group [dict get $g gid] 
		set hfrom $::me(id)
		set hto [dict get $g gid]
		set to "[string range [dict get $g name] 0 64] <[dict get $g gid]>" 
		set hsubject "[string range $::subject(main) 0 64]"
		set type "g"
	} elseif { $::cur(main,mode) == "n" } {
		log_puts "ALL" "forming message to news"
		set group {}
		set hto [string range $::to(main) 0 64]
		set to [string range $::to(main) 0 64]
		set hsubject "[string range $::subject(main) 0 64]"
		set type "n"
	} else {
		return
	}
	
	set body [string range [.e.x.t get 1.0 end] 0 65536]

	set whole {}
	append whole "From:\t$from\n"
	append whole "To:\t$to\n"
	append whole "Subject:\t$subject\n"
	append whole "Epoch:\t$epoch\n"
	append whole "\n"
	if { $::parent(main) != "" } {
		append whole "HDR [dict get [header_to_dict $::parent(main)] hash] Parent\n"
	}
	append whole "$body\n\n"

	log_puts "ALL" "Formed message:"
	log_puts "ALL" $whole

	set whole [encoding convertto utf-8 $whole]	

	set pwhole {}
	if { ($::card(main) != "" && $::cur(main,mode) == "m") || ($::cur(main,person,h) != "" && $::cur(main,mode) == "p") } {
		log_puts "ALL" "using pubkey to encrypt:"
		log_puts "ALL" $pubkey
		set pwhole $whole
		set symkey [crypto_symgen]
		log_puts "ALL" "encrypting symkey [wrap $symkey]"
		set symkey_e [crypto_enc -hex -pub $symkey $pubkey]
		set nil_block [string repeat \0 16]
		set whole_e [crypto_symenc $whole $symkey $nil_block] 
		log_puts "ALL" "aes-encrypted message $whole_e"
		set whole [wrap $symkey_e],[wrap $whole_e]
	}

	set len [string length $whole]
	set hash [crypto_cksum $whole]

	set h {}
	dict set h hash $hash 
	dict set h group $group
	dict set h len $len
	dict set h epoch $epoch
	dict set h from $hfrom
	dict set h to $hto 
	dict set h subject $hsubject
	dict set h type $type
	dict set h nickname $::me(nickname)
	dict set h kfrom $kfrom
	dict set h kto $kto 
	dict set h gsig {} 
	set header [dict_to_header $h] 
	log_puts "ALL" "Formed header:"
	log_puts "ALL" $header

	ml_add_eml all $hash $whole
	
	if { ($::card(main) != "" && $::cur(main,mode) == "m") || ($::cur(main,person,h) != "" && $::cur(main,mode) == "p") } {
		ml_add_eml plain $hash $pwhole
	}

	if { $::cur(main,mode) == "g" } {
		set gsrc [ml_get_srcs $hto]
		if { [lindex $gsrc 1] == 0 } {
			break
		}
		set peers [lrange $gsrc 2 end]
		foreach peer $peers {
			set speer [split $peer {:}]
			if { [lindex $speer 0] == $::me(id) } {
				continue
			}
			ml_genc [lindex $speer 0] [lindex $speer 1] [lindex $speer 2] "MAIL 0 DIG [list $hto 1 $header]" 0
		}
		after 500 [list ml_showlist g $hto]
	} elseif { $::cur(main,mode) == "p" } {
		ml_genc $hto {} {} "MAIL 0 PWT [list $::me(id) 1 $header]" 0
		after 500 [list ml_showlist p $hto]
	}

	return $header
}

proc form_contact {} {
	log_puts "ALL" "form_contact"
	# peerid:b64(pubkey):b64(nickname):b64(age):b64(sex(M/F/O/N)):b64(country):b64(city):epoch:b64(sig - sign previous with pubkey):... probable authority pkey&sig
	set c $::me(id)
	append c ":[wrap [crypto_exp_pub $::me(key)]]"
	append c ":[wrap [string range $::me(nickname) 0 64]]"
	append c ":[wrap [string range $::card(birthday) 0 16]]"
	append c ":[wrap [string range $::card(gender) 0 16]]"
	append c ":[wrap [string range $::card(country) 0 16]]"
	append c ":[wrap [string range $::card(city) 0 16]]"
	append c ":[clock seconds]"
	append c ":[wrap [crypto_sig $c $::me(key)]]"
	log_puts "ALL" "contact is $c"
	set ::me(contact) $c
	return $c
}

proc contact_to_dict {contact} {
	#log_puts "ALL" "contact_to_dict"
	if {[regexp -all {:} $contact] != 8} {
		return
	}
	dict set d peerid "[lindex [split $contact {:}] 0]" 
	dict set d pubkey "[unwrap [lindex [split $contact {:}] 1]]"
	if { [dict get $d peerid] != [crypto_cksum [dict get $d pubkey]] } {
		return
	}
	dict set d nickname "[unwrap [lindex [split $contact {:}] 2]]"
	dict set d birthday "[unwrap [lindex [split $contact {:}] 3]]"
	dict set d sex "[unwrap [lindex [split $contact {:}] 4]]"
	dict set d country "[unwrap [lindex [split $contact {:}] 5]]"
	dict set d city "[unwrap [lindex [split $contact {:}] 6]]"
	dict set d epoch "[lindex [split $contact {:}] 7]"
	dict set d sig "[unwrap [lindex [split $contact {:}] 8]]"
	return $d
}

proc dict_to_contact {d} {
	#log_puts "ALL" "dict_to_contact"
	set c {}
	append c [dict get $d peerid]
	append c :
	append c [wrap [dict get $d pubkey]]
	append c :
	append c [wrap [dict get $d nickname]]
	append c :
	append c [wrap [dict get $d birthday]]
	append c :
	append c [wrap [dict get $d sex]]
	append c :
	append c [wrap [dict get $d country]]
	append c :
	append c [wrap [dict get $d city]]
	append c :
	append c [dict get $d epoch]
	append c :
	append c [wrap [dict get $d sig]]
	return $c
}

proc update_mail {force} {
	if { [winfo exists .m] == 0 } {
		return
	}
	#if { ($::search == "") && ($::text == "") } {
	#	return
	#}
	log_puts "ALL" "update mail"
	#if { $::search != $::oldsearch } {
	#	read_headers $::search
	#	set ::oldsearch $::search
	#}
	#if { $::text != $::oldtext } {
	#	read_message [lindex [split $::text {,}] 0]
	#	set ::oldtext $::text
	#}
	if { $::search != "" || $force == "force" } {
		read_headers $::search
		#after 5000 [list update_mail {}]
	}
	if { $::text != "" || $force == "force" } {
		read_message [lindex [split $::text {,}] 0]
	}
}

proc update_directory {} {
	if { [winfo exists .d] == 0 } {
		return
	}
	#if { ($::contactsearch == "") } {
	#	return
	#}
	log_puts "ALL" "update directory"
	#if { $::contactsearch != $::oldcontactsearch } {
	#	read_contacts $::contactsearch
	#	set ::oldcontactsearch $::contactsearch
	#}
	if { ($::contactsearch != "") } {
		read_contacts $::contactsearch
	}
	after 3000 update_directory
}

proc update_group_directory {} {
	if { [winfo exists .gd] == 0 } {
		return
	}
	log_puts "ALL" "update group directory"
	if { ($::groupsearch != "") } {
		read_groups $::groupsearch
	}
	after 3000 update_group_directory
	
}

proc read_message {header} {

	if { $header == "" } {
		log_puts "ERR" "empty header, return"
		return
	}

	set h [header_to_dict $header]
	if { $h == "" } {
		return
	}
	
	set hash [dict get $h hash]

	log_puts "ALL" "Reading message for hash $hash"
	if { $hash == "" } {
		log_puts "ERR" "empty hash, return"
		return
	}

	.m.f.t delete 1.0 end

	set whole [ml_get_eml n $hash]
	if { $whole == {} } {
		return
	}

	set type [dict get $h type]
	set comment {}
	if { ($type == "m" && [dict get $h to] == $::me(id)) || ($type == "p" && [dict get $h to] == $::me(id)) } {
		log_puts "ALL" "message is personal, to me"
		set comment "personal to me"
		set symkey_e [unwrap [lindex [split $whole {,}] 0]]
		log_puts "ALL" "symkey_e is $symkey_e"
		set symkey [crypto_dec -hex -priv $symkey_e $::me(key)]
		log_puts "ALL" "decrypted symkey [wrap -maxlen 0 $symkey]"
		set whole_e [unwrap [lindex [split $whole {,}] 1]]
		log_puts "ALL" "aes-encrypted message $whole_e"
		set nil_block [string repeat \0 16]
		set whole [crypto_symdec $whole_e $symkey $nil_block] 
		log_puts "ALL" "whole is $whole"
		#set fchan [open [file join $::filepath mailnews dec $hash] w]
		#fconfigure $fchan -translation binary
		#puts -nonewline $fchan $whole
		#close $fchan
		ml_add_eml dec $hash $whole
	} elseif { $type == "m" && ([dict get $h kfrom] == [crypto_exp_pub $::me(key)] || [dict get $h kfrom] == {}) } {
		log_puts "ALL" "message is personal, by me"
		set comment "personal by me"
		#log_puts "ALL" "Opening message by [file join $::filepath mailnews plain $hash]"
		#set fchan [open [file join $::filepath mailnews plain $hash] r]
		#fconfigure $fchan -translation binary
		#set whole [read $fchan]
		#close $fchan
		set whole [ml_get_eml plain $hash] 
	} elseif { $type == "m" } {
		log_puts "ALL" "message is personal, not by me or for me"
		return
	} elseif { $type == "n" } {
		log_puts "ALL" "message is news"
		set comment "news article"
	} else {
		log_puts "ALL" "something is off, return, header: $h"
		return
	}

	set lines [split $whole "\n"]
	set from [lrange [lindex $lines 0] 1 end]
	set to [lrange [lindex $lines 1] 1 end]
	set subject [lrange [lindex $lines 2] 1 end]
	set epoch [lindex $lines 3]
	set bodylines [lrange $lines 5 end]
	log_puts "ALL" "Header is:"
	log_puts "ALL" "$header"
	log_puts "ALL" "Message read from filesystem is:"
	log_puts "ALL" "$whole"
	.m.f.t tag configure red -foreground {#c06060} 
	.m.f.t tag configure cyan -foreground {#60c0c0}
	.m.f.t tag configure blue -foreground {#6060c0}
	.m.f.t tag configure yellow -foreground {#c0c060}
	.m.f.t tag configure headerlink -foreground {#6060c0} -underline true
	.m.f.t tag configure grouplink -foreground {#6060c0} -underline true
	.m.f.t tag configure searchlink -foreground {#6060c0} -underline true
	.m.f.t tag configure filelink -foreground {#6060c0} -underline true
	.m.f.t tag configure imagelink -foreground {#c060c0} -underline true
	.m.f.t tag configure attachlink -foreground {#c06060} -underline true
	.m.f.t tag configure doclink -foreground {#c09060} -underline true
	.m.f.t insert end "[::msgcat::mc m_sent]: [clock format [dict get $h epoch] -format {%Y-%m-%d %H:%M:%S}]\n" {red}
	.m.f.t insert end "[::msgcat::mc m_comment]: $comment\n" {red}
	.m.f.t insert end "[::msgcat::mc m_from]: $from\n" {cyan m_from}
	.m.f.t insert end "[::msgcat::mc m_to]: $to\n" {cyan}
	.m.f.t insert end "[::msgcat::mc m_subject]: $subject\n" {searchlink}
	.m.f.t insert end "[::msgcat::mc m_epoch]: [clock format [lindex [split $epoch {: }] end] -format {%Y-%m-%d %H:%M:%S}]\n" {red}
	.m.f.t insert end "\n"

	disp_text .m.f.t $bodylines

	return
}

proc click_window {t w id x y} {
	log_puts "ALL" "click_window t $t w $w id $id x $x y $y"
	set tag {}
	switch $t {
	"s" { set tag "searchlink" }
	"f" { set tag "filelink" }
	"limg" { set tag "imagelink" }
	"gr" { set tag "grouplink" }
	"m_from" { set tag "m_from" }
	"h" { set tag "headerlink" }
	"a" { set tag "attachlink" }
	"g" { set tag "gr_scheme" }
	"ge" { set tag "gr_scheme" }
	"mysm" { set tag "mysm" }
	"img" { set tag "inline_image" }
	"rec" { set tag "inline_voice" }
	"lrec" { set tag "voicelink" }
	"doc" { set tag "doclink" }
	}
	if { $tag == {} } {
		return
	}
	if { [winfo exists $w] } {
		set range [$w tag prevrange $tag [$w index @$x,$y]]
		set data [eval $w get $range]
	} elseif { [winfo exists $w-c] } {
		set data [canvas_click $w-c $x $y $tag]
	} else {
		return
	}
	if { $data == {} } {
		return
	} else {
		log_puts "ALL" "click_window tag $tag data [string range $data 0 24]..."
	}
	if { $t == {s} } {
		if { $::cur(main,mode) == "n" || $::cur(main,mode) == "m" } {
			show_headers [sc_get_headers [prep_header_keys [lrange [split $data {: }] 1 end]]]
		}
		set ::searchfield(main) [lrange [split $data {: }] 1 end]
	} elseif { $t == {f} || $t == {limg} } {
		set mlfile_header [lindex [split $data {<>}] end-1]
		log_puts "ALL" "mlfile_header $mlfile_header"
		set mlh [dl_reqdict $mlfile_header]
		log_puts "ALL" "mlh $mlh"
		set name [dict get $mlh filename]
		log_puts "ALL" "name $name"
		set hash [dict get $mlh filehash]
		show_filedialog $mlfile_header {}
	} elseif { $t == {gr} } {
		set grpshrt [string trim [lindex $data 1]]
		if {[regexp -all {:} $grpshrt] > 0} {
			show_group_details $grpshrt
		}
	} elseif { $t == {m_from} } {
		set peerid [string range [string trim [lindex $data end]] 1 end-1]
		if { $peerid != "" && $peerid != $::me(id) } {
			set person [latest_contact $peerid]
			if {[regexp -all {:} $person] > 0 } {
				chat_offer [chat_add $person]
				show_buddy_details $person
			}
		}
	} elseif { $t == {h} } {
		set hdrshrt [string trim [lindex $data 1]]
		if {[regexp -all {:} $hdrshrt] > 0} {
			set ::cur(main,header) $hdrshrt
		} else {
			if { $::cur(main,mode) == {p} && $::cur(main,person,h) != "" } {
				set hdrs [ml_get_hdrs 31 mlphdr [dict get [contact_to_dict $::cur(main,person,h)] peerid]]
			} elseif { $::cur(main,mode) == {g} && $::cur(main,group,h) != "" } {
				set hdrs [ml_get_hdrs 31 mlhdr [dict get [ml_groupdict $::cur(main,group,h)] gid]]
			}
			set hdrs [lsort -unique [lsearch -all -inline $hdrs "$hdrshrt:*"]]
			foreach hdr $hdrs {
				if {[regexp -all {:} $hdr] > 0} {
					set ::cur(main,header) $hdr
					break
				}
			}
		}
		ml_showmsg .m.f.t $::cur(main,header)
	} elseif { $t == {a} } {
		set attach_desc [string trim [string map {{ATTACH } {}} [lindex [split [string range $data 0 250] {()}] 0]]]
		set start [string first $data "<"]
		set end [string first $data ">"]
		set attach_data [string range $data $start $end]
		save_file $attach_desc $attach_data
	} elseif { $t == {g} } {
		set gr_body [unwrap [lindex $data 1]]
		log_puts "ALL" "GR body $gr_body"
		gr_start [clock microseconds] $gr_body {}
	} elseif { $t == {ge} } {
		set gr_body [unwrap [lindex $data 1]]
		log_puts "ALL" "GR body $gr_body"
		show_gredit [clock microseconds] $gr_body {}
	} elseif { $t == {mysm} } {
		set mysm_text [unwrap [lindex $data 1]]
		log_puts "ALL" "MYSM text $mysm_text"
		show_mysm [clock microseconds] $mysm_text {}
	} elseif { $t == {img} } {
		log_puts "ALL" "just click inline image"
	} elseif { $t == {rec} } {
		set dur [lindex [split [string range $data 0 250] { }] 2]
		set start [string first "<" $data]
		set end [string first ">" $data]
		set idata [string range $data $start+1 $end-1]
		log_puts "ALL" "inline_voice data [string range $idata 0 10]...[string range $idata end-10 end] len [string length $idata]"
		if { $dur > 0 } {
			play_voice_start $w $dur [binary decode base64 $idata]
		}
	} elseif { $t == {lrec} } {
		set hdr [lindex [split $data {<>}] 1]
		dl_add_voice $w $hdr {} 
	} elseif { $t == {doc} } {
		set l [split [lindex [split $data {<>}] 1] "|"]
		if { $l == {} } { return }
		set p [lindex $l 0]
		set id [lindex $l 1]
		set hash [lindex $l 2]
		show_doc $p $id $hash
	}
}

proc save_file {desc data} {
	set fn [tk_getSaveFile -initialfile $desc]
	if { $fn == "" || [file exists $fn] } {
		return
	}
	set f [open $fn w]
	fconfigure $f -translation binary
	puts -nonewline $f [unwrap $data]
	flush $f
	close $f	
}

proc show_insertgroup {mode id} {
	log_puts "ALL" "show_insertgroup $mode $id"
	set w ".ig"
	if {[winfo exists $w] == 1} {
		return
	}
	if { $mode == {g} } {
		set tw ".g_$id.o.t"
	} elseif { $mode == {p} } {
		set tw ".g_$id.o.t"
	} elseif { $mode == {e} } {
		set tw .e.x.t
	} elseif { $mode == {w} } {
		set tw $id
	} else {
		set tw {}
	}
	proc insert_cmd {w tw mode id} {
		set lhash [lindex $::jgrouplist(main,h) [lindex [$w.l.l index active] 0]]
		set ldesc [lindex $::jgrouplist(main,l) [lindex [$w.l.l index active] 0]]
		if { $lhash != {} && $ldesc != {} && ([winfo exists $tw] == 1 || [winfo exists $tw-c])} {
			set notice "GRP $lhash $ldesc"
			if { $mode == {p} } {
				gchat_notice chat $id $notice
			} elseif { $mode == {g} } {
				gchat_notice gchat $id $notice
			} elseif { $mode == {e} || $mode == {w} } {
				$tw insert end "\nGRP " {blue grouplink}
				$tw insert end "$lhash " {hide grouplink}
				$tw insert end "$ldesc\n\n" {blue grouplink}
			}
		}
		destroy $w
	}
	toplevel $w
	wm title $w [::msgcat::mc "igroup_t"] 
	pack [panedwindow $w.p -ori vert] -fill both -expand 1
	$w.p add [wframe $w.l] -stretch always
	pack [listbox $w.l.l -listvariable ::jgrouplist(main,l) -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) -selectforeground $::options(basecolor) -selectbackground $::options(hilightcolor) -font $::options(font) -yscrollc "$w.l.y set" -width 80 -height 20] -fill both -expand 1 -side left
	pack [wscrollbar $w.l.y -activebackground $::options(hilightcolor) -troughcolor $::options(hilightcolor) -command {tl_yview 1 $w.l.l}] -fill y -side right
	$w.p add [wframe $w.b] -stretch never
	if { $tw != {} } {
		pack [wbutton $w.b.s -text [::msgcat::mc "insert"] -activebackground $::options(hilightcolor) -activeforeground $::options(basecolor) -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) -font $::options(font) -command "insert_cmd $w $tw $mode $id"] -fill both -side right
	}
	update_groups
	$w.l.l see end
}

proc show_recent {mode id t} {
	log_puts "ALL" "show_recent $mode $id $t"
	set w ".ir"
	if {[winfo exists $w] == 1} {
		return
	}
	if { $mode == {g} } {
		set tw ".g_$id.o.t"
	} elseif { $mode == {p} } {
		set tw ".g_$id.o.t"
	} elseif { $mode == {e} } {
		set tw .e.x.t
	} elseif { $mode == {w} } {
		set tw $id
	} else {
		set tw {}
	}
	proc insert_cmd {w tw mode id} {
		set lhash [lindex $::recent(main,h) [lindex [$w.l.l index active] 0]]
		set ldesc [lindex $::recent(main,l) [lindex [$w.l.l index active] 0]]
		if { $lhash != {} && $ldesc != {} && ([winfo exists $tw] == 1 || [winfo exists $tw-c] == 1) } {
			set notice "HDR $lhash $ldesc"
			if { $mode == {p} } {
				gchat_notice chat $id $notice
			} elseif { $mode == {g} } {
				gchat_notice gchat $id $notice
			} elseif { $mode == {e} || $mode == {w} } {
				$tw insert end "\n$notice\n\n" {blue headerlink}
			}
		}
		destroy $w
	}
	proc read_cmd {w} {
		set lhdr [lindex $::recent(main,f) [lindex [$w.l.l index active] 0]]
		if { $lhdr == {} } {
			return
		}
		set h [header_to_dict $lhdr]
		if { $h == {} } {
			return
		}
		set type [dict get $h type]
		if { $type == {p} } {
			set from [dict get $h from]
			set to [dict get $h to]
			if { $from == $::me(id) } {
				set person [lindex [array get ::contacts "[shawrap contact:$to]*"] 1]
			} else {
				set person [lindex [array get ::contacts "[shawrap contact:$from]*"] 1]
			}
			if { $person == {} } {
				return
			}
			if { $person != $::cur(main,person,h) } {
				set ::cur(main,person,h) $person
				set ::cur(main,person,l) [dict get [contact_to_dict $::cur(main,person,h)] nickname]
				ml_showlist p [dict get [contact_to_dict $::cur(main,person,h)] peerid]
			}
		} elseif { $type == {g} || $type == {gc} } {
			set group [dict get $h group]
			set group [lindex [array get ::groups "[shawrap group:$group]*"] 1]
			if { $group == {} } {
				return
			}
			if { $group != $::cur(main,group,h) } {
				set ::cur(main,group,h) $group
				set ::cur(main,group,l) [dict get [ml_groupdict $::cur(main,group,h)] name]
				ml_showlist g [dict get [ml_groupdict $::cur(main,group,h)] gid]
			}
		} else {
			return
		}
		.m.p paneconfigure .m.f -hide false
		.m.p paneconfigure .m.x -hide $::options(hide_pane)
		ml_showmsg .m.f.t $lhdr
		destroy $w
	}
	set ::recent(main,f) {}
	set ::recent(main,h) {}
	set ::recent(main,l) {}
	foreach hdr $::recent(main) {
		set h [header_to_dict $hdr]
		if { $h == {} } {
			continue
		}
		set hash [dict get $h hash]
		set type [dict get $h type]
		if { $type != $t && $t != {none} } {
			continue
		}
		set desc "[clock format [dict get $h epoch] -format {%Y-%m-%d %H:%M:%S}] | [string range [dict get $h from] 0 3] | [string range [dict get $h nickname] 0 11] | [string range [dict get $h hash] 0 3] | [string range [dict get $h subject] 0 31] ([dict get $h len])"
		lappend ::recent(main,f) $hdr
		lappend ::recent(main,h) $hash
		lappend ::recent(main,l) $desc
	}

	toplevel $w
	wm title $w [::msgcat::mc "recent_t"] 
	pack [panedwindow $w.p -ori vert] -fill both -expand 1
	$w.p add [wframe $w.l] -stretch always
	pack [listbox $w.l.l -listvariable ::recent(main,l) -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) -selectforeground $::options(basecolor) -selectbackground $::options(hilightcolor) -font $::options(font) -yscrollc "$w.l.y set" -width 80 -height 20] -fill both -expand 1 -side left
	pack [wscrollbar $w.l.y -activebackground $::options(hilightcolor) -troughcolor $::options(hilightcolor) -command {tl_yview 1 $w.l.l}] -fill y -side right
	$w.p add [wframe $w.b] -stretch never
	if { $tw != {} } {
		pack [wbutton $w.b.s -text [::msgcat::mc "insert"] -activebackground $::options(hilightcolor) -activeforeground $::options(basecolor) -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) -font $::options(font) -command "insert_cmd $w $tw $mode $id"] -fill both -side right
	} else {
		pack [wbutton $w.b.r -text [::msgcat::mc "read"] -activebackground $::options(hilightcolor) -activeforeground $::options(basecolor) -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) -font $::options(font) -command "read_cmd $w"] -fill both -side right
	}

	$w.l.l see end
}

proc disp_header {header} {
	log_puts "ALL" "disp_header"
	set h [header_to_dict $header]
	if { $h == "" } {
		return
	}
	if { [dict get $h type] == "m" } {
		set from [dict get $h from]
		if { $from != $::me(id) } {
			set from [lindex [array get ::contacts "[shawrap contact:$from]*"] 1]
		} else {
			set from "me"
		}
		if { $from != "" } {
			set subjtf "$from: personal"
		} else {
			set subjtf "personal"
		}
	} else {
		set to [dict get $h to]
		set subject [dict get $h subject]
		set subjtf "$to: $subject"
	}
	set epoch [dict get $h epoch]
	if { $epoch == "" } {
		set epoch 0
	}
	if { $epoch == "n"} {
		log_puts "ERR" "header $h wtf"
		return "error"
	}
	#return [list [clock format $epoch -format {%Y-%m-%d %H:%M:%S}] "$subjtf" [dict get $h hash]]
	return "[clock format $epoch -format {%Y-%m-%d %H:%M:%S}] | [dict get $h type] | [string range [dict get $h hash] 0 3] | $subjtf"
}

proc header_to_dict {header} {
	#log_puts "ALL" "header_to_dict"
	if {[string index $header end] != "=" && [string index $header end] != ":"} {
		log_puts "ERR" "weird end"
		return
	}
	if {[regexp -all {:} $header] != 11} {
		log_puts "ERR" "weird header"
		return
	}
	dict set d hash [lindex [split $header {:}] 0]
	dict set d group [lindex [split $header {:}] 1]
	dict set d len [lindex [split $header {:}] 2]
	dict set d epoch [lindex [split $header {:}] 3]
	dict set d from "[unwrap [lindex [split $header {:}] 4]]"
	dict set d to "[unwrap [lindex [split $header {:}] 5]]"
	dict set d subject "[unwrap [lindex [split $header {:}] 6]]"
	# old news n, old mail m, personal mail p, group mail g
	# group control gc, document d
	dict set d type "[lindex [split $header {:}] 7]"
	dict set d nickname "[unwrap [lindex [split $header {:}] 8]]"
	dict set d kfrom "[unwrap [lindex [split $header {:}] 9]]"
	dict set d kto "[unwrap [lindex [split $header {:}] 10]]"
	dict set d gsig "[unwrap [lindex [split $header {:}] 11]]"
	return $d
}

proc dict_to_header {d} {
	#log_puts "ALL" "dict_to_header"
	set h {}
	append h [dict get $d hash]
	append h :
	append h [dict get $d group]
	append h :
	append h [dict get $d len]
	append h :
	append h [dict get $d epoch]
	append h :
	append h [wrap [dict get $d from]]
	append h :
	append h [wrap [dict get $d to]]
	append h :
	append h [wrap [dict get $d subject]]
	append h :
	append h [dict get $d type] 
	append h :
	append h [wrap [dict get $d nickname]]
	append h :
	append h [wrap [dict get $d kfrom]]
	append h :
	append h [wrap [dict get $d kto]]
	append h :
	append h [wrap [dict get $d gsig]]
	return $h
}

proc read_headers {waitids} {
	log_puts "ALL" "read headers by waitids $waitids"
	if { $waitids == "" } {
		log_puts "WARN" "empty waitids, return"
		return
	}
	set hkeys {}
	foreach waitid $waitids {
	foreach {key value} [array get ::waitvalue "[lindex [split $waitid {,}] 0]*"] {
		set skey [lindex [split $key {,}] 0]
		if { $value == "DONE" } {
			log_puts "ALL" "type smt DONE $skey"
			lappend hkeys $skey
		}
	}
	}
	set ::msglist(main,l) {}
	#set ::msglist(date) {}
	#set ::msglist(subj) {}
	#set ::msglist(hash) {}
	set ::msglist(main,t) {}
	set ::msglist(main,k) {}
	log_puts "ALL" "filling msglist"
	foreach item $hkeys {
		set values [lsort -unique -stride 2 -index end [array get ::headers "$item*"]]
		if { [llength $values] == 0 } {
			continue	
		}
		array unset ::headers "$item*"
		foreach {vkey vvalue} $values {
			log_puts "ALL" "type hdrs $vkey $vvalue"
			set d [header_to_dict $vvalue]
			if { $d != "" } {
				array set ::headers [list $vkey $vvalue]
				lappend ::msglist(main,t) $vvalue
				lappend ::msglist(main,t) [dict get [header_to_dict $vvalue] epoch]
			}
		}
	}
	set ::msglist(main,t) [lsort -unique -integer -stride 2 -index end -increasing $::msglist(main,t)]
	foreach {msg epoch} $::msglist(main,t) {
		set hdr [disp_header $msg]
		if { $hdr == "" } {
			continue
		}
		lappend ::msglist(main,k) $msg
		lappend ::msglist(main,l) $hdr
		#lappend ::msglist(main,l) "[lindex $hdr 0] | [string range [lindex $hdr 2] 0 3] | [lindex $hdr 1]"
		#lappend ::msglist(date) [lindex $hdr 0]
		#lappend ::msglist(subj) [lindex $hdr 1]
		#lappend ::msglist(hash) [lindex $hdr 2]
	}
	#puts $::msglist
	#puts $::msglist(main,k)
}

proc disp_contact {contact} {
	log_puts "ALL" "disp_contact"
	set c [contact_to_dict $contact]
	if { $c == "" } {
		return
	}
	return "[clock format [dict get $c epoch] -format {%Y-%m-%d %H:%M:%S}] | [string range [crypto_cksum $contact] 0 3] | [dict get $c peerid] -> [dict get $c nickname]"
}

proc read_contacts {waitids} {
	log_puts "ALL" "read contacts by waitids $waitids"
	if { $waitids == "" } {
		log_puts "WARN" "empty waitids, return"
		return
	}
	set hkeys {}
	foreach waitid $waitids {
	foreach {key value} [array get ::waitvalue "$waitid*"] {
		set skey [lindex [split $key {,}] 0]
		if { $value == "DONE" } {
			log_puts "ALL" "type smt DONE $skey"
			lappend hkeys $skey
		}
	}
	}
	log_puts "ALL" "hkeys $hkeys"
	set ::contactlist(main,l) {}
	set ::contactlist(main,k) {}
	foreach item $hkeys {
		set c [lsort -unique -stride 2 -index end [array get ::contacts "$item*"]]
		if { [llength $c] == 0 } {
			continue
		}
		array unset ::contacts "$item*"
		foreach {vkey vvalue} $c {
			log_puts "ALL" "type cnts $vkey $vvalue"
			set cnt [disp_contact $vvalue]
			if { $cnt != "" } {
				#log_puts "ALL" "disp_contact [disp_contact $vvalue]"
				#lappend ::contactlist(main,l) [disp_contact $vvalue]
				array set ::contacts [list $vkey $vvalue]
				lappend ::contactlist(main,k) $vvalue 
				lappend ::contactlist(main,l) $cnt 
			}
		}
	}
}

proc disp_group {group} {
	log_puts "ALL" "disp_group"
	set g [ml_groupdict $group]
	if { $g == "" } {
		return
	}
	#return "[clock format [dict get $g epoch] -format {%Y-%m-%d %H:%M:%S}] | [string range [dict get $g gid] 0 3] | [dict get $g name] - [dict get $g desc]"
	return "[clock format [dict get $g epoch] -format {%Y-%m-%d %H:%M:%S}] | [string range [crypto_cksum $group] 0 3] | [dict get $g gid] -> [dict get $g name]"

}

proc read_groups {waitids} {
	log_puts "ALL" "read groups by waitids $waitids"
	if { $waitids == "" } {
		log_puts "WARN" "empty waitids, return"
		return
	}
	set hkeys {}
	foreach waitid $waitids {
	foreach {key value} [array get ::waitvalue "$waitid*"] {
		set skey [lindex [split $key {,}] 0]
		if { $value == "DONE" } {
			log_puts "ALL" "type smt DONE $skey"
			lappend hkeys $skey
		}
	}
	}
	log_puts "ALL" "hkeys $hkeys"
	set ::grouplist(main,l) {}
	set ::grouplist(main,k) {}
	foreach item $hkeys {
		set g [lsort -unique -stride 2 -index end [array get ::groups "$item*"]]
		if { [llength $g] == 0 } {
			continue
		}
		array unset ::groups "$item*"
		foreach {vkey vvalue} $g {
			log_puts "ALL" "type grps $vkey $vvalue"
			set grp [disp_group $vvalue]
			if { $grp != "" } {
				array set ::groups [list $vkey $vvalue]
				lappend ::grouplist(main,k) $vvalue 
				lappend ::grouplist(main,l) $grp
			}
		}
	}
}

proc show_text {id} {
	if { $id == "" } {
		return
	}
	set ::text $id
}

proc show_headers {ids} {
	if { $ids == "" } {
		return
	}
	set ::search $ids
}

proc show_groups {ids} {
	if { $ids == "" } {
		return
	}
	set ::groupsearch $ids
}

proc show_contacts {ids} {
	if { $ids == "" } {
		return
	}
	set ::contactsearch $ids
}

proc check_waitvalues {} {
	log_puts "ALL" "check_waitvalues"
	#log_puts "ALL" "waitlast [expr {$::last(wait)+500}] > [clock microseconds]"
	if { [expr {$::last(wait)+1000}] > [clock microseconds]} {
		return	
	}
	set ::last(wait) [clock microseconds]
	set h_updated 0
	set c_updated 0
	set g_updated 0
	set s_updated 0
	foreach {key value} [array get ::waitvalue] {
		# if not WAIT, do nothing
		if { $value != "WAIT" } {
			continue
		}
		log_puts "ALL" "waitvalue $key -> $value"
		set hash [lindex [split $key {,}] 0]
		# check if we have received any values by that key
		set found [lsort -unique -stride 2 -index end [array get ::valuestore "$hash*"]]
		set len [llength $found]
		if { $len > 0 } {
			array set ::waitvalue [list $key "DONE"]
		}
		# check if we have in target stores any values by that key
		log_puts "ALL" "mytype"
		set type [lindex [array get ::waitvalue "$key,type"] 1]
		set store {}
		switch $type {
			"headers" {	
				log_puts "ALL" "type $type"
				set store ::headers
				incr h_updated 1
			}
			"sources" {
				log_puts "ALL" "type $type"
				set store ::sources
				incr s_updated 1
			}
			"contacts" {
				log_puts "ALL" "type $type"
				set store ::contacts	
				incr c_updated 1
			}
			"groups" {
				log_puts "ALL" "type $type"
				set store ::groups
				incr g_updated 1
			}
			default {
				log_puts "ALL" "unknown type"
			}
		}
		set lfound {}
		if { $store != "" } {
			set lfound [lsort -unique -stride 2 -index end [array get $store "$hash*"]]
			log_puts "ALL" "type $store lfound $lfound"
			set llen [llength $lfound]
			if { $llen > 0 } {
				log_puts "WARN" "found locally"
				array set ::waitvalue [list $key "DONE"]
			}
		} else {
			array set ::waitvalue [list $key "DONE"]
			continue
		}
		# check if we need to do additional actions if these are headers or sources
		log_puts "ALL" "values len is $len and type is $type"
		set afound [list {*}$found {*}$lfound]
		log_puts "ALL" "set store $store to $afound"
		if { $len > 0 && $type != "" } {
			foreach {skey svalue} $afound {
				if {[string length $svalue] == 0} {
					continue
				}
				log_puts "ALL" "add $type $skey -> [string map {{{ {} }} {}} $svalue]"
				set c 0
				foreach item [string map {"{" "" "}" ""} $svalue] {
					log_puts "ALL" "add item $item"
					if { [string length "$item"] == 0 } {
						continue
					}
					if { [regexp -all {:} $item] != 0 && $type == "sources" } {	
						continue
					}
					if { $type == "groups" && [ml_groupdict $item] == "" } {
						continue
					}
					if { $type == "contacts" && [contact_to_dict $item] == "" } {
						continue
					}
					if { $type == "headers" && [header_to_dict $item] == "" } {
						continue
					}
					log_puts "ALL" "set store $store $skey->$item"
					array set $store [list $skey "$item"]
					array set $store [list $skey,[expr {$c%8}],[expr "[clock microseconds]%8"] "$item"]
					incr c 1
				}
			}
		}
	}
	if { $h_updated > 0 } {
		update_mail {} 
	} 
	if { $c_updated > 0 } {
		update_directory
	}
	if { $g_updated > 0 } {
		update_group_directory
	}
}

proc sol_store {} {
	log_puts "ALL" "sol_store"
	foreach store [list ::headers ::contacts ::peerstore] {
	foreach {rkey value} [array get $store] {
		set key [lindex [split $rkey {,}] 0]
		if { $value == "" } {
			array unset $store "$key*"
			continue
		}
		# find 1 peers closest
		set peers [closest_in_buckets $key 1]
		#log_puts "ALL" "sol_store to peers $peers"
		# send store to each
		foreach item $peers {
			set speer [split $item {:}]
			set delay [expr "[clock microseconds]%180000"]
			#log_puts "ALL" "sol delay $delay"
			after $delay [list str_start [str_create STORE [lindex $speer 1] [lindex $speer 2] $key $value]]
		}
	}
	}
}

proc sc_setsources {} {
	log_puts "ALL" "sc_setsources"
	foreach {key val} [array get ::headers] {
		#log_puts "ALL" "set sources for $val"
		set hd [header_to_dict $val]
		if { $hd == "" } {
			continue
		}
		set hash [dict get $hd hash]
		set eml [ml_get_eml all $hash]
		if { [array names ::file_by_hash $hash] != "" || $eml != "" } {
			array set ::sources [list $hash $::me(id)]
		} else {
			array unset ::sources "$hash*"
		}
	}
	foreach {key val} [array get ::file_by_hash] {
		#log_puts "ALL" "set sources for $val"
		set d [dl_reqdict $val]
		if { $d == "" } {
			continue
		}
		set hash [dict get $d filehash]
		array set ::sources [list $hash $::me(id)]
	}
	foreach {key val} [array get ::jgroups] {
		set g [ml_groupdict $val]
		if { $g == "" } {
			continue
		}
		set gid [dict get $g gid]
		set src {}
		foreach {id peer} [array get ::sources $gid] {
			lappend src $gid
			lappend src $peer
		}
		lappend src $gid
		lappend src $::me(id)
		set src [lsort -unique -stride 2 -index end $src]
		array set ::sources $src 
	}
}

proc sc_out {header} {
	# 
	log_puts "ALL" "sc_out header $header"
	set hd [header_to_dict $header]
	log_puts "ALL" "header for keywords : $hd"
	# create array of keywords
	#set k "[split $header {:}]"
	#foreach item $k {
	#	set h [crypto_cksum "header:$item"]
	#	lappend s $h 
	#	log_puts "ALL" "keyword $item to $h"
	#}
	lappend s [crypto_cksum "header:[dict get $hd hash]"]
	if { [dict get $hd type] == "m" } {
		lappend s [crypto_cksum "header:[dict get $hd kfrom]"]
		lappend s [crypto_cksum "header:[dict get $hd kto]"]
		lappend s [crypto_cksum "header:[dict get $hd from]"]
		lappend s [crypto_cksum "header:[dict get $hd to]"]
	} else {
		set to [split [dict get $hd to] { }]
		foreach item $to {
			set h [crypto_cksum "header:$item"]
			lappend s $h 
			log_puts "ALL" "keyword header:$item to $h"
		}
		set from [split [dict get $hd from] { }]
		foreach item $from {
			set h [crypto_cksum "header:$item"]
			lappend s $h 
			log_puts "ALL" "keyword header:$item to $h"
		}
		set subject [split "[dict get $hd subject]" { }]
		foreach item $subject {
			set h [crypto_cksum "header:$item"]
			lappend s $h 
			log_puts "ALL" "keyword header:$item to $h"
		}
	}
	foreach key $s {
		# find 4 peers closest
		set peers [closest_in_buckets $key 4]
		log_puts "ALL" "sc_out peers $peers"
		# send store to each
		foreach item $peers {
			set speer [split $item {:}]
			str_start [str_create STORE [lindex $speer 1] [lindex $speer 2] $key $header]
		}
		# don't forget to add to our own valuestore
		array set ::headers [list "$key" $header]
		array set ::headers [list $key,[expr "[clock microseconds]%64"] $header]
	}
	sc_setsources
}
proc shawrap {s} {
	return [crypto_cksum [encoding convertto utf-8 $s]]
}

proc sc_publishgroup {group} {
	if { $group == {} } {
		return
	}
	log_puts "ALL" "sc_publishgroup group $group"
	set g [ml_groupdict $group]
	if { $g == {} } {
		return
	}
	lappend s [shawrap "group:[dict get $g gid]"]
	# name - why the hell not
	lappend s [shawrap "group:[dict get $g name]"]
	lappend s [shawrap "group:[dict get $g desc]"]
	foreach w [split [dict get $g name] { }] {
		lappend s [shawrap "group:$w"]
	}
	# pkey 
	lappend s [shawrap "group:[dict get $g pkey]"]
	foreach key $s {
		# find 4 peers closest
		set peers [closest_in_buckets $key 4]
		log_puts "ALL" "sc_publishgroup peers $peers"
		# send store to each
		foreach item $peers {
			set speer [split $item {:}]
			str_start [str_create STORE [lindex $speer 1] [lindex $speer 2] $key $group]
		}
		# don't forget to add to our own valuestore
		array set ::groups [list "$key" $group]
		array set ::groups [list $key,[expr "[clock microseconds]%16"] $group]
	}
	array set ::sources [list "[dict get $g gid]" $::me(id)]
	array set ::sources [list [dict get $g gid],[expr "[clock microseconds]%64"] $::me(id)]
}

proc sc_publishcontact {contact} {
	if { $contact == {} } {
		return
	}
	log_puts "ALL" "sc_publishcontact contact $contact"
	set c [contact_to_dict $contact]
	if { $c == {} } {
		return
	}
	# peerid:b64(pubkey):b64(nickname):age:sex(M/F/O/N):b64(country):b64(city):epoch:b64(sig - sign previous with pubkey):... probable authority pkey&sig
	# peerid - probably needed
	lappend s [shawrap "contact:[dict get $c peerid]"]
	# nickname - why the hell not
	lappend s [shawrap "contact:[dict get $c nickname]"]
	foreach w [split [dict get $c nickname] { }] {
		lappend s [shawrap "contact:$w"]
	}
	# country
	lappend s [shawrap "contact:[dict get $c country]"]
	# city 
	lappend s [shawrap "contact:[dict get $c city]"]
	foreach key $s {
		# find 4 peers closest
		set peers [closest_in_buckets $key 4]
		log_puts "ALL" "sc_publishcontact peers $peers"
		# send store to each
		foreach item $peers {
			set speer [split $item {:}]
			str_start [str_create STORE [lindex $speer 1] [lindex $speer 2] $key $contact]
		}
		# don't forget to add to our own valuestore
		array set ::contacts [list "$key" $contact]
		array set ::contacts [list $key,[expr "[clock microseconds]%16"] $contact]
	}
}

proc enc_key {key hash} {
	log_puts "ALL" "enc_key key $key hash $hash"
	set pubkey {}
	catch { set pubkey [crypto_parse_pub $key] } res
	if { $pubkey == {} } {
		log_puts "ERR" "enc_key ruined pubkey $res\n"
		return
	}
	set symkey {}
	catch { set symkey [crypto_symgen] } res
	if { $symkey == {} } {
		log_puts "ERR" "enc_key bad random $res\n"
		return
	}
	array set ::keys [list "mysymkey_$hash" $symkey]
	catch { set symkey_e [crypto_enc -hex -pub $symkey $pubkey] } res
	log_puts "ALL" "enc_key encrypted key [binary encode hex $res]"
	set sig {}
	catch { set sig [crypto_sig $symkey_e $::me(key)] } res
	set mpubkey {}
	catch { set mpubkey [crypto_exp_pub $::me(key)] } res
	if { $symkey_e == {} || $sig == {} || $mpubkey == {} } {
		log_puts "ERR" "enc_key bad result, return"
		return
	}
	set ret [list 1 $hash [wrap $symkey_e] [wrap $sig] [wrap $pubkey]]
	return $ret
}

proc enc_data {msg hash} {
	log_puts "ALL" "enc_data msg [string range $msg 0 80] hash $hash"
	set symkey [lindex [array get ::keys "mysymkey_$hash"] 1]
	set nil_block [string repeat \0 16]
	set msg_e [crypto_symenc $msg $symkey $nil_block]
	set ret [list 0 $hash [wrap $msg_e] {} {}]
	return $ret
}

proc enc_msg {key msg init hash} {
	log_puts "ALL" "enc_msg start"
	if { $key == {} || $msg == {} || $init == {} || $hash == {} } {
		log_puts "ERR" "enc_msg empty inputs"
		return
	}
	set start [clock microseconds]
	if { [llength [array names ::keys "mysymkey_$hash"]] == 0 } {
		set init 1
	}
	log_puts "ALL" "start enc_msg $init $start"
	set ret {}
	if { $init == 1 } {
		lappend ret {*}[enc_key $key $hash]
		lappend ret {*}[enc_data $msg $hash]
	} elseif { $init == 0 } {
		lappend ret {*}[enc_data $msg $hash]
	}
	log_puts "ALL" "enc_msg end"
	return [join $ret {,}]
}

proc dec_key {s} {
	log_puts "ALL" "dec_key s $s"
	set hash [lindex $s 1]
	set symkey_e [unwrap [lindex $s 2]]
	set sig [unwrap [lindex $s 3]]
	set pubkey [unwrap [lindex $s 4]]
	set ver [crypto_ver $sig $symkey_e [crypto_parse_pub $pubkey]]
	if { $ver == "false" } {
		log_puts "ERR" "dec_key sigerr"
		return
	}
	set symkey [crypto_dec -hex -priv $symkey_e $::me(key)]	
	array set ::keys [list "symkey_$hash" $symkey]
	return
}

proc dec_data {s} {
	log_puts "ALL" "dec_data s $s"
	set hash [lindex $s 1]
	set msg_e [unwrap [lindex $s 2]]
	set symkey [lindex [array get ::keys "symkey_$hash"] 1]
	if { $symkey == {} } {
		log_puts "ERR" "dec_data no symmetric key stored"
		return
	}
	set nil_block [string repeat \0 16]
	log_puts "ALL" "dec_data msg_e [binary encode hex $msg_e] symkey [binary encode hex $symkey]"
	set msg [crypto_symdec $msg_e $symkey $nil_block]
	return $msg
}

proc dec_msg {emsg} {
	log_puts "ALL" "dec_msg start"
	set ret {}
	set se [split $emsg {,}]
	foreach {init hash e sig pub} $se {
		if { $init == 1 } {
			dec_key [list $init $hash $e $sig $pub]
		}
		if { $init == 0 } {
			set ret [dec_data [list $init $hash $e]]
		}
	}
	log_puts "ALL" "dec_msg end"
	return $ret
}

proc chat_add {contact} {
	#set hash [crypto_cksum [dist [crypto_cksum $contact] [crypto_cksum $::me(contact)]]]
	set hash [crypto_cksum [lsort [list [dict get [contact_to_dict $contact] peerid] $::me(id)]]]
	array set ::buddies [list $hash $contact]
	# add sigreq and signature automatically
	ml_add_sigreq p $hash $contact
	#set sig "$hash:[wrap [crypto_sig [dict get [contact_to_dict $contact] peerid] $::me(key)]]"
	#array set ::person_to_sig [list $hash $sig]
	#
	return $hash
}

proc gchat_notice {p id notice} {
	set ret [gchat_send $p $id {} {} "NOTICE" $notice]
	gchat_append $p $id [lindex $ret end] 1
	gchat_history $p $id [lindex $ret end]
	return $ret
}

proc gchat_toggle {p gid} {
	set w ".g_$gid"
	if { [ "$w.p" panecget "$w.r" -hide ] } {
		"$w.p" paneconfigure "$w.r" -hide false
	} else {
		"$w.p" paneconfigure "$w.r" -hide true
	}
}


proc gchat_sendbutton {p id} {
	#set msg [".g_$id.i.t" get 1.0 end]
	set body [string trim $::entry($p,$id)]
	if { $body == {} } {
		return
	}
	if { $p == "gchat" } {
		set check [rule_check_gchat $id $::me(id)]
		if { $check != "allow" } {
			gchat_append_refuse $p $id
			return
		}
	}
	set ret [gchat_text $p $id $body]
	#".g_$id.i.t" delete 1.0 end
	#".g_$id.i.t" mark set insert 1.0
	set ::entry($p,$id) {}
}

proc gchat_text {p id msg} {
	set ret [gchat_send $p $id {} {} "TEXT" $msg]
	gchat_append $p $id [lindex $ret end] 1
	gchat_history $p $id [lindex $ret end]
	return $ret
}

proc chat_offer {hash} {
	gchat_send chat $hash {} {} "OFFER" $::me(contact)
	set contacts [lsearch -all -inline [array get ::contacts] "*$hash*"]
	foreach contact $contacts {
		ml_add_sigreq p {} $contact
	}
}

#proc im_sendkey {contact} {
#	set hash [chat_add $contact]
#	set b [contact_to_dict $contact]
#	set pubkey [crypto_parse_pub [dict get $b pubkey]]
#	log_puts "ALL" "im_sendkey pubkey $pubkey\n"
#	set symkey [crypto_symgen]
#	set symkey_e [crypto_enc -hex -pub $symkey $pubkey]
#	set sig [crypto_sig $symkey_e $::me(key)]
#	array set ::keys "$hash,out" $symkey
#	return [wrap "K $symkey_e $sig"]
#}
#
#proc im_recvkey {hash msg} {
#	if { [llength [array names ::buddies $hash]] == 0 } {
#		array unset ::chatqueue "chat,$hash*"
#		return
#	}
#	set msg [unwrap $msg]
#	set b [contact_to_dict [array get ::buddies $hash]]
#	set pubkey [crypto_parse_pub [dict get $b pubkey]]
#	set symkey_e [lindex $msg 0]	
#	set sig [lindex $msg 1]	
#	set symkey [crypto_dec -hex -priv $symkey_e $::me(key)]
#	set ver [crypto_ver $sig $symkey_e $pubkey]
#	if { $ver == "false" } {
#		return "sigerr"
#	}
#	array set ::keys "$hash,in" $symkey
#}
#
#proc im_sendmsg {hash msg} {
#	# if no key saved, put error
#	set symkey [lindex [array get ::keys $hash,out] 1]
#	if { [string length $symkey] == 0 } {
#		return "no key"
#	} 
#	set nil_block [string repeat \0 16]
#	set msg_e [crypto_symenc $msg $symkey $nil_block]
#	return "M $msg_e"
#}
#
#proc im_recvmsg {hash msg_e} {
#	# if no key saved, put error
#	set symkey [lindex [array get ::keys $hash,in] 1]
#	if { [string length $symkey] == 0 } {
#		return "no key"
#	} 
#	set nil_block [string repeat \0 16]
#	set msg [crypto_symdec $msg_e $symkey $nil_block]
#	return $msg	
#}

proc gchat_send {p id from mid type body} {
	if { $type != "OK" && $type != "NO" } {
		set mid [crypto_cksum [clock microseconds]]
	}

	set msg [gchat_pack $id $mid $type $body]
	set targets {}
	set term {}

	switch $p {
	"gchat" {
		if { [llength [array names ::jgroups $id]] == 0 } {
			log_puts "ERR" "gchat no such $id in ::jgroups"
			array unset ::gchatqueue "$p,$id*"
			return
		}

		if { $::options(group_host_mode) != 1 || $gpeerid == $::me(id) } {
			lappend targets {*}[lrange [ml_get_srcs $id] 2 end]
		} else {
			lappend targets {*}[dict get [ml_groupdict $::jgroups($id)] peerid]
		}
		set term "GCHAT"
	}
	"chat" {
		if { [llength [array names ::buddies $id]] == 0 } {
			log_puts "ERR" "gchat no such $id in ::buddies"
			array unset ::gchatqueue "$p,$id*"
			return
		}
		set b [contact_to_dict [lindex [array get ::buddies $id] 1]]
		set peerid [dict get $b peerid]
		lappend targets $peerid
		set term "CHAT"
	}
	default {
		return
	}
	}

	log_puts "ALL" "gchat send to $id $from $mid [clock seconds] $type"
	if { $type != "OK" && $type != "NO" && $type != "RENEW" } {
		array set ::gchatqueue [list "$p,$id,$mid,msg" $msg]
		array set ::gchatqueue [list "$p,$id,$mid,targets" $targets]
		array set ::gchatqueue [list "$p,$id,$mid,last" 0]
		array set ::gchatqueue [list "$p,$id,$mid,count" 2]
		after 100 check_gchatqueue
		return [list $mid $msg]
	} elseif { $from != {} && $type == "RENEW" } {
		ml_genc $from {} {} "$term 0 $msg" 2
	} elseif { $from != {} } {
		ml_genc $from {} {} "$term 0 $msg" 0
	} else {
		log_puts "ERR" "gchat_send p=$p id=$id from=$from mid=$mid type=$type"
	}
	return
}

proc gchat_pack {id mid type body} {
	set msgl [list $id $mid [clock seconds] $type [wrap $body] [wrap $::me(nickname)] $::me(id)]
	set msgs [crypto_sig $msgl $::me(key)]
	lappend msgl $msgs
	set msg [wrap [list2bin $msgl]]
	return $msg
}

proc gchat_unpack {msg} {
	set s [bin2list [unwrap $msg]]
	
	log_puts "ALL" "gchat_unpack s $s"

	set id [lindex $s 0]
	set mid [lindex $s 1]
	set epoch [lindex $s 2]
	set type [lindex $s 3]
	set body [unwrap [lindex $s 4]]
	set nickname [unwrap [lindex $s 5]]
	set from [lindex $s 6]
	set sig [lindex $s 7]

	set contact {}
	catch { set contact [latest_contact $from] } r
	if { $contact == {} } {
		log_puts "ERR" "gchat_unpack can't find contact $from: $r"
		return
	}
	set c {}
	catch { set c [contact_to_dict $contact] } r
	if { $c == {} } {
		log_puts "ERR" "gchat_unpack bad contact : $r"
		return
	}
	set pubkey {}
	catch { set pubkey [crypto_parse_pub [dict get $c pubkey]] } r
	if { $pubkey == {} } {
		log_puts "ERR" "gchat_unpack no pubkey in contact : $r"
		return
	}
	set ver {}
	catch { set ver [crypto_ver $sig [lrange $s 0 end-1] $pubkey] } r
	if { $ver == "false" } {
		log_puts "ERR" "gchat_unpack bad signature : $r"
		return
	}
	return [list $id $mid $epoch $type $body $nickname $from $sig] 
}

proc gchat_recv {p host port msg} {
	log_puts "ALL" "gchat_recv $msg"
	set s [gchat_unpack $msg]
	if { $s == {} } {
		log_puts "ERR" "gchat_recv failed to unpack"
		return
	}
	set id [lindex $s 0]
	set mid [lindex $s 1]
	set epoch [lindex $s 2]
	set type [lindex $s 3]
	set body [lindex $s 4]
	set nickname [lindex $s 5]
	set from [lindex $s 6]
	set sig [lindex $s 7]

	log_puts "ALL" "gchat_recv p $p id $id mid $mid epoch $epoch type $type"
	if { [string length $body] > [expr "1024*1024*32"] } {
		log_puts "ERR" "message bigger than 32 megabyte, ignored"
		return
	}
	log_puts "ALL" "gchat_recv p $p id $id mid $mid epoch $epoch type $type body $body"
	if { $p == "gchat" } {
		set sc [ml_screen g $id $host $port]
		if { $sc != 0 } {
			log_puts "ERR" "screened out $host $port"
			return
		}

		if { [llength [array names ::jgroups $id]] == 0 } {
			gchat_send $p $id $from $mid "NOCONTACT" {}
			log_puts "ERR" "message to strange group"
			return
		} 

		set rc [rule_check_gchat $id $from]
		if { $rc == "deny" && $type != "NO" } {
			gchat_send $p $id $from $mid "NO" {}
			log_puts "ERR" "message filtered by control rule result"
			return
		}
		log_puts "ALL" "message filtering by control rule result $rc"
	} elseif { $p == "chat" } {
		set sc [ml_screen p [lindex [split [lindex [array get ::buddies $id] end] {:}] 0] $host $port]
		if { $sc != 0 } {
			log_puts "ERR" "screened out $host $port, $id not in buddies"
			return
		}
		if { [llength [array names ::buddies $id]] == 0 } {
			log_puts "ERR" "no buddy $id"
			gchat_send $p $id $from $mid "NOCONTACT" {}
			return
		} 
	} else {
		log_puts "ERR" "gchat_recv p=$p"
	}

	set gc [lindex [array get ::gchatcache "$p,$id,$mid"] end]
	if { $gc != {} } {
		log_puts "ERR" "duplicate message $p,$id,$mid"
		return
	}
	array set ::gchatcache [list "$p,$id,$mid" "$epoch"]
	after 600000 [list array unset ::gchatcache "$p,$id,$mid"]
	#
	if { $p == "gchat" && $::options(group_host_mode) == 1 && ( $type == "TEXT" || $type == "SYNC" || $type == "NOTICE" )} {
		set gpeerid [dict get [ml_groupdict $::jgroups($id)] peerid]
		if { $gpeerid == $::me(id)  } {	
		foreach peerid [lrange [ml_get_src $id] 2 end] {
			log_puts "ALL" "hostmode resend to peerid $peerid len [string length $peerid]"
			if { [string length $peerid] > 0 && $peerid != $::me(id) && $from != $peerid } {
				ml_genc $peerid {} {} "GCHAT 0 $msg" 0
			}
		}
		}
	}
	# here we should lookup peerid by host and port, check if it's in group_to_sig (replaced with
	# control rules),
	# put message to some persistent queue if not, so to not show it before need
	switch $type {
		"NOCONTACT" {
			# dunno what, the user is not in that group
		}
		"TEXT" {
			gchat_append $p $id $msg 1
			gchat_history $p $id $msg
			gchat_send $p $id $from $mid "OK" {}
			if { [winfo exists ".g_$id"] == 0 } {
				array set ::gnotices [list "$p,$id,$from,$mid" $type]
			}
		}
		"NOTICE" {
			set kind [lindex $body 0]
			switch $kind {
			"STATUS" {
				set stype [lindex [split [lindex [split $body { }] 1] {/}] 0] 
				set scomment [lindex [split [lindex [split $body { }] 1] {/}] 1] 
				set_peer_status $from $stype $scomment 0
			}
			"GR" {
				set key "$id,[lindex $body 1],[clock microseconds]-$mid"
				set m {}
				dict set m body [unwrap [lindex $body 2]]
				dict set m nick $nickname
				dict set m id $from
				dict set m epoch [clock seconds]
				set ::gr_queue($key) $m
				log_puts "ALL" "::gr_queue = [array get ::gr_queue]"
				after 10000 [list array unset ::gr_queue $key]
				foreach {task v} [array get ::gr_running] {
					log_puts "ALL" "::gr_running = $task $v"
					if { $v == 1 && [winfo exists .gr_view_$task] == 1} {
						catch { after idle [list gr_action $task notice] }
					}
				}
			}
			"GRS" {
				set name [lindex $body 1] 
				set filter [lindex $body 2]
				gchat_send $p $id $from $mid "OK" "NOTICE GRS $name [findobj $id $name $filter]"
			}
			}
			gchat_append $p $id $msg 1
			gchat_history $p $id $msg
			gchat_send $p $id $from $mid "OK" {}
		}
		"SYNC" {
			if { $::options(gchat_sync_allowed) == 1 } {
				log_puts "ALL" "gchat_recv SYNC $id"

				set rmids $body
				log_puts "ALL" "gchat_recv SYNC rmids $rmids"

				set lmids {}
				catch { set lmids [gchat_history_ids $p $id $::options(gchat_sync_days) {}] } res
				log_puts "ALL" "gchat_recv SYNC lmids $lmids"
				
				array set tmp {}
				foreach lmid $lmids {
					array set tmp $lmid 1
				}
				foreach rmid $rmids {
					array unset tmp $rmid
				}

				set mids [array names tmp]
				set arc {}
				catch { set arc [gchat_history_get $p $id $::options(gchat_sync_days) 200 $mids] } res
				log_puts "ALL" "gchat_recv SYNC arc $arc : $res"

				gchat_send $p $id $from $mid "OK" {}
				gchat_send $p $id $from {} "ARC" $arc
			}
		}
		"ARC" {
			if { $::options(gchat_sync_allowed) == 1 } {
				set lmids {}
				catch { set lmids [gchat_history_ids $p $id $::options(gchat_sync_days) {}] } res
				log_puts "ALL" "gchat_recv ARC lmids $lmids"

				array set tmp {}

				foreach lmid $lmids {
					array set tmp $lmid 1
				}

				log_puts "ALL" "gchat_recv ARC $id"
				foreach {mmid mdata} $body {
					if { [array get tmp $mmid] == 1 } {
						continue
					}
					gchat_append $p $id $mdata 1
					gchat_history $p $id $mdata
					gchat_send $p $id $mfrom $mmid "OK" {}
				}
			}
		}
		"RENEW" {
			if { $body == "ask" } {
				gchat_send $p $id $from $mid "RENEW" "answer" 
			}
		}
		"OK" {
			gchat_append_res $p $id $msg "OK"
			set targets {}
			catch { set targets $::gchatqueue($p,$id,$mid,targets) }
			catch { set targets [lsearch -all -inline -exact -not $targets $from] }
			array set ::gchatqueue [list "$p,$id,$mid,targets" $targets]
			if { $targets == {} } { 
				array unset ::gchatqueue "$p,$id,$mid,*"
			}

			if { [lindex $body 1] == "NOTICE" && [lindex $body 2] == "GRS" } {
				foreach obj [lindex $body 4] {
					saveobj $id [lindex $body 3] $obj
				}
			}
		} 
		"NO" {
			gchat_append_res $p $id $msg "NO"
			set targets {}
			catch { set targets $::gchatqueue($p,$id,$mid,targets) }
			catch { set targets [lsearch -all -inline -exact -not $targets $from] }
			array set ::gchatqueue [list "$p,$id,$mid,targets" $targets]
			if { $targets == {} } { 
				array unset ::gchatqueue "$p,$id,$mid,*"
			}
		}
		default {
			log_puts "ERR" "unknown p=$p message"
			log_puts "ERR" "msg $msg"
		}
	}
	after 50 check_gchatqueue
	log_puts "ALL" "gchat_recv end"
}

proc gchat_history {p id data} {
	set s [gchat_unpack $data]
	set mid [lindex $s 1]
	set path [file join $::filepath "$p" "h_$id.dat"]
	save_bin $path [list $mid $data]
	return
}

proc gchat_history_get {p id interval num aids} {
	log_puts "ALL" "gchat_history_get $id aids $aids"
	if { $interval == "" } {
		set interval 7 
	}	
	set minepoch [expr "[clock seconds] - 3600*24*$interval"]
	set path [file join $::filepath "$p" "h_$id.dat"]
	if { [file exists $path] == 0 } {
		log_puts "ERR" "gchat_history_get no such path"
		return
	}
	set hist [find_bin $path $aids $minepoch {} {}]
	set r {}
	foreach {mid data} $hist {
		if { [string length $data] > [expr "1024*512"] } {
			log_puts "ERR" "gchat_history_get too big"
			continue
		}
		if { $mid == {} || $data == {} } {
			continue
		}
		lappend r $mid $data 
	}
	log_puts "ALL" "gchat_history_get ret $r"
	if { $num == {} } {
		set num "end"
	} else {
		set num [expr {$num*2}]
	}
	set r [lrange $r 0 $num]
	return $r
}

proc gchat_history_ids {p id interval num} {
	log_puts "ALL" "gchat_history_ids $id"
	if { $interval == "" } {
		set interval 7 
	}	
	set minepoch [expr "[clock seconds] - 3600*24*$interval"]
	set path [file join $::filepath "$p" "h_$id.dat"]
	if { [file exists $path] == 0 } {
		log_puts "ERR" "gchat_history_ids no such path"
		return
	}
	set hist [find_bin $path {} $minepoch {} {}]
	set r {}
	foreach {mid data} $hist {
		if { [string length $data] > [expr "1024*512"] } {
			log_puts "ERR" "gchat_history_ids too big"
			continue
		}
		if { $mid == {} || $data == {} } {
			continue
		}
		lappend r $mid $data
	} 
	log_puts "ALL" "gchat_history_ids r $r" 
	set lr {}
	foreach {rid repoch} [lsort -unique -integer -stride 2 -index 1 -decreasing $r] {
		lappend lr $rid
	}
	log_puts "ALL" "gchat_history_ids lr $lr" 
	if { $num == {} } {
		set num "end"
	}
	set ret [lrange $lr 0 $num]
	log_puts "ALL" "gchat_history_ids ret $ret"
	return $ret
}

proc gchat_history_read {p id} {
	if { [winfo exists ".g_$id"] == 0 } {
		return
	}
	foreach {mid data} [gchat_history_get $p $id {} {} {}] {
		gchat_append $p $id $data 0
	}
	".g_$id.o.t" insert end "\n***\n\n"
	".g_$id.o.t" yview moveto 1
	return
}

proc gchat_append {p id data color} {
	set s [gchat_unpack $data]
	if { $s == {} } {
		log_puts "ERR" "gchat_append $p $id bad message"
		return
	}
	set epoch [lindex $s 2]
	set type [lindex $s 3]
	set body [lindex $s 4]
	set nickname [lindex $s 5]
	set from [lindex $s 6]

	if { $from != $::me(id) } {
		set tag red
		set dir "*[clock format $epoch -format {%H:%M:%S}]*:"
	} elseif { $from == $::me(id) }  {
		set tag green
		set dir "*[clock format $epoch -format {%H:%M:%S}]*:"
	} else {
		set nickname "weirdo"
		set tag yellow
		set dir "*[clock format $epoch -format {%H:%M:%S}]*:"
	}

	if { $type == "NOTICE" && [lindex $body 0] == "STATUS" } {
		return
	} elseif { [winfo exists ".g_$id"] == 1 && $color == 1 } {
		".g_$id.o.t" insert end "$nickname <$from>$dir\n" $tag 
		disp_line ".g_$id.o.t" "$body"
		".g_$id.o.t" yview moveto 1
	} elseif { [winfo exists ".g_$id"] == 1 && $color != 1 } {
		".g_$id.o.t" insert end "$nickname <$from>$dir\n" {}
		".g_$id.o.t" insert end "[string range $body 0 1000]\n" {}
		".g_$id.o.t" yview moveto 1
	} 

	return
}

proc gchat_append_res {p gid data res} {
	log_puts "ALL" "gchat_append_res $p $gid $data $res"
	set s [gchat_unpack $data]
	if { $s == {} } {
		return
	}
	set omid [lindex $s 1]
	set nickname [lindex $s 5]
	set from [lindex $s 6]
	log_puts "ALL" "gchat_append_res mid $omid from $from"
	set odata [lindex [gchat_history_get $p $gid {} {} $omid] end]
	if { $odata == {} } {
		return
	}
	set os [gchat_unpack $odata]
	if { $os == {} } {
		return
	}
	set onickname [lindex $os 5]
	set ofrom [lindex $os 6]
	set otype [lindex $os 3]
	log_puts "ALL" "gchat_append_res ofrom $ofrom otype $otype"
	if { $ofrom == $::me(id) } {
		set f "me"
	} else {
		set f "$onickname <$ofrom>"
	}
	set t "$nickname <$from>"
	if { [winfo exists ".g_$gid"] == 1 && $otype == "TEXT" && $res == "OK" } {
		if { $p == "gchat" } { 
		".g_$gid.o.t" insert end [::msgcat::mc "g_delivered" [clock format [clock seconds] -format {%H:%M:%S}] $otype "$f" "$t"] {ok}
		} else {
		".g_$gid.o.t" insert end [::msgcat::mc "g_delivered" [clock format [clock seconds] -format {%H:%M:%S}] $otype "$f" "$t"] {ok}
		}
		".g_$gid.o.t" yview moveto 1
	} elseif { [winfo exists ".g_$gid"] == 1 && $otype == "TEXT" && $res == "NO" } {
		".g_$gid.o.t" insert end [::msgcat::mc "g_rejected" [clock format [clock seconds] -format {%H:%M:%S}] $otype "$f" "$t"] {no}
		".g_$gid.o.t" yview moveto 1
	} else {
		log_puts "ERR" "gchat_append_res strange message otype $otype res $res"
	}
}

proc gchat_append_refuse {p gid} {
	if { [winfo exists ".g_$gid"] == 1 } {
		".g_$gid.o.t" insert end [::msgcat::mc "g_notallowed" [clock format [clock seconds] -format {%H:%M:%S}]] {refuse}
		".g_$gid.o.t" yview moveto 1
	}
} 


#proc check_gchatqueue {} {
#	log_puts "ALL" "check_gchatqueue"
#	if { [expr {$::last(gchq)+100}] > [clock microseconds] } {
#		return	
#	}
#	set ::last(gchq) [clock microseconds]
#	foreach {gid grp} [array get ::jgroups] {
#		set msgs [array get ::gchatqueue "gchat,$gid*msg"]
#		if { [llength $msgs] == 0 } {
#			log_puts "ERR" "no msgs in $gid"
#			continue
#		}
#		set gpeerid [dict get [ml_groupdict $::jgroups($gid)] peerid]
#		set gsrc {}
#		if { $::options(group_host_mode) != 1 || $gpeerid == $::me(id) } {
#			set gsrc [lrange [ml_get_srcs $gid] 2 end]
#		} else {
#			set gsrc $gpeerid
#		}
#		#set gsrc [lrange [ml_get_srcs $gid] 2 end]
#		lappend gsrc $gpeerid
#		log_puts "ALL" "gchatqueue gsrc $gsrc"
#		foreach {key msg} $msgs {
#		set rkey [string map {{,msg} {}} $key]
#		foreach pv $gsrc {
#			if { $pv == $::me(id) } {
#				log_puts "ERR" "pv $pv is me ${::me(id)}"
#				continue
#			}
#			if { [string length $pv] != 64 } {
#				log_puts "ERR" "pv $pv wrong length [string length $pv]"
#				continue
#			}
#			log_puts "ALL" "pv $pv"
#			set found [lsort -unique -stride 2 -index end [array get ::peerstore "$pv*"]]
#			log_puts "ALL" "pv found $found"
#			if {[llength $found] == 0 } {
#				#log_puts "ALL" "find sources for $gid"
#				#after 100 [list sc_get_sources $gid]
#				set peers [closest_in_buckets $pv 2]
#				log_puts "ALL" "gchat peers $peers"
#				foreach peer $peers {
#					set speer [split $peer {:}]
#					log_puts "ALL" "asking $peer for our gchat buddy"
#					if {[llength $speer] == 4} {
#						str_start [str_create FIND_NODE [lindex $speer 1] [lindex $speer 2] $pv none]
#					}
#				}
#			}
#			foreach {psk psv} $found {
#				if { [string length $psk] != 64 } {
#					continue
#				}
#				set rkey [string map {{,msg} {}} $key]
#				#log_puts "ALL" "msg $msg"
#				set speer [split $psv {:}]
#				#log_puts "ALL" "speer $speer"
#				set peerid [lindex $speer 0]
#				#log_puts "ALL" "peerid $peerid"
#				set host [lindex $speer 1]
#				#log_puts "ALL" "host $host"
#				set port [lindex $speer 2]
#				#log_puts "ALL" "port $port"
#				log_puts "ALL" "gchatqueue send $peerid $host $port GCHAT 0 $msg"
#				#send $host $port "GCHAT 0 $msg"
#				ml_genc $peerid $host $port "GCHAT 0 $msg" 0
#			}
#		}
#		log_puts "ALL" "gchatqueue unset $rkey"
#		array unset ::gchatqueue "$rkey*"
#		}
#	}
#}

proc check_gchatqueue {} {
	if { $::cur(net,on) != 1 } {
		return
	}
	log_puts "ALL" "check_gchatqueue"
	if { [expr {$::last(gchq)+100}] > [clock microseconds] } {
		return	
	}
	set ::last(gchq) [clock microseconds]
	set now [clock seconds]
	foreach {k targets} [array get ::gchatqueue "*targets"] {
		set sk [split $k {,}]
		set p [lindex $sk 0]	
		set id [lindex $sk 1]	
		set mid [lindex $sk 2]	
		set msg [lindex [array get ::gchatqueue "$p,$id,$mid,msg"] end]
		set last [lindex [array get ::gchatqueue "$p,$id,$mid,last"] end]
		set count [lindex [array get ::gchatqueue "$p,$id,$mid,count"] end]
		if { [expr {$last+3}] > $now } {
			continue
		} 
		switch $p {
		"gchat" {
			set term "GCHAT"
		}
		"chat" {
			set term "CHAT"
		}
		default {
			log_puts "ERR" "check_gchatqueue p=$p strange, skip message"
			continue
		}
		}
		log_puts "ALL" "check_gchatqueue p=$p send to targets"
		foreach peerid $targets {
			set found [array get ::peerstore "$peerid*"]
			if { $found == {} } {
				set peers [closest_in_buckets $peerid 4]
				log_puts "ALL" "chat peers $peers"
				foreach peer $peers {
					set speer [split $peer {:}]
					log_puts "ALL" "asking $peer for our chat buddy"
					if {[llength $speer] == 4} {
						str_start [str_create FIND_NODE [lindex $speer 1] [lindex $speer 2] $peerid none]
					}
				}
			}
			log_puts "ALL" "check_gchatqueue peerid=$peerid send message"
			ml_genc $peerid {} {} "$term 0 $msg" 0
		}
		incr count -1
		array set ::gchatqueue [list "$p,$id,$mid,last" [clock seconds]]
		array set ::gchatqueue [list "$p,$id,$mid,count" $count]
		if { $count < 0 } {
			array unset ::gchatqueue "$p,$id,$mid,*"
		}
	}
}

#proc check_chatqueue {} {
#	log_puts "ALL" "check_chatqueue"
#	if { [expr {$::last(chq)+100}] > [clock microseconds] } {
#		return	
#	}
#	set ::last(chq) [clock microseconds]
#	set enterq $::last(chq)
#	#log_puts "ALL" "start chatq $enterq"
#	foreach {hash buddy} [array get ::buddies] {
#		foreach {key value} [array get ::chatqueue "chat,$hash*peerid"] {
#			set found [array get ::peerstore "$value*"]
#			#log_puts "ALL" "found chat peers [llength $found] elements (all) -> $found"
#			if {[llength $found] > 0} {
#					set rkey [string map {{,peerid} {}} $key]
#					set msg [lindex [array get ::chatqueue "$rkey,msg"] 1]
#					set speer [split [lindex $found 1] {:}]
#					set peerid [lindex $speer 0]
#					set host [lindex $speer 1]
#					set port [lindex $speer 2]
#					set last [lindex [array get ::chatqueue "$rkey,last"] 1]
#					set count [lindex [array get ::chatqueue "$rkey,count"] 1]
#					if { $last != "" } {
#						set now [clock seconds]
#						set old [expr {$now-$last}]
#					} else {
#						set old 0	
#						set count 0
#					}
#					if { $count == 0 || ($old > 3 && $count == 1) } {
#						#tcp_send $host $port "CHAT 0 $msg"
#						#send $host $port "CHAT 0 $msg"
#						ml_genc $peerid $host $port "CHAT 0 $msg" 0
#					} else {
#						array unset ::chatqueue "$rkey*"
#					}
#					array set ::chatqueue [list "$rkey,last" [clock seconds]]
#					array set ::chatqueue [list "$rkey,count" [expr {$count+1}]]
#			} else {	
#					set peers [closest_in_buckets [lindex [split $value { }] 0] 2]
#					log_puts "ALL" "chat peers $peers"
#					foreach peer $peers {
#						set speer [split $peer {:}]
#						log_puts "ALL" "asking $peer for our chat buddy"
#						if {[llength $speer] == 4} {
#							str_start [str_create FIND_NODE [lindex $speer 1] [lindex $speer 2] $value none]
#						}
#					}
#			}
#		}
#	}
#	set end [clock microseconds]
#	#log_puts "ALL" "end chatq $end"
#	#log_puts "ALL" "time chatq [expr {$end-$enterq}]"
#}

proc check_peers {} {
	if { $::cur(net,on) != 1 } {
		return
	}
	log_puts "ALL" "check_peers and buckets"
	#log_puts "ALL" "peerlast [expr {$::last(peer)+200}] > [clock microseconds]"
	if { [expr {$::last(peer)+200}] > [clock microseconds]} {
		return	
	}
	set ::last(peer) [clock microseconds]
	#log_puts "ALL" "check peers and buckets"
	foreach {bkey bvalue} [array get ::b] {
		if {[llength [array names ::peerstore [lindex [split $bkey {,}] 1]]] == 0} {
			array unset ::b $bkey
		}
	}
	set inbuckets [llength [array names ::b]]
	set inpeerstore [llength [array names ::peerstore]]
	if { $inbuckets < 20 && $inbuckets <= $inpeerstore } {
		foreach {pkey pvalue} [array get ::peerstore] {
			log_puts "ALL" "check_peers check peer $pkey"
			set speer [split $pvalue {:}]
			if { [array get ::b "*,$pkey"] == "" } {
				str_start [str_create PING [lindex $speer 1] [lindex $speer 2] $pkey none]
			}
		}
	}
	array unset ::peerstore "${::me(id)}*"
	array unset ::b "*,${::me(id)}*"
}

proc update_groups {} {
	if { ( [winfo exists .g] == 0 && [winfo exists .ig] == 0 ) || [winfo exists .sgs] == 1 } {
		return
	}
	set ::jgrouplist(main,l) {}
	set ::jgrouplist(main,i) {}
	set ::jgrouplist(main,h) {}
	foreach {key value} [array get ::jgroups] {
		set b [ml_groupdict $value]
		lappend ::jgrouplist(main,l) "[dict get $b name] <[dict get $b gid]>"
		lappend ::jgrouplist(main,i) $key
		lappend ::jgrouplist(main,h) $value
	}
	after 3000 update_groups
}

proc latest_contact {peerid} {
	log_puts "ALL" "latest_contact $peerid"
	if { $peerid == {} } {
		log_puts "ERR" "latest_contact empty peerid"
		return
	}
	set contacts [lsearch -all -inline [array get ::contacts] "$peerid:*"]
	set l {}
	set epoch {}
	foreach {k contact} $contacts {
		set c [contact_to_dict $contact]
		if { $c == {} } {
			continue
		}
		if { [dict get $c peerid] != $peerid } {
			continue
		}
		if { [dict get $c sig] == {} } {
			continue
		}
		set epoch [dict get $c epoch]
		lappend l $epoch $contact 
	}
	if { $l != {} } {
		set l [lsort -decreasing -stride 2 -index 0 $l]
		set contact [lindex $l 1]
		log_puts "ALL" "latest_contact return $contact"
		return $contact
	} else {
		log_puts "ALL" "latest_contact return nothing"
		return
	}
}

proc update_buddy {buddyhash} {
	log_puts "ALL" "update_buddy $buddyhash"
	foreach {key value} [array get ::buddies $buddyhash] {
		set b [contact_to_dict $value]
		set peerid [dict get $b peerid]
		set nickname [dict get $b nickname]
		set sig [dict get $b sig]
		if { $sig != {} && $nickname != "#$peerid"} {
			log_puts "ALL" "update_buddy skip"
			continue
		}
		set latest [latest_contact $peerid]
		if { $latest != {} } {
			log_puts "ALL" "update_buddy latest $latest"
			set ::buddies($key) $latest
		}
	}
}

proc update_buddies {} {
	if { [winfo exists .b] == 0 || [winfo exists .sbs] == 1 } {
		return
	}
	log_puts "ALL" "update_buddies"
	set ::peernum [llength [lsort -unique [array names ::b]]]
	set ::buddylist(main,l) {}
	set ::buddylist(main,k) {}
	foreach {key value} [array get ::buddies] {
		update_buddy $key
		set b [contact_to_dict $value]
		set n [llength [array names ::gnotices "chat,$key*"]]
		set peerid [dict get $b peerid]
		set nickname [dict get $b nickname]
		lappend ::buddylist(main,l) "[lindex [array get ::statuses $peerid,type] 1] ($n) $nickname <$peerid>"
		lappend ::buddylist(main,k) $key
	}
	after 3000 update_buddies
}

proc copy_my_contact {} {
	clipboard clear
	clipboard append $::me(contact)
	return
}

proc copy_contact {} {
	clipboard clear
	set contact {}
	catch {
		set contact $::cur(main,person,h)
	}
	if { $contact == {} } {
		return
	}
	set c [contact_to_dict $contact]
	if { $c == {} } {
		return
	}
	clipboard append $contact
	return
}

proc add_copied_contact {} {
	set s {}
	catch {
	set s [clipboard get]
	}
	set c [contact_to_dict $s]
	if { $c == {} } {
		return
	} 
	if { [dict get $c peerid] == $::me(id) } {
		return
	}
	chat_add $s
	return
}

proc copy_group {} {
	clipboard clear
	set group {}
	catch {
		set group $::cur(main,group,h)
	}
	if { $group == {} } {
		return
	}
	set g [ml_groupdict $group]
	if { $g == {} } {
		return
	}
	clipboard append $group
	return
}

proc add_copied_group {} {
	set group {}
	catch {
	set group [clipboard get]
	}
	set g [ml_groupdict $group]
	if { $g == {} } {
		return
	}
	catch {
		set ::groups([dict get $g gid]) $group
		set ::jgroups([dict get $g gid]) $group
		ml_add_srcs [dict get $g gid] ${::me(id)}
		ml_add_srcs [dict get $g gid] [dict get $g peerid] 
		set ::cur(main,mode) {g}
		set ::cur(main,group,h) $group
		set ::cur(main,group,l) [dict get [ml_groupdict $::cur(main,group,h)] name]
		ml_showlist g [dict get [ml_groupdict $::cur(main,group,h)] gid]
		after idle [list sc_publishcontact ${::me(contact)}]
		after idle [list ml_grouphead $group]
	}
}

proc set_peer_status {id type comment last} {
	log_puts "ALL" "set_buddy_status $id $type $comment"
	set epoch [clock seconds]
	set oldepoch [lindex [array get ::statuses $id,epoch] 1]
	#log_puts "ALL" "oldepoch $oldepoch last $last"
	if { $oldepoch == $last || $last == 0 } {
		log_puts "ALL" "set status"
		array set ::statuses [list $id,type $type ]
		array set ::statuses [list $id,comment $comment ]
		array set ::statuses [list $id,epoch $epoch ]
	}
	if { $type != " " } {
		# 5 minutes
		after 300000 [list set_peer_status $id " " "offline" $epoch]
	}
}

proc send_my_status {type comment} {
	log_puts "ALL" "send_my_status $type $comment"
	foreach hash [array names ::buddies] {
		log_puts "ALL" "status->chat_notice $hash {STATUS $type/$comment}"
		gchat_send chat $hash {} [clock microseconds] "RENEW" "ask"
		gchat_notice chat $hash "STATUS $type/$comment"
	}
	set sid [wrap "$::me(nickname):${::me(id)}"]
	foreach gid [array names ::jgroups] {
		#set type "RENEW"
		#set body "ask"
		#set id [clock microseconds]
		#set msg [wrap "$gid $sid $id [clock seconds] $type $body"]
		#ml_genc  $sid [clock microseconds] $msg 0
		gchat_notice gchat $gid "STATUS $type/$comment"
	}
	log_puts "ALL" "send_my_status end"
}

proc sc_stop {ids} {
	set ::search {}
	set ::text {}
	if { $ids == "" } {
		log_puts "ERR" "empty ids, return"
		return
	}
	foreach id $ids {
		#foreach item [array names ::waitvalue "$id*"] {
		#	array set ::waitvalue [list $item "DONE"]
		#}
		after 5000 [list array unset ::waitvalue "$id*"]
	}
	after 200 check_waitvalues
}

proc sc_get_sources {hash} {
	log_puts "ALL" "sc_get_sources $hash"
	if { $hash == "" } {
		log_puts "ERR" "sc_get_sources empty key, return"
		return
	}
	set wv_existing [array names ::waitvalue $hash]
	if { $wv_existing != "" } {
		log_puts "ERR" "sc_get_sources already looking for this"
		return
	}
	set waitid [sc_get_value $hash]
	# bullshit for now
	# as in - wait for header to 
	# after get_value on sha1 hash of full message,
	# display waiting status -> not here, in display proc

	# wait for value by handle -> just set type

	# value should be interpreted as a list of sources in triples, sources should be 
	#	added to source store with (sha1 of file,sha1 of source) as key -> not here, in strategy for SOURCES response
	#		or ignored 
	array set ::waitvalue [list "$waitid,type" "sources"]
	# schedule that (have a scheduler array?)
	return $waitid
}

proc sc_get_groups {keys} {
	log_puts "ALL" "sc_get_groups"
	if { $keys == "" || [llength $keys] == 0} {
		log_puts "ERR" "empty keys, return"
		return
	}
	set r {}
	foreach key $keys {
		set waitid [sc_get_value $key]
		array set ::waitvalue [list "$waitid,type" "groups"]
		lappend r $waitid
	}
	return $r
}

proc sc_get_contacts {keys} {
	log_puts "ALL" "sc_get_contacts"
	if { $keys == "" || [llength $keys] == 0} {
		log_puts "ERR" "empty keys, return"
		return
	}
	set r {}
	foreach key $keys {
		set waitid [sc_get_value $key]
		array set ::waitvalue [list "$waitid,type" "contacts"]
		lappend r $waitid
	}
	return $r
}

proc sc_get_headers {keys} {
	log_puts "ALL" "sc_get_headers"
	if { $keys == "" || [llength $keys] == 0} {
		log_puts "ERR" "empty key, return"
		return
	}
	set r {}
	foreach key $keys {
	set waitid [sc_get_value $key]
	# bullshit for now
	# wait for get_value to add header
	# after get value on keyword,
	# display waiting status

	# wait for value by handle
	
	# value should be interpreted as a "sha1:chunksize:chunks:epoch:from:to:subject" without content 
	#		in b64 string, or ignored
	#		when interpreted, added to store of search results by key (search id,handle)
	array set ::waitvalue [list "$waitid,type" "headers"]
	# schedule that (have a scheduler array?)
	lappend r $waitid
	}
	return $r
}

proc sc_get_value {key} {
	log_puts "ALL" "sc_get_value $key"
	if { $key == "" } {
		log_puts "ERR" "empty key, return"
		return
	}
	# try to find locally
	#if { [llength [array names ::valuestore "$key*"]] > 0} {
	#	log_puts "ALL" "array names [array get ::valuestore "$key*"]"
	#	set id "$key,[clock microseconds]"
	#	array set ::waitvalue [list $id "DONE"]
	#	return $id
	#}	
	# commented, because it was bad, wrong and should be done in
	# check_waitvalues only
	# find 4 peers closest
	set peers [closest_in_buckets $key 4]
	# send find_value to each
	foreach peer $peers {
		set speer [split $peer {:}]
		str_start [str_create FIND_VALUE [lindex $speer 1] [lindex $speer 2] $key none]
	}
	# display waiting status <- not here
	
	# add it to waiting to be fetched things array <- that's ok
	set id "$key,[clock microseconds]"
	array set ::waitvalue [list $id "WAIT"]
	after 180000 [list array set ::waitvalue [list $id "DONE"]]
	after 200 check_waitvalues
	# return array key (key and time)
	return $id
}

proc sc_get_values {keys} {
	log_puts "ALL" "sc_get_values"
	set ret {}
	foreach key $keys {
		lappend ret [sc_get_value $key]
	}
	after 200 check_waitvalues
	return $ret
}

proc prep_group_keys {s} {
	if { [llength $s] == 0 } {
		log_puts "ERR" "no keys, return"	
		return
	}
	set ret {}
	foreach token $s {
		set k [shawrap "group:$token"]
		log_puts "ALL" "token $token to keyword $k"
		lappend ret $k
	}
	return $ret
}

proc prep_contact_keys {s} {
	if { [llength $s] == 0 } {
		log_puts "ERR" "no keys, return"	
		return
	}
	set ret {}
	foreach token $s {
		set k [shawrap "contact:$token"]
		log_puts "ALL" "token $token to keyword $k"
		lappend ret $k
	}
	return $ret
}

proc build_personal_filter {} {
	set s {}
	lappend s $::me(id)
	lappend s [crypto_exp_pub $::me(key)]
	lappend s $::me(contact)
	log_puts "ALL" "filter is $s"
	return $s
}

proc prep_header_keys {s} {
	if { [llength $s] == 0 } {
		log_puts "ERR" "no keys, return"	
		return
	}
	set ret {}
	foreach token $s {
		set k [crypto_cksum "header:$token"]
		log_puts "ALL" "token $token to keyword $k"
		lappend ret $k
	}
	return $ret
}

proc update_widgets {} {
	if { [winfo exists .p] == 0 } {
		return
	}
	log_puts "ALL" "update widgets"
	set ::p_l {}
	set ::dbg(b,l) {}
	set ::dbg(peerstore,l) {}	
	set ::dbg(valuestore,l) {}	
	set ::dbg(contacts,l) {}
	set ::dbg(headers,l) {}
	set ::dbg(waitvalue,l) {}
	foreach {sreq req} [array get ::p "*,req" ] {
		set s [lindex [split $sreq {,}] 0]
		set line "# $s | $::p($s,req) | $::p($s,state) | $::p($s,host) | $::p($s,port) | $::p($s,key) | $::p($s,value)" 
		lappend ::p_l $line	
	}
	foreach {bkey seen} [array get ::b ] {
		set b [lindex [split $bkey {,}] 0]
		set key [lindex [split $bkey {,}] 1]
		set line "$b | $key | $seen"
		lappend ::dbg(b,l) $line
	}
	foreach {key triple} [array get ::peerstore ] {
		set line "$key | $triple"
		lappend ::dbg(peerstore,l) $line
	}
	foreach {key value} [array get ::valuestore ] {
		set line "$key | $value"
		lappend ::dbg(valuestore,l) $line
	}
	foreach {key value} [array get ::contacts ] {
		set line "$key | $value"
		lappend ::dbg(contacts,l) $line
	}
	foreach {key value} [array get ::headers ] {
		set line "$key | $value"
		lappend ::dbg(headers,l) $line
	}
	foreach {key value} [array get ::waitvalue ] {
		set line "$key | $value"
		lappend ::dbg(waitvalue,l) $line
	}
	after 1000 update_widgets
}

proc udp_start {host port msg} {
	#log_puts "ALL" "udp_start $host $port $msg"
	set msg [wrap [zip -mode compress -level default $msg]]
	set id [expr "([clock microseconds]+[string length $msg])%65536"]
	set ::udp_out_fifo($id,host) $host
	set ::udp_out_fifo($id,port) $port
	set ::udp_out_fifo($id,fifo) [fifo]
	fconfigure $::udp_out_fifo($id,fifo) -translation binary 
	puts -nonewline $::udp_out_fifo($id,fifo) $msg
	flush $::udp_out_fifo($id,fifo)
	set all [expr "[string length $msg]/512+1"]
	set p [binary format H1su1su1su1 1 $id 0 $all]
	set p [wrap $p]
	rawsend $::udp_out_fifo($id,host) $::udp_out_fifo($id,port) $p
	after 100 [list udp_run $id 0 $all]
}

proc udp_run {id seq all} {
	#log_puts "ALL" "udp_run $id $seq $all"
	if { [llength [array names ::udp_out_fifo "$id,fifo"]] == 0 } {
		return
	}
	set piece [read $::udp_out_fifo($id,fifo) 512]
	if { $seq >= $all } {
		after 100 [list udp_end $id $all]
	} else {	
		set p [binary format H1su1su1su1a* 2 $id $seq $all $piece]
		set p [wrap $p]
		rawsend $::udp_out_fifo($id,host) $::udp_out_fifo($id,port) $p
		after 20 [list udp_run $id [expr {$seq+1}] $all]
	}
}

proc udp_end {id all} {
	#log_puts "ALL" "udp_end $id 0 $all"
	set p [binary format H1su1su1su1 3 $id 0 $all]
	set p [wrap $p]
	rawsend $::udp_out_fifo($id,host) $::udp_out_fifo($id,port) $p
	after 1000 [list rawsend $::udp_out_fifo($id,host) $::udp_out_fifo($id,port) $p]
	after 3000 [list rawsend $::udp_out_fifo($id,host) $::udp_out_fifo($id,port) $p]
	close $::udp_out_fifo($id,fifo)
	array unset ::udp_out_fifo "$id*"
}

proc udp_req {host port msg} {
	#log_puts "ALL" "udp_req $host $port $msg"
	set msg [unwrap $msg]
	binary scan $msg H1 type
	#log_puts "ALL" "udp_req type $type"
	set dmsg $msg
	binary scan $dmsg H* debug
	#log_puts "ALL" "udp_req debug $debug"
	set id {}
	if { $type == 0 } {
		binary scan $msg a* body
		str_req "$host $port" $body 0
	} elseif { $type == 1 } { 
		binary scan $msg H1su1su1su1 type id seq all
		if { [lindex [array get ::udp_in_fifo "$id,top"] end] > 0 } {
			return
		}
		#log_puts "ALL" "udp_req $id $seq $all"
		set ::udp_in_fifo($id,host) $host
		set ::udp_in_fifo($id,port) $port
		set ::udp_in_fifo($id,fifo) [fifo]
		set ::udp_in_fifo($id,rec) 0
		set ::udp_in_fifo($id,top) 0
		set ::udp_in_fifo($id,buf) 0
		set ::udp_in_fifo($id,all) $all
	} elseif { $type == 2 } {
		binary scan $msg H1su1su1su1a* type id seq all data
		if { $id == "" } {	
			return
		}
		#log_puts "ALL" "udp_req $id $seq $all"
		incr ::udp_in_fifo($id,rec) 1
		#log_puts "ALL" "udp_req $id top $::udp_in_fifo($id,top) and seq $seq"
		log_puts "ALL" "udp_req $id in buf are: [lsort [array names ::udp_in_fifo $id,buf,*]]"
		set ::udp_in_fifo($id,buf,$seq) $data
		if { $::udp_in_fifo($id,top) == $seq } {
			return
		}
		for { set c $::udp_in_fifo($id,top) } { $c <= $seq } { incr c 1 } {
			if { [llength [array get ::udp_in_fifo $id,buf,$c]] != 0 } {
				log_puts "WARN" "udp_req fixing missed packets $c"
				incr ::udp_in_fifo($id,top) 1
				puts -nonewline $::udp_in_fifo($id,fifo) $::udp_in_fifo($id,buf,$c)
				array unset ::udp_in_fifo "$id,buf,$c" 
			} else {
				break
			}
		}
		flush $::udp_in_fifo($id,fifo)
		return
	} elseif { $type == 3 } {
		binary scan $msg H1su1su1su1 type id seq all
		if { [llength [array names ::udp_in_fifo "$id*"]] == 0 || $id == "" } {
			return
		}
		#log_puts "ALL" "udp_req $id $seq $all"
		log_puts "ALL" "udp_req $id rec $::udp_in_fifo($id,rec) vs all $all"	
		#log_puts "ALL" "udp_req $id else if fifo existing and not done"
		if { $::udp_in_fifo($id,rec) == $all } {
			#log_puts "ALL" "udp_req $id rec $::udp_in_fifo($id,rec) == all $all"	
			set full [read $::udp_in_fifo($id,fifo)]
			str_req "$host $port" [zip -mode decompress [unwrap $full]] 0
			close $::udp_in_fifo($id,fifo)
			array unset ::udp_in_fifo "$id*"
		} else {
			#log_puts "ALL" "udp_req $id fifo existing and not done"
			after 1000 [list udp_req $host $port $msg]
		}
	} elseif { $type == 4 } {
		log_puts "ALL" "audio data in"
		binary scan $msg H1a* type data
		if { $::audio_in_fifo != "" } {
			puts -nonewline $::audio_in_fifo $data
			si play -blocking 0
		}
	} elseif { $type == 5 } {
		log_puts "ALL" "audio msg in"
		binary scan $msg H1H1 type op
		if { $op == 0 } {
			# if called, ring
			log_puts "ALL" "audio called, ring"
			audio_ring $host $port
		} elseif { $op == 1 } {
			# if accepted, start
			log_puts "ALL" "audio accepted, start"
			audio_start $host $port
		} elseif { $op == 2 } {
			# if teardown, do
			log_puts "ALL" "audio teardown, end"
			audio_end $host $port
		}
	} else {
		binary scan $msg H* fail
		log_puts "ERR" "udp_req weird message $fail"
	}
}

proc send {host port msg} {
	if { $::cur(net,on) != 1 } {
		return
	}
	log_puts "ALL" "send $host $port [join $msg]"
	#udp_start $host $port $msg
	#after idle [list tcp_send $host $port $msg]
	if { $::options(run_i2p) == 1 } {
		after idle [list i2p_send $host $msg]
	} else {
		after idle [list tcp_send $host $port $msg]
	}
}

proc rawsend {host port msg} {
	if { $::cur(net,on) != 1 } {
		return
	}
	#log_puts "ALL" "send"
	if { $host == "" || $port == "" || $msg == "" } {
		log_puts "ERR" "ERR something empty (h $host p $port), won't send $msg"
		return
	}
	if { ($host == "127.0.0.1" || $host == "localhost") && $port == $::options(myport) } {
		log_puts "ERR" "ERR won't send to myself"
		return
	}
	#set start [clock microseconds]
	set s [udp_open $::options(myport) reuse]
	#log_puts "ALL" "sending to $host $port msg $msg"
	#fconfigure $s -buffering line -remote [list $host $port]
	fconfigure $s -translation binary -remote [list $host $port]
	puts $s $msg
	#flush $s
	close $s	
	#set end [clock microseconds]
	#log_puts "ALL" "time send [expr {$end-$start}]"
}

proc tcp_send {host port msg} {
	log_puts "ALL" "tcp_send"
	if { $host == "" || $port == "" || $msg == "" } {
		log_puts "ERR" "tcp_send something empty (h $host p $port), won't send"
		return
	}
	if { ($host == "127.0.0.1" || $host == "localhost") && $port == $::options(myport) } {
		log_puts "ERR" "tcp_send won't send to myself"
		return
	}
	if { [clock add $::tick 1 minute] < [clock seconds] } {
		log_puts "ERR" "tcp_send tick too long ago, drop"
		return
	}
	if { [lindex [array get ::tcp_fail count] 1] > 30 } {
		log_puts "ERR" "tcp_send tcp_fail count decr"
		incr ::tcp_fail(count) -1
		return
	} elseif { [lindex [array get ::tcp_fail "$host,$port"] 1] > [expr "[clock seconds]-15"] } {
		log_puts "ERR" "tcp_send tcp_fail too recent"
		return
	} else {
		array unset ::tcp_fail "$host,$port"
	}
	
	set start [clock microseconds]
	set result {}
	set s {}
	#log_puts "ALL" "SENDING to $host $port msg $msg"
	#set s [lindex [array get ::tcp_conn "p2s,$host,$port"] 1]
	#if { $s == "" } { 
	#	set s [socket $host $port]
	#	array set ::tcp_conn [list "s,$s,$host,$port" $s]
	#}
	#array set ::tcp_conn [list "last,$s,$host,$port" [clock seconds]]
	#set s [lindex [array get ::tcp "s,$host,$port"] 1]
	#after 15000 [list tcp_check $s $host $port]
	catch {
	set s [tcp_init $host $port]
	}
	if { $s == "" } {
		log_puts "ERR" "ERR failed to open socket"
		array set ::tcp_fail [list "$host,$port" [clock seconds]]
		incr ::tcp_fail(count) 1
		return
	}
	log_puts "ALL" "tcp_send result: $result"
	array set ::tcp [list "socket,$s" [clock seconds]]
	log_puts "ALL" "TCP SOCKETS [llength [array names ::tcp]]"
	#fconfigure $s -blocking 1 -buffering none -translation binary
	###puts $s "$::options(myport)"
	#w_byte 101 $s
	#w_short $::options(myport) $s
	#flush $s
	log_puts "ALL" "CLIENT START $host $port"
	#fconfigure $s -buffering line
	fconfigure $s -blocking 0 -buffering full -translation binary
	set sid [after 60000 [list tcp_send_timeout $s]]
	fileevent $s readable [list tcp_send_res $s $host $port $sid ]
	log_puts "ALL" "CLIENT FIRST -> [string range $msg 0 31]"
	catch {
	after idle [list w_req $msg $s]
	}
	log_puts "ALL" "CLIENT FIRST DONE"
	#set end [clock microseconds]
	#log_puts "ALL" "time send [expr {$end-$start}]"
}

proc tcp_init {host port} {
	log_puts "ALL" "tcp_init $host $port"
	if { $host == {} || $port == {} } {
		log_puts "ERR" "tcp_init empty host"
		return
	}
	set s {}
	catch {
	set s [lindex [array get ::tcp_conn "addr2sock,$host,$port"] 1]
	}
	log_puts "ALL" "tcp_init prev $s"
	set err [tcp_check $s]
	if { $s == {} || $err == "err"} {
		log_puts "ERR" "tcp_init new socket"
		set s [socket $host $port]
		array set ::tcp_conn [list "addr2sock,$host,$port" $s]
		array set ::tcp_conn [list "sock2host,$s" $host]
		array set ::tcp_conn [list "sock2port,$s" $port]
	}
	#after 15000 [list tcp_check $s]
	return $s
}

proc tcp_check {s} {
	log_puts "ALL" "tcp_check $s"
	if { $s == {} } {
		return "err"
	}
	set err_chan {}
	set err_eof {}
	catch {
	set err_chan [chan configure -error $s]
	set err_eof [chan eof $s]
	} res
	log_puts "ALL" "err_chan $err_chan"
	log_puts "ALL" "err_eof $err_chan"
	if { $err_chan != {} || $err_eof == 1 } {
		log_puts "ERR" "tcp_check fail"
		tcp_cleanup $s
		return "err"
	} else {
		return
	}
}

proc tcp_cleanup {s} {
	log_puts "ALL" "tcp_cleanup"
	catch {
	close $s
	}
	set host {}
	set port {}
	catch {
	set host [lindex [array get ::tcp_conn "sock2host,$s"] 1]
	set port [lindex [array get ::tcp_conn "sock2port,$s"] 1]
	} res
	if { $host != {} && $port != {} } {
		log_puts "ERR" "tcp_cleanup no host or no port"
		catch {
		array unset ::tcp_conn "addr2sock,$host,$port"
		} res
	}
	catch {
	array unset ::tcp_conn "sock2host,$s"
	array unset ::tcp_conn "sock2port,$s"
	array unset ::tcp "socket,$s"
	} res
	return
}

proc tcp_send_timeout {s} {
	catch { tcp_cleanup $s }
	array unset ::tcp "socket,$s"
	log_puts "ALL" "TCP SOCKETS [llength [array names ::tcp]]"
}

proc tcp_send_res {s host port sid} {
	catch { after cancel $sid }
	set res {}
	catch {
	set res [r_req $s]
	set port [lindex $res 0]
	set res [lrange $res 1 end]
	}
	set peer "$host $port"
	if { $res == {} } {
		log_puts "ERR" "empty message"
	}
	log_puts "ALL" "CLIENT RES $res"
	if { [eof $s] } {
		log_puts "ERR" "CLIENT EOF CLOSE"
		tcp_cleanup $s
		array unset ::tcp "socket,$s"
		log_puts "ERR" "TCP SOCKETS [llength [array names ::tcp]]"
		#log_puts "ERR" "CLIENT CLOSE DONE"
	} elseif { ![fblocked $s] } {
		log_puts "ALL" "CLIENT <- [string range $res 0 31]"
		set rs {}
		catch {
		lappend rs {*}[str_req $peer $res 1]
		}
		log_puts "ALL" "CLIENT RS [string range $rs 0 63]"
		foreach r $rs {
			log_puts "ALL" "CLIENT -> [string range $r 0 31]"
			catch {
			after idle [list w_req $r $s]
			}
			log_puts "ALL" "CLIENT DONE"
		}
	} else {
		log_puts "ALL" "CLIENT BLOCKED"
	}
	log_puts "ALL" "CLIENT RES DONE"
}

proc listen_handler {c} {
	set start [clock microseconds]
	set packet [read $c]
	set peer [fconfigure $c -peer]
	#log_puts "ALL" "INCOMING: $peer / ([string length $packet]) {$packet}"
	if { $packet == {} } {
		log_puts "ERR" "empty packet"
		return
	}
	if { $packet != 0 } {
		#set start [clock microseconds]
		udp_req [lindex $peer 0] [lindex $peer 1] $packet
		#set end [clock microseconds]
		#log_puts "ALL" "time str_req [expr {$end-$start}]"
	} else {
		log_puts "ERR" "wrong, won't process"
	}
}

proc tcp_listen_handler {c host port} {
	set start [clock microseconds]
	#set fullpacket [read $c]
	#set outport [lindex [split $fullpacket "\n"] 0]
	#set packet [lindex [split $fullpacket "\n"] 1] 
	###gets $c outport
	#fconfigure $c -blocking 1 -buffering none -translation binary 
	#set magic [r_byte $c]
	#set outport [r_short $c]
	#set peer "$host $outport"
	#log_puts "ALL" "INCOMING: $peer / ([string length $packet]) {$packet}"
	#if { $packet == {} } {
	#	log_puts "ERR" "empty packet"
	#	return
	#}
	#if { $magic != 101 || $outport == {} } {
	#	log_puts "ERR" "new connection wrong magic $magic outport $outport"
	#}
	#log_puts "ALL" "SERVER START $peer"
	#fconfigure $c -buffering line
	array unset ::tcp_fail "$host,$port"
	array set ::tcp [list "socket,$c" [clock seconds]]
	log_puts "ALL" "TCP SOCKETS [llength [array names ::tcp]]"
	fconfigure $c -blocking 0 -buffering full -translation binary 
	set sid [after 60000 [list tcp_listen_handler_timeout $c]]
	fileevent $c readable [list tcp_listen_handler_cmd $c $host $port $sid]
}

proc tcp_listen_handler_timeout {c} {
	catch { tcp_cleanup $c }
	array unset ::tcp "socket,$c"
	log_puts "ALL" "TCP SOCKETS [llength [array names ::tcp]]"
}

proc tcp_listen_handler_cmd {c host port sid} {
	catch { after cancel $sid }
	set cmd {}
	catch {
	set cmd [r_req $c]
	set port [lindex $cmd 0]
	set cmd [lrange $cmd 1 end]
	}
	set peer "$host $port"
	if { $cmd == {} } {
		log_puts "ERR" "empty message"
	}
	#log_puts "ALL" "SERVER CMD $cmd"
	if { [eof $c] } {
		#log_puts "ERR" "SERVER EOF CLOSE"
		catch { tcp_cleanup $c }
		array unset ::tcp "socket,$c"
		log_puts "ERR" "TCP SOCKETS [llength [array names ::tcp]]"
		#log_puts "ERR" "SERVER EOF CLOSE DONE"
	} elseif { ![fblocked $c] } {
		set rs {}
		log_puts "ALL" "SERVER <- [string range $cmd 0 31]"
		set rs {}
		catch {
		lappend rs {*}[str_req $peer $cmd 1]
		} result
		#log_puts "ALL" "SERVER CATCH $result"
		#log_puts "ALL" "SERVER RS [string range $rs 0 63]"
		#log_puts "ALL" "SERVER SEND"
		foreach r $rs {
			log_puts "ALL" "SERVER -> [string range $r 0 31]"
			catch {
			after idle [list w_req $r $c]
			}
			log_puts "ALL" "SERVER DONE"
		}
	} else {
		#log_puts "ALL" "SERVER BLOCKED"
	}
	#log_puts "ALL" "SERVER CMD DONE"
}

proc listen {} {
	set c [udp_open $::options(myport) reuse]
	#fconfigure $c -buffering line -translation binary
	fconfigure $c -translation binary
	fileevent $c readable [list ::listen_handler $c]
	return $c
}

proc tcp_listen {} {
	set c [socket -server [list tcp_listen_handler] $::options(myport)]
	fconfigure $c -buffering full -translation binary
	return $c
}

#proc media_listen {} {
#	set c [udp_open $::mymediaport reuse]
#	fconfigure $c -buffering none -translation binary
#	fileevent $c readable [list ::media_listen_handler $c]
#	return $c
#}

# buckets are an array, peer is a list

proc put_to_bucket {dist peer} {
	if { [llength [split $peer]] > 1 } {
		log_puts "ERR" "ERR put to bucket $peer is strange"
		return
	}
	if { $peer == $::me(id) } {
		log_puts "ERR" "ERR can't put myself to bucket"
		return
	}
	log_puts "ALL" "put $dist,$peer to bucket"
	array set ::b [list "$dist,$peer" [expr [clock microseconds]]]
	check_bucket $dist
}

proc put_to_buckets {peer} {
	put_to_bucket [distorder [dist $peer $::me(id)]] $peer
}

proc oldest_in_bucket {dist} {
	if { $::cur(net,on) != 1 } {
		return
	}
	set oldest [ lindex [ lsort -integer -stride 2 -index 1 [ array get ::b "$dist,*" ] ] end-1 ]
	set ret [lindex [split $oldest {,}] end]
	return $ret
}

proc remove_from_bucket {dist peer} {
	if { $::cur(net,on) != 1 } {
		return
	}
	array unset ::b "$dist,$peer"
}

proc remove_from_buckets {peer} {
	if { $::cur(net,on) != 1 } {
		return
	}
	if { $peer == "none" } {
		return	
	}
	remove_from_bucket [distorder [dist $peer $::me(id)]] $peer
}

proc check_buckets {} {
	if { $::cur(net,on) != 1 } {
		return
	}
	# 32 bytes of key, 8 bits per byte
	# that's how many buckets we have
	set dnum [expr {32*8}]
	for { set i 0 } { $i < $dnum } { incr i 1 } {
		check_bucket $i
	}
}

proc check_bucket {b} {
	if { $::cur(net,on) != 1 } {
		return
	}
	set pnum [llength [array names ::b "$b,*"]]
	if { $pnum > 20 } {
		set todel [expr {$pnum-20}]
		for { set c 0 } { $c < $todel } { incr c 1 } {
			set oldest [oldest_in_bucket $b]
			remove_from_bucket $b $oldest
		}
	}
}

#proc dist {a b} {
#	set a_dec [format %u [expr "0x$a * 1"]]
#	set b_dec [format %u [expr "0x$b * 1"]]
#	set lhex [string length $::me(id)]
#	set lbin [expr {4*$lhex}]
#	#return [expr {2^$lbin+(int($a_dec) ^ int($b_dec))}]
#	#log_puts "ALL" "dist:"
#	#puts [expr "int($a_dec) ^ int($b_dec)"]
#	return [format %u [expr "int($a_dec) ^ int($b_dec)"]]
#	#return [expr "int(($a_dec ^ $b_dec)>>32)"]
#}

proc dist {a b} {
	set ret 0
	set abin [binary decode hex $a] 
	set bbin [binary decode hex $b]
	set anums {}
	set bnums {}
	binary scan $abin Iu* anums
	binary scan $bbin Iu* bnums
	set rnums [lmap aa $anums bb $bnums {expr $aa ^ $bb}]
	foreach rnum $rnums {
		set ret [expr {$ret + $rnum}]
	}
	log_puts "ALL" "dist ret $ret"
	return $ret
}

proc distorder {dist} {
	log_puts "ALL" "distorder $dist"
	set lhex [string length $::me(id)]
	set lbin [expr {4*$lhex}]
	for {set c 0} {$c < $lbin} {incr c} {
		set n [expr {pow(2,$c)}]
		log_puts "ALL" "distorder $dist value $n"
		if { $n > $dist} {
			log_puts "ALL" "distorder $dist return $c"
			return $c
		}
	}
	log_puts "ALL" "distorder $dist return default -1"
	return -1
}

proc closest_in_buckets {key num} {
	log_puts "ALL" "find $num closest keys in buckets to key $key"
	if { [regexp -all {:} $key] == 1 } {
		set key [lindex [split $key {:}] 0]
	}
	if { [llength [split $key]] > 1 } {
		log_puts "ERR" "ERR $key is strange"
	}
	set min [dist $key $::me(id)]
	log_puts "ALL" "distance between me and $key is $min"
	array set xorred {}
	foreach bkey [array names ::b] {
		set sbkey [lindex [split $bkey {,}] 1]
		log_puts "ALL" "bkey is $bkey, sbkey is $sbkey"
		log_puts "ALL" "dist is [dist $key $sbkey]"
		#array set xorred [list $sbkey [dist $key $sbkey]]
		array set xorred [list [dist $key $sbkey] $sbkey]
	}
	#log_puts "ALL" "closest - xorred array: [array get xorred]"
	#set ret {}
	#foreach {pkey ptime} [lrange [lsort -integer -stride 2 -index 1 [array get xorred]] 0 $num] {
	#	foreach {pskey psvalue} [array get ::peerstore "$pkey"] {
	#		lappend ret $psvalue
	#	}
	#}
	set ret {}
	foreach {ptime pkey} [lsort -integer -stride 2 -index 0 [array get xorred]] {
		log_puts "ALL" "closest ptime $ptime pkey $pkey" 
		if { $pkey == $::me(id) } {
			continue
		}
		foreach {pskey psvalue} [array get ::peerstore "$pkey*"] {
			log_puts "ALL" "closest pskey $pskey psvalue $psvalue"
			lappend ret $psvalue
		}
	}

	log_puts "ALL" "full set: $ret"
	set ret [lrange $ret 0 $num]
	log_puts "ALL" "returning closest $num: $ret"
	return $ret
}

# cmds

proc sol {host port} {
	log_puts "ALL" "sol"
	send $host $port "SOL 0 ${::me(id)} ${::me(pubkey)}"
}

proc ping {s host port} {
	log_puts "ALL" "ping"
	send $host $port "PING $s"
	after 30000 [list str_ping $s "TIMEOUT" 0]
}

proc store {s host port key val} {
	log_puts "ALL" "store"
	send $host $port "STORE $s $key $val"
	after 30000 [list str_store $s "TIMEOUT"]
}

proc find_node {s host port key} {
	log_puts "ALL" "find_node"
	send $host $port "FIND_NODE $s $key"
	after 30000 [list str_find_node $s "TIMEOUT" 0]
}

proc find_value {s host port key} {
	log_puts "ALL" "find_value"
	send $host $port "FIND_VALUE $s $key"
	after 30000 [list str_find_value $s "TIMEOUT" 0]
}

# strategies - process is a state START REQ DONE FAIL

proc str_create {req host port key value} {
	log_puts "ALL" "str_create"
	if { $host == "" || $port == "" } {
		log_puts "ERR" "str_create empty host $host or port $port"
		return
	}
	if { ($host == "127.0.0.1" || $host == "localhost") && $port == $::options(myport) && $::options(run_i2p) != 1 } {
		log_puts "ERR" "str_create can't send to myself host $host port $port"
		return
	}
	if { $::cur(i2p,dest) == $host && $::options(run_i2p) == 1 } {
		log_puts "ERR" "str_create can't send to myself host $host"
		return
	}
	set s [clock microseconds]
	if { $req == "PING" } {
		array set ::p [list "$s,req" "$req" "$s,host" "$host" "$s,port" "$port" "$s,key" "$key" "$s,value" "$value" "$s,state" "START" "$s,ttl" "6"]
	} elseif { $req == "STORE" } {
		array set ::p [list "$s,req" "$req" "$s,host" "$host" "$s,port" "$port" "$s,key" "$key" "$s,value" "$value" "$s,state" "START" "$s,ttl" "6"]
	} elseif { $req == "FIND_NODE" } {
		array set ::p [list "$s,req" "$req" "$s,host" "$host" "$s,port" "$port" "$s,key" "$key" "$s,value" "$value" "$s,state" "START" "$s,ttl" "6"]
	} elseif { $req == "FIND_VALUE" } {
		array set ::p [list "$s,req" "$req" "$s,host" "$host" "$s,port" "$port" "$s,key" "$key" "$s,value" "$value" "$s,state" "START" "$s,ttl" "6"]
	} else {
		array set ::p [list "$s,req" "$req" "$s,host" "$host" "$s,port" "$port" "$s,key" "$key" "$s,value" "$value" "$s,state" "ERROR" "$s,ttl" "6"]
		log_puts "ERR" "Unknown method for strategy creation"
	}
	return $s
}

proc str_start {s} {
	log_puts "ALL" "str_start"
	if { $s == "" } {
		log_puts "ERR" "no s"
		return
	}
	if { $::p($s,state) != "START" } {
		log_puts "ERR" "can't START in state: "
		log_puts "ERR" $::p($s,state)
		return -1
	}
	if { $::p($s,req) == "PING" } {
		ping $s $::p($s,host) $::p($s,port)
		array set ::p [list "$s,state" "REQ" "$s,start" [clock microseconds] "$s,change" [clock microseconds]]
	} elseif { $::p($s,req) == "STORE" } {
		store $s $::p($s,host) $::p($s,port) $::p($s,key) $::p($s,value)
		array set ::p [list "$s,state" "REQ" "$s,start" [clock microseconds] "$s,change" [clock microseconds]]
	} elseif { $::p($s,req) == "FIND_NODE" } {
		find_node $s $::p($s,host) $::p($s,port) $::p($s,key)
		array set ::p [list "$s,state" "REQ" "$s,start" [clock microseconds] "$s,change" [clock microseconds]]
	} elseif { $::p($s,req) == "FIND_VALUE" } {
		find_value $s $::p($s,host) $::p($s,port) $::p($s,key)
		array set ::p [list "$s,state" "REQ" "$s,start" [clock microseconds] "$s,change" [clock microseconds]]
	} else {
		array set ::p [list "$s,state" "ERROR" "$s,start" [clock microseconds] "$s,change" [clock microseconds]]
		log_puts "ERR" "Unknown method for strategy start"	
	}
}

proc req_ping {f s} {
	send [lindex [split $f { }] 0] [lindex [split $f { }] 1] [list "RES" $s "OK" $::me(pubkey)]
	return
}

proc req_store {f s r a} {
	#log_puts "ALL" "store value r=$r a=$a"
	array set ::valuestore [list "$r" $a]
	array set ::valuestore [list $r,[expr "[clock microseconds]%64"] $a]
	send [lindex [split $f { }] 0] [lindex [split $f { }] 1] [list "RES" $s "OK"]
	after 200 check_waitvalues
	return
}

proc req_find_node {f s r} {
	set res {}
	foreach {key value} [array get ::peerstore "$r*"] {
		if { $value == "" } {
			continue
		}
		lappend res $value
	}
	#log_puts "ALL" "sortedres [lrange [lsort -decreasing $res] 0 8]"
	set lenres [llength $res]
	if { $lenres > 7 } {
		set $lenres 7
	}
	if { $lenres > 0 } {
		log_puts "ALL" "FIND_NODE"
		set sres [lrange [lsort -decreasing $res] 0 8]
		send [lindex [split $f { }] 0] [lindex [split $f { }] 1] [list "RES" $s "OK" [lindex $sres [expr "[clock microseconds]%[llength $sres]"]] ]
		#log_puts "ALL" [list "RES" $s "OK" [lindex [array get ::peerstore "$r"] 1]]
		#send [lindex [split $f { }] 0] [lindex [split $f { }] 1] [list "RES" $s "OK" [lindex [array get ::peerstore "$r"] 1]]
	} else {
		log_puts "ALL" "FIND_NODE"
		#log_puts "ALL" [list "RES" $s "PEERS" {*}[closest_in_buckets $r 4]]
		send [lindex [split $f { }] 0] [lindex [split $f { }] 1] [list "RES" $s "PEERS" {*}[closest_in_buckets $r 4]]
	}
	return
}

proc req_find_value {f s r} {
	set stores [ list ::contacts ::groups ::headers ::sources]
	set res {}
	foreach store $stores {
		foreach {key value} [array get $store "$r*"] {
			if { $value == "" } {
				continue
			}
			lappend res $value
		}
	}
	#log_puts "ALL" "sortedres [lrange [lsort -decreasing $res] 0 8]"
	set lenres [llength $res]
	if { $lenres > 8 } {
		set $lenres 8
	}
	if { $lenres > 0 } {
		log_puts "ALL" "FIND VALUE"
		set sres [lrange [lsort -decreasing $res] 0 7]
		#send [lindex [split $f { }] 0] [lindex [split $f { }] 1] [list "RES" $s "OK" "$sres" ]
		#foreach val $sres {
		#	send [lindex [split $f { }] 0] [lindex [split $f { }] 1] [list "RES" $s "OK" "$val" ]
		#}
		log_puts "ALL" "findval send res $sres"
		send [lindex [split $f { }] 0] [lindex [split $f { }] 1] [list "RES" $s "OK" [lindex $sres [expr "[clock microseconds]%[llength $sres]"]]]
		#puts [list "RES" $s "OK" [lindex [array get ::valuestore "$r"] 1]]
		#send [lindex [split $f { }] 0] [lindex [split $f { }] 1] [list "RES" $s "OK" [lindex [array get ::valuestore "$r"] 1]]
	} else {
		log_puts "ERR" "not found value, sending peers"
		log_puts "ERR" "FIND_VALUE"
		#puts [list "findval peers" "RES" $s "PEERS" {*}[closest_in_buckets $r 4]]
		send [lindex [split $f { }] 0] [lindex [split $f { }] 1] [list "RES" $s "PEERS" {*}[closest_in_buckets $r 4]]
	}
	return
}

proc req_sol {f r a} {
	array set ::peerstore [list $r "$r:[lindex [split $f { }] 0]:[lindex [split $f { }] 1]:[lindex $a 0]"]
	log_puts "ALL" "add to peerstore"
	puts [list $r "$r:[lindex [split $f { }] 0]:[lindex [split $f { }] 1]:[lindex $a 0]"]
	# commented, because check_peers does that
	# uncommented because it doesn't
	after 200 check_peers
	#put_to_buckets $s
	# set fields
	puts [list $r "$r:[lindex [split $f { }] 0]:[lindex [split $f { }] 1]:[lindex $a 0]"]
	set ::formhost [lindex [split $f { }] 0]
	set ::formport [lindex [split $f { }] 1] 
	set ::formkey $r
	return
}

proc req_head {f s r a tcp} {
	log_puts "ALL" "req_head"
	#log_puts "ALL" "got HEAD s $s r $r a $a"
	if { $s != 0 } {
		log_puts "ERR" "plain HEAD $s answer $r"
		return
	}

	if { $r == "PWT" } {
		set sc [ml_screen p [lindex $a 0] [lindex [split $f { }] 0] [lindex [split $f { }] 1]]
	} elseif { $r == "PSH" } {
		set sc [ml_screen p [lindex $a 0] [lindex [split $f { }] 0] [lindex [split $f { }] 1]]
	} elseif { $r == "PDC" } {
		set sc [ml_screen p [lindex $a 0] [lindex [split $f { }] 0] [lindex [split $f { }] 1]]
	} elseif { $r == "DIG" } {
		set sc [ml_screen g [lindex $a 0] [lindex [split $f { }] 0] [lindex [split $f { }] 1]]
	} elseif { $r == "GDC" } {
		set sc [ml_screen g [lindex $a 0] [lindex [split $f { }] 0] [lindex [split $f { }] 1]]
	} else {
		set sc 0
	}
	if { $sc != 0 } {
		log_puts "ERR" "screened out $f"
		return
	}

	set ret {}
	if { $r == "CNT" } {
		set ret [lrange [ml_get_hdrs 31 mlhdr $a] start end-1]
	} elseif { $r == "SRC" } {
		set ret [ml_get_srcs $a]
		log_puts "ALL" "ml_get_srcs $a -> $ret"
	} elseif { $r == "SIG" } {
		#set ret [array get ::group_to_sig "$a,*"]
		#log_puts "ALL" "ml sig $a -> $ret"
	} elseif { $r == "DIG" || $r == "PWT" } {
		switch $r {
			"DIG" {
				set p "mlhdr"	
			}
			"PWT" {
				set p "mlphdr"
			}
		}
		set g [lindex $a 0]
		set ret [ml_get_hdrs 31 $p $a]
		log_puts "ALL" "ml_get_hdrs $p $a -> $ret"
	} elseif { $r == "EML" } {
		set ret {}
		foreach hash $a {
			set ml [wrap [ml_get_eml all $hash]]
			if { $ml == "" || $ml == -1 } {	
				continue
			}
			lappend ret $ml 
		}
	} elseif { $r == "GDC" || $r == "PDC" } {
		switch $r {
		"GDC" { set p "mlhdr" }
		"PDC" { set p "mlphdr" }
		}
		set id [lindex $a 0]
		set hash [lindex $a 1]
		set t [lindex $a 2]
		set ret [list $id $hash $t]
		foreach {k v} [doc_readall $p $id $hash $t] {
			lappend ret $k
		}
		log_puts "ALL" "$r ret $ret"
	} elseif { $r == "GDE" || $r == "PDE" } {
		switch $r {
		"GDE" { set p "mlhdr" }
		"PDE" { set p "mlphdr" }
		}
		set id [lindex $a 0]
		set hash [lindex $a 1]
		set t [lindex $a 2]
		set keys [lrange $a 3 end]
		set ret [list $id $hash $t]	
		foreach k $keys {
			lappend ret $k [doc_read $p $id $hash $t $k]
		}
		log_puts "ALL" "$r ret $ret"
	} elseif { $r == "PSH" } {
		set ret [list p $::me(id) [wrap [array get ::file_by_hash]]]
	} else {
		return
	}
	if { [llength $ret] > 0 } {
		lappend sr [ml_genc {} [lindex [split $f { }] 0] [lindex [split $f { }] 1] "HEAD 1 OK" $tcp]
		if { $r != "EML" } {
			lappend sr [ml_genc {} [lindex [split $f { }] 0] [lindex [split $f { }] 1] "MAIL 0 $r $ret" $tcp]
		} else {
			foreach rr $ret {
				lappend sr [ml_genc {} [lindex [split $f { }] 0] [lindex [split $f { }] 1] "MAIL 0 $r $rr" $tcp]
			}
		}
	} else {
		lappend sr [ml_genc {} [lindex [split $f { }] 0] [lindex [split $f { }] 1] "HEAD 1 FAIL" $tcp]
	}
	log_puts "ALL" "HEAD SR $sr"
	return $sr
}

proc req_mail {f s r a tcp} {
	log_puts "ALL" "req_mail"
	log_puts "ALL" "got MAIL s $s r $r a $a"
	if { $s != 0 } {
		log_puts "ERR" "plain MAIL $s answer $r"
		return
	}

	if { $r != "EML" && $r != "SIG" && ($r == "PWT" || $r == "PSH" || $r == "PDC") } {
		set sc [ml_screen p [lindex $a 0] [lindex [split $f { }] 0] [lindex [split $f { }] 1]]
	} elseif { $r != "EML" && $r != "SIG" && $r != "PWT" && $r != "PSH" } {
		set sc [ml_screen g [lindex $a 0] [lindex [split $f { }] 0] [lindex [split $f { }] 1]]
	} else {
		set sc 0
	}
	if { $sc != 0 } {
		log_puts "ERR" "screened out $f"
		return
	}

	if { $r == "CNT" } {
		set ::ml_cnt_grp [list [lindex $a 0],[clock seconds] [lindex $a 1]]
	} elseif { $r == "SRC" } {
		set g [lindex $a 0]
		set n [lindex $a 1]
		set srcs [lrange $a 2 end]
		log_puts "ALL" "SRC g $g n $n srcs $srcs"
		sc_get_contacts $srcs
		sc_get_contacts [prep_contact_keys $srcs]
		ml_add_srcs $g $srcs
	} elseif { $r == "SIG" } {
		#log_puts "ALL" "ml get sigs"
		#foreach {key val} $a {
		#	if { [array get ::group_to_sig $key] == "" } {
		#		if { [ml_check_sig g [lindex $key 0] [lindex $key 1] 1] != 0 } {
		#			array set ::group_to_sig [list $key $val]
		#		}
		#	}
		#}
	} elseif { $r == "DIG" || $r == "PWT" } {
		switch $r {
			"DIG" {
				set p "mlhdr"	
			}
			"PWT" {
				set p "mlphdr"
			}
		}
		set g [lindex $a 0]
		set n [lindex $a 1]
		set hdrs [lrange $a 2 end]
		set lhdrs [lrange [ml_get_hdrs 31 $p $g] 2 end]

		log_puts "ALL" "hdrs $hdrs"

		array set tmp {}
		array set rtmp {}
		foreach hdr $hdrs {
			set h [header_to_dict $hdr]
			if { $h == "" } {
				continue
			}
			set hash [dict get $h hash]
			set tmp($hash) $hdr
		}
		foreach lhdr $lhdrs {
			set lh [header_to_dict $lhdr]
			if { $lh == "" } {
				continue
			}
			set lhash [dict get $lh hash]
			array unset tmp $lhash
			set rtmp($lhash) 1
		}
		set lhashes [array names tmp]
		set ahdrs {}
		foreach k $lhashes {
			array unset rtmp $k
			lappend ahdrs $tmp($k)
		}

		set rhashes [array names rtmp]
		set remls {}
		foreach k $rhashes {
			set ml [wrap [ml_get_eml all $k]]
			if { $ml == "" || $ml == -1 } {	
				continue
			}
			lappend remls $ml 
		}
		array unset tmp
		array unset rtmp

		log_puts "ALL" "add headers $p $g $ahdrs"
		ml_add_hdrs $p $g $ahdrs

		log_puts "ALL" "send HEAD 0 EML $lhashes"
		ml_genc {} [lindex [split $f { }] 0] [lindex [split $f { }] 1] "HEAD 0 EML $lhashes" 0

		log_puts "ALL" "send MAIL 0 EML $remls"
		ml_genc {} [lindex [split $f { }] 0] [lindex [split $f { }] 1] "MAIL 0 EML $remls" 0

		if { $p == "mlhdr" } {
			ml_showlist g $g
		} elseif { $p == "mlphdr" } {
			ml_showlist p $g
		}
	} elseif { $r == "EML" } {
		log_puts "ALL" "req_mail add eml [llength $a]"
		foreach eml $a {
			ml_add_eml all {} [unwrap $eml]
		}
	} elseif { $r == "GDC" || $r == "PDC" } {
		switch $r {
		"GDC" { set p "mlhdr" }
		"PDC" { set p "mlphdr" }
		}
		set id [lindex $a 0]
		set hash [lindex $a 1]
		set t [lindex $a 2]
		set keys [lrange $a 3 end]
		set lkeys {} 
		foreach {k v} [doc_readall $p $id $hash $t] {
			lappend lkeys $k
		}
		array set tmp ""
		array set rtmp ""
		foreach key $keys {
			set tmp($key) 1
		}
		foreach lkey $lkeys {
			array unset tmp $lkey 
			set rtmp($lkey) 1
		}
		foreach key $keys {
			array unset rtmp $key
		}
		set get_sums [list $id $hash $t] 
		set give_sums [list $id $hash $t]
		foreach {k v} [array get tmp] {
			lappend get_sums $k
		}
		foreach {k v} [array get rtmp] {
			lappend give_sums $k [doc_read $p $id $hash $t $k]
		}
		switch $r {
		"GDC" { set rr "GDE" }
		"PDC" { set rr "PDE" }
		}

		log_puts "ALL" "send HEAD 0 $rr {*}$get_sums"
		ml_genc {} [lindex [split $f { }] 0] [lindex [split $f { }] 1] [list HEAD 0 $rr {*}$get_sums] 0

		log_puts "ALL" "send MAIL 0 $rr {*}$give_sums"
		ml_genc {} [lindex [split $f { }] 0] [lindex [split $f { }] 1] [list MAIL 0 $rr {*}$give_sums] 0

	} elseif { $r == "GDE" || $r == "PDE" } {
		switch $r {
		"GDE" { set p "mlhdr" }
		"PDE" { set p "mlphdr" }
		}
		set id [lindex $a 0]
		set hash [lindex $a 1]
		set t [lindex $a 2]
		set data [lrange $a 3 end]
		foreach {k v} $data {
			doc_save $p $id $hash $t $k $v
		} 
		doc_readtree $p $id $hash
		doc_readmsgs $p $id $hash
		#set node {}
		#catch { set node $::doc($p,$id,$hash,node) }
		#doc_replay $p $id $hash $node
	} elseif { $r == "PSH" } {
		show_files {*}$a
		return $sr
	} else {
		lappend sr [ml_genc {} [lindex [split $f { }] 0] [lindex [split $f { }] 1] "MAIL 1 FAIL" $tcp]
		log_puts "ALL" "SR $sr"
		return $sr
	}
	lappend sr [ml_genc {} [lindex [split $f { }] 0] [lindex [split $f { }] 1] "MAIL 1 OK" $tcp]
	log_puts "ALL" "MAIL SR $sr"
	return $sr
}

proc req_genc {f s r a tcp} {
	log_puts "ALL" "req_genc $r"
	set dmsg {}
	catch {
	set dmsg [dec_msg $r]
	} res
	if { $dmsg == "" } {
		log_puts "ERR" "failed to decrypt $res"
		return
	}
	log_puts "ALL" "GENC f $f r $r a $a dmsg $dmsg"
	set sr [str_req $f [string trim $dmsg] $tcp]
	log_puts "ALL" "SR $sr"
	return $sr
}

proc req_phone {f s r a} {
	log_puts "ALL" "req_phone"
	if { $::options(run_i2p) == 1 } {
		audio_dialog $r $a
	}
	return
}

proc req_get {f s r a} {
	log_puts "ALL" "req_get"
	#log_puts "ALL" "plain $m $s $r $a"
	if { $s != 0 } {	
		log_puts "ERR" "plain GET $s answer $r"
		return
	}
	set piece [dl_read $r]
	if { $piece != "" } { 
		ml_genc {} [lindex [split $f { }] 0] [lindex [split $f { }] 1] "GET 1 OK" 0
		ml_genc {} [lindex [split $f { }] 0] [lindex [split $f { }] 1] "GIVE 0 $piece" 0
	} else {
		ml_genc {} [lindex [split $f { }] 0] [lindex [split $f { }] 1] "GET 1 FAIL" 0
	}
	return
}

proc req_give {f s r a} {
	log_puts "ALL" "req_give"
	#log_puts "ALL" "plain $m $s $r $a"
	if { $s != 0 } {	
		log_puts "ERR" "plain GIVE $s answer $r"
		return
	}
	set ret [dl_write $r]
	if { $ret == 0 } {
		ml_genc {} [lindex [split $f { }] 0] [lindex [split $f { }] 1] "GIVE 1 OK" 0
	} else {
		ml_genc {} [lindex [split $f { }] 0] [lindex [split $f { }] 1] "GIVE 1 FAIL" 0
	}
	return
}

proc str_req {f p tcp} {	
	log_puts "ALL" "str_req $f $p"
	#log_puts "ALL" "STR_REQ $p"
	set m [lindex $p 0]
	set s [lindex $p 1]
	set r [lindex $p 2]
	set a [lrange $p 3 end]
	set start [clock microseconds]
	set sr {}
	if { $m == "PING" } {
		req_ping $f $s
		return
	} elseif { $m == "STORE" } {
		req_store $f $s $r $a
		return
	} elseif { $m == "FIND_NODE" } {
		req_find_node $f $s $r
		return
	} elseif { $m == "FIND_VALUE" } {
		req_find_value $f $s $r
		return
	} elseif { $m == "SOL" } {
		req_sol $f $r $a
		return
	} elseif { $m == "CHAT" } {
		gchat_recv chat [lindex [split $f { }] 0] [lindex [split $f { }] 1] $r
		return
	} elseif { $m == "GCHAT" } {
		gchat_recv gchat [lindex [split $f { }] 0] [lindex [split $f { }] 1] $r
		return
	} elseif { $m == "GENC" } {
		set ret [req_genc $f $s $r $a $tcp]
		return $ret
	} elseif { $m == "PHONE" } {
		req_phone $f $s $r $a
		return
	} elseif { $m == "GET" } {
		req_get $f $s $r $a
		return
	} elseif { $m == "GIVE" } {
		req_give $f $s $r $a
		return
	} elseif { $m == "HEAD" } {
		set ret [req_head $f $s $r $a $tcp]
		return $ret
	} elseif { $m == "MAIL" } {	
		set ret [req_mail $f $s $r $a $tcp]
		return $ret
	}

	if { [llength [array get ::p "$s*"]] == 0 } {
		log_puts "ERR" "no session str_req f:$f p:$p host:[lindex [split $f { }] 0] port:[lindex [split $f { }] 1] m:$m s:$s r:$r a:$a"
		log_puts "ERR" "no session"
		return -1
	} 	
	if { $s == "" } {
		log_puts "ERR" "no s, full message is $f $p"
		return
	}

	if { $::p($s,state) != "REQ" } {
		log_puts "ERR" "can't do REQ in state: "
		log_puts "ERR" $::p($s,state)
		return -1
	}
	
	set ttl $::p($s,ttl)
	if { $ttl <= 0 } {
		array set ::p [list "$s,state" "DONE" "$s,change" [clock microseconds]]
		return
	} else {
		array set ::ttl [list "$s,ttl" [expr "$ttl-1"]]
	}

	log_puts "ALL" "strategy $::p($s,req)"
	log_puts "ALL" "fields [array get ::p "$s,*"]"
	log_puts "ALL" "args m->$m s->$s r->$r a->$a"
	if { $::p($s,req) == "PING" } {
		str_ping $s $r $a
	} elseif { $::p($s,req) == "STORE" } {
		str_store $s $r
	} elseif { $::p($s,req) == "FIND_NODE" } {
		str_find_node $s $r $a
	} elseif { $::p($s,req) == "FIND_VALUE" } {
		str_find_value $s $r $a
	} else {
		log_puts "ERR" "Unknown strategy in str_req end"
	}	
	return
}

proc str_ping {s r a} {
	log_puts "ALL" "str_ping"
	if { $r == "OK" } { 
		log_puts "ALL" "PING $s $r $a"
		array set ::p [list "$s,state" "DONE" "$s,change" [clock microseconds]]
		set k [crypto_cksum [unwrap $a]] 
		if { $k != $::me(id) && $a != "" && $k == $::p($s,key) } {
			set peer "$k:$::p($s,host):$::p($s,port):$a"
			log_puts "ALL" "put to peerstore [list $k $peer]"
			array set ::peerstore [list $k $peer]
			sol $::p($s,host) $::p($s,port)
			put_to_buckets $k
		}
	} else {
		if { [lindex [array get ::p "$s,state" ] 1] == "DONE" } {
			log_puts "ERR" "already done"
			return
		}
		log_puts "ALL" "PING $s $r FAIL"
		array set ::p [list "$s,state" "FAIL" "$s,change" [clock microseconds]]
		remove_from_buckets $::p($s,key)
	}
	after 200 check_peers
}

proc str_store {s r} {
	log_puts "ALL" "str_store"
	if { $r == "OK" } {
		array set ::p [list "$s,state" "DONE" "$s,change" [clock microseconds]]
		#log_puts "ALL" "$s stored $r"
		after 10000 [list array unset ::p "$s,*"]
	}	else {
		if { [lindex [array get ::p "$s,state" ] 1] == "DONE" } {
			return
		}
		array set ::p [list "$s,state" "FAIL" "$s,change" [clock microseconds]]
	}
}

proc str_find_node {s r a} {
	log_puts "ALL" "str_find_node"
	if { $r == "PEERS" && $a != {} } {
		#log_puts "ALL" "findnode peers $a"
		foreach item [split [concat $a]] {
			#log_puts "ALL" "findnode peer $item"
			set peer [split $item {:}]
			array set ::peerstore [list [lindex $peer 0] $item]
			find_node $s [lindex $peer 1] [lindex $peer 2] $::p($s,key)
		}
		array set ::p [list "$s,change" [clock microseconds]]
	} elseif { $r == "OK" } {
		array set ::peerstore [list $::p($s,key) $a]
		array set ::p [list "$s,state" "DONE" "$s,change" [clock microseconds]]
	} else {
		if { [lindex [array get ::p "$s,state" ] 1] == "DONE" } {
			return
		}
		array set ::p [list "$s,state" "FAIL" "$s,change" [clock microseconds]]
	}
	after 200 check_peers
}

proc str_find_value {s r a} {
	log_puts "ALL" "str_find_value"
	if { $r == "PEERS" && $a != {} } {
		#log_puts "ALL" "findval peers $a"
		foreach item [split [concat $a]] {
			#log_puts "ALL" "findval peer $item"
			set peer [split $item {:}]
			array set ::peerstore [list [lindex $peer 0] $item]
			find_value $s [lindex $peer 1] [lindex $peer 2] $::p($s,key)
		}
		array set ::p [list "$s,change" [clock microseconds]]
		after 200 check_peers
	} elseif { $r == "OK" } {
		array set ::valuestore [list $::p($s,key) $a]
		array set ::valuestore [list $::p($s,key),[expr "[clock microseconds]%64"] $a]
		array set ::p [list "$s,state" "DONE" "$s,change" [clock microseconds]]
		after 200 check_waitvalues
	} else {
		if { [lindex [array get ::p "$s,state" ] 1] == "DONE" } {
			return
		}
		array set ::p [list "$s,state" "FAIL" "$s,change" [clock microseconds]]
	}
}

proc elapsed_s {p since s} {
	set ret {}
	set now [clock seconds]
	if { $now <= $since } {
		return
	}
	set elapsed [expr {$now-$since}]
	if { $elapsed < 3600 } {
		return "$p recent"
	}
	foreach div {86400 3600 60} mod {0 24 50} name {day hr min} {
		set n [expr {$elapsed/$div}]
		if { $mod > 0 } { set n [expr {$n%$mod}] }
		if { $n > 1 } { 
			lappend ret "$n ${name}s"
		} elseif { $n == 1 } {
			lappend ret "$n $name"
		}
	}
	return "$p [string trim [join $ret]] $s"
}

proc ml_showmsg {w hdr} {
	array unset ::dlaction_by_hash "*"
	if { ![winfo exists $w] } {
		log_puts "ERR" "ml_showmsg no window"
		return
	}
	$w delete 1.0 end
	if { $hdr == "" } {
		log_puts "ERR" "ml_showmsg no header"
		return
	}
	set h [header_to_dict $hdr]
	if { $h == "" } {
		log_puts "ERR" "ml_showmsg bad header"	
		return
	}

	set hash [dict get $h hash]
	set type [dict get $h type]

	set body {}
	set ebody {}
	if { $type == "p" && [dict get $h to] == $::me(id) } {
		set body [ml_get_eml dec $hash]
		if { $body == {} || $body == -1 } {
			log_puts "ERR" "ml_showmsg no decrypted message"	
			set ebody [ml_get_eml all $hash]
		}
		if { $ebody != {} && $ebody != -1 } {
			log_puts "ERR" "ml_showmsg decrypting"	
			set symkey_e [unwrap [lindex [split $ebody {,}] 0]]
			log_puts "ERR" "ml_showmsg symkey_e [binary encode hex $symkey_e]"	
			set symkey [crypto_dec -hex -priv $symkey_e $::me(key)]
			log_puts "ERR" "ml_showmsg symkey [binary encode hex $symkey]"	
			set body_e [unwrap [lindex [split $ebody {,}] 1]]
			log_puts "ERR" "ml_showmsg body_e [binary encode hex $body_e]"	
			set nil_block [string repeat \0 16]

			set body [crypto_symdec $body_e $symkey $nil_block]
		}
		if { $ebody != {} && $ebody != -1 && $body != {} && $body != -1 } {
			log_puts "ERR" "ml_showmsg add decrypted"	
			ml_add_eml dec $hash $body
		}
		set comment "personal to me"
	} elseif { $type == "p" && ([dict get $h kfrom] == [crypto_exp_pub $::me(key)] || [dict get $h kfrom] == {}) } {
		set body [ml_get_eml plain $hash]
		set comment "personal by me"
	} elseif { $type == "g" } {
		set body [ml_get_eml all $hash]
		set comment "group message"
	} elseif { $type == "gc" } {
		set body [ml_get_eml all $hash]
		set comment "group control message"
	} elseif { $type == "d" } {
		set body [ml_get_eml all $hash]
		set gid [dict get $h group]
		set comment "group document message"
		append body "GDC <mlhdr|$gid|$hash>"
	} else {
		set body "oopsie"
		set comment "oopsie"
	}

	if { $body == -1 || $body == "" } {
		log_puts "ALL" "ml_showmsg $hash empty body, try to fetch"
		if { $type == "g" || $type == "gc" || $type == "gd" } {
			set gid [dict get $h group]
			log_puts "ALL" "ml_showmsg $hash ask group $gid"
			set src [lsort -unique -stride 2 -index end [array get ::sources "$gid*"]]
			foreach {key val} $src {
				ml_genc $val {} {} "HEAD 0 EML $hash" 0
			}
		} elseif { $type == "p" } {
			set peerid [dict get $h from]
			log_puts "ALL" "ml_showmsg $hash ask peer $peerid"
			ml_genc $peerid {} {} "HEAD 0 EML $hash" 0
		}
		return
	}
	log_puts "ALL" "ml_showmsg $hash loaded body"

	set body [encoding convertfrom utf-8 $body]	
	set lines [split $body "\n"]
	set from [lrange [lindex $lines 0] 1 end]
	set to [lrange [lindex $lines 1] 1 end]
	set subject [lrange [lindex $lines 2] 1 end]
	set epoch [lrange [lindex $lines 3] 1 end]
	set bodylines [lrange $lines 5 end]
	$w tag configure red -foreground {#c06060} 
	$w tag configure cyan -foreground {#6090c0}
	$w tag configure blue -foreground {#6060c0}
	$w tag configure yellow -foreground {#c09060}
	$w tag configure magenta -foreground {#c060c0}
	$w tag configure hide -elide true
	$w tag configure headerlink -foreground {#6060c0} -underline true
	$w tag configure grouplink -foreground {#6060c0} -underline true
	$w tag configure filelink -foreground {#6060c0} -underline true
	$w tag configure attachlink -foreground {#c06060} -underline true
	$w tag configure gr_scheme -foreground {#c06060} -underline true
	$w tag configure mysm -foreground {#60c060} -underline true
	$w tag configure inline_image -foreground {#c060c0} -underline true
	$w tag configure imagelink -foreground {#c060c0} -underline true
	$w tag configure inline_voice -foreground {#c060c0} -underline true
	$w tag configure voicelink -foreground {#c060c0} -underline true
	$w tag configure doclink -foreground {#c09060} -underline true
	#$w insert end "Comment: $comment\n" {red}
	#$w insert end "   Sent: [clock format [dict get $h epoch] -format {%Y-%m-%d %H:%M:%S}]\n" {red}
	$w insert end "[::msgcat::mc m_comment]: $comment ; [clock format [dict get $h epoch] -format {%Y-%m-%d %H:%M:%S}][elapsed_s {,} [dict get $h epoch] {ago}]\n" {red}
	$w insert end "[::msgcat::mc m_from]: $from\n" {cyan m_from}
	#$w insert end "[::msgcat::mc m_to]: $to\n" {cyan}
	$w insert end "[::msgcat::mc m_subject]: $subject\n" {cyan}
	$w insert end "\n"

	log_puts "ALL" "ml_showmsg $hash displayed headers"

	disp_text $w $bodylines
}

proc disp_text {w bodylines} {
	set att 0
	set attdata {}
	foreach line $bodylines {
		disp_line $w $line
	}
	$w insert end "\n"
}

proc disp_line {w line} {
		set first [lindex [split [string range $line 0 20] { }] 0]
		switch $first {
		"FILE"  {
			set tag {blue filelink}
		}
		"LREC"  {
			set tag {magenta voicelink}
		}
		"LIMG" {
			if { $::options(linked_images) == 1 } {
				set req [lindex [split $line {<>}] 1]
				set d [dl_reqdict $req]
				set name [dict get $d filename]
				set ext [lindex [split $name {.}] end]
				if { $ext == {png} || $ext == {PNG} } {
					log_puts "ALL" "image req $req"
					log_puts "ALL" "image d $d"
					log_puts "ALL" "image name $name"
					set hash [dict get $d filehash]
					dl_add_image $w $req {}
				}
			}
			set tag {magenta imagelink}
		}
		"IMG" {
			set sp [string first "<" $line]
			set ep [string last ">" $line]
			set imgdata [binary decode base64 [string range $line $sp+1 $ep-1]]
			insert_image $w [$w index end] "Image" $imgdata 
			set tag {}
			return
		}
		"REC" {
			set sp [string first {<} $line]
			set ep [string first {>} $line]
			set prefix [string range $line 0 [expr {$sp-1}]]
			#$w insert end "Some voice record, don't have a canvas player\n" {}
			$w insert end "$line " {hide inline_voice}
			$w insert end "$prefix<...>\n" {inline_voice}
			set tag {}
			return
		}
		"GR" {
			$w insert end "$line " {hide gr_scheme} 
			set nline "GR scheme\n"
			set line $nline
			set tag {red gr_scheme}
		}
		"MYSM" {
			$w insert end "$line " {hide mysm} 
			set nline "MYSM program\n"
			set line $nline
			set tag {red mysm}
		}
		"HDR" {
			$w insert end "$line " {hide headerlink} 
			#set nline "[lrange $line 2 end] hash://[lindex [split [lindex $line 1] {:}] 0]\n"
			set nline "[lindex $line 0] [lrange $line 2 end]\n"
			set line $nline
			set tag {blue headerlink}
		}
		"GRP" {
			$w insert end "$line " {hide grouplink} 
			#set nline "[lrange $line 2 end] group://[lindex [split [lindex $line 1] {:}] 0]\n"
			set nline "[lindex $line 0] [lrange $line 2 end]\n"
			set line $nline
			set tag {blue grouplink}
		}
		"ATTACH" {
			$w insert end "$line " {hide attachlink}
			set nline "[string trim [lindex [split [string range $line 0 250] {()}] 0]]\n"
			set line $nline
			set tag {red attachlink}
		}
		"GDC" {
			set tag {yellow doclink}
		}
		">" {
			set tag {magenta}
		}
		default {
			set tag {} 
		}
		}
		$w insert end "[string range $line 0 1000]\n" $tag
}

# command for personal mail is PWT for headers, usual EML to ask with hashes
proc ml_personhead {contact} {
	if { $contact == {} } {
		return
	}
	foreach {hash con} [array get ::buddies] {
		if { $con == $contact } {
			gchat_send chat $hash {} [clock microseconds] "RENEW" "ask"
			update_buddy $hash
		}
	}
	set c [contact_to_dict $contact]
	log_puts "ALL" "ml_personhead c $c"
	set peerid [dict get $c peerid]
	# find if we have this peer in store
	set foundpeers [lsort -unique -stride 2 -index end [array get ::peerstore "$peerid*"]]
	# if not, ask DHT
	if { [llength $foundpeers] == 0 } {
		set peers [lsort -unique [closest_in_buckets $peerid 4]]
		#log_puts "ALL" "ml_personhead mail peers $peers"
		foreach peer $peers {
			set speer [split $peer {:}]
			#log_puts "ALL" "ml_personhead asking $peer for our mail contact"
			if {[llength $speer] == 4} {
				#log_puts "ALL" "ml_personhead $speer ask him for $peerid"
				after idle [list str_start [str_create FIND_NODE [lindex $speer 1] [lindex $speer 2] $peerid none]]
			} else {
				log_puts "ERR" "ml_personhead $speer invalid peer"
			}
		}
	# send HEAD to each found peer 
	} else {
		foreach {key peer} $foundpeers {
			#log_puts "ALL" "ml_personhead send key $key peer $peer"
			set speer [split $peer {:}]
			#send [lindex $speer 1] [lindex $speer 2] "HEAD 0 PWT ${::me(id)}"
			after idle [list ml_genc [lindex $speer 0] [lindex $speer 1] [lindex $speer 2] "HEAD 0 PWT ${::me(id)}" 0]
		}
	}
	after 200 [list ml_showlist p $peerid]
}

proc ml_personbrowse {contact} {
	set c [contact_to_dict $contact]
	set peerid [dict get $c peerid]
	set foundpeers [lsort -unique -stride 2 -index end [array get ::peerstore "$peerid*"]]
	if { [llength $foundpeers] == 0 } {
		set peers [lsort -unique [closest_in_buckets $peerid 4]]
		#log_puts "ALL" "ml_personhead mail peers $peers"
		foreach peer $peers {
			set speer [split $peer {:}]
			#log_puts "ALL" "ml_personhead asking $peer for our mail contact"
			if {[llength $speer] == 4} {
				#log_puts "ALL" "ml_personhead $speer ask him for $peerid"
				str_start [str_create FIND_NODE [lindex $speer 1] [lindex $speer 2] $peerid none]
			} else {
				log_puts "ERR" "ml_personhead $speer invalid peer"
			}
		}
	} else {
		foreach {key peer} $foundpeers {
			#log_puts "ALL" "ml_personhead send key $key peer $peer"
			set speer [split $peer {:}]
			#send [lindex $speer 1] [lindex $speer 2] "HEAD 0 PWT ${::me(id)}"
			ml_genc [lindex $speer 0] [lindex $speer 1] [lindex $speer 2] "HEAD 0 PSH ${::me(id)}" 0
		}
	}
}

proc ml_genc {peerid host port msg response} {
	log_puts "ALL" "ml_genc peerid $peerid host $host port $port"
	set host [string map {{localhost} {127.0.0.1}} $host]
	#log_puts "ALL" "ml_genc peerid $peerid host $host port $port msg [string range $msg 0 127]"
	set pubkey {}
	if { $peerid == {} } {	
		log_puts "ALL" "ml_genc empty peerid"
		set peers [lsort -unique [lsearch -all -inline [array get ::peerstore] "*:$host:$port:*"]]
		log_puts "ALL" "ml_genc peers $peers"
		set len [llength $peers]
		log_puts "ALL" "ml_genc len $len"
		if { $len != 0 } {
			set in [expr "[clock microseconds]%$len"]
			set peerid [lindex [split [lindex $peers $in] {:}] 0]
			set pubkey [unwrap [lindex [split [lindex $peers $in] {:}] 3]]
		}
	} elseif { $host == {} && $port == {} && $response != 1 } {
		log_puts "ALL" "ml_genc find host and port by peerid $peerid"
		set peers [lsort -unique [lsearch -all -inline [array get ::peerstore] "$peerid:*:*:*"]]
		set len [llength $peers]
		if { $len != 0 } {
			set in [expr "[clock microseconds]%$len"]
			set host [lindex [split [lindex $peers $in] {:}] 1]
			set port [lindex [split [lindex $peers $in] {:}] 2]
			set pubkey [unwrap [lindex [split [lindex $peers $in] {:}] 3]]
			log_puts "ALL" "ml_genc by peerid found h $host and p $port"
		}
	}
	if { $pubkey == "" || $pubkey == "?" } {
		log_puts "ALL" "ml_genc empty pubkey, get from peerstore"
		set pubkey [unwrap [lindex [split [lindex [array get ::peerstore $peerid] 1] {:}] 3]]
	}
	log_puts "ALL" "ml_genc peerid $peerid"
	if { $pubkey == "" || $pubkey == "?" } {
		set contacts [lsearch -all -inline [array get ::contacts] "*$peerid*"]
		log_puts "ALL" "ml_genc contacts $contacts"
		if { $contacts == {} } {
			sc_get_contacts $peerid
		}
		set contact {}
		set c {}
		foreach ccontact $contacts {
			set cc [contact_to_dict $ccontact]
			if { $cc != "" } {	
				set pubkey [dict get $cc pubkey]
				if { $pubkey == "?" } {
					sc_get_contacts $peerid
					continue
				}
				set c $cc
				set contact $ccontact
			} else {
				continue
			}
		}
		#log_puts "ALL" "ml_genc contact $contact"
		#log_puts "ALL" "ml_genc c $c"
	}
	log_puts "ALL" "ml_genc peerid $peerid sum [crypto_cksum $pubkey]"
	log_puts "ALL" "ml_genc pubkey $pubkey"
	if { $pubkey != "" && $peerid != "" && [crypto_cksum $pubkey] == $peerid } {
		log_puts "ALL" "ml_genc encrypting msg"
		set ids [lsort [list $::me(id) $peerid]]
		set hash "g-[lindex $ids 0]-[lindex $ids 1]"
		set emsg {}
		if { [llength [array names ::keys "mysymkey_$hash"]] > 0 && $response == 1} {
			catch { set emsg [enc_msg $pubkey $msg 0 $hash] } res
		} else {
			catch { set emsg [enc_msg $pubkey $msg 1 $hash] } res
		}
		if { $emsg == "" } {
			log_puts "ERR" "ml_genc emsg failed $res"
			return
		} else {
			log_puts "ALL" "ml_genc emsg succeeded"
		}
		if { $response != 1 } { 
			log_puts "ALL" "ml_genc send $host $port 0"
			array unset ::tcp_fail "$host,$port"
			send $host $port "GENC 0 $emsg"
		} else {
			log_puts "ALL" "ml_genc respond 1"
			return "GENC 0 $emsg"
		}
	} elseif { $::options(plain_allowed) == 1 } {
		log_puts "ALL" "ml_genc sending plain msg"
		if { $response != 1 } {
			array unset ::tcp_fail "$host,$port"
			send $host $port $msg
		} else {
			return $msg
		}
	} else {
		log_puts "ERR" "ml_genc can't send"
		#sc_get_contacts [prep_contact_keys $peerid]
		#log_puts "ALL" "ml_genc can't send contacts $contacts contact $contact c $c pubkey $pubkey peerid $peerid"
	}
}

proc ml_grouphead {group} {
	log_puts "ALL" "ml_grouphead start"
	#set start [clock microseconds]
	set g [ml_groupdict $group]
	set gid [dict get $g gid]
	set sid [wrap "${::me(nickname)}:${::me(id)}"]
	#set end [clock microseconds]
	#log_puts "ALL" "ml_grouphead timemltostart [expr {$end-$start}]"
	#set start [clock microseconds]
	gchat_send gchat $gid {} [clock microseconds] "RENEW" "ask"
	#set end [clock microseconds]
	#log_puts "ALL" "ml_grouphead timemlsendrenew [expr {$end-$start}]"
	set gpeerid [dict get $g peerid]
	#set start [clock microseconds]
	# ask gid sources for sources
	if { $::options(group_host_mode) != 1 || $gpeerid == $::me(id) } {
		set src [lsort -unique -stride 2 -index end [array get ::sources "$gid*"]]
	} else {
		set src [list $gid $gpeerid]
	}
	#set end [clock microseconds]
	#log_puts "ALL" "ml_grouphead timemlfindsources [expr {$end-$start}]"
	#log_puts "ALL" "ml_grouphead src $src"
	#set start [clock microseconds]
	set gpeers {}
	foreach {key val} $src {
		lappend gsrc $val
		foreach {pkey pval} [lsort -unique -stride 2 -index end [array get ::peerstore "$val*"]] {
			set speer [split $pval {:}]
			log_puts "ALL" "asking src peer $pkey=$pval for our mail contact"
			#send [lindex $speer 1] [lindex $speer 2] "HEAD 0 SRC $gid"
			after idle [list ml_genc [lindex $speer 0] [lindex $speer 1] [lindex $speer 2] "HEAD 0 SRC $gid" 0]
			after idle [list ml_genc [lindex $speer 0] [lindex $speer 1] [lindex $speer 2] "MAIL 0 SRC $gid 1 ${::me(id)}" 0]
			lappend gpeers $pval
		}
	}
	#set end [clock microseconds]
	#log_puts "ALL" "ml_grouphead timemlsrc [expr {$end-$start}]"
	# ask known group sources for sources
	if { $::options(group_host_mode) != 1 || $gpeerid == $::me(id) } {
		lappend gsrc {*}[lrange [ml_get_srcs $gid] 2 end]
	} else {
		lappend gsrc $gpeerid
	}
	#set start [clock microseconds]
	#log_puts "ALL" "ml_grouphead gsrc $gsrc"
	foreach val $gsrc {
		if { [string length $val] != 64 } {
			log_puts "ALL" "strange source $val"
			continue
		}
		set peers1 [lsort -unique -stride 2 -index end [array get ::peerstore "$val*"]]
		set peers2 [closest_in_buckets $val 4]
		set peers [list {*}$peers1 {*}$peers2]
		log_puts "ALL" "chat peers $peers"
		foreach peer $peers {
			set speer [split $peer {:}]
			log_puts "ALL" "asking $peer for our group source"
			if {[llength $speer] == 4} {
				after idle [list str_start [str_create FIND_NODE [lindex $speer 1] [lindex $speer 2] $val none]]
			} else {
				log_puts "ERR" "peer too short $peer -> [llength $speer]"
			}
		}
		foreach {pkey pval} $peers {
			set speer [split $pval {:}]
			log_puts "ALL" "asking gsrc peer $pkey=$pval for our mail contact"
			#send [lindex $speer 1] [lindex $speer 2] "HEAD 0 SRC $gid"
			if { $::options(group_host_mode) != 1 || $gpeerid == $::me(id) } {
				after idle [list ml_genc [lindex $speer 0] [lindex $speer 1] [lindex $speer 2] "MAIL 0 SRC $gid 1 ${::me(id)}" 0]
			}
			#after idle [list ml_genc [lindex $speer 0] [lindex $speer 1] [lindex $speer 2] "HEAD 0 SIG $gid" 0]
			if { $::options(group_host_mode) != 1 || $gpeerid == $::me(id) } {
				after idle [list ml_genc [lindex $speer 0] [lindex $speer 1] [lindex $speer 2] "HEAD 0 SRC $gid" 0]
			}
		}
	}
	#set end [clock microseconds]
	#log_puts "ALL" "ml_grouphead timemlsig [expr {$end-$start}]"
	# ask DHT for sources, but don't wait
	if { $::options(group_host_mode) != 1 || $gpeerid == $::me(id) } {
		after idle [list sc_get_sources $gid]
	}
	#set start [clock microseconds]
	# send HEAD to each known group member
	foreach val $gsrc {
		if { [string length $val] != 64 } {
			log_puts "ALL" "wrong length gsrc $val"
			continue
		}
		foreach {pkey pval} [lsort -unique -stride 2 -index end [array get ::peerstore "$val*"]] {
			set speer [split $pval {:}]
			log_puts "ALL" "asking gsrc peer $pkey=$pval for our group"
			#send [lindex $speer 1] [lindex $speer 2] "HEAD 0 DIG $gid"
			after idle [list ml_genc [lindex $speer 0] [lindex $speer 1] [lindex $speer 2] "MAIL 0 SRC $gid 1 ${::me(id)}" 0]
			after idle [list ml_genc [lindex $speer 0] [lindex $speer 1] [lindex $speer 2] "HEAD 0 DIG $gid" 0]
		}
	}
	#set end [clock microseconds]
	#log_puts "ALL" "ml_grouphead timemldig [expr {$end-$start}]"
	# vwait for some flag to know that we've received enough answers OR 30 seconds have passed
	# fill msglist for display 
	after 200 [list ml_showlist g $gid]
	after 200 [list ml_replay $group]
	log_puts "ALL" "ml_grouphead end"
}

proc ml_showhier {hdrlist} {
	dom createDocument root root

	foreach hdr $hdrlist {
		set hash {}

		catch { set hash [dict get [header_to_dict $hdr] hash] }
		if { $hash == "" } {
			continue
		}

		ml_hierfillrec $root $hash

	}

	ml_disphierrec $root 0

}

proc ml_disphierrec {node dep} {
	foreach child [$node childNodes] {

		set name {}
		set subj {}
		set name [$child nodeName]
		set eml {}
		set hash {}

		if { $name == "name" } {
			set subj [$child nodeValue]
		} elseif { $val == "eml" } {
			set eml [$child nodeValue]
		} else {
			ml_disphierrec $child [expr "$dep+1"]
		}
		if { $subj != {} && $val != {} } {
			log_puts "ALL" "DISPHIER $node $subj [string range $eml 0 15]..."
		}
	}
}

proc ml_hierfillrec {root hash} {

	set eml [ml_get_eml all $hash]
	set bodylines [split $eml "\n"]
	set sline [lindex $eml 2]
	set pline [lindex $eml 5]
	set s [string range $pline 0 2]
	
	if { $s == "HDR" } {
		set phash [lindex $pline 1]
		ml_hierfillrec $root $phash
	}	else {
		set phash $root
	}
	
	$phash appendChild $hash
	$hash appendChild name
	$hash appendChild eml
	[[$hash firstChild] nodeValue $name]
	[[$hash lastChild] nodeValue $eml]

}

proc rule_check {group hdr rule} {
	set g [ml_groupdict $group]
	set h [header_to_dict $hdr]
	set owner [dict get $g peerid]
       	set type [dict get $h type]
       	set author [dict get $h from]
	set users [dict get $rule users]
	set mods [dict get $rule mods]

	# vars - gid, author, owner, mods, users
	if { $type == {g} && ( $users == "*" || [lsearch -all -inline -exact $users $author] != {} || $author == $owner ) } {
		return allow
	} elseif { $type == {gc} && ( $author == $owner || [lsearch -all -inline -exact $mods $author] != {} ) } {
		return allow_set
	} else {
		return deny
	}
	# return result
}

proc rule_add_user {gid peerid} {
	log_puts "ALL" "rule_add_user gid $gid peerid $peerid"
	set rule {}
	catch { set rule $::rule($gid) }
	if { $rule == {} } {
		log_puts "ERR" "rule_add_user rule empty, replay"
		ml_replay $group
	}
	set group {}
	catch { set group $::jgroups($gid) }
	if { $group == {} } {
		log_puts "ERR" "rule_add_user empty group"
		return
	}
	set owner [dict get [ml_groupdict $group] peerid]
	if { $owner != $::me(id) } {
		log_puts "ERR" "rule_add_user owner is not me"
		return
	}
	set users [dict get $::rule($gid) users]
	set mods [dict get $::rule($gid) mods]
	lappend users $peerid
	lappend mods $owner
	set users [lsort -unique $users]
	set mods [lsort -unique $mods]
	dict set ::rule($gid) users $users
	dict set ::rule($gid) mods $mods
	ml_add_srcs $gid $peerid
	ml_add_srcs $gid $owner
	rule_send $gid
	ml_replay $group
	log_puts "ALL" "rule_add_user end"
}

proc rule_check_gchat {gid from} {
	log_puts "ALL" "rule_check_gchat $gid $from"
	set group [lindex [array get ::jgroups $gid] 1]
	log_puts "ALL" "rule_check_gchat group $group"
	set hdr {}
	dict set hdr from $from
	dict set hdr nickname {}
	dict set hdr type {g}
	dict set hdr group $gid
	dict set hdr epoch [clock seconds]
	dict set hdr to $gid
	dict set hdr hash {}
	dict set hdr len {}
	dict set hdr subject {}
	dict set hdr kfrom {}
	dict set hdr kto {}
	dict set hdr gsig {}
	log_puts "ALL" "rule_check_gchat hdr dict $hdr"
	set h [dict_to_header $hdr]
	log_puts "ALL" "rule_check_gchat hdr $h"
	return [rule_check $group $h $::rule($gid)]
}

proc disp_rule {gid id} {
	log_puts "ALL" "disp_rule $gid $id"
	set group $::jgroups($gid)
	set g [ml_groupdict $group]
	set gpeerid [dict get $g peerid]
	set mods [dict get $::rule($gid) mods]
	set users [dict get $::rule($gid) users]
	set ret "([::msgcat::mc role]: "
	if { $gpeerid == $id }  {
		append ret [::msgcat::mc "owner"]
	} elseif { [lsearch -all -inline -exact $mods $id] != {} } {
		append ret [::msgcat::mc "mod"]
	} elseif { [lsearch -all -inline -exact $users $id] != {} || $users == "*" } {
		append ret [::msgcat::mc "user"]
	} else {
		append ret [::msgcat::mc "nobody"]
	}
	append ret ")"
	return $ret
}

proc ml_replay {group} {
	log_puts "ALL" "ml_replay $group enter"
	if { $group == {} } {
		log_puts "ERR" "ml_replay empty group"
		return
	}
	set gid {}
	catch { set gid [dict get [ml_groupdict $group] gid] }
	if { $gid == {} } {
		log_puts "ERR" "ml_replay empty gid"
		return
	}
	# by default anyone with signed group
	# membership request can post and read
	#
	# have no clear idea how to revoke that yet
	#
	# control rule is called with
	# group, hdr, and state variables
	# 
	# if a rule is called in mail replay,
	# if type is gc and author in mods,
	#  set new rule, allow,
	# else ignore
	#
	# if type is g and author in users,
	#  allow,
	# else ignore
	#
	# if a rule is called in group chat,
	# if author in users,
	#  allow,
	# else ignore
	#
	# set default mods
	# set default users
	# set default rule
	#
	
	# initial state
	set gpeerid [dict get [ml_groupdict $group] peerid]
	set mods {}
	lappend mods $gpeerid
	set users {}
	lappend users "*" 

	# rule is a dictionary with variables
	set rule {}
	dict set rule mods $mods
	dict set rule users $users

	# read headers
	set hdrs [lrange [ml_get_hdrs 31 mlhdr $gid] 2 end]
	set sorted {}
	foreach hdr $hdrs {
		set h [header_to_dict $hdr]
		if { $h == "" } {
			continue
		}
		set type [dict get $h type]
		if { $type == "gc" || $type == "g" } {
			lappend sorted $hdr [dict get $h epoch]
		}
	}
	set ck {}
	foreach {hdr epoch} [lsort -increasing -stride 2 -index end $sorted] {
		set h [header_to_dict $hdr]
		set hash [dict get $h hash]
		set ck [rule_check $group $hdr $rule]
		switch $ck {
			"allow" {
				#log_puts "ERR" "ml_replay shouldn't be here $hash"			
				log_puts "ALL" "ml_replay allow $hash"			
			}
			"allow_set" {
				set msg [ml_get_eml all $hash]
				log_puts "ALL" "ml_replay hash $hash msg $msg"	
				set lines [lrange [split $msg "\n"] 5 end]
				foreach line $lines {
					switch [lindex $line 0] {
						"mods" {
							set mods [lrange $line 1 end]
							lappend mods $gpeerid
							set mods [lsort -unique $mods]
							dict set rule mods $mods
						}
						"users" {
						 	set users [lrange $line 1 end]
							lappend users $gpeerid
							set users [lsearch -all -inline -not -exact [lsort -unique $users] "*"]
							dict set rule users $users
						}
					}
				}
				log_puts "ALL" "ml_replay update $hash rule $rule"	
			}
			"deny" {
				ml_add_del $hash
				log_puts "ERR" "ml_replay deny $hash"			
			}
			default {
				log_puts "ERR" "ml_replay strange result $hash"			
			}
		}	
	}
	set ::rule($gid) $rule
	ml_add_srcs $gid $gpeerid
	log_puts "ERR" "ml_replay end"
}

proc ml_showlist {mode obj} {
	switch $mode  {
	"g" {
		set group $obj
		ml_replay [lindex [array get ::jgroups $group] end]
		catch { set ::topline(main,l) "[::msgcat::mc group]: $::cur(main,group,l)" ; append ::topline(main,l) " [disp_rule $group $::me(id)]" }
		catch { set ::topline(main,r) "[dict get [ml_groupdict $::cur(main,group,h)] gid]" }
		set hdrs [lrange [ml_get_hdrs 31 mlhdr $group] 2 end]
	}
	"p" {
		set person $obj	
		catch { set ::topline(main,l) "[::msgcat::mc person]: $::cur(main,person,l)" }
		catch { set ::topline(main,r) "[dict get [contact_to_dict $::cur(main,person,h)] peerid]" }
		set hdrs [lrange [ml_get_hdrs 31 mlphdr $person] 2 end]
	}
	default {
		log_puts "ERR" "ml_showlist unknown mode $mode"
		return
	}
	}
	set ::msglist(main,l) {}
	set ::msglist(main,k) {}
	log_puts "ALL" "filling msglist"
	if { $::searchfield(main) != "" } {
		set reg [string map {{ } {.*}} $::searchfield(main)]
	} else {
		set reg {.*}
	}
	log_puts "ALL" "regex is $reg"
	set sorted {}
	foreach hdr $hdrs {
		set h [header_to_dict $hdr]	
		if { $h == "" } {
			continue
		}
		if { [regexp $reg $h] == 0 } {
			continue	
		}
		set type [dict get $h type]
		switch $type {
		"p" {}
		"g" {}
		"gc" {}
		default { continue}
		}
		set t "[clock format [dict get $h epoch] -format {%Y-%m-%d %H:%M:%S}] | [string range [dict get $h from] 0 3] | [string range [dict get $h nickname] 0 11] | [string range [dict get $h hash] 0 3] | [string range [dict get $h subject] 0 31] ([dict get $h len])"
		lappend sorted $t $hdr [dict get $h epoch]
	}
	foreach {title hdr epoch} [lsort -decreasing -stride 3 -index end $sorted] {
		lappend ::msglist(main,l) $title
		lappend ::msglist(main,k) $hdr
	}

	#ml_showhier $::msglist(main,k)
}

proc ml_groupdict {group} {
	if {[regexp -all {:} $group] != 6} {
		return
	}
	set h [split $group {:}]
	set d {}
	dict set d gid [lindex $h 0]
	dict set d name [unwrap [lindex $h 1]]
	dict set d desc [unwrap [lindex $h 2]] 
	dict set d pkey [unwrap [lindex $h 3]]
	dict set d epoch [lindex $h 4]
	dict set d peerid [lindex $h 5]
	dict set d psig [unwrap [lindex $h 6]]
	return $d
}

proc ml_dictgroup {d} {
	set h "[dict get $d gid]:[wrap [dict get $d name]]:[wrap [dict get $d desc]]:[wrap [dict get $d pkey]]:[dict get $d epoch]:[dict get $d peerid]:[wrap [dict get $d psig]]"
	return $h
}

proc wrap {str} {
	set ret {?}
	catch {
 		set ret [binary encode base64 [encoding convertto utf-8 $str]]
	} res
	#log_puts "ALL" "catch wrap $res"
	#if { $ret == {} } {
	#	log_puts "ALL" "wrap failure"
	#}
	return $ret
}

proc unwrap {str} {
	set ret {?}
	catch {
		set ret [encoding convertfrom utf-8 [binary decode base64 $str]] 
	} res
	#log_puts "ALL" "catch unwrap $res"
	#if { $ret == {} } {
	#	log_puts "ALL" "unwrap failure"
	#}
	return $ret
}

proc ml_get_srcs {grp} {
	set path [file join $::filepath "mlsrc" $grp]
	if { [file exists $path] == 0 } {
		log_puts "ERR" "ml_get_srcs path $path doesn't exist"
		return "$grp 0 "
	} 
	set f [open $path r]
	set cnt 0
	set srcs {}
	while { [gets $f line] >= 0 } {
		lappend srcs $line
	}
	foreach {key val} [array get ::sources "$grp*"] {
		set p [split $val {:}]
		if { [llength $p] == 1 } {
			lappend srcs [lindex $p 0]
		}
	}
	set rusers {}
	set rmods {}
	catch {
		set rusers [dict get $::rule($grp) users]
		set rmods [dict get $::rule($grp) users]
	}
	set srcs [lsearch -all -inline -not -exact [lsort -unique [list {*}$srcs {*}$rmods {*}$rusers]] "*"]
	set srcs [lsort -unique $srcs]
	set cnt [llength $srcs]
	close $f
	log_puts "ALL" "ml_get_srcs return $grp $cnt $srcs"
	return "$grp $cnt $srcs"
} 

proc ml_get_hdrs {days p id} {
	#set path [file join $::filepath "mlhdr" $grp]
	#if { [file exists $path] == 0 } {
	#	log_puts "ERR" "ml_get_hdrs path $path doesn't exist"
	#	return
	#} 
	#set f [open $path r]
	#set cnt 0
	#set hdrs {}
	#while { [gets $f line] >= 0 } {
	#	lappend hdrs $line
	#}
	#set hdrs [lsort -unique $hdrs]
	#set hdrs [ml_filter_del $hdrs]
	#set cnt [llength $hdrs]
	#close $f
	#return "$grp $cnt $hdrs"
	
	switch $p {
		"mlhdr" {
			set rid $id
		}
		"mlphdr" {
			set rid $::me(id)
		}
		default {
			return
		}
	}

	if { $days == {} } {
		set minepoch {}
	} else {
		set minepoch [expr "[clock seconds] - 3600*24*$days"]
	}

	set path [file join $::filepath "$p" "$id.dat"]
	if { [file exists $path] == 0 } {
		return
	} 
	set cnt 0
	set hdrs {}	
       	foreach {k v} [find_bin $path {} $minepoch {} {}] {
		lappend hdrs $v
	}
	set hdrs [lsort -unique $hdrs]
	set hdrs [ml_filter_del $hdrs]
	set cnt [llength $hdrs]
	return "$rid $cnt $hdrs"
} 

proc ml_add_del {hash} {
	#set hash [lindex [split $hash {:}] 0]
	#set path [file join $::filepath mldel]
	#set f [open $path a]
	#puts $f $hash
	#flush $f
	#close $f
	#ml_del_eml $hash
	#return

	set path [file join $::filepath "mldel.dat"]
	save_bin $path [list $hash $hash]
	#ml_del_eml $hash
}

proc ml_filter_del {hashes} {
	#log_puts "ALL" "ml_filter_del args $hashes"
	#set path [file join $::filepath mldel]
	#if { ![file exists $path] } {
	#	#log_puts "ALL" "ml_filter_del no del file"
	#	return $hashes
	#}
	#set f [open $path r]
	#set del [split [read $f] "\n"]
	#close $f
	#set ret {}
	#foreach hash $hashes {
	#	#log_puts "ALL" "ml_filter_del deleted $del tofind [lindex [split $hash {:}] 0]"
	#	set res [lsearch $del [lindex [split $hash {:}] 0]]
	#	#log_puts "ALL" "ml_filter_del res $res"
	#	if { $res == {} || $res == -1 } {
	#		lappend ret $hash
	#	}
	#}
	#log_puts "ALL" "filtered hashes $ret"
	#return $ret

	array set tmp {}
	set path [file join $::filepath "mldel.dat"]
	if { ![file exists $path] } {
		#log_puts "ALL" "ml_filter_del no del file"
		return $hashes
	}
	set del [get_bin $path $hashes]
	foreach hash $hashes {
		set tmp($hash) 1
	}
	foreach d $del {
		array unset tmp $d 
	}
	set ret {}
	set ret [array names tmp]
	return $ret
}

#proc ml_del_eml {p hash} {
#	log_puts "ALL" "deleting letter $hash"
#	#set prefix [lindex [split $hash {_}] 0]
#	#set end [lindex [split $hash {_}] 1]
#	#if { $end != $prefix } {
#	#	set path [file join $::filepath mailnews $prefix $end]
#	#} else {
#	#	set path [file join $::filepath mailnews $hash]
#	#}
#	#if { [file exists $path] == 0 } {
#	#	log_puts "ERR" "no letter $path stored"
#	#	return -1
#	#}
#	#catch {
#	#file delete $path
#	#}
#	set path [file join $::filepath "mailnews_$p.dat"]
#	del_bin $path $hash
#}

proc ml_get_eml {p hash} {
	log_puts "ALL" "getting letter $hash"
	if { [ml_filter_del $hash] == {} } {
		log_puts "ERR" "letter $hash in delete list, not stored"
		return -1
	}
	#set cached {}
	#catch { set cached $::lettercache(data,$p,$hash) }
	#if { $cached != {} } {
	#	log_puts "ALL" "letter $p $hash was cached"
	#	return $cached
	#}
	### old
	#if { $p != "all" } {
	#set path [file join $::filepath mailnews $p $hash]
	#} else {
	#set path [file join $::filepath mailnews $hash]
	#}
	#if { [file exists $path] == 0 } {
	#	log_puts "ERR" "no letter $path stored"
	#	return -1
	#}
	#set f [open $path r]
	#fconfigure $f -translation binary
	#set ret [read $f]
	#set chash [crypto_cksum $ret]
	#close $f
	### new
	set path [file join $::filepath "mailnews_$p.dat"]
	set ret {}
       	foreach {k v} [get_bin $path [list $hash]] {
		if { $v == {} } {
			continue
		}
		lappend ret $v
	}
	if { [llength $ret] > 1 } {
		log_puts "ERR" "more than one letter $p $hash stored"
		return -1
	}
	set ret [lindex [lsort -unique $ret] end]
	if { $ret == {} } {
		log_puts "ERR" "no letter $p $hash stored"
		return -1
	} 
	set chash [crypto_cksum $ret]
	### end
	if { $p == "all" && $hash != $chash } {
		log_puts "ERR" "wrong hash $hash != $chash"
		return -1
	}

	#set ::lettercache(data,$p,$hash) $ret
	#set ::lettercache(epoch,$p,$hash) [clock seconds]
	
	# must be even, it's number of keys and values
	#set num 20
	# pick only old keys
	#set kvold [lrange [lsort -decreasing -integer -stride 2 -index end [array get ::lettercache "epoch,$p,*"]] 0 end-$num]
	# unset cache entries
	#foreach {k e} $kvold {
	#	set t [lindex [split $k {,}] end]
	#	array unset ::lettercache "*,$p,$t"	
	#}

	return $ret
}

proc ml_add_srcs {grp srcs} {
	log_puts "ALL" "ml_add_srcs grp $grp srcs $srcs"
	set t_srcs {}
	set t_srcs [lrange [ml_get_srcs $grp] 2 end]
	lappend t_srcs {*}$srcs
	foreach {key val} [array get ::sources "$grp*"] {
		set p [split $val {:}]
		if { [llength $p] == 1 } {
			lappend t_srcs [lindex $p 0]
		}
	}
	set t_srcs [lsearch -all -inline -not [lsort -unique $t_srcs] $::me(id)]
	log_puts "ALL" "ml_add_srcs t_srcs $t_srcs"
	set path [file join $::filepath "mlsrc" $grp]
	set f [open $path w]
	foreach src $t_srcs {
		puts $f $src
	}
	flush $f
	close $f
}

proc ml_add_hdrs {p id hdrs} {
	#set new_hdrs [lrange [ml_get_hdrs 31 $p $id] 2 end]
	#lappend new_hdrs {*}$hdrs
	#set path [file join $::filepath $p $id]
	#set f [open $path w]
	#foreach hdr $new_hdrs {
	#	if { [header_to_dict $hdr] != "" } {  
	#		puts $f $hdr
	#	}
	#}
	#flush $f
	#close $f
	#return
	
	#lappend hdrs {*}$new_hdrs
	#set hdrs [lsort -unique $hdrs]
	#
	switch $p {
		"mlhdr" {
		}
		"mlphdr" {
		}
		default {
			return
		}
	}

	array set tmp {}
	foreach hdr $hdrs {
		set h [header_to_dict $hdr]
		if { $h == "" } {  
			continue
		}
		set k [dict get $h hash]
		if { $k == "" } {
			continue
		}
		set tmp($k) $hdr
	}
	foreach hdr [lrange [ml_get_hdrs 31 $p $id] 2 end] {
		set h [header_to_dict $hdr]
		if { $h == "" } {  
			continue
		}
		set k [dict get $h hash]
		if { $k == "" } {
			continue
		}
		array unset tmp $k	
	}
	set path [file join $::filepath "$p" "$id.dat"]
	save_bin $path [array get tmp] 
}

proc ml_add_eml {p hash eml} {
	log_puts "ALL" "ml_add_eml"
	if { $hash == {} } {
		set hash [crypto_cksum $eml]
	}
	log_puts "ALL" "letter hash $hash"
	if { [ml_filter_del $hash] == {} } {
		log_puts "ERR" "letter $hash in delete list, not stored"
		return -1
	}
	### new
	set path [file join $::filepath "mailnews_$p.dat"]
	save_bin $path [list $hash $eml] 
	### old
	#if { $p == "all" } {
	#set path [file join $::filepath "mailnews" $hash]
	#} else {
	#set path [file join $::filepath "mailnews" $p $hash]
	#}
	#if { [file exists $path] == 1 } {
	#	log_puts "ERR" "letter $hash already stored"
	#	return -1
	#}
	#set f [open $path w]
	#fconfigure $f -translation binary
	#puts -nonewline $f $eml
	#flush $f
	#close $f
	### end
}

proc dl_reqdict {req} {
	if {[regexp -all {:} $req] != 3} {
		return
	}
	set r [split $req {:}]
	set d {}
	dict set d filename [unwrap [lindex $r 0]]
	dict set d filehash [lindex $r 1]	
	dict set d offset [lindex $r 2]	
	dict set d len [lindex $r 3]	
	#log_puts "ALL" "dl_reqdict $r TO $d"
	return $d
}

proc dl_dictreq {d} {
	set r [wrap [dict get $d filename]]:[dict get $d filehash]:[dict get $d offset]:[dict get $d len] 
	#log_puts "ALL" "dl_dictreq $d TO $r"
	return $r
}

proc dl_read {req} {
	log_puts "ALL" "dl_read"
	set r [dl_reqdict $req]	
	#log_puts "ALL" "dl_read r $r"
	set filehash [dict get $r filehash]
	set offset [dict get $r offset]
	set len [dict get $r len]
	set detail [lindex [array get ::file_by_hash $filehash] 1]
	#log_puts "ALL" "detail($filehash): $detail"
	set local_filename [unwrap [dict get $detail name]]
	#log_puts "ALL" "dl_read local_filename $local_filename"
	if { [string length $detail] == 0 } {
		log_puts "ERR" "dl_read no such indexed file"
		return
	}
	if { [file exists $local_filename] != 1 || [file isfile $local_filename] != 1} {
		log_puts "ERR" "dl_read no such file by indexed name"
		return
	}
	set f [open $local_filename r]
	if { $f == "" } {
		log_puts "ERR" "dl_read file not opened"
		return
	}
	fconfigure $f -translation binary
	#log_puts "ALL" "dl_read seek $f $offset start"
	seek $f $offset start
	set data [read $f $len]
	close $f
	return $req,[wrap $data]
}

proc dl_write {body} {
	set s [split $body {,}]
	set req [lindex $s 0]
	set data [unwrap [lindex $s 1]]
	log_puts "ALL" "dl_write"
	set r [dl_reqdict $req]	
	log_puts "ALL" "dl_write r $r"
	set filehash [dict get $r filehash]
	set filename [lindex [file split [dict get $r filename]] end]
	set offset [dict get $r offset]
	set len [dict get $r len]
	set local_filename [file join $::filepath "temp" $filename]
	if { [file exists $local_filename] == 1 && [file isfile $local_filename] != 1} {
		log_puts "ERR" "not a file"
		return
	}
	if { $::dlstate_by_hash($filehash,state) != "RUN" } {
		log_puts "ERR" "not running"
		return
	}	
	set f [open $local_filename a+]
	fconfigure $f -buffering none -translation binary
	log_puts "ALL" "dl_write seek $f $offset start"
	seek $f $offset start 
	puts -nonewline $f $data
	flush $f
	close $f
	log_puts "ALL" "dl_write "
	set top [lindex [array get ::dlstate_by_hash "$filehash,top"] 1]
	array set ::dlstate_by_hash [list $filehash,top [expr {$offset+$len}]]
	array set ::dlstate_by_hash [list $filehash,last [clock seconds]]
	log_puts "ALL" "dl_write dl_run"
	after 200 [list dl_run $filehash]
	return 0
}

proc dl_getpeers {hash cnt} {
	log_puts "ALL" "dl_getpeers"
	set have [array get ::sources "$hash*"]
	lappend have {*}[array get ::sources "[crypto_cksum $hash]*"]
	set cnt [expr "$cnt+1"]
	if { [llength $have] == 0 && $cnt < 20 } {
		log_puts "ALL" "dl_getpeers sc_get_sources $hash"
		sc_get_sources $hash
		sc_get_sources [crypto_cksum $hash]
		after 5000 [list dl_getpeers $hash $cnt]
	} else {
		log_puts "ALL" "dl_getpeers have $have"
		set peers {}
		foreach {key value} $have {
			log_puts "ALL" "dl_getpeers have is $key $value"
			foreach {pkey pvalue} [lsort -unique -stride 2 -index end [array get ::peerstore "$value*" ]] {
				log_puts "ALL" "dl_getpeers peer $pvalue"
				lappend peers $pvalue
			}
		}
		if { [llength $peers] > 0 } {
			log_puts "ALL" "peers $peers"
			array set ::dlstate_by_hash [list $hash,otherpeers $peers]
			after 100 [list dl_run $hash]
		}
	}
}

proc dl_add {req buddyhash otherpeers action} {
	log_puts "ALL" "dl_add"
	set r [dl_reqdict $req]
	set hash [dict get $r filehash]
	set ex {}
	catch { set ex $::file_by_hash($hash) }
	dict set r filename [lindex [file split [dict get $r filename]] end]
	array set ::dl_by_hash [list $hash $r]
	array set ::dlstate_by_hash [list $hash,state "STOP"]
	# if it's a buddy transfer, we set a buddy to give us data 
	array set ::dlstate_by_hash [list $hash,buddy $buddyhash]
	# and if we are given a list of peers, then we add them
	if { [llength $otherpeers] == 0 && $buddyhash == "" && $ex == {} } {
		log_puts "ALL" "dl_getpeers $hash 0"
		dl_getpeers $hash 0
	}
	array set ::dlstate_by_hash [list $hash,otherpeers $otherpeers]
	array set ::dlstate_by_hash [list $hash,top 0]
	array set ::dlstate_by_hash [list $hash,last [clock seconds]]
	array set ::dlaction_by_hash [list $hash $action]
	return $hash
}

proc dl_start {hash} {
	if { $hash == "" } {
		return
	}
	log_puts "ALL" "dl_start"
	
	set ex {}
	set local_filename {}
	catch { set ex $::file_by_hash($hash) }
	log_puts "ALL" "dl_start ex $ex"
	if { $ex != {} } {
		log_puts "ALL" "dl_start ex not empty"
		set r [lindex [array get ::dl_by_hash $hash] end]
		set filename [lindex [file split [dict get $r filename]] end]
		set local_filename [file join $::filepath "temp" $filename]
		set ex_filename [unwrap [dict get $ex name]]
		set res {}
		catch { file copy $ex_filename $local_filename } res
		log_puts "ALL" "dl_start ex copy $res"
	}
	log_puts "ALL" "dl_start ex $ex"
	if { $local_filename != {} && [file exists $local_filename] } {
		log_puts "ALL" "dl_start plan dl_finish"
		after 1000 [list dl_finish $hash]
		return
	} 

	array set ::dlstate_by_hash [list $hash,state "RUN"]
	array set ::dlstate_by_hash [list $hash,last [clock seconds]]
	dl_getpeers $hash 0
	dl_check $hash
	after 50 [list dl_run $hash]
}

proc dl_check {hash} {
	if { $hash == "" } {
		return
	}
	if { [llength [array names ::dlstate_by_hash "$hash*"]] == 0 } {
		log_puts "ERR" "no such dlstate"
		return
	}
	if { $::dlstate_by_hash($hash,state) != "RUN" } {
		log_puts "ERR" "not running"
		return
	}	
	if { [array get ::dlstate_by_hash $hash,buddy] == "" && [llength [array get ::dlstate_by_hash $hash,otherpeers ]] == 0 } {
		log_puts "ERR" "no buddy" 
		#return
	}	
	if { $::dlstate_by_hash($hash,last) < [expr "[clock seconds] - 10"] } {
		dl_run $hash
	}
	after 1000 [list dl_check $hash]
}

proc dl_run {hash} {
	log_puts "ALL" "dl_run"
	if { $::dlstate_by_hash($hash,state) != "RUN" } {
		log_puts "ERR" "not running"
		return
	}	
	if { [array get ::dlstate_by_hash $hash,buddy] == "" && [llength [array get ::dlstate_by_hash $hash,otherpeers ]] == 0 } {
		log_puts "ERR" "no buddy" 
		#return
	}	
	set r [lindex [array get ::dl_by_hash $hash] 1]
	set size [dict get $r len]
	if { $::dlstate_by_hash($hash,top) < $size } {
		set cr {}
		dict set cr filehash $hash
		dict set cr filename [lindex [file split [dict get $r filename]] end]
		dict set cr offset $::dlstate_by_hash($hash,top)
		# 32mb+ -> chunk 16mb
		if { $size >= 33554432 } {
			set chunksize 16777216 
		} else {
			set chunksize $::options(default_chunksize)
		}
		dict set cr len $chunksize
		set req [dl_dictreq $cr]
		# normal transfer between buddies
		if { [lindex [array get ::dlstate_by_hash $hash,buddy] end] != "" } {
			log_puts "ALL" "dl_run normal transfer to $::dlstate_by_hash($hash,buddy)"
			set buddy $::dlstate_by_hash($hash,buddy)
			set b [contact_to_dict [lindex [array get ::buddies $buddy] 1]]
			set peerid [dict get $b peerid]
			set peer [lindex [array get ::peerstore $peerid] 1]
			set speer [split $peer {:}]
			ml_genc [lindex $speer 0] [lindex $speer 1] [lindex $speer 2] "GET 0 $req" 0
		# ask peers - choose random one
		} elseif { [llength [array get ::dlstate_by_hash $hash,otherpeers ]] != 0 } {
			set peernum [llength $::dlstate_by_hash($hash,otherpeers)]
			log_puts "ALL" "dl_run plain transfer peers $peernum"
			if { $peernum != 0 } {
				set otherpeer_index [expr "[clock microseconds]%$peernum"]
				log_puts "ALL" "dl_run plain transfer index $otherpeer_index"
				set otherpeer [lindex $::dlstate_by_hash($hash,otherpeers) $otherpeer_index]
				log_puts "ALL" "dl_run plain transfer $otherpeer"
				set speer [split $otherpeer {:}]
				ml_genc [lindex $speer 0] [lindex $speer 1] [lindex $speer 2] "GET 0 $req" 0
			} else {
				log_puts "ALL" "dl_run no peers"
			}
		}
	} elseif {$::dlstate_by_hash($hash,top) >= $size} {
		array unset ::dlstate_by_hash "$hash,id"
		dl_stop $hash
		after 1000 [list dl_finish $hash]
	} else {
		log_puts "ERR" "dl_run weird top $hash , top $::dlstate_by_hash($hash,top), size $size"
	}
}

proc dl_stop {hash} {
	if { $hash == "" } {
		return
	}
	log_puts "ALL" "dl_stop"
	array set ::dlstate_by_hash [list $hash,state "STOP"]
}

proc dl_finish {hash} {
	if { $hash == "" } {
		return
	}
	log_puts "ALL" "dl_finish"
	set r [lindex [array get ::dl_by_hash $hash] end]
	if { $r == "" } {
		log_puts "ERR" "dl_finish no dl"
		return
	}
	set filename [lindex [file split [dict get $r filename]] end]
	set local_filename [file join $::filepath "temp" $filename]
	log_puts "ALL" "dl_finish filename $filename"
	log_puts "ALL" "dl_finish local_filename $local_filename"
	if { [file exists $local_filename] == 0 } {
		log_puts "ERR" "dl_finish $local_filename doesn't exist"
		return	
	}
	set final_filename [file join $::filepath "downloads" $filename]
	log_puts "ALL" "dl_finish final_filename $final_filename"
	log_puts "ALL" "dl_finish hashing file $local_filename"
	set data {}
	catch {
	set c [open $local_filename r]
	fconfigure $c -translation binary
	set data [read $c]
	close $c
	} res
	if { $data == {} } {
		log_puts "ERR" "error reading downloaded file"
		return
	}
	set lhash [crypto_cksum -hex $data]
	if { $lhash != $hash } {
		log_puts "ERR" "error checking downloaded file"
		array set ::dlstate_by_hash [list $hash,state "ERROR"]
		return
	}
	if { [file exists $final_filename] != 1 } {
		file rename $local_filename $final_filename
	}
	array set ::dlstate_by_hash [list $hash,state "DONE"]
	
	set dlaction {}
	catch { set dlaction $::dlaction_by_hash($hash) }
	if { $dlaction != {} } {
		log_puts "ALL" "dl_finish dlaction $dlaction"
		#catch { {*}$dlaction $data }
		{*}$dlaction $data
	}

	after 18000 [list dl_del $hash]
}

proc dl_del {hash} {
	if { $hash == "" } {
		return	
	}
	log_puts "ALL" "dl_del"
	set r [lindex [array get ::dl_by_hash $hash] 1]
	if { $r == "" } {
		return
	}
	if { [lindex [array get ::dlstate_by_hash $hash,state] 1] != "DONE" } {
		set filename [dict get $r filename]
		set local_filename [file join $::filepath "temp" $filename]
		log_puts "ALL" "dl_del local_filename $local_filename"
		if { [file exists $local_filename] == 1 } {
			file delete $local_filename
		}
	}
	array unset ::dl_by_hash $hash
	array unset ::dlstate_by_hash $hash,*
	array unset ::dlaction_by_hash $hash*
}

proc saveobj {gid name obj} {
	set path [file join $::filepath "obj" "${gid}_${name}.dat"]
	set ho {}
	foreach o $obj {
		set h [crypto_cksum -hex $o]
		lappend ho $h $o
	}
	return [save_bin $path $ho]
}

proc save_bin {path keyvals} {
	if { $path == {} || $keyvals == {} } {
		log_puts "ERR" "save_bin some inputs empty, path $path, keyvals $keyvals"
		return
	}

	set tg {}
	array set tmp {}
	foreach {key val} $keyvals {
		set tmp($key) $val
		lappend tg $key
	}
	foreach {key val} [get_bin $path $tg] {
		array unset tmp $key
	}

	set chan {}
	catch { set chan [open $path a] }

	if { $chan == {} } {
		log_puts "ERR" "save_bin failed to open"
		catch { close $chan }
		return
	}

	chan configure $chan -translation binary -buffering full

	# seek to end
	chan seek $chan 0 end

	# write record
	catch {
	foreach {key val} [array get tmp] {
		w_wide [clock seconds] $chan
		w_str $key $chan
		w_byte 0 $chan
		w_str $val $chan
	}
	}

	catch { flush $chan }

	catch { close $chan }

	return 0
}

proc find_bin {path keys sts ets filter} {
	#log_puts "ALL" "find_bin path $path, keys $keys, sts $sts, ets $ets, filter $filter"
	if { $path == {} } {
		log_puts "ERR" "find_bin path empty, path $path, keys $keys, sts $sts, ets $ets, filter $filter"
		return
	}

	set chan {}
	catch { set chan [open $path r] }

	if { $chan == {} } {
		log_puts "ERR" "find_bin failed to open"
		catch { close $chan }
		return
	}

	chan configure $chan -translation binary -buffering full

	set ts {}
	set del {}
	set key {}
	set val {}
	set ret {}
	while { ![eof $chan] } {
		catch {
		set ts [r_wide $chan]
		set key [r_str $chan]
		set del [r_byte $chan]
		set val [r_str $chan]
		}
		set r 0
		if { $del != 0 } {
			log_puts "ERR" "find_bin key $key del != 0, skip"
			continue
		}
		if { $ts < $sts && $sts != {} } {
			log_puts "ERR" "find_bin key sts $sts not empty and more than ts $ts"
			continue
		} 
		if { $ts > $ets && $ets != {} } {
			log_puts "ERR" "find_bin key ets $ets not empty and more than ts $ts"
			continue
		} 
		if { $keys != {} && [lsearch -all -inline -exact $keys $key] == {} } {
			log_puts "ERR" "find_bin key $key not in keys $keys"
			continue
		} elseif { $keys != {} && [lsearch -all -inline -exact $keys $key] != {} } {
			log_puts "ERR" "find_bin found key $key in keys $keys"
			set ii [lsearch -exact $keys $key]
			set keys [lreplace $keys $ii $ii]
		}
		foreach {fkey fval} [dict get $filter] {
			set oval {}
			catch {
			set oval [dict get $val $fkey]
			}
			if { $oval != $fval } {
				log_puts "ERR" "find_bin key $key filter oval $oval != fval $fval"
				incr r 1
			}
		}
		if { $r == 0 } {
			lappend ret $key $val
		}
	}

	catch { close $chan }

	return $ret
}

proc get_bin {path keys} {
	if { $path == {} || $keys == {} } {
		log_puts "ERR" "get_bin some inputs empty, path $path, keys $keys"
		return
	}

	set ret {}

	#foreach key $keys {
	#	set val {}
	#	catch { set val $::bincache(data,$path,$key) }
	#	if { $val != {} } {
	#		log_puts "ALL" "get_bin $key was cached"
	#		lappend ret $key $val	
	#		set ii [lsearch $keys $key]
	#		set keys [lreplace $keys $ii $ii]
	#	}
	#}

	set chan {}
	catch { set chan [open $path r] }

	if { $chan == {} } {
		log_puts "ERR" "get_bin $path failed to open"
		catch { close $chan }
		return
	}

	chan configure $chan -translation binary -buffering full

	set ts {}
	set del {}
	set key {}
	set val {}
	while { ![eof $chan] } {
		catch {
		set ts [r_wide $chan]
		set key [r_str $chan]
		set del [r_byte $chan]
		set val [r_str $chan]
		}
		if { $del != 0 } {
			log_puts "ERR" "get_bin key $key del != 0, skip"
			continue
		}
		set found [lsearch -all -inline $keys $key]
		if { $found != {} } {
			log_puts "ERR" "get_bin found key $key in keys $keys"
			lappend ret $key $val
			set ii [lsearch $keys $key]
			set keys [lreplace $keys $ii $ii]
		}
	}

	catch { close $chan }

	#foreach {key val} $ret {
	#	set ::bincache(data,$path,$key) $val
	#	set ::bincache(epoch,$path,$key) [clock seconds]
	#}

	# must be even, it's number of keys and values
	#set num 200
	# pick only old keys
	#set kvold [lrange [lsort -decreasing -integer -stride 2 -index end [array get ::bincache "epoch,*"]] 0 end-$num]
	# unset cache entries
	#foreach {k e} $kvold {
	#	set tp [lindex [split $k {,}] 0]
	#	set th [lindex [split $k {,}] 1]
	#	array unset ::bincache "*,$tp,$th"
	#}

	return $ret
}

proc del_bin {path keys} {
	if { $path == {} || $keys == {} } {
		log_puts "ERR" "del_bin some inputs empty, path $path, keys $keys"
		return
	}

	set chan {}
	catch { set chan [open $path r+] }

	if { $chan == {} } {
		log_puts "ERR" "del_bin failed to open"
		catch { close $chan }
		return
	}

	chan configure $chan -translation binary -buffering full

	set ts {}
	set key {}
	set val {}
	set ret {}
	while { ![eof $chan] } {
		catch {
		set ts [r_wide $chan]
		set key [r_str $chan]
		set found [lsearch -all -inline $keys $key]
		if { $found != {} } {
			w_byte 1 $chan
		} else {
			r_byte $chan
		}
		set val [r_str $chan]
		}
	}

	catch { flush $chan }

	catch { close $chan }

	return 0

}

proc iter_bin {path action} {
	if { $path == {} || $action == {} } {
		log_puts "ERR" "iter_bin no path or action supplied"
		return
	}

	set chan {}
	catch { set chan [open $path r] }
	
	if { $chan == {} } {
		log_puts "ERR" "iter_bin failed to open"
		catch { close $chan }
		return
	}

	chan configure $chan -translation binary -buffering full

	while { ![eof $chan] } {
		set ts {}
		set key {}
		set val {}
		catch {
		set ts [r_wide $chan]
		}
		catch {
		set key [r_str $chan]
		}
		set val [r_str $chan]
		if { $ts == {} || $key == {} } {
			log_puts "ERR" "iter_bin empty ts $ts or key $key, stop"
			break
		}
		{*}$action $ts $key $val
	}

	catch { close $chan }
}

main $argv
