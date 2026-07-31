#
# FS - I don't need storage management - I already have a filesystem
# I need CREATE, READ, UPDATE and DELETE operations
#
# I notably need them on dirs as much as on files
# I can simply use every path as resource to be created, updated, read or deleted
# value is ctime:mtime:ownerpeerid:size:type:filehash
#   type is dir/file
#   filehash is empty for dirs
#   atime is not needed
#
# thus I flatten the FS into a simple index, storing it in a directory

proc ml_filedict {fvalue} {
	set s [split $fvalue {:}]
	set d {}
	dict set d ctime [lindex $s 0]
	dict set d mtime [lindex $s 1]
	dict set d ownerpeerid [lindex $s 2]
	dict set d size [lindex $s 3]
	dict set d type [lindex $s 4]
	dict set d filehash [lindex $s 5]
	return $d
}

proc ml_dictfile {fdict} {
	set ctime [dict get $fdict ctime]
	set mtime [dict get $fdict mtime]
	set ownerpeerid [dict get $fdict ownerpeerid]
	set size [dict get $fdict size]
	set type [dict get $fdict type]
	set filehash [dict get $fdict filehash]
	return "$ctime:$mtime:$ownerpeerid:$size:$type:$filehash"
}

###
# some kind of local (no exchange yet) group filesystem browser
### 
proc show_files args {
	if { [winfo exists .fff] == 1 } {	
		return
	}
	set t [lindex $args 0]
	set id [lindex $args 1]
	set files [unwrap [lrange $args 2 end]]
	set ::fff_pwd /
	set ::fff_cid $id
	set ::fff_files $files
	toplevel .fff
	wm title .fff "Files $t id $id files $files"
	pack [panedwindow .fff.p -ori vert] -fill both -expand 1
	.fff.p add [frame .fff.t] -stretch never 
	#pack [wbutton .fff.t.x -text "exit" -activebackground $::options(hilightcolor) -activeforeground $::options(basecolor) -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor)  -font $::options(font) -command "destroy .fff"] -fill both -side left 
	.fff.p add [frame .fff.l] -stretch always
	pack [wscrollbar .fff.l.y -activebackground $::options(hilightcolor) -troughcolor $::options(hilightcolor) -command "tl_yview 2 .fff.l.n .fff.l.s"] -fill y -side right
	pack [listbox .fff.l.n -listvariable ::ml_fnode_name -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) -selectforeground $::options(basecolor) -selectbackground $::options(hilightcolor) -font $::options(font) -height 24 -width 40 -yscrollc ".fff.l.y set"] -fill both -expand 1 -side left
	pack [listbox .fff.l.s -listvariable ::ml_fnode_size -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) -selectforeground $::options(basecolor) -selectbackground $::options(hilightcolor) -font $::options(font) -height 24 -width 8 -yscrollc ".fff.l.y set"] -fill y -side left
	.fff.p add [frame .fff.b] -stretch never 
	pack [wbutton .fff.b.get -text "get" -activebackground $::options(hilightcolor) -activeforeground $::options(basecolor) -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor)  -font $::options(font) -command {show_filedialog [lindex $::ml_fnode [lindex [.fff.l.n index active] 0]] {}}] -fill both -side right
	#.fff.p add [frame .fff.n] -stretch never 
	#pack [wbutton .fff.n.up -text "up" -activebackground $::options(hilightcolor) -activeforeground $::options(basecolor) -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor)  -font $::options(font) -command {ml_schedup}] -fill both -side right
	#pack [wbutton .fff.n.down -text "down" -activebackground $::options(hilightcolor) -activeforeground $::options(basecolor) -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor)  -font $::options(font) -command {ml_scheddown}] -fill both -side right
	#.fff.p add [frame .fff.b] -stretch never 
	#pack [wbutton .fff.b.get -text "get" -activebackground $::options(hilightcolor) -activeforeground $::options(basecolor) -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor)  -font $::options(font) -command {ml_schedget [lindex $::ml_fnode_name [lindex [.fff.l.n index active] 0]]}] -fill both -side right
	#pack [wbutton .fff.b.put -text "put" -activebackground $::options(hilightcolor) -activeforeground $::options(basecolor) -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor)  -font $::options(font) -command {ml_schedput}] -fill both -side right
	#pack [wbutton .fff.b.mkdir -text "mkdir" -activebackground $::options(hilightcolor) -activeforeground $::options(basecolor) -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor)  -font $::options(font) -command {ml_schedmkdir}] -fill both -side right
	#pack [wbutton .fff.b.del -text "delete" -activebackground $::options(hilightcolor) -activeforeground $::options(basecolor) -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor)  -font $::options(font) -command {ml_scheddel [lindex $::ml_fnode_name [lindex [.fff.l.n index active] 0]]}] -fill both -side right
	update_fnodes $::fff_files
}

proc ml_schedup {} {
	if { $::fff_pwd == {/} } {
		return
	}
	set sp [file split $::fff_pwd]
	set np [file join [lrange $sp 0 end-1]]
	set ::fff_pwd $np
	update_fnodes
}

proc ml_scheddown {name} {
	if { $name == "" } {
		return
	} 
	set np [file join $::fff_pwd $name]
	set ::fff_pwd $np
	update_fnodes
}

proc ml_schedget {name} {
	set fp [file join $::fff_pwd $name]
	set fv [ml_get_file $::fff_gid $fp]
	# need to add file to downloads and index by path
	set d {}
	dict set d filename $name
	dict set d filehash [dict get $fv hash] 
	dict set d offset 0
	dict set d len [dict get $fv size] 
	dl_add [dl_dictreq $d] {} {}
}

proc ml_schedput {} {
	set path [tk_getOpenFile]
	set sname [lindex [file split $path] end]
	log_puts "ALL" "path $path"
	set f [open $path r]
	fconfigure $f -translation binary
	set data [read $f]
	close $f
	ml_add_eml $data
	set hash [sha1::sha1 $data]
	set npath [file join $::fff_pwd $sname]
	# need to create structure and index by path
	set struct "[clock seconds]:[clock seconds]:${::me(id)}:[string length $data]:file:$hash"
	ml_add_file $::fff_gid $npath $struct
	update_fnodes
}

proc ml_schedmkdir {} {
	#show_mkdir_entry $::fff_gid $::fff_pwd
	# need to index directory by path
	update_fnodes
}

proc ml_scheddel {name} {
	set fp [file join $::fff_pwd $name]
	# need to remove from index by path
	update_fnodes
}

proc update_fnodes {files} {
	if { $::fff_pwd == "" } {
		set ::fff_pwd / 
	}
	set cid $::fff_cid
	set ::ml_fnode_name {}
	set ::ml_fnode_size {}
	set ::ml_fnode_hash {}
	set ::ml_fnode {}
	foreach {fcur d} $files {
		log_puts "ALL" "dict $d"
		lappend ::ml_fnode_name [unwrap [dict get $d name]]
		lappend ::ml_fnode_size [dict get $d size]
		lappend ::ml_fnode_hash $fcur 
		lappend ::ml_fnode [dict get $d name]:$fcur:0:[dict get $d size]
	}
}
