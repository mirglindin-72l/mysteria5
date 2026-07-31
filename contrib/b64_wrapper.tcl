package require critcl

if {![critcl::compiling]} {
	error {critcl found no compiler}
}

namespace eval ::b64 {
	variable bindingsVersion 999;
	variable version {};
}

critcl::framework

critcl::cflags -Wall -Os -c -I./contrib/b64
critcl::ldflags -Os -L./contrib/b64

critcl::ccode {
	#include <stdio.h>
	#include <string.h>
	#include <stdint.h>
	#include <stdlib.h>

	#include "base64.c"
}

critcl::cinit {
	char s[32];
	Tcl_CreateNamespace(ip, "::b64", NULL, NULL);
	sprintf(s, "69");
	Tcl_SetVar2Ex(ip, "::b64::version", NULL, Tcl_NewStringObj(s, -1), 0);
} {}

critcl::ccommand ::b64::enc {cdata interp objc objv} {
	unsigned char *in_buf;
	Tcl_Size in_len;
	unsigned char *out_buf;
	Tcl_Size out_len;

	if (objc != 2) {
		puts("enc wrong args");
		Tcl_WrongNumArgs(interp, 1, objv, "data");
		return TCL_ERROR;
	}
	
	in_buf = (void *)Tcl_GetByteArrayFromObj(objv[1], &in_len);

	//out_buf = malloc(out_len*4/3);
	//for(int i = 0 ; i < out_len ; i++) {
	//	out_buf[i] = 0;
	//}

	puts("b64 enc");
	out_buf = base64_encode(in_buf,in_len);
	puts("b64 enc end");

	Tcl_SetObjResult(interp, Tcl_NewByteArrayObj(out_buf, out_len));

	free(out_buf);

	return TCL_OK;
}

critcl::ccommand ::b64::dec {cdata interp objc objv} {
	unsigned char *in_buf;
	Tcl_Size in_len;
	unsigned char *out_buf;
	Tcl_Size out_len;

	if (objc != 2) {
		puts("dec wrong args");
		Tcl_WrongNumArgs(interp, 1, objv, "data");
		return TCL_ERROR;
	}
	
	in_buf = (void *)Tcl_GetByteArrayFromObj(objv[1], &in_len);

	out_len = in_len*3/4;
	//out_buf = malloc(out_len);

	//for(int i = 0 ; i < out_len ; i++) {
	//	out_buf[i] = 0;
	//}

	puts("b64 dec");
	out_buf = base64_decode(in_buf,in_len,&out_len);
	puts("b64 dec end");

	Tcl_SetObjResult(interp, Tcl_NewByteArrayObj(out_buf, out_len));

	free(out_buf);

	return TCL_OK;
}

critcl::load

proc ::b64::test {} {
	set data "hello world"
	set enc [::b64::enc $data]
	set dec [::b64::dec $enc]
	puts $data
	puts $enc
	puts $dec
}

::b64::test

vwait forever
