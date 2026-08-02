#include <tcl.h>

#include <stdio.h>
#include <string.h>
#include <stdint.h>
#include <stdlib.h>

#include "sodium.h"
	
static int tcl_sodium_init (void *clientData,
	Tcl_Interp *interp,
	int objc,
	Tcl_Obj *const objv[]) {

	if (sodium_init() == -1) {
		return TCL_ERROR;
	}
	return TCL_OK;
}

static int tcl_sodium_genpair_enc (void *clientData,
	Tcl_Interp *interp,
	int objc,
	Tcl_Obj *const objv[]) {

	unsigned char recipient_pk[crypto_box_PUBLICKEYBYTES];
	unsigned char recipient_sk[crypto_box_SECRETKEYBYTES];
	crypto_box_keypair(recipient_pk, recipient_sk);

	if (objc != 1) {
		puts("genpair_enc wrong args");
		Tcl_WrongNumArgs(interp, 1, objv, "");
		return TCL_ERROR;
	}

	Tcl_Obj * ret = Tcl_NewListObj(0,NULL);
	Tcl_Obj * tpk = Tcl_NewByteArrayObj(recipient_pk,crypto_box_PUBLICKEYBYTES);
	Tcl_Obj * tsk = Tcl_NewByteArrayObj(recipient_sk,crypto_box_SECRETKEYBYTES);
	Tcl_ListObjAppendElement(interp, ret, tpk);
	Tcl_ListObjAppendElement(interp, ret, tsk);
	Tcl_SetObjResult(interp, ret);

	return TCL_OK;
}

static int tcl_sodium_enc (void *clientData,
	Tcl_Interp *interp,
	int objc,
	Tcl_Obj *const objv[]) {

	unsigned char *pubkey_buf;
	Tcl_Size pubkey_len;
	unsigned char *data_buf;
	Tcl_Size data_len;
	unsigned char *out_buf;
	Tcl_Size out_len;

	if (objc != 3) {
		puts("enc wrong args");
		Tcl_WrongNumArgs(interp, 1, objv, "pubkey data");
		return TCL_ERROR;
	}
	
	pubkey_buf = (void *)Tcl_GetByteArrayFromObj(objv[1], &pubkey_len);
	data_buf = (void *)Tcl_GetByteArrayFromObj(objv[2], &data_len);

	out_len = data_len + crypto_box_SEALBYTES;
	out_buf = malloc(out_len);
	for (int i = 0 ; i < out_len ; i++) out_buf[i] = 0;

	if (crypto_box_seal(out_buf,data_buf,data_len,pubkey_buf) != 0) {
		puts("enc failed to make sealed box");
		return TCL_ERROR;
	}

	Tcl_SetObjResult(interp, Tcl_NewByteArrayObj(out_buf, out_len));

	free(out_buf);

	return TCL_OK;
}

static int tcl_sodium_dec (void *clientData,
	Tcl_Interp *interp,
	int objc,
	Tcl_Obj *const objv[]) {

	unsigned char *privkey_buf;
	Tcl_Size privkey_len;
	unsigned char *pubkey_buf;
	Tcl_Size pubkey_len;
	unsigned char *data_buf;
	Tcl_Size data_len;
	unsigned char *out_buf;
	Tcl_Size out_len;

	if (objc != 4) {
		puts("dec wrong args");
		Tcl_WrongNumArgs(interp, 1, objv, "privkey pubkey data");
		return TCL_ERROR;
	}
	
	privkey_buf = (void *)Tcl_GetByteArrayFromObj(objv[1], &privkey_len);
	pubkey_buf = (void *)Tcl_GetByteArrayFromObj(objv[2], &pubkey_len);
	data_buf = (void *)Tcl_GetByteArrayFromObj(objv[3], &data_len);

	out_len = data_len - crypto_box_SEALBYTES;
	out_buf = malloc(out_len);
	for (int i = 0 ; i < out_len ; i++) out_buf[i] = 0;

	if (crypto_box_seal_open(out_buf,data_buf,data_len,pubkey_buf,privkey_buf) != 0) {
		puts("dec failed to open sealed box");
		return TCL_ERROR;
	}

	Tcl_SetObjResult(interp, Tcl_NewByteArrayObj(out_buf, out_len));

	free(out_buf);

	return TCL_OK;
}

static int tcl_sodium_genpair_sig (void *clientData,
	Tcl_Interp *interp,
	int objc,
	Tcl_Obj *const objv[]) {

	unsigned char pk[crypto_sign_PUBLICKEYBYTES];
	unsigned char sk[crypto_sign_SECRETKEYBYTES];
	crypto_sign_keypair(pk, sk);

	if (objc != 1) {
		puts("genpair_sig wrong args");
		Tcl_WrongNumArgs(interp, 1, objv, "");
		return TCL_ERROR;
	}

	Tcl_Obj * ret = Tcl_NewListObj(0,NULL);
	Tcl_Obj * tpk = Tcl_NewByteArrayObj(pk,crypto_sign_PUBLICKEYBYTES);
	Tcl_Obj * tsk = Tcl_NewByteArrayObj(sk,crypto_sign_SECRETKEYBYTES);
	Tcl_ListObjAppendElement(interp, ret, tpk);
	Tcl_ListObjAppendElement(interp, ret, tsk);
	Tcl_SetObjResult(interp, ret);

	return TCL_OK;
}

static int tcl_sodium_sig (void *clientData,
	Tcl_Interp *interp,
	int objc,
	Tcl_Obj *const objv[]) {

	unsigned char *privkey_buf;
	Tcl_Size privkey_len;
	unsigned char *data_buf;
	Tcl_Size data_len;

	if (objc != 3) {
		puts("sig wrong args");
		Tcl_WrongNumArgs(interp, 1, objv, "privkey data");
		return TCL_ERROR;
	}
	
	privkey_buf = (void *)Tcl_GetByteArrayFromObj(objv[1], &privkey_len);
	data_buf = (void *)Tcl_GetByteArrayFromObj(objv[2], &data_len);

	unsigned char sig[crypto_sign_BYTES];

	crypto_sign_detached(sig, NULL, data_buf, data_len, privkey_buf);

	Tcl_SetObjResult(interp, Tcl_NewByteArrayObj(sig, crypto_sign_BYTES));

	return TCL_OK;
}

static int tcl_sodium_ver (void *clientData,
	Tcl_Interp *interp,
	int objc,
	Tcl_Obj *const objv[]) {

	unsigned char *pubkey_buf;
	Tcl_Size pubkey_len;
	unsigned char *data_buf;
	Tcl_Size data_len;
	unsigned char *sig_buf;
	Tcl_Size sig_len;

	if (objc != 4) {
		puts("ver wrong args");
		Tcl_WrongNumArgs(interp, 1, objv, "pubkey data sig");
		return TCL_ERROR;
	}
	
	pubkey_buf = (void *)Tcl_GetByteArrayFromObj(objv[1], &pubkey_len);
	data_buf = (void *)Tcl_GetByteArrayFromObj(objv[2], &data_len);
	sig_buf = (void *)Tcl_GetByteArrayFromObj(objv[3], &sig_len);

	if (crypto_sign_verify_detached(sig_buf, data_buf, data_len, pubkey_buf) != 0) {
		Tcl_SetObjResult(interp, Tcl_NewIntObj(1));
	}

	Tcl_SetObjResult(interp, Tcl_NewIntObj(0));

	return TCL_OK;
}

static int tcl_sodium_hash (void *clientData,
	Tcl_Interp *interp,
	int objc,
	Tcl_Obj *const objv[]) {

	unsigned char *data_buf;
	Tcl_Size data_len;

	if (objc != 2) {
		puts("hash wrong args");
		Tcl_WrongNumArgs(interp, 1, objv, "data");
		return TCL_ERROR;
	}
	
	data_buf = (void *)Tcl_GetByteArrayFromObj(objv[1], &data_len);

	unsigned char hash[crypto_generichash_BYTES];

	crypto_generichash(hash,crypto_generichash_BYTES,data_buf,data_len,NULL,0);

	Tcl_SetObjResult(interp, Tcl_NewByteArrayObj(hash,crypto_generichash_BYTES));

	return TCL_OK;
}

static int tcl_sodium_symgen (void *clientData,
	Tcl_Interp *interp,
	int objc,
	Tcl_Obj *const objv[]) {

	unsigned char key[crypto_secretstream_xchacha20poly1305_KEYBYTES];
	crypto_secretstream_xchacha20poly1305_keygen(key);
	Tcl_SetObjResult(interp, Tcl_NewByteArrayObj(key,crypto_secretstream_xchacha20poly1305_KEYBYTES));
	return TCL_OK;
}

static int tcl_sodium_symenc (void *clientData,
	Tcl_Interp *interp,
	int objc,
	Tcl_Obj *const objv[]) {

	unsigned char *key_buf;
	Tcl_Size key_len;
	unsigned char *data_buf;
	Tcl_Size data_len;
	unsigned char *out_buf;
	Tcl_Size out_len;
	unsigned char *out_buf_data;
	Tcl_Size out_len_data;

	if (objc != 3) {
		puts("symenc wrong args");
		Tcl_WrongNumArgs(interp, 1, objv, "key data");
		return TCL_ERROR;
	}
	
	key_buf = (void *)Tcl_GetByteArrayFromObj(objv[1], &key_len);
	data_buf = (void *)Tcl_GetByteArrayFromObj(objv[2], &data_len);

	crypto_secretstream_xchacha20poly1305_state state;

	out_len = crypto_secretstream_xchacha20poly1305_HEADERBYTES + data_len + crypto_secretstream_xchacha20poly1305_ABYTES;
	out_buf = malloc(out_len);
	for (unsigned long i = 0 ; i < out_len ; i++) out_buf[i] = 0;

	out_buf_data = out_buf + crypto_secretstream_xchacha20poly1305_HEADERBYTES;
	out_len_data = out_len - crypto_secretstream_xchacha20poly1305_HEADERBYTES;

	int hret = crypto_secretstream_xchacha20poly1305_init_push(&state,out_buf,key_buf);
	printf("enc init with ret %d\n",hret);

	int ret = crypto_secretstream_xchacha20poly1305_push(&state,out_buf_data,NULL,data_buf,data_len,NULL,0,crypto_secretstream_xchacha20poly1305_TAG_FINAL);
	printf("enc chunk with ret %d\n",ret);


	Tcl_SetObjResult(interp, Tcl_NewByteArrayObj(out_buf, out_len));

	free(out_buf);

	return TCL_OK;
}

static int tcl_sodium_symdec (void *clientData,
	Tcl_Interp *interp,
	int objc,
	Tcl_Obj *const objv[]) {

	unsigned char *key_buf;
	Tcl_Size key_len;
	unsigned char *data_buf;
	Tcl_Size data_len;
	unsigned char *out_buf;
	Tcl_Size out_len;

	if (objc != 3) {
		puts("symdec wrong args");
		Tcl_WrongNumArgs(interp, 1, objv, "key data");
		return TCL_ERROR;
	}
	
	key_buf = (void *)Tcl_GetByteArrayFromObj(objv[1], &key_len);
	data_buf = (void *)Tcl_GetByteArrayFromObj(objv[2], &data_len);

	out_len = data_len - crypto_secretstream_xchacha20poly1305_HEADERBYTES - crypto_secretstream_xchacha20poly1305_ABYTES;
	out_buf = malloc(out_len);
	for (unsigned long i = 0 ; i < out_len ; i++) out_buf[i] = 0;

	crypto_secretstream_xchacha20poly1305_state state;
	unsigned char tag;
	tag = 0;

	int hret = crypto_secretstream_xchacha20poly1305_init_pull(&state,data_buf,key_buf);
	if (hret != 0) {
		puts("failed decrypting in header");
		printf("failed with ret %d\n",hret);
		return TCL_ERROR;
	}


	data_buf += crypto_secretstream_xchacha20poly1305_HEADERBYTES;
	data_len -= crypto_secretstream_xchacha20poly1305_HEADERBYTES;

	int ret = crypto_secretstream_xchacha20poly1305_pull(&state,out_buf,NULL,&tag,data_buf,data_len,NULL,0);
	if (ret != 0) {
		puts("failed decrypting chunk");
		printf("failed with ret %d\n",ret);
		return TCL_ERROR;
	}

	if (tag != crypto_secretstream_xchacha20poly1305_TAG_FINAL) {
		puts("tag doesn't match");
		printf("failed with tag %d\n",tag);
		return TCL_ERROR;
	}

	Tcl_SetObjResult(interp, Tcl_NewByteArrayObj(out_buf, out_len));

	free(out_buf);

	return TCL_OK;
}

int Sodium_wrapper_Init(Tcl_Interp *interp) {
	printf("init TCL stubs for Sodium\n");
	if (Tcl_InitStubs(interp, "8.6-", 0) == NULL) {
		return TCL_ERROR;
	}
	/*
	printf("init TCL require for Sodium\n");
	if (Tcl_PkgRequire(interp, "Tcl", "8.6-", 0) == NULL) {
		return TCL_ERROR;
	}
	*/
	printf("creating sodium commands");
	Tcl_CreateObjCommand(interp, "::sodium::init", tcl_sodium_init, NULL, NULL);
	Tcl_CreateObjCommand(interp, "::sodium::genpair_enc", tcl_sodium_genpair_enc, NULL, NULL);
	Tcl_CreateObjCommand(interp, "::sodium::enc", tcl_sodium_enc, NULL, NULL);
	Tcl_CreateObjCommand(interp, "::sodium::dec", tcl_sodium_dec, NULL, NULL);
	Tcl_CreateObjCommand(interp, "::sodium::genpair_sig", tcl_sodium_genpair_sig, NULL, NULL);
	Tcl_CreateObjCommand(interp, "::sodium::sig", tcl_sodium_sig, NULL, NULL);
	Tcl_CreateObjCommand(interp, "::sodium::ver", tcl_sodium_ver, NULL, NULL);
	Tcl_CreateObjCommand(interp, "::sodium::hash", tcl_sodium_hash, NULL, NULL);
	Tcl_CreateObjCommand(interp, "::sodium::symgen", tcl_sodium_symgen, NULL, NULL);
	Tcl_CreateObjCommand(interp, "::sodium::symenc", tcl_sodium_symenc, NULL, NULL);
	Tcl_CreateObjCommand(interp, "::sodium::symdec", tcl_sodium_symdec, NULL, NULL);

	return TCL_OK;
}
