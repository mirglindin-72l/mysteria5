proc show_gredit {task body tw} {
	set w ".gr_edit_$task"
	if {[winfo exists $w] == 1} {
		return
	}

	toplevel $w
	wm title $w "Graphical GR editor $task"
	pack [panedwindow "$w.p" -ori ver] -fill both -expand 1

	# top bar - subject, group,
	# button to commit, (like a normal message, but with d type)
	# 
	# button to check (check for inputs validity, check for empty in and out paths)
	#
	# button to interpet (spawn a viewer window to try this)
	#
	# button to clear state (highlights and chosen blocks)
	#
	
	# tool bar - object
	# buttons to add blocks for
	#
	# branching (boolean expression, 2 out paths)
	# fields : {{entry "Expression:" expr}}
	#
	# assignment (list of variables and expressions, should be even, 2 out paths)
	# fields : {{entry "Vars:" pairs}}
	#
	# draw square (a form for text, bg, fg, border colors, editability toggle,
	# font, size and coordinates and name, and optional reference to an action by name, 2 out paths)
	# fields : {{entry "Text:" text} {entry "BG:" bg} {entry "FG:" fg} {entry "BC:" bc} {bool "Editable:" editable}
	# {entry "Font:" font} {entry "Name:" name} {entry "Action:" action}}
	# context : {{x integer} {y integer} {h integer} {w integer}}
	#
	# test square (if exists, 2 out paths)
	# fields : {{entry "Name:" name}}
	#
	# remove square (by name, 2 out paths)
	# fields : {{entry "Name:" name}}
	#
	# fetch post (in variable with hash, target variable for post as dictionary,
	# wait interval, attempts, 2 out paths)
	#
	# fetch person (in variable with peerid, in variable with keywords,
	# target variable for dictionary, wait interval, attempts, 2 out paths)
	#
	# fetch group (same as person)
	#
	# script block (in var, in script, target var, spawn interpreter without FS access or any access)
	# - slave safe interpreter, basic functionality, cool  
	# fields : {{entry "Name:" name} {entry "Expression:" expr}}
	#
	# action (doesn't have inputs, but has a name, is interpreted when a square is clicked)
	# fields : {{entry "Name:" name}}
	#
	# special actions are: start (when loading), notice (group message arrives), shouldn't be removed
	# special variables are: input, output, lasterror
	#
	# +++
	# 
	# button to add paths (click one block output, light up something in red,
	# click another block input, return to normal)
	#
	# button to delete something
	#
	
	gr_edit_clear $task
	
	# top bar
	"$w.p" add [frame "$w.t"] -stretch never
	pack [label "$w.t.l" -text "Subject:" -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) -font $::options(font) ] -fill both -side left
	pack [wentry "$w.t.e" -textvar ::gr_edit_subject($task) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) -font $::options(font) ] -fill both -side left
	if { $tw != {} && [winfo exists $tw] } {
		pack [wbutton "$w.t.s" -text "insert" -activebackground $::options(hilightcolor) -activeforeground $::options(basecolor) -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor)  -font $::options(font) -command "gr_edit_insert $task $tw ; after 1000 [list gr_edit_clear $task] ; after idle [list destroy .gr_edit_$task]"] -fill both -side left
	}
	pack [wbutton "$w.t.r" -text "run" -activebackground $::options(hilightcolor) -activeforeground $::options(basecolor) -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor)  -font $::options(font) -command [concat {gr_start [clock microseconds] [gr_edit_form } $task { ] {}}]] -fill both -side left
	pack [wbutton "$w.t.p" -text "clear" -activebackground $::options(hilightcolor) -activeforeground $::options(basecolor) -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor)  -font $::options(font) -command "gr_edit_clear $task"] -fill both -side left
	pack [wbutton "$w.t.sv" -text "save" -activebackground $::options(hilightcolor) -activeforeground $::options(basecolor) -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor)  -font $::options(font) -command "gr_savefile $task"] -fill both -side left
	if { $tw == {} } {
		pack [wbutton "$w.t.op" -text "open" -activebackground $::options(hilightcolor) -activeforeground $::options(basecolor) -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor)  -font $::options(font) -command "gr_edit_clear $task ; destroy $w ; after idle {gr_openfile $task {}}" ] -fill both -side left
	} else {
		pack [wbutton "$w.t.op" -text "open" -activebackground $::options(hilightcolor) -activeforeground $::options(basecolor) -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor)  -font $::options(font) -command "gr_edit_clear $task ; destroy $w ; after idle {gr_openfile $task $tw}" ] -fill both -side left
	}
	
	"$w.p" add [frame "$w.t0"] -stretch never
	foreach b [list action cond assign init delay get_time format_time] {
		pack [wbutton "$w.t0.$b" -text "$b" -activebackground $::options(hilightcolor) -activeforeground $::options(basecolor) -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor)  -font $::options(font) -command "set ::gr_edit_add_type($task) $b ; set ::gr_edit_state($task) add"] -fill both -side left
	}

	"$w.p" add [frame "$w.t1"] -stretch never
	foreach b [list draw_text draw_solid draw_frame draw_button] {
		pack [wbutton "$w.t1.$b" -text "$b" -activebackground $::options(hilightcolor) -activeforeground $::options(basecolor) -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor)  -font $::options(font) -command "set ::gr_edit_add_type($task) $b ; set ::gr_edit_state($task) add"] -fill both -side left
	}

	"$w.p" add [frame "$w.t2"] -stretch never
	foreach b [list obj_find obj_get obj_save obj_form obj_split] {
		pack [wbutton "$w.t2.$b" -text "$b" -activebackground $::options(hilightcolor) -activeforeground $::options(basecolor) -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor)  -font $::options(font) -command "set ::gr_edit_add_type($task) $b ; set ::gr_edit_state($task) add"] -fill both -side left
	}

	"$w.p" add [frame "$w.t3"] -stretch never
	foreach b [list draw toggle delete win_text set_text] {
		pack [wbutton "$w.t3.$b" -text "$b" -activebackground $::options(hilightcolor) -activeforeground $::options(basecolor) -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor)  -font $::options(font) -command "set ::gr_edit_add_type($task) $b ; set ::gr_edit_state($task) add"] -fill both -side left
	}

	"$w.p" add [frame "$w.t4"] -stretch never
	foreach b [list recv send sync_storage insert_text] {
		pack [wbutton "$w.t4.$b" -text "$b" -activebackground $::options(hilightcolor) -activeforeground $::options(basecolor) -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor)  -font $::options(font) -command "set ::gr_edit_add_type($task) $b ; set ::gr_edit_state($task) add"] -fill both -side left
	}

	# canvas pane
	"$w.p" add [frame "$w.m"] -stretch always
	#pack [canvas "$w.m.c" -width 800 -height 800 -highlightthickness 0] -fill both -side left
	pack [frame "$w.m.f"] -fill both -expand 1
	grid [canvas "$w.m.f.c" -width 800 -height 800 -highlightthickness 0 \
		-yscrollcommand "$w.m.f.y set" \
		-xscrollcommand "$w.m.f.x set" \
		] -row 0 -column 0 -sticky nsew
	grid [wscrollbar "$w.m.f.y" -orient vertical -command "$w.m.f.c yview"] -row 0 -column 1 -sticky ns 
	grid [wscrollbar "$w.m.f.x" -orient horizontal -command "$w.m.f.c xview"] -row 1 -column 0 -sticky ew
	grid [ttk::sizegrip "$w.m.f.s"] -row 1 -column 1 -sticky news
	
	# bottom bar - text with current state of editor
	"$w.p" add [frame "$w.b"] -stretch never
	pack [wbutton "$w.b.del" -text "delete" -activebackground $::options(hilightcolor) -activeforeground $::options(basecolor) -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor)  -font $::options(font) -command "set ::gr_edit_state($task) delete"] -fill both -side left
	pack [wbutton "$w.b.edit" -text "edit" -activebackground $::options(hilightcolor) -activeforeground $::options(basecolor) -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor)  -font $::options(font) -command "set ::gr_edit_state($task) edit"] -fill both -side left
	pack [label "$w.b.l" -textvar ::gr_edit_state($task) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) -font $::options(font) ] -fill both -side left

	bind "$w.m.f.c" <1> [concat {+ gr_edit_click} $task {1 %x %y}]
	bind "$w.m.f.c" <3> [concat {+ gr_edit_click} $task {3 %x %y}]

	array unset ::gr_edit_nodes "$task,*"
	set ::gr_edit_cnt($task) 0
	if { $body != {} } {
		foreach d $body  {
			array set ::gr_edit_nodes [list $task,[dict get $d name] $d]
			incr ::gr_edit_cnt($task) 1
		}
		foreach {nk nd} [array get ::gr_edit_nodes "$task,*"] {
			set ondone [dict get $nd ondone]	
		}
		set cnt 0
		set topass [array names ::gr_edit_nodes "$task,*"]
		foreach cur {start notice input} {
		while { $cur != {} } {
			set d $::gr_edit_nodes($task,$cur)
			set i [lsearch -all $topass $task,$cur]
			set topass [lreplace $topass $i $i]
			gr_edit_draw $task $d [expr {120+240*($cnt%3)}] [expr {40+80*$cnt}] 
			set cur {}
			foreach out {ondone onfail} {
				set v [dict get $d $out]
				if { $v != {} } {
					set cur $v
				}
			}
			incr cnt 1
		}
		}
		foreach rem $topass {
			set d $::gr_edit_nodes($rem)
			gr_edit_draw $task $d [expr {120+240*($cnt%3)}] [expr {40+80*$cnt}] 
			incr cnt 1
		}
		unset topass
		foreach {nk nd} [array get ::gr_edit_nodes "$task,*"] {
			log_puts "ALL" "nk $nk nd $nd"
			foreach out {ondone onfail} {
				set fname {}
				set tname {}
				catch {
				set fname [dict get $nd name]
				set tname [dict get $nd $out]
				}
				if { $fname != {} && $tname != {} } {
					gr_edit_connect $task $fname $out $tname
				}
			}
		}
	}
	if { $body == {} } {
		foreach name {start notice input} {
			set d {}
			dict set d name $name
			dict set d main action
			dict set d delay 1000
			dict set d ondone {}
			dict set d onfail {}
			dict set d vars {}	
			array set ::gr_edit_nodes [list $task,[dict get $d name] $d]
			gr_edit_draw $task $d 120 [expr {40+80*$::gr_edit_cnt($task)}]
			incr ::gr_edit_cnt($task) 1
		}
	}
}

proc gr_edit_delete {task name} {
	if { $name == {} } {
		return
	}
	foreach cond [list "name:$name" "arrow&&tname:$name" "arrow&&fname:$name"] {
		foreach item [.gr_edit_$task.m.f.c find withtag $cond] {
			.gr_edit_$task.m.f.c delete $item 
		}
	}
	array unset ::gr_edit_nodes $task,$name
}

proc gr_edit_connect {task fname out tname} {
	log_puts "ALL" "gr_edit_connect $task fname $fname out $out tname $tname"
	if { $fname == $tname } {
		log_puts "ERR" "gr_edit_connect $task can't connect to itself"
		return
	}
	set d [lindex [array get ::gr_edit_nodes $task,$fname] 1]
	if { $d == {} } {
		log_puts "ERR" "gr_edit_connect $task node nonexistent, d $d, nodes [array get ::gr_edit_nodes "$task,*"]"
		return
	}
	dict set d $out $tname
	array set ::gr_edit_nodes [list $task,$fname $d]


	set fc {}
	set tc {}
	foreach item [.gr_edit_$task.m.f.c find withtag "name:$fname&&rectangle"] {
		set fc [.gr_edit_$task.m.f.c coords $item]
	}
	foreach item [.gr_edit_$task.m.f.c find withtag "name:$tname&&rectangle"] {
		set tc [.gr_edit_$task.m.f.c coords $item]
	}
	if { $fc == {} || $tc == {} } {
		log_puts "ERR" "gr_edit_connect fc $fc tc $tc"
	}
	set fc_x1 [lindex $fc 0]
	if { $fc_x1 == {} } { set fc_x1 0 }
	set fc_y1 [lindex $fc 1]
	if { $fc_y1 == {} } { set fc_y1 0 }
	set fc_x2 [lindex $fc 2]
	if { $fc_x2 == {} } { set fc_x2 0 }
	set fc_y2 [lindex $fc 3]
	if { $fc_y2 == {} } { set fc_y2 0 }
	set tc_x1 [lindex $tc 0]
	if { $fc_x1 == {} } { set fc_x1 0 }
	set tc_y1 [lindex $tc 1]
	if { $fc_y1 == {} } { set fc_y1 0 }
	set tc_x2 [lindex $tc 2]
	if { $fc_x2 == {} } { set fc_x2 0 }
	set tc_y2 [lindex $tc 3]
	if { $fc_y2 == {} } { set fc_y2 0 }
	set lfc {}
	set ltc {}
	set color {}
	if { $out == "ondone" } {
		set color {green}
		set lfc [list $fc_x2 $fc_y1 ]
		set ltc [list $tc_x1 $tc_y1 ]
	} elseif { $out == "onfail" } {
		set color {red}
		set lfc [list $fc_x2 $fc_y2 ]
		set ltc [list $tc_x1 $tc_y2 ]
	} else {
		#set color {blue}
		#set lfc [list $fc_x2 [expr {($fc_y1+$fc_y2)/2}] ]
		#set ltc [list $tc_x1 [expr {($tc_y1+$tc_y2)/2}] ]
		log_puts "ERR" "gr_edit_connect $task out $out not set"
		return
	}
	if { $lfc == $ltc } {
		log_puts "ERR" "gr_edit_connect $task same point"
		return	
	}
	log_puts "ALL" "gr_edit_connect lfc $lfc ltc $ltc"
	set tags [list arrow "$out" "fname:$fname" "tname:$tname"]
	set deltags [list arrow "$out" "fname:$fname"]
	foreach item [.gr_edit_$task.m.f.c find withtag "arrow&&$out&&fname:$fname"] {
		.gr_edit_$task.m.f.c delete $item
	}
	log_puts "ALL" "gr_edit_connect $task delete done"
	.gr_edit_$task.m.f.c create line {*}$lfc {*}$ltc -arrow last -fill $color -width 3 -tags $tags
	log_puts "ALL" "gr_edit_connect $task create done"
}

proc gr_edit_add {task old} {
	set w ".gr_edit_add_$task"
	if { [winfo exists $w] == 1 } {
		return
	}

	if { $old == {} } {
		set type $::gr_edit_add_type($task)
		set ::gr_edit_add_name($task) "blk_[clock seconds]"
		set ::gr_edit_add_ondone($task) {}
		set ::gr_edit_add_onfail($task) {}
	} else {
		set type [dict get $::gr_edit_nodes($task,$old) main]
		set ::gr_edit_add_type($task) $type
		set ::gr_edit_add_name($task) $old 
		set ::gr_edit_add_ondone($task) [dict get $::gr_edit_nodes($task,$old) ondone]
		set ::gr_edit_add_onfail($task) [dict get $::gr_edit_nodes($task,$old) onfail]
	} 

	toplevel $w
	wm title $w "Add block of type $type"
	pack [panedwindow "$w.p" -ori vert ]
        "$w.p" add [frame "$w.t"] -stretch never
        pack [label "$w.t.l" -text "Type: $type" -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) -font $::options(font) ] -fill both -side left 
        "$w.p" add [frame "$w.n"] -stretch never
        pack [label "$w.n.l" -text "Name: " -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) -font $::options(font) ] -fill both -side left 
	if { $old == {} } {
        	pack [wentry "$w.n.e" -textvar ::gr_edit_add_name($task) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) -font $::options(font) ] -fill both -side left
	} else {
        	pack [label "$w.n.e" -textvar ::gr_edit_add_name($task) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) -font $::options(font) ] -fill both -side left
	}
        "$w.p" add [frame "$w.d"] -stretch never
        pack [label "$w.d.l" -text "On done: " -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) -font $::options(font) ] -fill both -side left 
        pack [label "$w.d.e" -textvar ::gr_edit_add_ondone($task) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) -font $::options(font) ] -fill both -side left
        "$w.p" add [frame "$w.f"] -stretch never
        pack [label "$w.f.l" -text "On fail: " -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) -font $::options(font) ] -fill both -side left 
        pack [label "$w.f.e" -textvar ::gr_edit_add_onfail($task) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) -font $::options(font) ] -fill both -side left

	set dfields {}
	log_puts "ALL" "gr_edit_add $task set dfields default by type $type"
	switch $type {
		"cond" {
		# conditional, requires
		# a type selection UI
			dict set dfields left {}
			dict set dfields op {}
			dict set dfields right {}
		}
		"init" {
		# set variables to constants,
		# might be idiocy
			dict set dfields 0_target {}
			dict set dfields 0_const {}
			dict set dfields 1_target {}
			dict set dfields 1_const {}
			dict set dfields 2_target {}
			dict set dfields 2_const {}
			dict set dfields 3_target {}
			dict set dfields 3_const {}
			dict set dfields 4_target {}
			dict set dfields 4_const {}
			dict set dfields 5_target {}
			dict set dfields 5_const {}
		}
		"assign" {
		# set variable to result of operation
		# on two variables
			dict set dfields 0_target {}
			dict set dfields 0_left {}
			dict set dfields 0_op {}
			dict set dfields 0_right {}
			dict set dfields 1_target {}
			dict set dfields 1_left {}
			dict set dfields 1_op {}
			dict set dfields 1_right {}
			dict set dfields 2_target {}
			dict set dfields 2_left {}
			dict set dfields 2_op {}
			dict set dfields 2_right {}
		}
		"delay" {
		# wait specified time 
			dict set dfields delay 5000
		}
		"obj_find" {
		# find objects, by group/namespace/condition
		# (logical expression by attributes)
		# with limit to returned amount of hashes
			dict set dfields target s_obj
			dict set dfields gid s_gid
			dict set dfields name s_name
			dict set dfields filter {}
		}
		"obj_get" {
		# get objects, by group/namespace/(hash list)
		# returns array of {hash attr body}
			dict set dfields target s_obj
			dict set dfields gid s_gid
			dict set dfields name s_name
			dict set dfields hash {}
		}
		"obj_save" {
		# save object, by group/namespace/attr/body
		# checksum of {attr body} is hash
			dict set dfields gid s_gid
			dict set dfields name s_name
			dict set dfields obj {}
		}
		"obj_form" {
			dict set dfields target s_obj
			dict set dfields 0_key {}
			dict set dfields 0_val {}
			dict set dfields 1_key {}
			dict set dfields 1_val {}
			dict set dfields 2_key {}
			dict set dfields 2_val {}	
			dict set dfields 3_key {}
			dict set dfields 3_val {}
			dict set dfields 4_key {}
			dict set dfields 4_val {}	
		}
		"obj_split" {
			dict set dfields obj {}
			dict set dfields 0_target {}
			dict set dfields 0_key {}
			dict set dfields 1_target {}
			dict set dfields 1_key {}
			dict set dfields 2_target {}
			dict set dfields 2_key {}
			dict set dfields 3_target {}
			dict set dfields 3_key {}
			dict set dfields 4_target {}
			dict set dfields 4_key {}
		}
		#"obj_replace" {
		#	dict set dfields gid s_gid
		#	dict set dfields name s_name
		#	dict set dfields hash {}
		#	dict set dfields obj {}
		#}
		#"obj_delete" {
		#	dict set dfields gid s_gid
		#	dict set dfields name s_name
		#	dict set dfields hash {}
		#}
		"get_time" {
		# get seconds
			dict set dfields target {}
		}
		"format_time" {
		# format time from seconds to string
			dict set dfields target s_date
			dict set dfields fmt {%Y-%m-%d %a %H:%M:%S}
			dict set dfields epoch s_now
		}
		"recv" {
		# append notice from queue to list variable
		# TODO implement
			dict set dfields gid s_gid
			dict set dfields name {}
			dict set dfields target {}
		}
		"send" {
		# put outgoing notice to queue 
		# TODO implement
			dict set dfields gid s_gid
			dict set dfields name {}
			dict set dfields obj {}
		}
		"sync" {
		# sync storage for gid and namespace
		# with filter similar to obj_find,
		# meaning requesting matching objects
		# from known group members
		# TODO implement
			dict set dfields gid s_gid
			dict set dfields name {}
			dict set dfields filter {}
		}
		"win_text" {
		# create text widget embedded in canvas
		#
		# TODO implement
			dict set dfields name {}
			dict set dfields x {}
			dict set dfields y {}
			dict set dfields w {}
			dict set dfields h {}
		}
		"set_text" {
		# configure text widget embedded in canvas,
		# arbitrary commands accepted by widget,
		# usable for adding, deleting, hiding text,
		# configuring tags
		#
		# TODO implement
			dict set dfields name {}
			dict set dfields 0_cmd {}
			dict set dfields 0_arg1 {}
			dict set dfields 0_arg2 {}
		}
		"insert_text" {
		# insert text into this scheme's text buffer
		# replaces existing by name
			dict set dfields type text
			dict set dfields name hello_txt
			dict set dfields fg green
			dict set dfields font {Sans 10}
			dict set dfields body "hello world"
		}
		#"insert_image" {
		#	dict set dfields type image
		#	dict set dfields name hello_img
		#	dict set dfields hash {}
		#}
		"draw_text" {
		# draw text in this scheme's graphical buffer
			dict set dfields name hello_txt
			dict set dfields type text
			dict set dfields bg white
			dict set dfields font {Sans 10}
			dict set dfields body {hello world}
			dict set dfields x 0
			dict set dfields y 0
			dict set dfields w 100
			dict set dfields h 40
		}
		"draw_solid" {
		# draw rectangle in this scheme's graphical buffer
			dict set dfields name hello_sld
			dict set dfields type solid
			dict set dfields bg green
			dict set dfields x 0
			dict set dfields y 0
			dict set dfields w 100
			dict set dfields h 100
		}
		"draw_frame" {
		# draw frame in this scheme's graphical buffer
			dict set dfields name hello_frm
			dict set dfields type solid
			dict set dfields bg yellow
			dict set dfields x 0
			dict set dfields y 0
			dict set dfields w 100
			dict set dfields h 100
		}
		"draw_button" {
		# draw button in this scheme's graphical buffer
			dict set dfields name hello_btn
			dict set dfields type button
			dict set dfields action notice
			dict set dfields bg red
			dict set dfields x 0
			dict set dfields y 0
			dict set dfields w 100
			dict set dfields h 40
		}
		"draw_image" {
			dict set dfields name hello_pic
			dict set dfields type image
			dict set dfields req {}
			dict set dfields x 0
			dict set dfields y 0
			dict set dfields w 200
			dict set dfields h 200
		}
		"draw" {
		# unified block for text columns on canvas
			dict set dfields name hello
			dict set dfields type common
			dict set dfields action notice
			dict set dfields font {Sans 10}
			dict set dfields body "hello world"
			dict set dfields fg yellow
			dict set dfields bg blue
			dict set dfields img {}
			dict set dfields bc gray
			dict set dfields x 0
			dict set dfields y 0
			dict set dfields w 100
			dict set dfields h 40
		}
		"toggle" {
		# toggle visibility of name in this
		# scheme's graphical buffer
			dict set dfields name sometarget
		}
		"delete" {
		# delete by name in this scheme's
		# graphical buffer
			dict set dfields name sometarget
		}
	}
	log_puts "ALL" "gr_edit_add $task dfields $dfields"
	if { $old != {} } {
		log_puts "ALL" "gr_edit_add $task set dfields from old $old"
		set d $::gr_edit_nodes($task,$old)
		foreach k [dict keys $dfields] {
			catch { dict set dfields $k [dict get $d vars $k] }
		}
		log_puts "ALL" "gr_edit_add $task dfields $dfields"
	}
	array unset ::gr_edit_add_dfields $task,*
	foreach k [lsort [dict keys $dfields]] {
		set ::gr_edit_add_dfields($task,$k) [dict get $dfields $k]
		set fl "fl_$k"
		set fe "fe_$k"
        	"$w.p" add [frame "$w.$fl"] -stretch never
        	pack [label "$w.$fl.l" -text "D $k: " \
			-highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) \
			-font $::options(font) -width 12 ] -side left 
        	"$w.p" add [frame "$w.$fe"] -stretch never
        	pack [wentry "$w.$fe.e" -textvar ::gr_edit_add_dfields($task,$k) \
			-highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) \
			-font $::options(font) -width 60] -fill both -side right
	}

	proc save_cmd {task old} {
		log_puts "ALL" "gr_edit_add $task save_cmd $old"
		set d {}
		dict set d name $::gr_edit_add_name($task)
		dict set d main $::gr_edit_add_type($task)
		dict set d ondone $::gr_edit_add_ondone($task)
		dict set d onfail $::gr_edit_add_onfail($task)
		log_puts "ALL" "gr_edit_add $task got main vars"
		foreach {fk v} [array get ::gr_edit_add_dfields "$task,*"] {
			set k [lindex [split $fk {,}] end]
			dict set d vars $k $v
		}
		log_puts "ALL" "gr_edit_add $task got opt vars"
		array set ::gr_edit_nodes [list $task,$::gr_edit_add_name($task) $d]
		if { $old == {} } {
			log_puts "ALL" "gr_edit_add $task call draw"
			gr_edit_draw $task $d $::gr_edit_x($task) $::gr_edit_y($task) 
			incr ::gr_edit_cnt($task) 1
		}
		array unset ::gr_edit_add_name $task
		array unset ::gr_edit_add_type $task
		array unset ::gr_edit_add_ondone $task
		array unset ::gr_edit_add_onfail $task
		array unset ::gr_edit_add_dfields $task,*
		after idle [list destroy .gr_edit_add_$task]
	}

        "$w.p" add [frame "$w.b"] -stretch never
	if { $old == {} } {
        pack [wbutton "$w.b.s" -text "add" \
		-activebackground $::options(hilightcolor) -activeforeground $::options(basecolor) \
		-highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) \
		-highlightbackground $::options(hilightcolor) -font $::options(font) \
		-command "save_cmd $task {}"] -fill both -side right
	} else {
        pack [wbutton "$w.b.s" -text "save" \
		-activebackground $::options(hilightcolor) -activeforeground $::options(basecolor) \
		-highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) \
		-highlightbackground $::options(hilightcolor) -font $::options(font) \
		-command "save_cmd $task $old"] -fill both -side right
	}
}

proc gr_edit_draw {task d x y} {
	log_puts "ALL" "gr_edit_draw task $task d $d x $x y $y"
	set w ".gr_edit_$task.m.f.c"
	set font {Sans 10 bold}
	set name [dict get $d name] 
	set main [dict get $d main] 
	set fg {red}
	set bg {blue}
	switch $main {
		"action" {
			set bg {green}
			set fg {white}
		}
		"cond" {
			set bg {blue}
			set fg {yellow}
		}
		"assign" {
			set bg {blue}
			set fg {yellow}
		}
		"init" {
			set bg {blue}
			set fg {yellow}
		}
	}
	set tags {}
	lappend tags "name:$name"
	lappend tags "type:$main"
	foreach item [$w find withtag "name:$name"] {
		$w delete $item
	}
	$w create rectangle [expr {$x-90}] [expr {$y-15}] [expr {$x+90}] [expr {$y+15}] -fill $bg -outline {gray} -width 2 -tags [list {*}$tags "rectangle"]
	$w create text $x $y -text "<$main:$name>" -fill $fg -font $font -tags [list {*}$tags "text"] 
}

proc gr_edit_insert {task tw} {
	log_puts "ALL" "gr_edit_insert $task"
	if { $tw == {} } {
		log_puts "ERR" "gr_edit_insert $task no widget given"
		return
	}
	if { [winfo exists $tw] != 1 } {
		log_puts "ERR" "gr_edit_insert $task widget doesn't exist"
		return
	}
	set body [gr_edit_form $task]
	set obj [wrap $body]
	$tw insert end "GR $obj " {hide gr_scheme}
	$tw insert end "GR scheme\n" {red gr_scheme}
	log_puts "ALL" "gr_edit_insert $task end"
}

proc gr_edit_form {task} {
	set ret {}
	foreach {name val} [array get ::gr_edit_nodes "$task,*"] {
		lappend ret $val
	}
	return $ret
}

proc gr_edit_clear {task} {
	array unset ::gr_edit_nodes "$task,*"
	array unset ::gr_edit_add_name "$task"
	array unset ::gr_edit_add_type "$task"
	array unset ::gr_edit_add_ondone "$task"
	array unset ::gr_edit_add_onfail "$task"
	array unset ::gr_edit_add_dfields "$task,*"
	array unset ::gr_edit_x "$task"
	array unset ::gr_edit_y "$task"
	array unset ::gr_edit_cnt "$task"
	array unset ::gr_edit_state "$task"
	array unset ::gr_edit_selected "$task"
	catch {
	.gr_edit_$task.m.f.c delete all
	}
}

proc gr_edit_click {task b x y} {
	# register when over a "button" object
	set ::gr_edit_x($task) [.gr_edit_$task.m.f.c canvasx $x]
	set ::gr_edit_y($task) [.gr_edit_$task.m.f.c canvasy $y]
	set items [.gr_edit_$task.m.f.c find withtag current]
	set num [llength $items]
	log_puts "ALL" "gr_edit_click $task x $x y $y num $num items -> $items"
	set name {}
	set type {}
	set fname {}
	set ftype {}
	foreach item $items {
		set fname [lsearch -all -inline [.gr_edit_$task.m.f.c itemcget $item -tags] "name:*"]
		set ftype [lsearch -all -inline [.gr_edit_$task.m.f.c itemcget $item -tags] "type:*"]
		if { $fname != {} && $ftype != {} } {
			set name [lindex [split $fname {:}] end]
			set type [lindex [split $ftype {:}] end]
			log_puts "ALL" "gr_edit_click $task name:$name type:$type"
		}
	}
	if { $::gr_edit_state($task) == "delete" && $b == 1} {
		log_puts "ALL" "gr_edit_click $task delete $name"
		after idle [list gr_edit_delete $task $name]
		set ::gr_edit_state($task) {}			
		return
	} elseif { $::gr_edit_state($task) == "add" && $b == 1} {
		log_puts "ALL" "gr_edit_click $task add"
		gr_edit_add $task {}
		set ::gr_edit_state($task) {}
		return
	} elseif { $::gr_edit_state($task) == "edit" && $b == 1 && $num > 0 } {
		if { $name == {} } {
			return
		}
		log_puts "ALL" "gr_edit_click $task edit $name"
		gr_edit_add $task $name
		set ::gr_edit_state($task) {}
		return
	} elseif { $::gr_edit_state($task) == "add" && $b == 1 && $num == 0 } {
		log_puts "ALL" "gr_edit_click $task add cancel"
		set ::gr_edit_state($task) {}
		return
	} elseif { $::gr_edit_state($task) == "edit" && $b == 1 && $num == 0 } {
		log_puts "ALL" "gr_edit_click $task edit cancel"
		set ::gr_edit_state($task) {}
		return
	} elseif { $::gr_edit_state($task) == "connect_done" && $num > 0 } {
		if { $name == {} } {
			return
		}
		log_puts "ALL" "gr_edit_click $task connect_done end $name"
		gr_edit_connect $task $::gr_edit_selected($task) ondone $name
		set ::gr_edit_selected($task) {}
		set ::gr_edit_state($task) {}
		return
	} elseif { $::gr_edit_state($task) == "connect_done" && $num == 0 } {
		log_puts "ALL" "gr_edit_click $task connect_done cancel"
		set ::gr_edit_selected($task) {}
		set ::gr_edit_state($task) {}
		return
	} elseif { $::gr_edit_state($task) == "connect_fail" && $num > 0 } {
		if { $name == {} } {
			return
		}
		log_puts "ALL" "gr_edit_click $task connect_fail end $name"
		gr_edit_connect $task $::gr_edit_selected($task) onfail $name
		set ::gr_edit_selected($task) {}
		set ::gr_edit_state($task) {}
		return
	} elseif { $::gr_edit_state($task) == "connect_fail" && $num == 0 } {
		log_puts "ALL" "gr_edit_click $task connect_fail cancel"
		set ::gr_edit_selected($task) {}
		set ::gr_edit_state($task) {}
		return
	} elseif { $::gr_edit_state($task) == "" && $num > 0 } {
		if { $name == {} } {
			return
		}
		log_puts "ALL" "gr_edit_click $task start connect $name"
		if { $b == 1 } {
			log_puts "ALL" "gr_edit_click $task connect_done start $name"
			set ::gr_edit_state($task) "connect_done"
			set ::gr_edit_selected($task) $name
		} elseif { $b == 3 } {
			log_puts "ALL" "gr_edit_click $task connect_fail start $name"
			set ::gr_edit_state($task) "connect_fail"
			set ::gr_edit_selected($task) $name
		}
		return
	}	
	log_puts "ALL" "gr_edit_click $task nowhere"
}

proc show_grview {task title} {
	# build TCL array of blocks by name
	# build another of objects by name
	# show canvas
	# interpret start action (need tasks, or alternatively something like dl_run)
	# bind click to canvas to interpret action mentioned by square
	log_puts "ALL" "show_grview $task $title"
	set w ".gr_view_$task"
	if {[winfo exists $w] == 1} {
		return
	}

	toplevel $w
	wm title $w "Graphical viewer $task - $title"
	pack [panedwindow "$w.p" -ori ver] -fill both -expand 1

	# top bar - subject, group, author, etc, a clone button, a reset button
	"$w.p" add [frame "$w.t"] -stretch never
	pack [label "$w.t.l" -text "$title" -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) -font $::options(font) ] -fill both -side left

	# middle pane - canvas
	"$w.p" add [frame "$w.m"] -stretch always
	#pack [canvas "$w.m.c" -width 800 -height 800 -highlightthickness 0] -expand 1 -fill both -side left
	pack [frame "$w.m.f"] -fill both -expand 1
	grid [canvas "$w.m.f.c" -width 800 -height 800 -highlightthickness 0 \
		-yscrollcommand "$w.m.f.y set" \
		-xscrollcommand "$w.m.f.x set" \
		] -row 0 -column 0 -sticky nsew
	grid [wscrollbar "$w.m.f.y" -orient vertical -command "$w.m.f.c yview"] -row 0 -column 1 -sticky ns 
	grid [wscrollbar "$w.m.f.x" -orient horizontal -command "$w.m.f.c xview"] -row 1 -column 0 -sticky ew
	grid [ttk::sizegrip "$w.m.f.s"] -row 1 -column 1 -sticky news
	

	# bottom bar - text with current state of viewer
	"$w.p" add [frame "$w.b"] -stretch never
	pack [label "$w.b.l" -textvar ::gr_view_state($task) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) -font $::options(font) ] -fill both -side left
	"$w.p" add [frame "$w.e"] -stretch never
	pack [wentry "$w.e.e" -textvar ::gr_insert_line($task) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) -font $::options(font) ] -expand 1 -fill both -side left

	proc onsend {task} {
		set msg $::gr_insert_line($task)
		set ::gr_vars($task,s_input) $msg
		catch { gr_action $task input }
		set ::gr_insert_line($task) {}
	}

	bind "$w.m.f.c" <1> [concat {+ gr_view_click} $task {1 %x %y}]
	bind "$w.m.f.c" <3> [concat {+ gr_view_click} $task {3 %x %y}]
	bind "$w.e.e" <Key-Return> "onsend $task" 
}

proc show_grinsert {task title} {
	set w ".gr_insert_$task"
	if {[winfo exists $w] == 1} {
		return
	}

	toplevel $w
	wm title $w "Text viewer $task - $title"
	pack [panedwindow "$w.p" -ori ver] -fill both -expand 1

	# top bar - subject, group, author, etc, a clone button, a reset button
	"$w.p" add [frame "$w.t"] -stretch never
	pack [label "$w.t.l" -text "$title" -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) -font $::options(font) ] -fill both -side left

	# middle pane - canvas
	"$w.p" add [frame "$w.m"] -stretch always
	pack [text "$w.m.t" -wrap word] -expand 1 -fill both -side left

	# bottom bar - text with current state of viewer
	"$w.p" add [frame "$w.b"] -stretch never
	pack [label "$w.b.l" -textvar ::gr_view_state($task) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) -font $::options(font) ] -fill both -side left
	"$w.p" add [frame "$w.e"] -stretch never
	pack [wentry "$w.e.e" -textvar ::gr_insert_line($task) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) -font $::options(font) ] -expand 1 -fill both -side left

	proc onsend {task} {
		set msg $::gr_insert_line($task)
		set ::gr_vars($task,s_input) $msg
		catch { gr_action $task input }
		set ::gr_insert_line($task) {}
	}

	bind "$w.m.t" <1> [concat {+ gr_insert_click} $task {1 %x %y}]
	bind "$w.m.t" <3> [concat {+ gr_insert_click} $task {3 %x %y}]
	bind "$w.e.e" <Key-Return> "onsend $task" 
} 

proc gr_start {task block invars} {
	log_puts "ALL" "gr_start task $task block $block invars $invars"
	if { $task == {} || $block == {} } {
		log_puts "ERR" "gr_start input incomplete"
		return
	}
	set gid {}
	catch {
	set gid [dict get [ml_groupdict $::cur(main,group,h)] gid]
	}
	if { $gid == {} } {
		log_puts "ERR" "gr_start no group chosen"
		return
	}
	gr_reset $task
	gr_init $task
	gr_load $task $block
	foreach {key val} [dict get $invars] {
		set ::gr_vars($task,$key) $val
	}
	set ::gr_vars($task,s_gid) $gid 
	set ::gr_vars($task,s_menick) $::me(nickname)
	set ::gr_vars($task,s_me) $::me(id)
	set ::gr_vars($task,s_mesid) "${::me(nickname)}:${::me(id)}"
	show_grview $task "run t:$task in g:$gid as ${::me(id)}"
	catch { gr_action $task "start" }
} 

proc gr_end {task outvars} {
	set d {}
	foreach var $outvars {
		foreach {key val} [array get ::gr_vars "$task,$var"] {
			dict set d $key $val	
		}
	}
	gr_reset $task
	return $d
}

proc gr_init {task} {
	array unset ::gr_blocks "$task,*"
       	proc ::gr_p_cond {task vars} {
		log_puts "ALL" "gr_proc $task $vars"
		set ret "fail"
		catch {
			set lval [gr_synval $task [dict get $vars left]]
			set rval [gr_synval $task [dict get $vars right]]
			set op [gr_synval $task [dict get $vars op]]
			if { $lval $op $rval } {
				set ret "done" 
			}
		} res
		log_puts "ALL" "gr_proc res $res"
		return $ret
	}
	set ::gr_blocks($task,cond) ::gr_p_cond
	proc ::gr_p_init {task vars} {
		log_puts "ALL" "gr_proc $task $vars"
		set ret "fail"
		catch {
			foreach n {0 1 2 3 4 5} {
				set target [dict get $vars "${n}_target"]
				set const [gr_synval $task [dict get $vars "${n}_const"]]
				if { $target != {} } {
					set ::gr_vars($task,$target) $const
				}
			}
			set ret "done"
		} res
		log_puts "ALL" "gr_proc res $res"
		return $ret
	}
	set ::gr_blocks($task,init) ::gr_p_init
	proc ::gr_p_assign {task vars} {
		log_puts "ALL" "gr_proc $task $vars"
		set ret "fail"
		catch {
			foreach n {0 1 2} {
				set target [dict get $vars "${n}_target"]
				set left [gr_synval $task [dict get $vars "${n}_left"]]
				set op [gr_synval $task [dict get $vars "${n}_op"]]
				set right [gr_synval $task [dict get $vars "${n}_right"]]
				if { $target != {} } {
					set ::gr_vars($task,$target) [expr {$left $op $right}]
				}
			}
			set ret "done"
		} res
		log_puts "ALL" "gr_proc res $res"
		return $ret
	}
	set ::gr_blocks($task,assign) ::gr_p_assign
	proc ::gr_p_delay {task vars} {
		log_puts "ALL" "gr_proc $task $vars"
		set ret "delay"
		return $ret
	}
	set ::gr_blocks($task,delay) ::gr_p_delay
	proc ::gr_p_insert {task vars} {
		log_puts "ALL" "gr_proc $task $vars"
		set ret "fail"
		catch {
			show_grinsert $task "run"
			gr_insert .gr_insert_$task.m.t $vars
			set ret "done"
		} res
		log_puts "ALL" "gr_proc res $res"
		return $ret
	}
	set ::gr_blocks($task,insert_text) ::gr_p_insert
	#set ::gr_blocks($task,insert_image) ::gr_p_insert
	proc ::gr_p_draw {task vars} {
		log_puts "ALL" "gr_proc $task $vars"
		set ret "fail"
		catch {
			#show_grview $task "run"
			gr_draw .gr_view_$task.m.f.c $vars
			set ret "done"
		} res
		log_puts "ALL" "gr_proc res $res"
		return $ret
	} 
	set ::gr_blocks($task,draw_text) ::gr_p_draw
	set ::gr_blocks($task,draw_solid) ::gr_p_draw
	set ::gr_blocks($task,draw_frame) ::gr_p_draw
	set ::gr_blocks($task,draw_button) ::gr_p_draw
	set ::gr_blocks($task,draw_image) ::gr_p_draw
	set ::gr_blocks($task,draw) ::gr_p_draw
	proc ::gr_p_objget {task vars} {
		log_puts "ALL" "gr_proc $task $vars"
		set ret "fail"
		catch {
			if { [gr_obj_get $task $vars] == 0 } {
				set ret "done"
			}
		} res
		log_puts "ALL" "gr_proc res $res"
		return $ret
	} 
	set ::gr_blocks($task,obj_get) ::gr_p_objget
	proc ::gr_p_objfind {task vars} {
		log_puts "ALL" "gr_proc $task $vars"
		set ret "fail"
		catch {
			if { [gr_obj_find $task $vars] == 0 } {
				set ret "done"
			}
		} res
		log_puts "ALL" "gr_proc res $res"
		return $ret
	} 
	set ::gr_blocks($task,obj_find) ::gr_p_objfind
	proc ::gr_p_objsave {task vars} {
		log_puts "ALL" "gr_proc $task $vars"
		set ret "fail"
		catch {
			if { [gr_obj_save $task $vars] == 0 } {
				set ret "done"
			}
		} res
		log_puts "ALL" "gr_proc res $res"
		return $ret
	} 
	set ::gr_blocks($task,obj_save) ::gr_p_objsave
	proc ::gr_p_objform {task vars} {
		log_puts "ALL" "gr_proc $task $vars"
		set ret "fail"
		catch {
			set d {}
			set target [dict get $vars target]
			dict unset vars target
			foreach {0 1 2 3 4} {
				set k {}
				catch {
				set k [gr_synval $task [dict get $vars "${n}_key"]]
				}
				set v {}
				catch {
				set v [gr_synval $task [dict get $vars "${n}_value"]]
				}
				if { $k != {} } { 
					dict set d $k $v
				}
			}
			set ::gr_vars($task,$target) $d
			set ret "done"
		} res
		log_puts "ALL" "gr_proc res $res"
		return $ret
	} 
	set ::gr_blocks($task,obj_form) ::gr_p_objform
	proc ::gr_p_objsplit {task vars} {
		log_puts "ALL" "gr_proc $task $vars"
		set ret "fail"
		catch {
			set obj [gr_synval $task [dict get $vars obj]]
		       	dict unset vars obj
			foreach n {0 1 2 3 4} {
				set t {}
				catch {
				set t [dict get $vars "${n}_target"]
				}
				set k {}
				catch {
				set k [gr_synval $task [dict get $vars "${n}_key"]]
				}
				if { $k != {} && $t != {} } {
					set ::gr_vars($task,$t) [dict get $obj $k]
				}
			}
			set ret "done"
		} res
		log_puts "ALL" "gr_proc res $res"
		return $ret
	} 
	set ::gr_blocks($task,obj_split) ::gr_p_objsplit
	proc ::gr_p_gettime {task vars} {
		log_puts "ALL" "gr_proc $task $vars"
		set ret "fail"
		catch {
			set target [dict get $vars target]
			if { $target != {} } {
				set ::gr_vars($task,$target) [clock seconds]
			}
			set ret "done"
		} res
		log_puts "ALL" "gr_proc res $res"
		return $ret
	}
	set ::gr_blocks($task,get_time) ::gr_p_gettime
	proc ::gr_p_formattime {task vars} {
		log_puts "ALL" "gr_proc $task $vars"
		set ret "fail"
		catch {
			set target [dict get $vars target]
			set fmt [gr_synval $task [dict get $vars fmt]]
			set epoch [gr_synval $task [dict get $vars epoch]]
			if { $target != {} } {
				set ::gr_vars($task,$target) [clock format $epoch -format $fmt] 
			}
			set ret "done"
		} res
		log_puts "ALL" "gr_proc res $res"
		return $ret
	}
	set ::gr_blocks($task,format_time) ::gr_p_formattime
	proc ::gr_p_send {task vars} {
		log_puts "ALL" "gr_proc $task $vars"
		set ret "fail"
		catch {
			gr_send $task $vars
			set ret "done"
		} res
		log_puts "ALL" "gr_proc res $res"
		return $ret
	}
	set ::gr_blocks($task,send) ::gr_p_send
	proc ::gr_p_recv {task vars} {
		log_puts "ALL" "gr_proc $task $vars"
		set ret "fail"
		catch {
			gr_recv $task $vars
			set ret "done"
		} res
		log_puts "ALL" "gr_proc res $res"
		return $ret
	}
	set ::gr_blocks($task,recv) ::gr_p_recv
	proc ::gr_p_sync {task vars} {
		log_puts "ALL" "gr_proc $task $vars"
		set ret "fail"
		catch {
			gr_sync $task $vars
			set ret "done"
		} res
		log_puts "ALL" "gr_proc res $res"
		return $ret
	}
	set ::gr_blocks($task,sync) ::gr_p_sync
	proc ::gr_p_wintext {task vars} {
		log_puts "ALL" "gr_proc $task $vars"
		set ret "fail"
		catch {
			#show_grview $task "run"
			gr_wintext $task $vars
			set ret "done"
		} res
		log_puts "ALL" "gr_proc res $res"
		return $ret
	}
	set ::gr_blocks($task,win_text) ::gr_p_wintext
	proc ::gr_p_settext {task vars} {
		log_puts "ALL" "gr_proc $task $vars"
		set ret "fail"
		catch {
			#show_grview $task "run"
			gr_settext $task $vars
			set ret "done"
		} res
		log_puts "ALL" "gr_proc res $res"
		return $ret
	}
	set ::gr_blocks($task,set_text) ::gr_p_settext
	proc ::gr_p_toggle {task vars} {
		log_puts "ALL" "gr_proc $task $vars"
		set ret "fail"
		catch {
			#show_grview $task "run"
			gr_toggle .gr_view_$task.m.f.c $vars
			set ret "done"
		} res
		log_puts "ALL" "gr_proc res $res"
		return $ret
	}
	set ::gr_blocks($task,toggle) ::gr_p_toggle
	proc ::gr_p_delete {task vars} {
		log_puts "ALL" "gr_proc $task $vars"
		set ret "fail"
		catch {
			#show_grview $task "run"
			gr_delete .gr_view_$task.m.f.c $vars
			set ret "done"
		} res
		log_puts "ALL" "gr_proc res $res"
		return $ret
	}
	set ::gr_blocks($task,delete) ::gr_p_delete
	proc ::gr_p_action {task vars} {
		log_puts "ALL" "gr_proc $task $vars"
		return "done"
	}
	set ::gr_blocks($task,action) ::gr_p_action
}

proc gr_reset {task} {
	# just clear canvas and variables
	array unset ::gr_vars "$task,*"
	array unset ::gr_nodes "$task,*"
	array unset ::gr_blocks "$task,*"
	array unset ::gr_view_state "$task"
	array unset ::gr_running "$task"
}

proc gr_action {task name} {
	catch {
	after idle [list gr_run $task $::gr_nodes($task,$name) 3]
	set ::gr_running($task) 1
	}
}

proc gr_load {task body} {
	foreach d $body {
		set name [dict get $d name]
		array set ::gr_nodes [list $task,$name $d]
		puts "gr_load name $name node $d"
	}
}

proc gr_toggle {c d} {
	if { $d == {} || $c == {} } {
		log_puts "ERR" "gr_toggle not enough information c $c d $d"
		return
	}
	log_puts "ALL" "gr_toggle called c $c d $d"
	set name {}
	set res {}
	catch {
	set name [dict get $d name]
	} res
	if { $name == {} } {
		log_puts "ERR" "gr_toggle name empty"
		return
	}
	if { [$c itemcget name:$name -hide] } {
		$c itemconfigure name:$name -hide false
	} else {
		$c itemconfigure name:$name -hide true
	}
}

proc gr_delete {c d} {
	if { $d == {} || $c == {} } {
		log_puts "ERR" "gr_delete not enough information c $c d $d"
		return
	}
	log_puts "ALL" "gr_delete called c $c d $d"
	set name {}
	set res {}
	catch {
	set name [dict get $d name]
	} res
	if { $name == {} } {
		log_puts "ERR" "gr_delete name empty"
		return
	}
	foreach cond {name fname tname} {
		set tag "$cond:$name"
		foreach item [$c find withtag $tag] {
			$c delete $item
		}	
	}
	log_puts "ALL" "gr_delete done $name"
}

proc gr_insert {t d} {
	if { $d == {} || $t == {} } {
		log_puts "ERR" "gr_insert not enough information t $t d $d"
		return
	}
	log_puts "ALL" "gr_insert called t $t d $d"
	set type {}
	set name {}
	set fg {}
	set font {}
	set body {}
	set hash {}
	catch {
	set type [dict get $d type]
	set name [dict get $d name]
	}
	if { $type == "text" } {
	catch {
	set tags [dict get $d name]
	set body [dict get $d body]
	} res
	} elseif { $type == "image" } {
	catch {
	set hash [dict get $d hash]
	} res
	}
	if { $type == {} || $name == {} } {
		log_puts "ERR" "gr_insert incomplete d $d"
		return
	}
	log_puts "ALL" "gr_insert res $res"
	lappend tags "name:$name" 

	set ranges [$t tag ranges "name:$name"]
	foreach {from to} $ranges {
		$t delete $from $to
	}
	if { $type == "text" } {
	$t tag configure "name:$name" -foreground "$fg" -font "$font"
	$t insert end $body $tags
	}
}

proc gr_draw {c d} {
	if { $d == {} || $c == {} } {
		log_puts "ERR" "gr_draw not enough information c $c d $d"
		return
	}
	log_puts "ALL" "gr_draw called c $c d $d"
	set type {}
	set name {}
	set x {}
	set y {}
	set w {}
	set h {}
	set res {}
	catch {
	set type [dict get $d type]
	set name [dict get $d name]
	set x [dict get $d x]
	set y [dict get $d y]
	set w [dict get $d w]
	set h [dict get $d h]
	} res
	log_puts "ALL" "gr_draw res $res"
	if { $type == {} || $name == {} || $x == {} || $y == {} || $w == {} || $h == {} } {
		log_puts "ERR" "gr_draw incomplete d $d"
		return
	}
	set tags [list all "type:$type" "name:$name"]
	log_puts "ALL" "gr_draw tags $tags"
	catch {
	switch $type {
		"text" {
			set body [dict get $d body]
			set fg [dict get $d bg]
			set font [dict get $d font]
			log_puts "ALL" "gr_draw text body $body fg $fg"
			$c create text [expr {$x+$w/2}] [expr {$y+$h/2}] -width $w -text $body -fill $fg -font $font -tags $tags 
		}
		"solid" {
			set bg [dict get $d bg]
			log_puts "ALL" "gr_draw solid bg $bg"
			$c create rectangle $x $y [expr {$x+$w}] [expr {$y+$h}] -fill $bg -outline $bg -width 0 -tags $tags
		}
		"frame" {
			set bg [dict get $d bg]
			log_puts "ALL" "gr_draw frame bg $bg"
			$c create rectangle $x $y [expr {$x+$w}] [expr {$y+$h}] -fill {} -outline $bg -width 3 -tags $tags
		}
		"image" {
			set img [dict get $d img]
			if { $img != {} } {
				catch {
				set i [image create photo -format PNG -data $img]
				log_puts "ALL" "gr_draw image"
				$c create image $x $y -image $i -tags $tags
				}
			}
		}
		"button" {
			set action [dict get $d action]
			set bg [dict get $d bg]
			#set bc [dict get $d bc]
			#set th [dict get $d th]
			lappend tags "action:$action"
			log_puts "ALL" "gr_draw button action $action bg $bg"
			$c create polygon $x $y [expr {$x+$w/2}] $y [expr {$x+$w}] [expr {$y+$h/2}] [expr {$x+$w/2}] [expr {$y+$h}] $x [expr {$y+$h}] -fill $bg -width 0 -tags $tags
			$c create text [expr {$x+$w/3}] [expr {$y+$h/2}] -width $w -text $action -fill black -tags $tags 
		}
		"common" {
			set fg [dict get $d fg]
			set bg [dict get $d bg]
			set bc [dict get $d bc]
			set font [dict get $d font]
			set body [dict get $d body]
			set action [dict get $d action]
			set img [dict get $d img]
			if { $img != {} } {
				catch {
				set i [image create photo -format PNG -data $img]
				log_puts "ALL" "gr_draw image"
				$c create image $x $y -image $i -tags $tags
				}
			}
			if { $action != {} } {
				lappend tags "action:$action"
			}
			log_puts "ALL" "gr_draw common"
			$c create rectangle $x $y [expr {$x+$w}] [expr {$y+$h}] -fill $bg -outline $bc -width 3 -tags $tags
			if { $img != {} } {
				log_puts "ALL" "gr_draw common img not implemented"
			}
			$c create text [expr {$x+$w/2}] [expr {$y+$h/2}] -width $w -text $body -fill $fg -font $font -tags $tags 
		}
		default {
			log_puts "ERR" "gr_draw unknown object type $type"
		}
	}
	} res
	log_puts "ALL" "gr_draw res $res"
}

proc gr_view_click {task b x y} {
	set items [.gr_view_$task.m.f.c find withtag current]
	set num [llength $items]
	log_puts "ALL" "gr_view_click $task x $x y $y num $num items -> $items"
	set found {}
	foreach item $items {
		set found [lsearch -all -inline [.gr_view_$task.m.f.c itemcget $item -tags] "action:*"]
		if { $found != {} } {
			set action [lindex [split $found {:}] end]
			log_puts "ALL" "gr_view_click $task start action $action"
			after idle [list gr_action $task $action]
		}
	}
}

proc gr_insert_click {task b x y} {
	log_puts "ERR" "gr_insert_click not implemented"
	return
}

proc gr_run {task block count} {
	if { $::gr_running($task) != 1 } {
		log_puts "ERR" "gr_run $task stopping due to scheme not running"
		gr_reset $task
		return
	}
	if { $block == {} } {
		log_puts "ERR" "gr_run $task empty block, end"
		return
	}
	if { $count == {} } {
		log_puts "ERR" "gr_run $task empty count"
		set count 0
	}
	log_puts "ALL" "gr_run $task block $block count $count"
	# a block has
	#
	# a name
	# a type
	#
	# an input
	# a list of outputs
	#
	# a list of fields
	#
	#
	#
	set vars {}
	catch { set vars [dict get $block vars] }
	set delay 1000
	catch { set delay [dict get $block vars delay] }
	set main [dict get $block main]
	set ondone [dict get $block ondone]
	set onfail [dict get $block onfail]

	log_puts "ALL" "gr_run $task script $::gr_blocks($task,$main) vars $vars"
	set res {}
	catch {
	set p $::gr_blocks($task,$main)
	set res [$p $task $vars]
	} err
	log_puts "ALL" "gr_run $task res $res err $err"

	if { $res == "done" } {
		log_puts "ERR" "gr_run $task done"
		set ::gr_view_state($task) [string range "gr_run $task done block $block" 0 80]
		after idle [list gr_run $task [lindex [array get ::gr_nodes $task,$ondone] end] $count]
	} elseif { $res == "fail" } {
		log_puts "ERR" "gr_run $task fail"
		set ::gr_view_state($task) [string range "gr_run $task fail block $block count $count" 0 80]
		after idle [list gr_run $task [lindex [array get ::gr_nodes $task,$onfail] end] $count]
	} elseif { $res == "delay" } {
		log_puts "ERR" "gr_run $task delay"
		set ::gr_view_state($task) [string range "gr_run $task delay block $block go to next" 0 80]
		after $delay [list gr_run $task [lindex [array get ::gr_nodes $task,$ondone] end] $count]
	} elseif { $res != "delay" && $count > 0 } {
		log_puts "ERR" "gr_run $task unclear, try again"
		set ::gr_view_state($task) [string range "gr_run $task unclear, try again block $block count $count - 1" 0 80]
		after $delay [list gr_run $task $block [expr {$count - 1}]] 
	} else {
		log_puts "ERR" "gr_run $task stop"
		set ::gr_view_state($task) [string range "gr_run $task stop block $block" 0 80]
		gr_reset $task
	}
} 

proc gr_obj_save {task vars} {
	set gid {}
	set name {}
	set obj {}
	catch {
	set gid [gr_synval [dict get $vars gid]]
	set name [gr_synval [dict get $vars name]]
	set obj [gr_synval [dict get $vars obj]]
	}
	return [saveobj $gid $name $obj]
}

proc gr_obj_find {task vars} {
	set gid {}
	set name {}
	set filter {}
	catch {
	set target [dict get $vars target]
	set gid [gr_synval $task [dict get $vars gid]]
	set name [gr_synval $task [dict get $vars name]]
	set filter [gr_synval $task [dict get $vars filter]]
	}
	set ret [findobj $gid $name $filter]
	if { $ret != {} && $target != {} } {
		set ::gr_vars($task,$target) $ret
		return 0
	}
	return
}

proc gr_obj_get {task vars} {
	set gid {}
	set name {}
	set hash {}
	catch {
	set target [dict get $vars target]
	set gid [gr_synval $task [dict get $vars gid]]
	set name [gr_synval $task [dict get $vars name]]
	set hash [gr_synval $task [dict get $vars hash]]
	}
	set ret [getobj $gid $name $hash]
	if { $ret != {} && $target != {} } {
		set ::gr_vars($task,$target) $ret
		return 0
	}
	return
}

proc gr_synval {task syn} {
	# I really want to make it possible
	# to choose between vars and consts
	# in editors, but later
	set var {}
	catch {
	set var [array names ::gr_vars "$task,$syn"]
	}
	if { $var == {} } {
		return $syn
	} else {
		return $::gr_vars($task,$syn)
	}
	### this further doesn't happen
	set type [lindex $syn 0]
	set data [lindex $syn 1]
	set ret {}
	switch $type {
		"c" {
			log_puts "ALL" "gr_synval it's a constant"
			set ret $data
		}
		"v" {
			log_puts "ALL" "gr_synval it's a variable"
			catch { set ret $::gr_vars($task,$data) }
		}
		default {
			log_puts "ALL" "gr_synval invalid type"
			set ret {}
		}
	}
	return $ret
}

proc gr_send {task vars} {
	log_puts "ALL" "gr_send task $task vars $vars"
	set gid {}
	set name {}
	set obj {}
	catch {
	set gid [gr_synval $task [dict get $vars gid]]
	set name [gr_synval $task [dict get $vars name]]
	set obj [gr_synval $task [dict get $vars obj]]
	}
	if { $gid == {} || $name == {} || $obj == {} } {
		log_puts "ERR" "gr_send necessary vars missing"
		return
	}
	set notice "GR $name [wrap $obj]"
	gchat_notice $gid $notice
}

proc gr_recv {task vars} {
	log_puts "ALL" "gr_recv task $task vars $vars"
	set target {}
	set gid {}
	catch {
	set target [dict get $vars target]
	set gid [gr_synval $task [dict get $vars gid]]
	set name [gr_synval $task [dict get $vars name]]
	}
	if { $target == {} || $gid == {} } {
		log_puts "ERR" "gr_recv necessary vars missing"
		return
	}
	set notices [array names ::gr_queue "$gid,$name,*"]
	set key [lindex [lsort -decreasing $notices] end]
	set ::gr_vars($task,$target) $::gr_queue($key)
	array unset ::gr_queue "$key"
}

proc gr_sync {task vars} {
	log_puts "ALL" "gr_sync task $task vars $vars"
	set gid {}
	set name {}
	set filter {}
	catch {
	set gid [gr_synval $task [dict get $vars gid]]
	set name [gr_synval $task [dict get $vars name]]
	set filter [gr_synval $task [dict get $vars filter]]
	}
	if { $gid == {} || $name == {} } {
		log_puts "ERR" "gr_sync necessary vars missing"
		return
	}
	set notice "GRS $name $filter"
	gchat_notice $gid $notice
}

proc gr_wintext {task vars} {
	log_puts "ALL" "gr_wintext task $task vars $vars"
	set name {}
	set x {}
	set y {}
	set w {}
	set h {}
	catch {
	set name [gr_synval $task [dict get $vars name]]
	set x [gr_synval $task [dict get $vars x]]
	set y [gr_synval $task [dict get $vars y]]
	set w [gr_synval $task [dict get $vars w]]
	set h [gr_synval $task [dict get $vars h]]
	}
	
	if { $name == {} || $x == {} || $y == {} || $w == {} || $h == {} } {
		log_puts "ERR" "gr_wintext necessary vars missing"
		return
	}

	lappend tags "name:$name" 

	set cw ".gr_view_$task.m.f.c"
	set tw "$cw.t_$name"
	text $tw -wrap word
	$cw create window [expr {$x+$w/2}] [expr {$y+$h/2}] -window $tw -width $w -height $h -tags $tags 
	return $tw
}

proc gr_settext {task vars} {
	log_puts "ALL" "gr_settext task $task vars $vars"
	set name {}
	catch { set name [dict get $vars name] }
	if { $name == {} } {
		log_puts "ERR" "gr_settext necessary vars missing"
		return
	}
	dict unset vars name
	set cw ".gr_view_$task.m.f.c"
	set tw "$cw.t_$name"
	foreach n {0} {
		set cmd [gr_synval $task [dict get $vars "${n}_cmd"]]
		set arg1 [gr_synval $task [dict get $vars "${n}_arg1"]]
		set arg2 [gr_synval $task [dict get $vars "${n}_arg2"]]
		switch $cmd {
			"clear" {
				$tw delete 1.0 end
			}
			"insert" {
				$tw insert end "$arg1\n" $arg2	
			}
			"configure" {
				$tw tag configure $arg1 {*}$arg2	
			}
			default {
				return
			}
		}
	}
	return

}

proc gr_n2t {n} {
	# that graphical editor has downsides, thus text representation
	set name [dict get $n name]
	set main [dict get $n main]
	set ondone [dict get $n ondone]
	set onfail [dict get $n onfail]
	set vars {}
	catch { set vars [dict get $n vars] }
	set svars {}
	foreach {k v} $vars {
		append svars "$k=$v "
	}
	append s "$main:$name d->$ondone f->$onfail {$svars}"
	return $s
}

proc gr_t2n {l} {
	# from text to scheme
	set name {}
	set main {}
	set ondone {}
	set onfail {}
	set svars {}
	set vars {}
	set name [lindex [split [lindex $l 0] {:}] 1]
	set main [lindex [split [lindex $l 0] {:}] 0]
	foreach token $l {
		if { [string range $token 0 2] == "d->" } {
			set ondone [string range $token 3 end]	
		}
		if { [string range $token 0 2] == "f->" } {
			set onfail [string range $token 3 end]	
		}
		if { [string index $token 0] == "{" && [string index $token end] == "}" } {
			set svars [string range $token 1 end-1]
		}
	}
       	foreach s $svars {
		set k {}
		set v {}
		set i [string first {=} $s]
		set k [string range $s $i-1]
		set v [string range $s $i+1]
		dict set vars $k $v	
	}
	log_puts "ALL" "gr_t2n name $name main $main ondone $ondone onfail $onfail vars $vars"
	set t {}
	dict set t name $name
	dict set t main $main
	dict set t ondone $ondone
	dict set t onfail $onfail
	dict set t vars $vars
	return $t
}

proc gr_openfile {task tw} {
	if { $task == {} } {
		return
	}
	log_puts "ALL" "gr_openfile $task"
	set types {
		{{GR} {.gr}}
	}
	set filename [tk_getOpenFile -filetypes $types]
	if { $filename == {} || ![file exists $filename] } {
		log_puts "ERR" "gr_openfile $task no name given or no such file"
		return
	}
	set f [open $filename r]
	fconfigure $f -translation binary -buffering none
	set data [read $f]
	close $f
	log_puts "ALL" "gr_openfile $task done, open in editor"
	set ::gr_edit_subject($task) [lindex [file split $filename] end]
	show_gredit $task $data $tw
}

proc gr_savefile {task} {
	if { $task == {} } {
		return
	}
	log_puts "ALL" "gr_savefile $task"
	set types {
		{{GR} {.gr}}
	}
	set filename [tk_getSaveFile -filetypes $types]
	if { $filename == {} } {
		log_puts "ERR" "gr_savefile $task no name given"
		return
	}
	if { [file exists $filename] } {
		set ans [tk_messageBox -message "File exists, overwrite?" -type yesno]
		if { $ans != {yes} } {
			log_puts "ERR" "gr_savefile $task not overwriting file"
			return
		}		
	}
	set data [gr_edit_form $task]
	set f [open $filename w]
	fconfigure $f -translation binary -buffering none
	puts -nonewline $f $data
	close $f
	log_puts "ALL" "gr_savefile $task done"
}

### What we need to make a "webpage" with a chatroom using GR:
# receive notices:
# 1) can't store last notice in a variable, it'll be a race condition
# 2) can't allow a scheme to mess up anything other than object storage
# 3) have to somehow filter notices - groups solve author's membership,
# but rights in this scheme have to be resolved ; perhaps we can have
# a control message with a scheme in a group, that scheme takes notice
# components and returns a value
# 4) or we can have only one scheme message, that embeds a node to get
# a scheme object, that in turn gets executed and checks for permission
# 5) or we can get messages from object storage filtered by control
# type and author and, ahem, replay them
# 6) if we have replace functionality, and permissions on the same
# level, then we can just replay to the last control rule,
# which can simply list privilege levels (read-only,read-write,moderator),
# but in that case it's best to have an index where one can quickly find
# all objects with the same root
#
# thus we can check which notices are not to be ignored
# we need to check them to not litter storage, because
# the check for objects read en masse from storage
# obviously doesn't remove what's already stored
#
# send notices:
# 1) no way in hell we can send requests to specific peers
# from a scheme ; the question is, whether we can send them
# to other groups, or, alternatively, to other topics than
# ours ; namespace is an internal concept, so inside
# scheme one can choose different namespaces
# 2) a notice is an object with time mark signed by us and
# possibly replacing another, no other traits, it's a meta system ;
# perhaps a root/child/replace type should also be common
# 
# author, object hash, object sig, object
# in the scheme itself there's no need to consider signature checks
# so a notice is sent by topic to peers whom we know to be on it
#
# change and check privileges:
# 1) sending a control message is the easy part
# 2) checking it is the hard one
# 3) we want a meta-system, thus we can't do it below this level
# 4) we can get objects in order, and we can have a few list variables
# with privilege levels
# 5) so we can loop through objects, but it's slow with this ; we can
# loop through filtered control objects and those will be fewer,
# and we can store replay results for a period for ourselves to not
# do it every time, that a scheme can do, so keep a topic state for
# ourselves as an object, and replay control messages only for
# period after that, for which we get objects from synced storage
# by time period and type
#
# sync storage:
# 1) that's a problem, but we can take the last control message we have
# and sync in portions
# 2) we can sync via notices, they are not the same as storage
# 3) a notice can have an attribute saying it shouldn't be stored
# 4) and an object can contain anything, so we can just request a period
# in a notice ... and get a fuckload of responses, so it should probably
# name a specific user, then after some delay another notice with another
# user, and so on
# 5) so for syncing storage we are broadcasting that we need help
# that's not an operation done too often with small latency needed,
# so we can broadcast our cry for help, then get similarly broadcasted
# responses, then broadcasted archive ... never mind
# 6) but since this part doesn't have to be on the scheme level,
# syncing can be done without broadcasts, just carefully in small intervals,
# in scheme it'll just be a block with filter supplied
# 7) I think this might be a group, not topic, business after all
# or one can have schemes with different communication context,
# some offline, some for groups, some for topics
#
# need to start schemes with context
# need to pass topic, group, whatever is needed, basically arguments
# need to return value
#
# need a block to start an object like a scheme, and to get return value 
#
# the beauty part:
# 1) printing text in canvas and selecting it is using a wrong tool,
# should instead embed a text widget, which is supported, but that
# means we need a block to set up a text widget inside canvas,
# and a block to change text in it
# 2) should be able to also embed entry widget in canvas and trigger
# input action by pressing Return, which means detecting the focused
# widget in canvas and identifying it (name tag is probably good enough)
# 3) alternatively can have one entry area, perhaps even a text widget, below,
# and use it similarly to prompts in Gemini ; entry prompt and reaction
# would be all customizable from scheme
# 4) in that logic the default text widget can also be something like a log
# area below canvas, and it all can be one window, with unused panes hidden,
# or perhaps hidden and shown by scheme
# 
# considering that people call Telegram convenient, I think I'll do that.
# still leaves need to show various text widgets embedded in canvas,
# otherwise copying long texts from it is a problem.
#
# but! the manpage says actually selecting text in canvas isn't that hard
# text widgets are cool, but perhaps I'll try without embedding anything
#
# canvas scroll and image background (unmoving when scrolling) seem a good idea
# if we scroll not the image, but the widgets on top of it
#

### Alternative version
#
# I don't need this graphical thing. I also don't need these node dependencies. OK, suppose I even
# do, but I can assign scripts to nodes with tasks and vars with no participation of a painful
# to use graphical editor.
#
# I can use a set of input variables and a safe interpreter, used upon the last control rule posted by
# group owner. A control rule is a script in such a situation, and it operates upon an arriving message.
#
# This means other users can't post control rules, and I am fine with that.
#
# Current control rule for a group can be cached to a variable? I don't know.
#
# Needs another message type for groups.
#
# 
#
#

### end

### all the previous has been deemed bullshit
# instead control messages with replay have been added
# perhaps some sort of index for ht pages with replay
# is also possible, to have readable links inside the
# group

proc saveobj {gid name obj} {
	set path [file join $::filepath "obj" "${gid}_${name}.dat"]
	set ho {}
	foreach o $obj {
		set h [::sha1::sha1 -hex $o]
		lappend ho $h $o
	}
	return [save_bin $path $ho]
}

proc findobj {gid name filter} {
	set path [file join $::filepath "obj" "${gid}_${name}.dat"]

	set sts {}
	catch {
	set sts [dict get $filter sts]
	dict unset filter sts
	}

	set ets {}
	catch {
	set ets [dict get $filter ets]
	dict unset filter ets
	}

	set hash {}
	catch {
	set hash [dict get $filter hash]
	dict unset filter hash
	}

	return [find_bin $path $hash $sts $ets $filter]
}

proc getobj {gid name hash} {
	set path [file join $::filepath "obj" "${gid}_${name}.dat"]
	return [get_bin $path $hash]
}

proc delobj {gid name hash} {
	set path [file join $::filepath "obj" "${gid}_${name}.dat"]
	return [del_bin $path $hash]
}

