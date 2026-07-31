package require critcl

if {![critcl::compiling]} {
	error {critcl found no compiler}
}

namespace eval ::queue {
	variable bindingsVersion 999;
	variable version {};
}

critcl::framework

critcl::cflags -Wall -Os -c -I./contrib/queue
critcl::ldflags -Os -L./contrib/queue

critcl::ccode {
	#include <stdio.h>
	#include <string.h>
	#include <stdint.h>
	#include <stdlib.h>
	
	#include "queue.h"
	#include "queue.c"
}	

critcl::cinit {
	char s[32];
	Tcl_CreateNamespace(ip, "::queue", NULL, NULL);
	sprintf(s, "69");
	Tcl_SetVar2Ex(ip, "::queue::version", NULL, Tcl_NewStringObj(s, -1), 0);
} {}

critcl::ccommand ::queue::init_raw {cdata interp objc objv} {
	//puts("::queue::init_raw");
	Tcl_Size size;

	if (objc != 2) {
		puts("enc wrong args");
		Tcl_WrongNumArgs(interp, 1, objv, "size");
		return TCL_ERROR;
	}
	
	Tcl_GetLongFromObj(interp, objv[1], &size);

	q_data * q = malloc(sizeof(q_data));
	q_init(q,size);

	Tcl_SetObjResult(interp, Tcl_NewLongObj((void *)q));

	//printf("::queue::init_raw result %td\n",q);
	//puts("::queue::init_raw end");
	return TCL_OK;
}

critcl::ccommand ::queue::term_raw {cdata interp objc objv} {
	//puts("::queue::term_raw");
	q_data * q;
	Tcl_Size h;
	char * hd;

	if (objc != 2) {
		puts("enc wrong args");
		Tcl_WrongNumArgs(interp, 1, objv, "handle");
		return TCL_ERROR;
	}

	hd = Tcl_GetString(objv[1]);
	//printf("::queue::read_raw handle %s\n",hd);
	Tcl_GetSizeIntFromObj(interp, objv[1],&h);
	//printf("::queue::write_raw got handle value %ld\n",h);
	q = (q_data *)h;
	//printf("::queue::write_raw got handle %td\n",q);
	
	if ( q != NULL ) {
		q_term(q);
	}

	//puts("::queue::term_raw end");
	return TCL_OK;
}

critcl::ccommand ::queue::write_raw {cdata interp objc objv} {
	//puts("::queue::write_raw");
	q_data * q;
	Tcl_Size h;
	char * hd;
	char * data_buf;
	Tcl_Size data_len;
	Tcl_Size ret;

	if (objc != 3) {
		puts("enc wrong args");
		Tcl_WrongNumArgs(interp, 1, objv, "handle data");
		return TCL_ERROR;
	}

	hd = Tcl_GetString(objv[1]);
	//printf("::queue::read_raw handle %s\n",hd);
	Tcl_GetSizeIntFromObj(interp, objv[1],&h);
	//printf("::queue::write_raw got handle value %ld\n",h);
	q = (q_data *)h;
	//printf("::queue::write_raw got handle %td\n",q);
	data_buf = (void *)Tcl_GetByteArrayFromObj(objv[2], &data_len);
	//printf("::queue::write_raw got data_len %td\n",data_len);

	ret = q_write(data_buf,data_len,q);
	//printf("::queue::write_raw ret %td\n",ret);

	Tcl_SetObjResult(interp, Tcl_NewLongObj(ret));

	//puts("::queue::write_raw end");
	return TCL_OK;
}

critcl::ccommand ::queue::read_raw {cdata interp objc objv} {
	//puts("::queue::read_raw");
	q_data * q;
	Tcl_Size h;
	char * hd;
	char * data_buf;
	Tcl_Size data_len;

	if (objc != 3) {
		puts("enc wrong args");
		Tcl_WrongNumArgs(interp, 1, objv, "handle len");
		return TCL_ERROR;
	}

	hd = Tcl_GetString(objv[1]);
	//printf("::queue::read_raw handle %s\n",hd);
	Tcl_GetSizeIntFromObj(interp, objv[1],&h);
	//printf("::queue::read_raw got handle value %ld\n",h);
	q = (q_data *)h;
	//printf("::queue::read_raw got handle %td\n",q);
	Tcl_GetLongFromObj(interp, objv[2], &data_len);
	//printf("::queue::read_raw got data_len %td\n",data_len);

	data_buf = malloc(data_len);
	q_read(data_buf,data_len,q);

	Tcl_SetObjResult(interp, Tcl_NewByteArrayObj(data_buf, data_len));
	free(data_buf);

	//puts("::queue::read_raw end");
	return TCL_OK;
}

critcl::load

package require tcl::chan::events

proc ::queue::queue {} {
	return [::chan create {read write} ::queue::handler]
}

proc ::queue::handler {cmd ch args} {
    variable qptr
    switch $cmd {
        initialize {
            # Must return the list of supported subcommands
	    set qptr {}
	    catch { set qptr $::cur(qptr,$ch) }
	    if { $qptr == {} } {
			#puts "init"
			set ::cur(qptr,$ch) [::queue::init_raw 9600000]
			#puts "init $::cur(qptr,$ch)"
	    }
            return {initialize finalize watch write read}
        }
        finalize {
            # Clean up when the channel is closed
		#puts "finalize"
		::queue::term_raw $::cur(qptr,$ch)
		#puts "finalize $::cur(qptr,$ch)"
		return
        }
        watch { /* Mandatory, but empty for this example */ return }
	write {
		#puts "write args $args"
		#set data [string range $args 1 end-1]
		set data [join $args {}]
		#puts "write"
		set ret [::queue::write_raw $::cur(qptr,$ch) $data]
		#puts "write $::cur(qptr,$ch) ret $ret"
		return $ret
	
	}
        read {
		#puts "read args $args"
		set count $args
		if { $count == {} } {
			set count 9600
		}
		#puts "read"
		set ret [::queue::read_raw $::cur(qptr,$ch) $count]
		#puts "read $::cur(qptr,$ch) ret $ret"
		if {$ret eq {}} {
			return -code error EAGAIN
		}
		return $ret
        }
    }
}

proc ::queue::test {} {
	set c [::queue::queue]
	fconfigure $c -translation binary -buffering none

	for { set i 0 } {$i < 102400} {incr i 1 } {
	puts $c "hello world"
	flush $c

	set echo [read $c 20]

	puts "OUT $echo"
	}
	close $c
}

#::queue::test
