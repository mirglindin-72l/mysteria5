package require critcl

if {![critcl::compiling]} {
	error {critcl found no compiler}
}

namespace eval ::pa {
	variable bindingsVersion 999;
	variable version {};
}

critcl::framework

if { $::tcl_platform(os) == {Darwin} } {
	set pcpath [glob /opt/homebrew/Cellar/portaudio/*/lib/pkgconfig]
	set env(PKG_CONFIG_PATH) $pcpath
	set pcl [exec pkg-config --libs portaudio-2.0] 
	set pcc [exec pkg-config --cflags portaudio-2.0] 
} elseif { $::tcl_platform(os) != {Windows NT} } {
	set pcl [exec pkg-config --libs portaudio-2.0] 
	set pcc [exec pkg-config --cflags portaudio-2.0] 
} else {
	set pcl {-L./contrib/win64 -lportaudio_x64}
	set pcc {-I./contrib/win64/include -I./contrib/pa -static-libgcc -static-libstdc++}
}
critcl::cflags -Wall -Os -c -I./ {*}$pcc
critcl::ldflags -Os -L./ {*}$pcl
critcl::cache ./critcl

critcl::ccode {
	#include <stdio.h>
	#include <string.h>
	#include <stdint.h>

	#include "./contrib/pa/pa_init.c"
	#include "./contrib/pa/pa_rec_chan.c"
	#include "./contrib/pa/pa_rec_start.c"
	#include "./contrib/pa/pa_rec_end.c"
	#include "./contrib/pa/pa_play_chan.c"
	#include "./contrib/pa/pa_play_start.c"
	#include "./contrib/pa/pa_play_end.c"
	#include "./contrib/pa/pa_term.c"
}

critcl::cinit {
	char s[32];
	Tcl_CreateNamespace(ip, "::pa", NULL, NULL);
	sprintf(s, "69");
	Tcl_SetVar2Ex(ip, "::pa::version", NULL, Tcl_NewStringObj(s, -1), 0);
} {}

critcl::ccommand ::pa::init {cdata interp objc objv} {
	int sr = 0;
	int ch = 0;

	if (objc != 3) {
		Tcl_WrongNumArgs(interp, 1, objv, "samplerate channels");
		return TCL_ERROR;
	}

	Tcl_GetIntFromObj(interp, objv[1], &sr);
	Tcl_GetIntFromObj(interp, objv[2], &ch);

	pa_init(interp,sr,ch);

	return TCL_OK;
}

critcl::ccommand ::pa::rec_chan {cdata interp objc objv} {
	char *cname;

	if (objc != 2) {
		Tcl_WrongNumArgs(interp, 1, objv, "chan");
		return TCL_ERROR;
	}

	cname = Tcl_GetString(objv[1]);

	pa_rec_chan(cname);

	return TCL_OK;
}

critcl::ccommand ::pa::play_chan {cdata interp objc objv} {
	char *cname;

	if (objc != 2) {
		Tcl_WrongNumArgs(interp, 1, objv, "chan");
		return TCL_ERROR;
	}

	cname = Tcl_GetString(objv[1]);

	pa_play_chan(cname);

	return TCL_OK;
}

critcl::ccommand ::pa::rec_start {cdata interp objc objv} {
	pa_rec_start();

	return TCL_OK;
}

critcl::ccommand ::pa::play_start {cdata interp objc objv} {
	pa_play_start();

	return TCL_OK;
}

critcl::ccommand ::pa::rec_end {cdata interp objc objv} {
	pa_rec_end();

	return TCL_OK;
}

critcl::ccommand ::pa::play_end {cdata interp objc objv} {
	pa_play_end();

	return TCL_OK;
}

critcl::ccommand ::pa::term {cdata interp objc objv} {
	pa_term();

	return TCL_OK;
}

critcl::load

source "./contrib/opus_wrapper.tcl"

proc ::pa::test {} {
	puts "pa_init"
	::pa::init 48000 1
	after 1000 ::pa::test_rec_start
}

proc ::pa::test_rec_start {} {
	puts "pa_rec_start"
	set path "test.raw"
	set f [open $path w]
	fconfigure $f -translation binary -buffering none
	::pa::rec_chan $f
	::pa::rec_start
	after 10000 [list ::pa::test_rec_end $f]
}

proc ::pa::test_rec_end {f} {
	puts "pa_rec_end"
	::pa::rec_end
	close $f
	after 1000 ::pa::test_encode_and_back
}

proc ::pa::test_encode_and_back {} {
	set path "test.raw"
	set f [open $path r]
	fconfigure $f -translation binary -buffering none
	set data [read $f]
	close $f
	set opus_data [::opus::enc $data 48000 1]
	set dec_data [::opus::dec $opus_data 48000 1]
	set path "test0.raw"
	set f [open $path w]
	fconfigure $f -translation binary -buffering none
	puts -nonewline $f $dec_data
	close $f
	after 1000 ::pa::test_play_start
}

proc ::pa::test_play_start {} {
	puts "pa_play_start"
	set path "test0.raw"
	set f [open $path r]
	fconfigure $f -translation binary -buffering none
	::pa::play_chan $f
	::pa::play_start
	after 10000 [list ::pa::test_play_end $f]
}

proc ::pa::test_play_end {f} {
	puts "pa_play_end"
	::pa::play_end
	close $f

	after 1000 ::pa::term
}

#::pa::test

#vwait forever
