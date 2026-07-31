proc mysm_text {task gid txt} {
	if { $task == {} } {
		log_puts "ERR" "mysm_text task empty"
		return
	}
	set ::mysm($task,gid) $gid
	set ::mysm($task,w) ".mysm_$task"
	set c 0
	foreach line [split $txt "\n"] {
		log_puts "ALL" "mysm_text load line $line"
		set ::mysm($task,lines,$c) $line
		if { [string index [string trim $line] end] == {:} } {
			set ::mysm($task,marks,[string range [string trim $line] 0 end-1]) $c
		} 
		incr c 1
	}
	set ::mysm($task,end) $c
	set ::mysm($task,pc) 0
}

proc mysm_exec {task} {
	set pc {}
	catch {
	set pc $::mysm($task,pc)
	}
	if { $pc == {} } {
		log_puts "ERR" "mysm_exec it appears pc is not set, meaning we're not running"
		after idle [list mysm_clear $task]
		return
	}
	if { $pc == $::mysm($task,end) } {
		return
	}
	set line $::mysm($task,lines,$pc)
	set term [lindex $line 0]
	log_puts "ALL" "mysm_exec pc $pc line $line term $term"
	switch $term {
		"mov" {
			set treg [lindex $line 1]
			set freg [lindex $line 2]
			set ::mysm($task,regs,$treg) $::mysm($task,regs,$freg)
		}
		"load" {
			set treg [lindex $line 1]
			set num [lindex $line 2]
			set ::mysm($task,regs,$treg) $num
		}
		"in" {
			set treg [lindex $line 1]
			set fin [lindex $line 2]
			set ::mysm($task,regs,$treg) [lpop ::mysm($task,ins,$fin)]
		}
		"out" {
			set tout [lindex $line 1]
			set freg [lindex $line 2]
			lappend ::mysm($task,outs,$tout) $::mysm($task,regs,$freg)	
		}
		"add" {
			set treg [lindex $line 1]
			set freg [lindex $line 2]
			incr ::mysm($task,regs,$treg) $::mysm($task,regs,$freg)
		
		}
		"sub" {
			set treg [lindex $line 1]
			set freg [lindex $line 2]
			incr ::mysm($task,regs,$treg) -$::mysm($task,regs,$freg)
		}
		"cmp" {
			set treg [lindex $line 1]
			set freg [lindex $line 2]
			if { $::mysm($task,regs,$treg) == $::mysm($task,regs,$freg) } {
				set ::mysm($task,flags,eq) 1
			} else {
				set ::mysm($task,flags,eq) 0
			}
		}
		"je" {
			set npc $::mysm($task,marks,[lindex $line 1])
			if { $::mysm($task,flags,eq) == 1 } {
				set ::mysm($task,pc) $npc
				return
			}
		}
		"jne" {
			set npc $::mysm($task,marks,[lindex $line 1])
			if { $::mysm($task,flags,eq) != 1 } {
				set ::mysm($task,pc) $npc
				return
			}
		}
		"jmp" {
			set npc $::mysm($task,marks,[lindex $line 1])
			set ::mysm($task,pc) $npc
			return
		}
		"pop" {
			set treg [lindex $line 1]
			set ::mysm($task,regs,$treg) [lpop ::mysm($task,stack)]
		}
		"push" {
			lappend ::mysm($task,stack) $::mysm($task,regs,[lindex $line 1])
		}
		"call" {
			set npc [lindex $line 1]
			lappend ::mysm($task,stack) $::mysm($task,pc)
			set ::mysm($task,pc) $npc
			return
		}
		"ret" {
			set ::mysm($task,pc) [lpop ::mysm($task,stack)]
			if { $::mysm($task,pc) == {} } {
				set ::mysm($task,pc) $::mysm($task,end)
			}
			return
		}
		default {
		
		}
	}
	incr ::mysm($task,pc) 1
	if { $::mysm($task,pc) < $::mysm($task,end) } {
		set ::mysm($task,label) "exec run"
		log_puts "ALL" "mysm_exec again"
		mysm_exec $task
	} else {
		set ::mysm($task,label) "exec stop"
		log_puts "ALL" "mysm_exec done"
	}
}

proc mysm_int {task mark} {
	log_puts "ALL" "mysm_int $task $mark"
	set pc {}
	catch { set pc $::mysm($task,marks,$mark) }
	if { $pc == {} } {
		return
	}
	set ::mysm($task,pc) $pc
	mysm_exec $task
}

proc mysm_clear {task} {
	set w ".mysm_$task"
	array unset ::mysm "$task,*"
	set ::mysm($task,label) "cleared"
	$w.x.t insert end "cleared" {red}
}

#set testprog {
#load reg0 123
#load reg1 qwe
#out out0 reg0
#out out0 reg1
#}

#mysm_text test {} $testprog
#mysm_exec test
#puts "out ${::mysm(test,outs,out0)}"
#puts "::mysm [array get ::mysm test,*]"

#vwait forever

### What it can be used for

# if we have sync outs and sync ins, we can put a TCL
# event handler on sync out and sync in, do _something_
# on sync out change and call mysm "interrupt" on
# sync in change.
#
# that means we can have a set of outputs describing a
# screen with text and perhaps a canvas, and a set of
# inputs describing something like incoming events
# queue, and a set of outputs for outgoing events.
#
# that can be used to request letters and render them.
# but really I don't know what that can be used for.
# we can have a timer interrupt and animations.
#
# we can obviously have _anything_ with this, just
# not sure what's the fun place it can have in
# Mysteria letters.
#
# perhaps animations is what I'll use it for.

### List of inputs and outputs

# ins:
#
# nin0 - input 1, event elements number 
# nin1 - input 2, event elements sequence
# nin2 - input 3, event topic
# ninS - input sync, does nothing, calls interrupt by mark "tin"
#
# outs:
#
# nout0 - output 1, event elements number
# nout1 - output 2, event elements sequence
# nout2 - output 3, event topic
# noutS - output sync, does nothing, means that output message is formed
#
# dout0 - disp output 1, text string tokens number
# dout1 - disp output 2, text string tokens sequence
# dout2 - disp output 3, tag string tokens number
# dout3 - disp output 4, tag string tokens sequence 
# doutS - disp output sync, display message is formed
# doutC - disp output clear, need to clear display 
#
# gout0 - graphical output 1, graphical elements number 
# gout1 - graphical output 2, coordinate x seq
# gout2 - graphical output 3, coordinate y seq
# gout3 - graphical output 4, width seq
# gout4 - graphical output 5, height seq
# gout5 - graphical output 6, color seq
# goutS - graphical output sync, output seq is formed
# goutC - graphical output clear, need to clear canvas

proc mysm_nin {task topic body} {
	set seq {}
	binary scan $body cu* seq
	set num [llength $seq]
	lappend ::mysm($task,ins,nin0) $num
	lappend ::mysm($task,ins,nin1) $seq
	lappend ::mysm($task,ins,nin2) $topic
	set ::mysm($task,ins,ninS) {} 
}

proc mysm_nout {task} {
	set num [lpop ::mysm($task,outs,nout0)]
	set seq [lrange $::mysm($task,outs,nout1) 0 $num-1] 
	set ::mysm($task,outs,nout1) [lrange $::mysm($task,outs,nout1) $num end] 
	set topic [lpop ::mysm($task,outs,nout2)]
	set body [binary format cu* $seq]
	set gid $::mysm($task,gid)
	set notice "MYSM $topic [wrap $body]"
	gchat_notice $gid $notice
}

proc mysm_dout {task} {
	set snum [lpop ::mysm($task,outs,dout0)]
	set sseq [lrange $::mysm($task,outs,dout1) 0 $snum-1] 
	set ::mysm($task,outs,dout1) [lrange $::mysm($task,outs,dout1) $snum end] 
	set tnum [lpop ::mysm($task,outs,dout2)]
	set tseq [lrange $::mysm($task,outs,dout3) 0 $tnum-1] 
	set ::mysm($task,outs,dout3) [lrange $::mysm($task,outs,dout3) $tnum end] 
	set sbody [binary format cu* $sseq]
	set tbody [binary format cu* $tseq]
	$::mysm($task,w) insert end $sbody $tbody
}

proc mysm_load {task} {
	set w ".mysm_$task"
	set group $::cur(main,group,h)
	if { $group == {} } {
		set gid {}
	} else {
		set g [ml_groupdict $group]
		set gid {}
		catch { set gid [dict get $g gid] }
	}
	set txt [$w.e.t get 1.0 end]
	mysm_text $task $gid $txt
	set ::mysm($task,ins,inS) {}
	set ::mysm($task,outs,outS) {}
	set ::mysm($task,outs,doutS) {}
	trace add variable ::mysm($task,ins,ninS) write "mysm_int $task ninput"
	trace add variable ::mysm($task,outs,noutS) write "mysm_out $task"
	trace add variable ::mysm($task,outs,doutS) write "mysm_dout $task"
	set ::mysm($task,label) "loaded"
}

proc mysm_open {task} {
	set path [tk_getOpenFile]
	if { ![file exists $path] } {
		return
	}
	set c {}
	catch { set c [open $path r] }
	if { $c == {} } {
		return
	}
	fconfigure $c -translation binary -buffering none
	set data [read $c]
	close $c
	$w.e.t insert end $data {}
	$w.e.t insert end "\n" {}
	set ::mysm($task,label) "opened $path"
}

proc mysm_save {task} {
	set path [tk_getSaveFile]
	set c {}
	catch { set c [open $path w] }
	if { $c == {} } {
		return
	}
	fconfigure $c -translation binary -buffering none
	puts -nonewline $c [$w.e.t get 1.0 end]
	close $c
	set ::mysm($task,label) "saved $path"
}

proc mysm_insert {task tw} {
	set w ".mysm_$task"
	set fw "$w.e.t"
	set notice "MYSM [wrap [$fw get 1.0 end]]"
	$tw insert end $notice {mysm}
	$tw insert end "\n" {}
}

proc mysm_enter {task} {
	set txt $::mysm($task,entry)
	set seq {}
	binary scan $txt cu* seq
	set len [llength $seq]
	lappend ::mysm($task,ins,ein0) $len
	lappend ::mysm($task,ins,ein1) $seq
	mysm_int $task einput
}

proc show_mysm {task data tw} {
	if { $task == {} } {
		set task [clock microseconds]
	}
	set w ".mysm_$task"
	if { [winfo exists $w] } {
		return
	}
	toplevel $w
	wm title $w "MYSM #$task"
	### edit pane, output pane ###
	pack [panedwindow $w.p -ori vert] -fill both -expand 1
	$w.p add [frame $w.t] -minsize 24 -stretch never
	pack [wbutton $w.t.open -text "open" -command "mysm_open $task"] -fill both -side left
	pack [wbutton $w.t.save -text "save" -command "mysm_save $task"] -fill both -side left
	if { $tw != {} && [winfo exists $tw] } {
		pack [wbutton $w.t.insert -text "insert" -command "mysm_insert $task $tw"] -fill both -side left
	}
	pack [wlabel $w.t.l -text "MYSM #$task"] -side left
	pack [wbutton $w.t.b0 -text "exec" -command "mysm_exec $task"] -fill both -side right
	pack [wbutton $w.t.b1 -text "load" -command "mysm_load $task"] -fill both -side right
	pack [wbutton $w.t.b2 -text "clear" -command "mysm_clear $task"] -fill both -side right
	###
	set q {}
	append q "+++\n"
	append q "Ops (data): mov <t> <f>, load <t> <c>, in <t> <i>, out <o> <f>\n"
	append q "Ops (math): add <t> <f>, sub <t> <f>\n"
	append q "Ops (jump): cmp <r> <r>, je <m>, jne <m>, jmp <m>\n"
	append q "Ops (stack): pop <t>, push <f>, call <m>, ret\n"	
	append q "+++\n"
	append q "Ins (entry): ein0 (num), ein1 (seq)\n"
	append q "Ins (net): nin0 (num), nin1 (seq),\n  nin2 (topic), ninS (sync)\n"
	append q "Outs (net): nout0 (num), nout1 (seq),\n  nout2 (topic), noutS (sync)\n"
	append q "Outs (disp): dout0 (snum), dout1 (sseq),\n  dout2 (tnum), dout3 (tseq),\n  doutS (sync), doutC (clear)\n"
	append q "+++\n"
	append q "Reserved marks: ninput, einput\n"
	append q "+++\n"
	###
	#$w.p add [frame $w.q] -minsize 24 -stretch never
	#pack [wlabel $w.q.l -text "$q"] -side left
	###
	$w.p add [frame $w.e] -stretch always
	pack [wscrollbar $w.e.y -command "$w.e.t yview"] -fill y -side right
	pack [text $w.e.t -wrap word -font $::options(font) -yscrollc "$w.e.y set" \
		-highlightthickness $::options(line_th) -selectbackground $::options(hilightcolor) \
		-highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) \
		] -fill both -expand 1 -side right
	###
	if { $data != {} } {
	$w.e.t insert end $data {}	
	$w.e.t insert end "\n" {}	
	} else {
	$w.e.t insert end "jmp done\n" {}
	$w.e.t insert end "ninput:\n" {}
	$w.e.t insert end "jmp done\n" {}
	$w.e.t insert end "einput:\n" {}
	$w.e.t insert end "done:\n" {}
	}
	###
	$w.p add [frame $w.x] -stretch always
	pack [wscrollbar $w.x.y -command "$w.x.t yview"] -fill y -side right
	pack [text $w.x.t -wrap word -font $::options(font) -yscrollc "$w.x.y set" \
		-highlightthickness $::options(line_th) -selectbackground $::options(hilightcolor) \
		-highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) \
		] -fill both -expand 1 -side right
	###
	$w.p add [frame $w.ee] -minsize 24 -stretch never
	pack [wentry $w.ee.e -textvar ::mysm($task,entry)] -fill both -expand 1 -side left
	pack [wbutton $w.ee.s -text "enter" -command "mysm_enter $task"] -fill both -side right
	$w.p add [frame $w.b] -minsize 24 -stretch never
	pack [wlabel $w.b.l -textvar ::mysm($task,label)] -side left
	###
	$w.x.t tag configure red -foreground red
	$w.x.t tag configure green -foreground green
	$w.x.t tag configure blue -foreground blue
	$w.x.t tag configure yellow -foreground yellow
	$w.x.t tag configure cyan -foreground cyan
	$w.x.t tag configure magenta -foreground magenta
	$w.x.t tag configure underline -underline true
	$w.x.t tag configure hide -elide true

	$w.x.t insert end "$q\n" {green}
}
