# -*- tcl -*-
# # ## ### ##### ######## #############
# (C) 2009 Andreas Kupries

# @@ Meta Begin
# Package tcl::chan::fifo_fix 1.1
# Meta as::author {Andreas Kupries}
# Meta as::copyright 2009
# Meta as::license BSD
# Meta description Re-implementation of Memchan's fifo
# Meta description channel. Based on Tcl 8.5's channel
# Meta description reflection support. Exports a single
# Meta description command for the creation of new
# Meta description channels. No arguments. Result is the
# Meta description handle of the new channel.
# Meta platform tcl
# Meta require TclOO
# Meta require tcl::chan::events
# Meta require {Tcl 8.5}
# @@ Meta End
# # ## ### ##### ######## #############

####
#
#
#
#
#
####

package require Tcl 8.5 9
package require TclOO
package require tcl::chan::events

# # ## ### ##### ######## #############

namespace eval ::tcl::chan {}

proc ::tcl::chan::fifo_fix {} {
    return [::chan create {read write} [fifo_fix::implementation new]]
}

oo::class create ::tcl::chan::fifo_fix::implementation {
    superclass ::tcl::chan::events ; # -> initialize, finalize, watch

    method initialize {args} {
	my allow write
	next {*}$args
    }

    method read {c n} {
	set result {}

	#puts "FIFO read $c $n"
	if { $n >= $size } {
		set result $data
		set data {}
		set size 0
	} else {
		set result [string range $data 0 $n-1]
		set data [string range $data $n end]
		set size [expr {$size-$n}]
	}
	my Readable

	if {$result eq {}} {
	    return -code error EAGAIN
	}

	return $result
    }

    method write {c bytes} {
	#puts "FIFO write $c len=[string length $bytes]"
	append data $bytes
	set n [string length $bytes]
	set size [expr {$size+$n}]
	my Readable

	return $n
    }

    # # ## ### ##### ######## #############

    variable start end size data

    # # ## ### ##### ######## #############

    constructor {} {
	set start 0
	set end 0
	set data {}
	set size  0
	next
    }

    method Readable {} {
	if { $size } {
            #puts "FIFO readable allow"
	    my allow read
	} else {
            #puts "FIFO readable disallow"
	    my disallow read
	}
	return
    }
}

# # ## ### ##### ######## #############
package provide tcl::chan::fifo_fix 1.1
return
