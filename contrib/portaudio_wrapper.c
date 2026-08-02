#include <tcl.h>

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

static int tcl_pa_init(void *clientData,
	Tcl_Interp *interp,
	int objc,
	Tcl_Obj *const objv[]) {

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

static int tcl_pa_rec_chan(void *clientData,
	Tcl_Interp *interp,
	int objc,
	Tcl_Obj *const objv[]) {

	char *cname;

	if (objc != 2) {
		Tcl_WrongNumArgs(interp, 1, objv, "chan");
		return TCL_ERROR;
	}

	cname = Tcl_GetString(objv[1]);

	pa_rec_chan(cname);

	return TCL_OK;
}

static int tcl_pa_play_chan(void *clientData,
	Tcl_Interp *interp,
	int objc,
	Tcl_Obj *const objv[]) {

	char *cname;

	if (objc != 2) {
		Tcl_WrongNumArgs(interp, 1, objv, "chan");
		return TCL_ERROR;
	}

	cname = Tcl_GetString(objv[1]);

	pa_play_chan(cname);

	return TCL_OK;
}

static int tcl_pa_rec_start(void *clientData,
	Tcl_Interp *interp,
	int objc,
	Tcl_Obj *const objv[]) {

	pa_rec_start();

	return TCL_OK;
}

static int tcl_pa_play_start(void *clientData,
	Tcl_Interp *interp,
	int objc,
	Tcl_Obj *const objv[]) {

	pa_play_start();

	return TCL_OK;
}

static int tcl_pa_rec_end(void *clientData,
	Tcl_Interp *interp,
	int objc,
	Tcl_Obj *const objv[]) {

	pa_rec_end();

	return TCL_OK;
}

static int tcl_pa_play_end(void *clientData,
	Tcl_Interp *interp,
	int objc,
	Tcl_Obj *const objv[]) {

	pa_play_end();

	return TCL_OK;
}

static int tcl_pa_term(void *clientData,
	Tcl_Interp *interp,
	int objc,
	Tcl_Obj *const objv[]) {

	pa_term();

	return TCL_OK;
}

int Portaudio_wrapper_Init(Tcl_Interp *interp) {
	printf("init TCL stubs for PA\n");
	if (Tcl_InitStubs(interp, "8.6-", 0) == NULL) {
		return TCL_ERROR;
	}
	/*
	printf("init TCL require for PA\n");
	if (Tcl_PkgRequire(interp, "Tcl", "8.6-", 0) == NULL) {
		return TCL_ERROR;
	}
	*/
	printf("creating PA commands\n");
	Tcl_CreateObjCommand(interp, "::pa::init", tcl_pa_init, NULL, NULL);
	Tcl_CreateObjCommand(interp, "::pa::rec_chan", tcl_pa_rec_chan, NULL, NULL);
	Tcl_CreateObjCommand(interp, "::pa::play_chan", tcl_pa_play_chan, NULL, NULL);
	Tcl_CreateObjCommand(interp, "::pa::rec_start", tcl_pa_rec_start, NULL, NULL);
	Tcl_CreateObjCommand(interp, "::pa::play_start", tcl_pa_play_start, NULL, NULL);
	Tcl_CreateObjCommand(interp, "::pa::rec_end", tcl_pa_rec_end, NULL, NULL);
	Tcl_CreateObjCommand(interp, "::pa::play_end", tcl_pa_play_end, NULL, NULL);
	Tcl_CreateObjCommand(interp, "::pa::term", tcl_pa_term, NULL, NULL);

	return TCL_OK;
}
