proc show_tree {} {
	set w ".tree"
	if { [winfo exists $w] == 1 } {
		return
	}

	make_nmenu

	toplevel $w
	wm title $w "Roster $::menick <$::me>"

	pack [panedwindow $w.p -ori vert -width 240] -fill both -expand 1

	$w.p add [frame $w.l] -stretch always
	pack [ ttk::treeview $w.l.t -columns "Objects" -show "tree" -height 12 -selectmode browse -yscrollc "$w.l.y set" ] -fill both -expand 1 -side right 
	pack [ scrollbar $w.l.y -activebackground {#606060} -troughcolor {#606060} -command "$w.l.t yview"] -fill y -expand 0 -side right

	$w.p add [frame $w.i] -stretch never
	pack [label $w.i.mpl -text "<" -highlightcolor {#909090} -highlightbackground {#606060} -font $::font ] -fill both -side left
	pack [label $w.i.me -textvar ::me -highlightcolor {#909090} -highlightbackground {#606060} -font $::font ] -fill both -side left 
	pack [label $w.i.mpr -text ">" -highlightcolor {#909090} -highlightbackground {#606060} -font $::font ] -fill both -side left
	$w.p add [frame $w.n] -stretch never 
	pack [label $w.n.l -textvar ::menick -highlightcolor {#909090} -highlightbackground {#606060} -font $::font ] -fill both -expand 1 -side left
	pack [label $w.n.p -textvar ::peernum -highlightcolor {#909090} -highlightbackground {#606060} -font $::font ] -fill both -side left

	set folderIcon $::icons(folder) 

	$w.l.t column "Objects" -stretch true
	set ::t_groups [$w.l.t insert {} end -text {Groups} -image $folderIcon -open true]
	set ::t_buddies [$w.l.t insert {} end -text {Buddies} -image $folderIcon -open true]

	array set ::t_bind_to_key {}
	array set ::t_gind_to_key {}

	#bind $w.l.t <<TreeviewSelect>> {
	#}
	bind $w.l.t <1> {click_tree 1}
	bind $w.l.t <3> {click_tree 3} 
	bind $w.n.l <1> {+ tk_popup .nmenu %X %Y}

	after idle [list update_tree]

	return
}


proc update_tree {} {
		set w ".tree"
		if { [winfo exists $w] != 1 } {
			return
		}

		$w.l.t delete [$w.l.t children $::t_groups]
		$w.l.t delete [$w.l.t children $::t_buddies]

		array unset ::t_bind_to_key "*"
		array unset ::t_gind_to_key "*"

		set uOnlineIcon $::icons(u_online)
		set uOfflineIcon $::icons(u_offline)
		set gAdminIcon $::icons(g_admin)
		set gNormalIcon $::icons(g_normal)

		set ::peernum [llength [lsort -unique [array names ::b]]]

		foreach {gkey gval} [array get ::jgroups] { 
			set g [ml_groupdict $gval]
			if { [dict get $g peerid] == $::me } {
				set gIcon $gAdminIcon
			} else {
				set gIcon $gNormalIcon
			}
			set name "[dict get $g name] <[dict get $g gid]>"
			set ret [$w.l.t insert $::t_groups end -text "$name" -image $gIcon]
			array set ::t_gind_to_key [list $ret $gkey]
		}

		foreach {bkey bval} [array get ::buddies] {
			set status [lindex [array get ::statuses "$bkey,type"] 1]
			if { $status == "O" } {
				set uIcon $uOnlineIcon
			} else {
				set uIcon $uOfflineIcon
			}
			log_puts "ALL" "buddy $bkey status $status statuses [array get ::statuses]"
			set b [contact_to_dict $bval]
			set name "[dict get $b nickname] <[dict get $b peerid]>"
			set ret [$w.l.t insert $::t_buddies end -text "$name" -image $uIcon]
			array set ::t_bind_to_key [list $ret $bkey]
		}

		return
}

proc click_tree {b} {
		set w ".tree"
		set sel [$w.l.t selection]
		set bkey [lindex [array get ::t_bind_to_key "$sel"] end]
		set gkey [lindex [array get ::t_gind_to_key "$sel"] end]
		log_puts "ALL" "click_tree sel->$sel bkey->$bkey gkey->$gkey b->$b"
		log_puts "ALL" "click_tree ::t_bind_to_key->[array get ::t_bind_to_key] ::t_gind_to_key->[array get ::t_gind_to_key]"
		if { $bkey != {} && $b == 1 } {
			show_chatwindow $bkey
		}
		if { $bkey != {} && $b == 3 } {
			show_buddy_details $bkey
		}
		if { $gkey != {} && $b == 1 } {
			show_gchatwindow $gkey
		}
		if { $gkey != {} && $b == 3 } {
			show_group_details $::jgroups($gkey)
		}
		#after 1000 [list update_tree]

		return
}

