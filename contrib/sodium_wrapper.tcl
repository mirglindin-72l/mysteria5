package require critcl

#if {![critcl::compiling]} {
#	error {critcl found no compiler}
#}

namespace eval ::sodium {
	variable bindingsVersion 999;
	variable version {};
}

critcl::framework

if { $::tcl_platform(os) == {Darwin} } {
	set pcpath [glob /opt/homebrew/Cellar/libsodium/*/lib/pkgconfig]
	set env(PKG_CONFIG_PATH) $pcpath
	set pcl [exec pkg-config --libs libsodium]
	set pcc [exec pkg-config --cflags libsodium]
} elseif { $::tcl_platform(os) != {Windows NT} } {
	set pcl [exec pkg-config --libs libsodium]
	set pcc [exec pkg-config --cflags libsodium]
} else {
	set pcc {-I./contrib/win64/include -static-libgcc -static-libstdc++}
	set pcl {-L./contrib/win64 -llibsodium-26}
}
critcl::cflags -Wall -Os -c -I./ {*}$pcc
critcl::ldflags -Os -L./ {*}$pcl

critcl::cache ./critcl

critcl::ccode {
	#include <stdio.h>
	#include <string.h>
	#include <stdint.h>
	#include <stdlib.h>

	#include "sodium.h"
	
}

critcl::cinit {
	char s[32];
	Tcl_CreateNamespace(ip, "::sodium", NULL, NULL);
	sprintf(s, "69");
	Tcl_SetVar2Ex(ip, "::sodium::version", NULL, Tcl_NewStringObj(s, -1), 0);
} {}

critcl::ccommand ::sodium::init {cdata interp objc objv} {
	if (sodium_init() == -1) {
		return TCL_ERROR;
	}
	return TCL_OK;
}

# tested
critcl::ccommand ::sodium::genpair_enc {cdata interp objc objv} {
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

# tested
critcl::ccommand ::sodium::enc {cdata interp objc objv} {
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

# tested
critcl::ccommand ::sodium::dec {cdata interp objc objv} {
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

# tested
critcl::ccommand ::sodium::genpair_sig {cdata interp objc objv} {
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

# tested
critcl::ccommand ::sodium::sig {cdata interp objc objv} {
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

# tested
critcl::ccommand ::sodium::ver {cdata interp objc objv} {
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

# tested
critcl::ccommand ::sodium::hash {cdata interp objc objv} {
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

# tested
critcl::ccommand ::sodium::symgen {cdata interp objc objv} {
	unsigned char key[crypto_secretstream_xchacha20poly1305_KEYBYTES];
	crypto_secretstream_xchacha20poly1305_keygen(key);
	Tcl_SetObjResult(interp, Tcl_NewByteArrayObj(key,crypto_secretstream_xchacha20poly1305_KEYBYTES));
	return TCL_OK;
}

# tested
critcl::ccommand ::sodium::symenc {cdata interp objc objv} {
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

# tested
critcl::ccommand ::sodium::symdec {cdata interp objc objv} {
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

critcl::load

::sodium::init

proc ::sodium::test {} {
	puts "symgen"
	set key [::sodium::symgen]
	set src "hello world"
	puts "start: $src, hash [binary encode hex [::sodium::hash $src]]"
	puts "symenc"
	set enc [::sodium::symenc "$key" "$src"]
	puts "encrypted: [binary encode hex $enc]"
	puts "symdec"
	set dec [::sodium::symdec $key $enc]
	puts "decrypted: $dec, hash [binary encode hex [::sodium::hash $dec]]"
	puts "hash string len [string length [binary encode hex [::sodium::hash test]]]"
	###
	puts "genpair_sig"
	set pair_sig [::sodium::genpair_sig]
	set pub_sig [lindex $pair_sig 0] 
	set priv_sig [lindex $pair_sig 1] 
	puts "pub_sig [binary encode hex $pub_sig]"
	puts "priv_sig [binary encode hex $priv_sig]"
	set data "bonanza mamma mia"
	puts "data to sig : $data"
	set sig [::sodium::sig $priv_sig $data]
	puts "sig [binary encode hex $pub_sig]"
	set ver [::sodium::ver $pub_sig $data $sig]
	puts "ver $ver"
	###
	puts "genpair"
	set pair1 [::sodium::genpair_enc]
	set pub1 [lindex $pair1 0] 
	set priv1 [lindex $pair1 1] 
	puts "pub1 [binary encode hex $pub1]"
	puts "priv1 [binary encode hex $priv1]"
	set pair2 [::sodium::genpair_enc]
	set pub2 [lindex $pair2 0] 
	set priv2 [lindex $pair2 1] 
	puts "pub2 [binary encode hex $pub2]"
	puts "priv2 [binary encode hex $priv2]"
	set data "himmeldonnerwetter ins dreck"
	puts "data to enc : $data"
	set enc_to1 [::sodium::enc $pub1 $data]
	set enc_to2 [::sodium::enc $pub2 $data]
	puts "enc_to1 [binary encode hex $enc_to1]"
	puts "enc_to2 [binary encode hex $enc_to2]"
	set dec_to1 [::sodium::dec $priv1 $pub1 $enc_to1]
	set dec_to2 [::sodium::dec $priv2 $pub2 $enc_to2]
	puts "dec_to1 $dec_to1"
	puts "dec_to2 $dec_to2"
}

package provide sodium 69

#::sodium::test
