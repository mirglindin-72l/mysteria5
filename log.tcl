# 0 - errors are printed, 1 - also warnings, 2 - everything 
set ::log_level 2
set ::log_path [file join "." "log_[clock format [clock seconds] -format {%Y%m%d_%H%M%S}].log"]
set ::log [open $::log_path w]
set ::loglist {}
puts "Open log at $::log_path"


proc log_puts {lvl msg} {
	switch $lvl {
		"ERR" {
			set n 0
		}
		"WARN" {
			set n 1
		}
		"ALL" {
			set n 2
		}
		default {
			set n 2
		}
	}
	set tw [string range "LOG ($lvl) [clock format [clock seconds] -format {%b-%d %H:%M:%S}]: $msg" 0 199]
	if { $n <= $::log_level } {
		puts $::log "$tw" 
		flush $::log
		puts "$tw" 

		set ::loglist [linsert $::loglist 0 "$tw"]
		set ::loglist [lrange $::loglist 0 128]
	}
	return
}
