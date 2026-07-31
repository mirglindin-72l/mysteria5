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

proc ::tcl::chan::myrb {} {
    return [::chan create {read write} [myrb::implementation new]]
}

oo::class create ::tcl::chan::myrb::implementation {
    superclass ::tcl::chan::events ; # -> initialize, finalize, watch

    method initialize {args} {
	set c [lindex $args 0]
	set qptr {}
	catch { set qptr $::cur(qptr,$c) }
	if { $qptr == {} } {
		set ::cur(qptr,$c) [::queue::init_raw 96000]
	}
	my allow write
	next {*}$args
    }

    method read {c n} {
	set result {}

	set result [::queue::read_raw $::cur(qptr,$c) $n]

	set n [string length $result]
	set nsz [expr {$size-$n}]
	if { $nsz >= 0 } {
		set size $nsz
	} else {
		set size 0
	}

	#my Readable

	if {$result eq {}} {
	    return -code error EAGAIN
	}

	return $result
    }

    method write {c bytes} {
	set n [::queue::write_raw $::cur(qptr,$c) $bytes]

	set nsz [expr {$size+$n}]
	if { $nsz > 96000 } {
		set size 96000
	} else {
		set size $nsz
	}

	my Readable

	return $n
    }

    # # ## ### ##### ######## #############

    variable qptr size

    # # ## ### ##### ######## #############

    constructor {} {
	set size 1
	next
    }

    method Readable {} {
	puts "size $size"
	if { $size } {
	    puts "read allow"
	    my allow read
	} else {
	    puts "read disallow"
	    my disallow read
	}
	return
    }
}

# # ## ### ##### ######## #############
package provide tcl::chan::myrb 1.1
return
