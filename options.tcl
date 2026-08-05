proc write_ini {} {
	set path [file join $::filepath "options.ini"]
	set c [open $path w]
	puts $c {[mysteria]}
	foreach {key value} [lsort -stride 2 -index 0 [array get ::options]] {
		if { $key == {} } {
			continue
		}
		set s "$key=$value"
		puts $c $s
	}
	flush $c
	close $c
}

proc read_ini {} {
	set path [file join $::filepath "options.ini"]
	if { [file exists $path] == 0 } {
		return
	}
	set c [open $path r]
	set body [read $c]
	close $c
	set lines [split $body "\n"]
	set header [lindex $lines 0]
	if { $header != {[mysteria]} } {
		return
	}
	set lines [lrange $lines 1 end]
	foreach line $lines {
		set first {}
		set first [string first {=} $line]
		set key [string range $line 0 $first-1]
		if { $key == {} } {
			continue
		}
		set value [string range $line $first+1 end]
		if { $value == {} } {
			continue
		}
		set ::options($key) $value
	}
}

proc show_options {} {
	set w .opt
	if { [winfo exists $w] == 1 } {
		return
	}
	toplevel $w
	wm title $w "Options"
	pack [panedwindow "$w.p" -ori ver] -fill both -expand 1
	"$w.p" add [frame "$w.t"] -minsize 24 -stretch never
	pack [label "$w.t.l" -text "Options list:" -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) -font $::options(font) ] -fill both -side left
	"$w.p" add [panedwindow "$w.o" -ori ver] -stretch always
	set i 0
	foreach {key value} [lsort -stride 2 -index 0 [array get ::options]] {
		if { $key == {} } {
			continue
		}
		"$w.o" add [frame "$w.t_$i"] -minsize 24 -stretch never
		pack [label "$w.t_$i.l" -text "$key" -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) -font $::options(font) ] -fill both -side left
        	pack [wentry "$w.t_$i.e" -textvar ::options($key) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor) -font $::options(font) ] -fill both -side right
		incr i 1
	}
	"$w.p" add [frame "$w.b"] -minsize 24 -stretch never
	pack [wbutton "$w.b.r" -text "read" -activebackground $::options(hilightcolor) -activeforeground $::options(basecolor) -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor)  -font $::options(font) -command "read_ini"] -fill both -side right
	pack [wbutton "$w.b.w" -text "write" -activebackground $::options(hilightcolor) -activeforeground $::options(basecolor) -highlightthickness $::options(line_th) -highlightcolor $::options(bordercolor) -highlightbackground $::options(hilightcolor)  -font $::options(font) -command "write_ini ; msg_set"] -fill both -side right
}
