package require critcl

if {![critcl::compiling]} {
	error {critcl found no compiler}
}

namespace eval ::tinyaes {
	variable bindingsVersion 999;
	variable version {};
}

critcl::framework

critcl::cflags -Wall -Os -c -DAES256=1 -I./contrib/tiny-AES-C
critcl::ldflags -Os -L./contrib/tiny-AES-C

critcl::cheaders ./contrib/tiny-AES-C/aes.h
critcl::clibraries ./contrib/tiny-AES-C/aes.a

critcl::cache ./critcl

critcl::ccode {
	#include <stdio.h>
	#include <string.h>
	#include <stdint.h>

	#define AES256 1

	#define CBC 1
	
	#include "aes.h"
	#include "aes.c"
}

critcl::cinit {
	char s[32];
	Tcl_CreateNamespace(ip, "::tinyaes", NULL, NULL);
	sprintf(s, "69");
	Tcl_SetVar2Ex(ip, "::tinyaes::version", NULL, Tcl_NewStringObj(s, -1), 0);
} {}

# args - data, integer list, key, integer list, iv, integer list
critcl::ccommand ::tinyaes::encraw {cdata interp objc objv} {
	void *data_buf;
	void *key_buf;
	void *iv_buf;
	Tcl_Size data_len;
	Tcl_Size key_len;
	Tcl_Size iv_len;

	if (objc != 4) {
		Tcl_WrongNumArgs(interp, 1, objv, "data key iv");
		return TCL_ERROR;
	}
	
	data_buf = (void *)Tcl_GetByteArrayFromObj(objv[1], &data_len);
	key_buf = (void *)Tcl_GetByteArrayFromObj(objv[2], &key_len);
	iv_buf = (void *)Tcl_GetByteArrayFromObj(objv[3], &iv_len);

	struct AES_ctx ctx;
	AES_init_ctx_iv(&ctx, key_buf, iv_buf);
	AES_CBC_encrypt_buffer(&ctx, data_buf, data_len);

	Tcl_SetObjResult(interp, Tcl_NewByteArrayObj(data_buf, data_len));

	return TCL_OK;
}

# args - data, integer list, key, integer list, iv, integer list
critcl::ccommand ::tinyaes::decraw {cdata interp objc objv} {
	void *data_buf;
	void *key_buf;
	void *iv_buf;
	Tcl_Size data_len;
	Tcl_Size key_len;
	Tcl_Size iv_len;

	if (objc != 4) {
		Tcl_WrongNumArgs(interp, 1, objv, "data key iv");
		return TCL_ERROR;
	}
	
	data_buf = (void *)Tcl_GetByteArrayFromObj(objv[1], &data_len);
	key_buf = (void *)Tcl_GetByteArrayFromObj(objv[2], &key_len);
	iv_buf = (void *)Tcl_GetByteArrayFromObj(objv[3], &iv_len);

	struct AES_ctx ctx;
	AES_init_ctx_iv(&ctx, key_buf, iv_buf);
	AES_CBC_decrypt_buffer(&ctx, data_buf, data_len);

	Tcl_SetObjResult(interp, Tcl_NewByteArrayObj(data_buf, data_len));

	return TCL_OK;
}

critcl::load

proc ::tinyaes::san {data key iv} {
	set dlen [string length $data]
	set klen [string length $key]
	set ilen [string length $iv]
	if { $klen != 32 } {
		error "wrong key length $klen"
		return
	}
	if { $ilen != 16 } {
		error "wrong iv length $ilen"
		return
	}
	set drem [expr {$dlen%32}]
	if { $drem != 0 } {
		append data [string repeat \0 [expr {32-$drem}]]
	}
	return [list $data $key $iv]
}

proc ::tinyaes::enc {data key iv} {
	set san [::tinyaes::san $data $key $iv]
	return [::tinyaes::encraw {*}$san]
}

proc ::tinyaes::dec {data key iv} {
	set san [::tinyaes::san $data $key $iv]
	return [::tinyaes::decraw {*}$san]
}
