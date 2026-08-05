proc show_doc_list {p id} {
	log_puts "ALL" "show_doc_list $p $id"
	if { $p != "mlhdr" } { return }
	set w ".dl_${p}_${id}"
	if { [winfo exists $w] } {
		return
	}
	proc show_cmd {p id} {
		set w ".dl_${p}_${id}"
		show_doc $p $id [lindex $::doc($p,$id,k) [$w.l.l index active]]
	}
	toplevel $w
	wm title $w "Docs of $p $id"
	pack [panedwindow $w.p -ori vert] -fill both -expand 1
	$w.p add [wframe $w.top] -stretch never
	pack [wlabel $w.top.l -text "Docs of $p $id:" ] -side left
	$w.p add [wframe $w.l] -stretch always
	pack [listbox $w.l.l -listvariable ::doc($p,$id,l) -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) -selectforeground $::options(basecolor) -selectbackground $::options(hilightcolor) -font $::options(font) -yscrollc "$w.l.y set" -width 80 -height 20] -fill both -expand 1 -side left
	pack [wscrollbar $w.l.y -activebackground $::options(hilightcolor) -troughcolor $::options(hilightcolor) -command "yview $w.l.l"] -fill y -side right
	$w.p add [wframe $w.show] -stretch never
	pack [wbutton $w.show.b -text "show" -command "show_cmd $p $id" ] -fill both -side right
	$w.p add [wframe $w.add] -stretch never
	pack [wlabel $w.add.l -text "New: " ] -side left
	pack [wentry $w.add.e -textvariable ::doc($p,$id,new,subj)] -fill both -expand 1 -side left
	pack [wbutton $w.add.b -text [::msgcat::mc "add"] -command "doc_new $p $id"] -fill both -side right
	update_doc_list $p $id
}

proc update_doc_list {p id} {
	log_puts "ALL" "update_doc_list $p $id"
	set ::doc($p,$id,k) {}
	set ::doc($p,$id,l) {}
	foreach hdr [lrange [ml_get_hdrs 365 $p $id] 2 end] {
		set h [header_to_dict $hdr]
		if { $h == {} } {
			continue
		}
		set type [dict get $h type]
		if { $type != "d" } {
			continue
		}
		set hash [dict get $h hash]
		set t "[clock format [dict get $h epoch] -format {%Y-%m-%d %H:%M:%S}] | [string range [dict get $h from] 0 3] | [string range [dict get $h nickname] 0 11] | [string range [dict get $h hash] 0 3] | [string range [dict get $h subject] 0 31] ([dict get $h len])"
		lappend ::doc($p,$id,k) $hash
		lappend ::doc($p,$id,l) $t
	}
}

proc doc_new {p id} {
	log_puts "ALL" "doc_new $p $id"
	set subj {}
	catch {
	set subj $::doc($p,$id,new,subj)
	set ::doc($p,$id,new,subj) {}
	}
	if { [string trim $subj] == {} } {
		log_puts "ERR" "doc_new $p $id no subj"
		return
	}
	### form message with type "d", subject as above
	### save as normal email header, don't save body
	switch $p {
	"mlhdr" {
		set kfrom "[crypto_exp_pub $::me(key)]"
        	set kto {}
        	set hfrom $::me(id)
        	set from "[string range $::me(nickname) 0 64] <$::me(id)>"
        	set subject "$subj"
        	set epoch [clock seconds]
        	set g [ml_groupdict $::jgroups($id)]
        	set group $id
        	set hto $id
        	set to "[string range [dict get $g name] 0 64] <$id>"
        	set hsubject "$subj"
        	set type "d"
	}
	default {
		log_puts "ERR" "doc_new $p $id wrong p"
		return 
	}
	}

	set whole {}
	append whole "From:\t$from\n"
        append whole "To:\t$to\n"
        append whole "Subject:\t$subject\n"
        append whole "Epoch:\t$epoch\n"
        append whole "\n"
        append whole "\n\n"

	log_puts "ALL" "Formed document message:"
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

	log_puts "ALL" "Formed document header:"
	log_puts "ALL" $header

	### shouldn't be necessary, but for now let it be for tradition
	ml_add_eml all {} $whole

	### in the end we save this header
	ml_add_hdrs $p $id $header

	### send out
	set gsrc [ml_get_srcs $hto]
	if { [lindex $gsrc 1] == 0 } { break }
	set peers [lrange $gsrc 2 end]
	foreach peer $peers {
		set speer [split $peer {:}]
		if { [lindex $speer 0] == $::me(id) } {
			continue
		}
		ml_genc [lindex $speer 0] [lindex $speer 1] [lindex $speer 2] "MAIL 0 DIG [list $hto 1 $header]" 0
	}
	update_doc_list $p $id
	if { $p == "mlhdr" } {
		set pp g	
	} elseif { $p == "mlphdr" } {
		set pp p
	} else {
		return
	} 
	ml_showlist $pp $id
}

proc show_doc {p id hash} {
	log_puts "ALL" "show_doc $p $id $hash"
	if { $p != "mlhdr" } { return }
	if { $id == {} } { return }
	if { $hash == {} } { return }
	set w ".d_${p}_${id}_${hash}"
	if { [winfo exists $w] } {
		return
	}
	toplevel $w
	wm title $w "Doc $p $id $hash"
	pack [panedwindow $w.p -ori vert] -fill both -expand 1
	$w.p add [wframe $w.top] -stretch never
	pack [wlabel $w.top.l -textvariable ::doc($p,$id,$hash,node)] -side left
	pack [wbutton $w.top.ta -text [::msgcat::mc "+"] -command "doc_toggle_add $p $id $hash"] -fill both -side right
	pack [wbutton $w.top.tt -text [::msgcat::mc "edits"] -command "doc_toggle_tree $p $id $hash"] -fill both -side right
	pack [wbutton $w.top.tm -text [::msgcat::mc "msgs"] -command "doc_toggle_msgs $p $id $hash"] -fill both -side right
	$w.p add [wframe $w.edit] -stretch never -hide true
	pack [wbutton $w.edit.i -text [::msgcat::mc "e_filepick"]  -activebackground $::options(hilightcolor) -activeforeground $::options(basecolor) -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor)  -font $::options(font) -command "insert_single_file w $w.page.t"] -fill both -side left
	pack [wbutton $w.edit.a -text [::msgcat::mc "e_fileindex"]  -activebackground $::options(hilightcolor) -activeforeground $::options(basecolor) -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor)  -font $::options(font) -command "show_fileoffer w $w.page.t" ] -fill both -side left
	pack [wbutton $w.edit.limg -text [::msgcat::mc "image"]  -activebackground $::options(hilightcolor) -activeforeground $::options(basecolor) -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor)  -font $::options(font) -command "insert_linked_image w $w.page.t"] -fill both -side right
	pack [wbutton $w.edit.lrec -text [::msgcat::mc "voice"]  -activebackground $::options(hilightcolor) -activeforeground $::options(basecolor) -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor)  -font $::options(font) -command "insert_linked_voice w $w.page.t"] -fill both -side right
	pack [wbutton $w.edit.l -text [::msgcat::mc "e_letter"]  -activebackground $::options(hilightcolor) -activeforeground $::options(basecolor) -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor)  -font $::options(font) -command "show_recent w $w.page.t none" ] -fill both -side left
	pack [wbutton $w.edit.grp -text [::msgcat::mc "e_group"]  -activebackground $::options(hilightcolor) -activeforeground $::options(basecolor) -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor)  -font $::options(font) -command "show_insertgroup w $w.page.t" ] -fill both -side left
	pack [wbutton $w.edit.g -text [::msgcat::mc "e_gr"]  -activebackground $::options(hilightcolor) -activeforeground $::options(basecolor) -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor)  -font $::options(font) -command "show_gredit [clock microseconds] {} $w.page.t" ] -fill both -side right
	pack [wbutton $w.edit.mysm -text [::msgcat::mc "mysm"]  -activebackground $::options(hilightcolor) -activeforeground $::options(basecolor) -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor)  -font $::options(font) -command "show_mysm [clock microseconds] {} $w.page.t" ] -fill both -side right
	$w.p add [panedwindow $w.m -ori hor] -stretch always
	$w.m add [wframe $w.page] -stretch always
	pack [wscrollbar $w.page.y -activebackground $::options(hilightcolor)  -troughcolor $::options(hilightcolor)  -command "$w.page.t yview"] -fill y -side right
        pack [text $w.page.t -wrap word -yscrollc "$w.page.y set" \
		-selectforeground {#6090c0} -selectbackground $::options(hilightcolor) \
                -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) \
		-highlightbackground $::options(hilightcolor) \
                -padx 5 -pady 3 -height 36 -width 50 -font $::options(font)] \
                -fill both -expand 1 -side right
	$w.m add [panedwindow $w.r -ori vert] -stretch always
	$w.r add [wframe $w.tree] -stretch always
	pack [wscrollbar $w.tree.y -activebackground $::options(hilightcolor)  -troughcolor $::options(hilightcolor)  -command "$w.tree.t yview"] -fill y -side right
        pack [text $w.tree.t -wrap word -yscrollc "$w.tree.y set" \
		-selectforeground {#6090c0} -selectbackground $::options(hilightcolor) \
                -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) \
		-highlightbackground $::options(hilightcolor) \
                -padx 5 -pady 3 -height 18 -width 30 -font $::options(font)] \
                -fill both -expand 1 -side right
	$w.r add [wframe $w.record] -stretch always
	pack [wscrollbar $w.record.y -activebackground $::options(hilightcolor)  -troughcolor $::options(hilightcolor)  -command "$w.record.t yview"] -fill y -side right
        pack [text $w.record.t -wrap word -yscrollc "$w.record.y set" \
		-selectforeground {#6090c0} -selectbackground $::options(hilightcolor) \
                -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) \
		-highlightbackground $::options(hilightcolor) \
                -padx 5 -pady 3 -height 18 -width 30 -font $::options(font)] \
                -fill both -expand 1 -side right
	$w.m add [panedwindow $w.c -ori vert] -stretch always -hide true
	$w.c add [wframe $w.msg] -stretch always
	pack [wscrollbar $w.msg.y -activebackground $::options(hilightcolor)  -troughcolor $::options(hilightcolor)  -command "$w.msg.t yview"] -fill y -side right
        pack [text $w.msg.t -wrap word -yscrollc "$w.msg.y set" \
		-selectforeground {#6090c0} -selectbackground $::options(hilightcolor) \
                -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) \
		-highlightbackground $::options(hilightcolor) \
                -padx 5 -pady 3 -height 36 -width 30 -font $::options(font)] \
                -fill both -expand 1 -side right
	$w.c add [wframe $w.entry] -stretch never -minsize 24
	pack [wentry $w.entry.e -textvariable ::doc($p,$id,$hash,entry)] -fill both -expand 1 -side left
	pack [wbutton $w.entry.b -text [::msgcat::mc "add"] -command "doc_msg $p $id $hash ; doc_head $p $id $hash"] -fill both -side right
	$w.p add [wframe $w.bottom] -stretch never -minsize 24
	pack [wlabel $w.bottom.l -textvariable ::doc($p,$id,$hash,bottom)] -fill both -side left
	pack [wbutton $w.bottom.u -text [::msgcat::mc "clear"] -command "doc_display $p $id $hash"] -fill both -side right
	pack [wbutton $w.bottom.r -text [::msgcat::mc "gather"] -command "doc_head $p $id $hash"] -fill both -side right
	pack [wbutton $w.bottom.b -text [::msgcat::mc "save"] -command "doc_edit $p $id $hash ; doc_head $p $id $hash"] -fill both -side right

	set ::doc($p,$id,$hash,node) $hash
	set ::doc($p,$id,$hash,body) "" 

	$w.record.t tag configure delete -overstrike 1 -foreground {#c06060} -overstrikefg {#c06060}
	$w.record.t tag configure insert -underline 1 -foreground {#60c060} -underlinefg {#60c060}
	$w.record.t tag configure author -underline 1 -foreground {#c060c0} 
	$w.record.t tag configure stamp -foreground {#c0c060}
	$w.record.t tag configure nodelink -underline 1 -foreground {#6060c0} -underlinefg {#6060c0} 
	$w.tree.t tag configure author -underline 1 -foreground {#c060c0}
	$w.tree.t tag configure stamp -foreground {#c0c060} 
	$w.tree.t tag configure nodelink -underline 1 -foreground {#6060c0} -underlinefg {#6060c0} 
	$w.msg.t tag configure author -underline 1 -foreground {#c060c0} 
	$w.msg.t tag configure stamp -foreground {#c0c060} 
	$w.page.t tag configure red -foreground {#c06060}
	$w.page.t tag configure cyan -foreground {#60c0c0}
	$w.page.t tag configure blue -foreground {#6060c0}
	$w.page.t tag configure yellow -foreground {#c0c060}
	$w.page.t tag configure magenta -foreground {#c060c0}
	$w.page.t tag configure hide -elide true
	$w.page.t tag configure inline_voice -foreground {#c060c0} -underline true
	$w.page.t tag configure inline_image -foreground {#c060c0} -underline true
	$w.page.t tag configure mysm -foreground {#60c060} -underline true
	$w.page.t tag configure filelink -foreground {#6060c0} -underline true
	$w.page.t tag configure imagelink -foreground {#c060c0} -underline true
	$w.page.t tag configure grouplink -foreground {#6060c0} -underline true
	$w.page.t tag configure attachlink -foreground {#c06060} -underline true
	$w.page.t tag configure headerlink -foreground {#6060c0} -underline true
	$w.page.t tag configure searchlink -foreground {#6060c0} -underline true

	$w.record.t tag bind nodelink <1> "+ doc_clickwindow nodelink $w.tree.t $p $id $hash %x %y" 
	$w.tree.t tag bind nodelink <1> "+ doc_clickwindow nodelink $w.tree.t $p $id $hash %x %y" 

	set cmd_s "+ click_window s $w.page.t none %x %y"
	set cmd_f "+ click_window f $w.page.t none %x %y"
	set cmd_h "+ click_window h $w.page.t none %x %y"
	set cmd_a "+ click_window a $w.page.t none %x %y"
	set cmd_g "+ click_window g $w.page.t none %x %y"
	set cmd_ge "+ click_window ge $w.page.t none %x %y"
	set cmd_gr "+ click_window gr $w.page.t none %x %y"
	set cmd_rec "+ click_window rec $w.page.t none %x %y"
	set cmd_lrec "+ click_window lrec $w.page.t none %x %y"
	set cmd_img "+ click_window img $w.page.t none %x %y"
	set cmd_limg "+ click_window limg $w.page.t none %x %y"
	set cmd_mysm "+ click_window mysm $w.page.t none %x %y"
	set cmd_doc "+ click_window doc $w.page.t none %x %y"

	$w.page.t tag bind searchlink <1> $cmd_s
	$w.page.t tag bind filelink <1> $cmd_f
	$w.page.t tag bind headerlink <1> $cmd_h
	$w.page.t tag bind attachlink <1> $cmd_a
	$w.page.t tag bind gr_scheme <1> $cmd_g
	$w.page.t tag bind gr_scheme <3> $cmd_ge
	$w.page.t tag bind grouplink <1> $cmd_gr
	$w.page.t tag bind inline_voice <1> $cmd_rec
	$w.page.t tag bind voicelink <1> $cmd_lrec
	$w.page.t tag bind inline_image <1> $cmd_img
	$w.page.t tag bind imagelink <1> $cmd_limg
	$w.page.t tag bind mysm <1> $cmd_mysm
	$w.page.t tag bind doclink <1> $cmd_doc

	doc_head $p $id $hash
	set last [doc_readtree $p $id $hash]
	doc_readmsgs $p $id $hash
	doc_replay $p $id $hash [lindex $last 0]
}

proc doc_clickwindow {t w p id hash x y} {
	switch $t {
	"nodelink" { }
	default { return }
	}

	if { [winfo exists $w] } {
		set range [$w tag prevrange $t [$w index @$x,$y]]
		set data [eval $w get $range]
	} else {
		return
	}

	switch $t {
	"nodelink" {
		set node [lindex [split $data "|"] end-1]
		doc_replay $p $id $hash $node
	}
	}
}

proc doc_toggle_add {p id hash} {
	set w ".d_${p}_${id}_${hash}"
	if { ![winfo exists $w] } { return }
	if { [ "$w.p" panecget "$w.edit" -hide ] } {
		"$w.p" paneconfigure "$w.edit" -hide false
	} else {
		"$w.p" paneconfigure "$w.edit" -hide true
	}
}

proc doc_toggle_tree {p id hash} {
	set w ".d_${p}_${id}_${hash}"
	if { ![winfo exists $w] } { return }
	if { [ "$w.m" panecget "$w.r" -hide ] } {
		"$w.m" paneconfigure "$w.r" -hide false
	} else {
		"$w.m" paneconfigure "$w.r" -hide true
	}
}

proc doc_toggle_msgs {p id hash} {
	set w ".d_${p}_${id}_${hash}"
	if { ![winfo exists $w] } { return }
	if { [ "$w.m" panecget "$w.c" -hide ] } {
		"$w.m" paneconfigure "$w.c" -hide false
	} else {
		"$w.m" paneconfigure "$w.c" -hide true
	}
}

proc doc_edit {p id hash} {
	log_puts "ALL" "doc_edit $p $id $hash"
	set w ".d_${p}_${id}_${hash}"
	set tw "$w.page.t"
	if { ![winfo exists $tw] } { return }

	set doc $::doc($p,$id,$hash,body) 
	set ndoc [$tw get 1.0 end]

	set d {}
	catch {
	set d [delta $doc $ndoc]
	}
	if { $d == {} } {
		return
	}
	
	set body [wrap $d]

	set parent $::doc($p,$id,$hash,node)

	set epoch [clock seconds]

	set author $::me(id)

	set l {}
	lappend l $author $epoch $parent $body
	set cksum [crypto_cksum -hex $l]
	lappend l $cksum
	set sig [crypto_sig $l $::me(key)]
	lappend l $sig

	set record [join $l " "]

	if { $p == "mlhdr" } {
		set rc [rule_check_gchat $id $author]
		if { $rc != "allow" } {
			return
		}
	}

	doc_save $p $id $hash e $cksum $record
	doc_head $p $id $hash
	doc_replay $p $id $hash $cksum
	doc_readtree $p $id $hash
}

proc doc_msg {p id hash} {
	log_puts "ALL" "doc_msg $p $id $hash"
	set w ".d_${p}_${id}_${hash}"
	if { ![winfo exists $w] } { return }

	set e $::doc($p,$id,$hash,entry)
	set ::doc($p,$id,$hash,entry) {}

	set body [wrap $e]

	set parent $hash

	set epoch [clock seconds]

	set author $::me(id)

	set l {}
	lappend l $author $epoch $parent $body
	set cksum [crypto_cksum -hex $l]
	lappend l $cksum
	set sig [crypto_sig $l $::me(key)]
	lappend l $sig

	set record [join $l " "]

	doc_save $p $id $hash m $cksum $record
	doc_head $p $id $hash
	doc_readmsgs $p $id $hash
	return
}

proc doc_save {p id hash t key value} {
	set path [file join $::filepath "doc" "${p}_${id}_${hash}_${t}.dat"]
	save_bin $path [list $key $value]
	return
}

proc doc_read {p id hash t key} {
	set path [file join $::filepath "doc" "${p}_${id}_${hash}_${t}.dat"]
	set ret [lindex [get_bin $path $key] end]
	return $ret
}

proc doc_readall {p id hash t} {
	log_puts "ALL" "doc_readall $p $id $hash $t"
	set path [file join $::filepath "doc" "${p}_${id}_${hash}_${t}.dat"]
	set ret [find_bin $path {} {} {} {}]
	return $ret
}

proc doc_readtree {p id hash} {
	log_puts "ALL" "doc_readtree $p $id $hash"
	set w ".d_${p}_${id}_${hash}"
	set tw "$w.tree.t"
	if { ![winfo exists $tw] } { return }
	$tw delete 1.0 end
	$tw insert end "Tree:\n"

	set path [file join $::filepath "doc" "${p}_${id}_${hash}_e.dat"]
	set rets [find_bin $path {} {} {} {}]
	foreach {k v} $rets {
		log_puts "ALL" "doc_readtree k $k"
		log_puts "ALL" "doc_readtree v $v"
		doc_append_tree $p $id $hash $v
	}
	$tw see end
	return [lrange $rets end-1 end]
}

proc doc_readmsgs {p id hash} {
	log_puts "ALL" "doc_readmsgs $p $id $hash"
	set w ".d_${p}_${id}_${hash}"
	set mw "$w.msg.t"
	if { ![winfo exists $mw] } { return }
	$mw delete 1.0 end
	$mw insert end "Messages:\n"

	set path [file join $::filepath "doc" "${p}_${id}_${hash}_m.dat"]
	set rets [find_bin $path {} {} {} {}]
	foreach {k v} $rets {
		log_puts "ALL" "doc_readmsgs k $k"
		log_puts "ALL" "doc_readmsgs v $v"
		doc_append_msg $p $id $hash $v
	}
	$mw see end
	return [lrange $rets end-1 end]
}

proc doc_apply {p id hash record} {
	log_puts "ALL" "doc_apply $p $id $hash $record"
	if { $record == {} } { return }
	set l [split $record]
	set author [lindex $l 0]
	set epoch [lindex $l 1]
	set parent [lindex $l 2]
	set body [lindex $l 3]
	set cksum [lindex $l 4]
	set sig [lindex $l 5]
	
	set cnode $::doc($p,$id,$hash,node)
	if { $cnode != $parent } {
		log_puts "ERR" "doc_apply cnode != parent"
		return
	}
	
	set ndoc {}
	catch {
		set ndoc [apply_delta $::doc($p,$id,$hash,body) [unwrap $body]]
	}
	if { $ndoc == {} } {
		set ndoc "APPLY DELTA ERROR"
	}
	set ::doc($p,$id,$hash,node) $cksum
	set ::doc($p,$id,$hash,body) $ndoc
		
	return
}

proc doc_display {p id hash} {
	log_puts "ALL" "doc_display"
	set w ".d_${p}_${id}_${hash}"
	set pw "$w.page.t"
	if { ![winfo exists $pw] } { return }
	$pw delete 1.0 end
	set body $::doc($p,$id,$hash,body)
	foreach line [split $body "\n"] {
		disp_line $pw $line
	}
}

proc doc_append_msg {p id hash record} {
	if { $record == {} } { return }
	set w ".d_${p}_${id}_${hash}"
	set mw "$w.msg.t"
	if { ![winfo exists $mw] } { return }

	set l [split $record]
	set author [lindex $l 0]
	set epoch [lindex $l 1]
	set parent [lindex $l 2]
	set body [lindex $l 3]
	set cksum [lindex $l 4]
	set sig [lindex $l 5]

	set nickname {}
	catch {	
	set contact [latest_contact $author]
	set c [contact_to_dict $contact]
	set nickname [dict get $c nickname]
	}

	$mw insert end "$nickname <$author> [clock format $epoch -format {%Y-%m-%d %H:%M:%S}]: \n" {author}
	$mw insert end "[unwrap $body]\n" {msg}
	return
}

proc doc_set_record {p id hash record} {
	log_puts "ALL" "doc_set_record $p $id $hash $record"
	if { $record == {} } { return }
	set w ".d_${p}_${id}_${hash}"
	set rw "$w.record.t"
	if { ![winfo exists $rw] } { return }
	$rw delete 1.0 end
	$rw insert end "Record:\n"

	set l [split $record]
	log_puts "ALL" "doc_set_record l $l"
	set author [lindex $l 0]
	set epoch [lindex $l 1]
	set parent [lindex $l 2]
	set body [lindex $l 3]
	set cksum [lindex $l 4]
	set sig [lindex $l 5]

	set nickname {}
	catch {
	set contact [latest_contact $author]
	set c [contact_to_dict $contact]
	set nickname [dict get $c nickname]
	}

	$rw insert end "Parent |$parent|\n" {nodelink}
	$rw insert end "Author: $nickname <$author>\n" {author}
	$rw insert end "Epoch: [clock format $epoch -format {%Y-%m-%d %H:%M:%S}]: \n\n" {stamp}
	set lines [split [unwrap $body] "\n"]
	foreach line $lines {
		set tags {}
		switch [string index $line 0] {
			"-" { lappend tags delete }
			"+" { lappend tags insert }
			"d" { lappend tags delete }
			"a" { lappend tags insert }
		}
		$rw insert end "$line\n" $tags 
	}
	return

}

proc doc_replay {p id hash node} {
	log_puts "ALL" "doc_replay $p $id $hash $node"
	if { $node == {} } { return }
	set w ".d_${p}_${id}_${hash}"
	set pw "$w.page.t"
	set rw "$w.record.t"
	if { ![winfo exists $rw] || ![winfo exists $pw] } { return }

	set ::doc($p,$id,$hash,body) "" 
	set ::doc($p,$id,$hash,node) $hash 
	array unset ::dlaction_by_hash "*"

	set dnode $node
	set cur {}
	set seq {}
	set parent -1
	while { $node != $hash } {
		set record [doc_read $p $id $hash e $node]
		if { $record == {} } {
			log_puts "ERR" "doc_replay empty rec"
			return -1
		}
		log_puts "ALL" "doc_replay node $record"
		set l [split $record]
		set author [lindex $l 0]
		set epoch [lindex $l 1]
		set parent [lindex $l 2]
		set body [lindex $l 3]
		set cksum [lindex $l 4]
		set sig [lindex $l 5]
		if { $cksum == {} } {
			log_puts "ERR" "doc_replay empty rec node"
			return -1
		}	
		if { $cksum != $node } {
			log_puts "ERR" "doc_replay rec node $cksum != node $node"
			return -1
		}
		set node $parent
		lappend seq $record
	}
	while 1 {
		if { $seq == {} } { break }
		set cur [lpop seq]
		doc_apply $p $id $hash $cur
	}

	set ln [split $dnode]
	set author [lindex $ln 0]
	set epoch [lindex $ln 1]
	set parent [lindex $ln 2]
	set body [lindex $ln 3]
	set cksum [lindex $ln 4]
	set sig [lindex $ln 5]

	set l {}
	lappend l $author $epoch $parent $body
	set sum [crypto_cksum -hex $l]
	if { $sum != $dnode } {
		log_puts "ERR" "doc_replay checksum is wrong, $sum != $dnode" 
	}

	doc_set_record $p $id $hash $cur
	doc_display $p $id $hash
	return
}

proc doc_append_tree {p id hash record} {
	if { $record == {} } { return }
	set w ".d_${p}_${id}_${hash}"
	set tw "$w.tree.t"
	if { ![winfo exists $tw] } { return }

	set l [split $record]
	set author [lindex $l 0]
	set epoch [lindex $l 1]
	set parent [lindex $l 2]
	set body [lindex $l 3]
	set cksum [lindex $l 4]
	set sig [lindex $l 5]

	if { $p == "mlhdr" } {
		set rc [rule_check_gchat $id $author]
		if { $rc != "allow" } {
			return
		}
	}

	log_puts "ALL" "doc_append_tree $p $id $hash"
	log_puts "ALL" "doc_append_tree parent $parent"

	if { $parent != $hash } {
		#set pos [lindex [$tw tag ranges "node:$parent"] end]
		set pos "end"
	} else {
		set pos "end"
	}
	if { $pos == "" } { set pos "end" }

	set nickname {}
	catch {
	set contact [latest_contact $author]
	set c [contact_to_dict $contact]
	set nickname [dict get $c nickname]
	}

	$tw insert $pos "$nickname <$author>\n" [list author node:$cksum]
	$tw insert $pos "*[clock format $epoch -format {%Y-%m-%d %H:%M:%S}]*: \n" [list stamp node:$cksum]
	$tw insert $pos "|$cksum|\n\n" [list nodelink node:$cksum]
	return
}

proc doc_head {p id hash} {
       if { $p == "mlhdr" } {
                set gsrc [ml_get_srcs $id]
                if { [lindex $gsrc 1] == 0 } {
                        break
                }
                set peers [lrange $gsrc 2 end]
                foreach peer $peers {
                        set speer [split $peer {:}]
                        if { [lindex $speer 0] == $::me(id) } {
                                continue
                        }
                        ml_genc [lindex $speer 0] [lindex $speer 1] [lindex $speer 2] "HEAD 0 GDC $id $hash e" 0
                        ml_genc [lindex $speer 0] [lindex $speer 1] [lindex $speer 2] "HEAD 0 GDC $id $hash m" 0
                }
        } elseif { $p == "mlphdr" } {
		ml_genc $id {} {} "HEAD 0 PDC $id $hash e" 0
		ml_genc $id {} {} "HEAD 0 PDC $id $hash m" 0
        }
}
