# supply file
proc import_arc {path} {
	# read keys and values sequentially,
	# split every key and add value
	# according to type
	iter_bin $path import_arc_pair
	return
}

# import pair
proc import_arc_pair {ts key val} {
	set s [split $key {.}]
	set t [lindex $s 0]
	set st [lindex $s 1]
	set id [lindex $s 2]
	switch $t.$st {
		"p.i" {
			set c [contact_to_dict $val]
			if { $c == {} } {
				return
			}
			if { [dict get $c peerid] == $::me(id) } {
				return
			}
			chat_add $val
			return
		}
		"g.i" {
			set g [ml_groupdict $val]
			if { $g == {} } {
				return
			}	
			set ::groups([dict get $g gid]) $val
			set ::jgroups([dict get $g gid]) $val
			ml_add_srcs [dict get $g gid] ${::me(id)}
			ml_add_srcs [dict get $g gid] [dict get $g peerid]
		}
		"p.h" {
			set mid [lindex $s 3]
			ml_add_hdrs mlphdr $id [list $val]
		}
		"g.h" {
			set mid [lindex $s 3]
			ml_add_hdrs mlhdr $id [list $val]
		}
		"m.b" {
			ml_add_eml all $val
		}
		"f.b" {
			set path [file join $::filepath "share" "file_${id}"]
			if { ![file exists $path] } {
				catch {
				set ch [open $path w+]
				fconfigure $ch -translation binary -buffering none
				puts -nonewline $w $val
				close $ch
				}
			}
			catch { hash_file $path }
		}
		default {
			log_puts "ERR" "import_arc_pair strange type $t.$st, not importing"	
			return
		}
	}
}

# supply path, start ts, end ts, list of gids, list of peerids,
# and whether to export indexed files ; all files are exported,
# if yes ; alternatively we can scan every message for links
# and then export only contained files ; that would be more
# compact, but the export process much slower
proc export_arc {path start end gids peerids bool_files} {
	# first write contacts with keys p.i.<peerid>
	# then write groups with keys g.i.<gid>
	#
	# then for each contact write mail headers
	# with keys p.h.<peerid>.<hash>,
	# then for each group with keys g.h.<gid>.<hash>,
	#
	# then message bodies, if files are enabled,
	# scanning each for links and writing,
	# message body keys are m.b.<hash>,
	# file keys are f.b.<hash>
	
	set peers {}
	foreach peerid $peerids {
		set contact [latest_contact $peerid]
		lappend peers "p.i.${peerid}" $contact
	}
	save_bin $path $peers

	set groups {}
	foreach gid $gids {
		set group $::groups($gid)
		lappend groups "g.i.${gid}" $group
	}
	save_bin $path $groups

	foreach peerid $peerids {
		set spath [file join $::filepath "mlphdr" "$peerid.dat"]
		set hdrs {}
		foreach {k v} [find_bin $spath {} $start $end {}] {
			set eml [ml_get_eml all $k]
			save_bin $path [list "p.h.$k" $v]
			save_bin $path [list "p.b.$k" $eml]
			if { $bool_files == 1 } {
				export_arc_emllinks $path $eml
			}
		}
	}

	foreach gid $gids {
		set spath [file join $::filepath "mlhdr" "$gid.dat"]
		set hdrs {}
		foreach {k v} [find_bin $spath {} $start $end {}] {
			set eml [ml_get_eml all $k]
			save_bin $path [list "g.h.$k" $v]
			save_bin $path [list "g.b.$k" $eml]
			if { $bool_files == 1 } {
				export_arc_emllinks $path $eml
			}
		}
	}
	set desc {}
	append desc "+++\n"
	append desc "Start: [clock format $start -format {%Y-%b-%d %a %H:%M:%S} -gmt 1]\n"
	append desc "End: [clock format $end -format {%Y-%b-%d %a %H:%M:%S} -gmt 1]\n"
	append desc "GIDs: $gids\n"
	append desc "PeerIDs: $peerids\n"
	append desc "Linked files: $bool_files\n"
	append desc "+++\n"
	save_bin $path [list "desc" "$desc"]
}

proc export_arc_emllinks {path body} {
	foreach line [split $body "\n"] {
		set cmd [lindex $line 0]
		set link {}
		switch $cmd {
			"FILE" {
				set link [lindex [split $line {<>}] end-1]
			}
			"LIMG" {
				set link [lindex [split $line {<>}] end-1]
			}
			"LREC" {
				set link [lindex [split $line {<>}] end-1]
			}
			default {
				continue
			}	
		}
		if { $link == {} } {
			continue
		}
		set d [ml_reqdict $link]
		if { $d == {} } {
			continue
		}
		set hash [dict get $d filehash]
		if { $hash == {} } {
			continue
		}
		set found [lindex [array get ::file_by_hash $hash] end]
		if { $found == {} } {
			continue
		}
		set name [unwrap [dict get $found name]]
		set c {}
		catch { set c [open $name r] }
		if { $c == {} } {
			continue
		}
		fconfigure -translation binary -buffering none
		set data [read $c]
		catch { close $c }
		if { $data == {} } {
			return
		}
		save_bin $path [list "f.b.$hash" $data]	
	}
}

# for now does nothing
proc show_exporter {} {
	set w ".export"
	if { [winfo exists $w] } {
		return
	}
	toplevel $w
	wm title $w "Exporter"
	pack [ panedwindow $w.p -ori vert ] -fill both -expand 1

	$w.p add [frame $w.s] -minsize 24 -stretch never
	pack [ label $w.s.sl -text "From (YYYY-MM-DD):" -font $::options(font) -justify left ] -fill both -side left 
	pack [ wentry $w.s.s -textvariable ::cur(export,start) ] -fill both -side right
	$w.p add [frame $w.e] -minsize 24 -stretch never
	pack [ label $w.e.el -text "To (YYYY-MM-DD):" -font $::options(font) -justify left ] -fill both -side left 
	pack [ wentry $w.e.e -textvariable ::cur(export,end) ] -fill both -side right 


	### dynamic
	set choice {true false}
	$w.p add [frame $w.ct] -minsize 24 -stretch never
	pack [ label $w.ct.l -text "Contacts:" -font $::options(font) -justify left ] -fill both -side left 
	set i 0
	foreach {key contact} [array get ::buddies] {
		set c [contact_to_dict $contact] 
		if { $c == {} } {
			log_puts "ERR" "show_exporter key $key c $c"
			continue
		}
		set name [disp_contact $contact]
		set id [dict get $c peerid]
		$w.p add [frame $w.ct_$i] -minsize 24 -stretch never
		pack [label $w.ct_$i.name -textvariable ::cur(export,ct,$i,l) -font $::options(font)] -side left
		set e [tk_optionMenu $w.ct_$i.sel ::cur(export,ct,$i,c) {*}$choice]
		$e configure -font $::options(font)
		pack $w.ct_$i.sel -side right
		set ::cur(export,ct,$i,l) $name
		set ::cur(export,ct,$i,c) false
		set ::cur(export,ct,$i,i) $id
		incr i 1
	}
	$w.p add [frame $w.gt] -minsize 24 -stretch never
	pack [ label $w.gt.l -text "Groups:" -font $::options(font) -justify left ] -fill both -side left 
	set i 0
	foreach {key group} [array get ::jgroups] {
		set g [ml_groupdict $group]
		if { $g == {} } {
			log_puts "ERR" "show_exporter key $key g $g"
			continue
		}
		set name [disp_group $group]
		set id [dict get $g gid]
		$w.p add [frame $w.gt_$i] -minsize 24 -stretch never
		pack [label $w.gt_$i.name -textvariable ::cur(export,gt,$i,l) -font $::options(font)] -side left
		set e [tk_optionMenu $w.gt_$i.sel ::cur(export,gt,$i,c) {*}$choice]
		$e configure -font $::options(font)
		pack $w.gt_$i.sel -side right
		set ::cur(export,gt,$i,l) $name
		set ::cur(export,gt,$i,c) false
		set ::cur(export,gt,$i,i) $id
		incr i 1	
	}
	$w.p add [frame $w.ft] -minsize 24 -stretch never
	pack [ label $w.ft.l -text "Export linked files:" -font $::options(font) -justify left ] -fill both -side left 
	set e [tk_optionMenu $w.ft.sel ::cur(export,ft) {*}$choice]
	$e configure -font $::options(font)
	pack $w.ft.sel -side right
	set ::cur(export,ft) false
	$w.p add [frame $w.b] -minsize 24 -stretch never
	set export_cmd {
		set start {}
		set end {}
		set peerids {}
		set gids {}
		set bool_files {}
		catch {set start [clock scan $::cur(export,start) -format {%Y-%m-%d}] }
		catch {set end [clock scan $::cur(export,end) -format {%Y-%m-%d}] }
		foreach {k v} [array names ::cur "export,ct,*,i"] {
			set i [lindex [split $k {,}] 2]
			set id $::cur(export,ct,$i,i)
			set choice $::cur(export,ct,$i,c)
			if { $choice == {true} } {
				lappend peerids $id
			}
		}
		foreach {k v} [array names ::cur "export,gt,*,i"] {
			set i [lindex [split $k {,}] 2]
			set id $::cur(export,gt,$i,i)
			set choice $::cur(export,gt,$i,c)
			if { $choice == {true} } {
				lappend gids $id
			}
		}
		if { $::cur(export,ft) == {true} } {
			set bool_files 1
		} else {
			set bool_files 0
		}
		set path [tk_getSaveFile] 
		if { $path == {} } {
			return
		}
		if { [file exists $path] } {
			return
		}
		export_arc $path $start $end $gids $peerids $bool_files
	}
	pack [wbutton $w.b.b -text "Export" -command "$export_cmd ; destroy $w" ] -fill both -side right
}

proc show_importer {} {
	set w ".import"
	if { [winfo exists $w] } {
		return
	}
	set path [tk_getOpenFile] 
	if { $path == {} } {
		log_puts "ERR" "show_importer path is empty"
		return
	}
	if { ![file exists $path] } {
		log_puts "ERR" "show_importer file doesn't exist"
		return
	}
	if { [winfo exists $w] } {
		log_puts "ERR" "show_importer window exists"
		return
	}
	set desc [lindex [get_bin $path "desc"] end]
	if { $desc == {} } {
		log_puts "ERR" "show_importer no desc"
		return
	}
	toplevel $w
	wm title $w "Importer"
	pack [ panedwindow $w.p -ori vert ] -fill both -expand 1
	$w.p add [frame $w.f] -minsize 24 -stretch never 
	pack [ label $w.f.l -text "Description (just a string, not to trust):" -font $::options(font) -justify left ] -fill both -side left 
	$w.p add [frame $w.t] -stretch always
	pack [ label $w.t.dl -text "$desc" -font $::options(font) -justify left ] -fill both -side right 
	$w.p add [frame $w.b] -minsize 24 -stretch never 
	pack [wbutton $w.b.b -text "Import" -command "import_arc $path ; destroy $w"] -fill both -side right
}
