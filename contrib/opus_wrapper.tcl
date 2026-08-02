package require critcl

#if {![critcl::compiling]} {
#	error {critcl found no compiler}
#}

namespace eval ::opus {
	variable bindingsVersion 999;
	variable version {};
}

critcl::framework

if { $::tcl_platform(os) == {Darwin} } {
	set pcpath [glob /opt/homebrew/Cellar/opus/*/lib/pkgconfig]
	set env(PKG_CONFIG_PATH) $pcpath
	set pcl [exec pkg-config --libs opus]
	set pcc [exec pkg-config --cflags opus]
} elseif { $::tcl_platform(os) != {Windows NT} } {
	set pcl [exec pkg-config --libs opus]
	set pcc [exec pkg-config --cflags opus]
} else {
	set pcl {-L./contrib/win64 -lopus}
	set pcc {-I./contrib/win64/include -Wno-error=incompatible-pointer-types -Os -c -static-libgcc -static-libstdc++}
}
critcl::cflags -Wall -Os -c -I./ {*}$pcc
critcl::ldflags -Os -L./ {*}$pcl
critcl::cache ./critcl

critcl::ccode {
	#include <stdio.h>
	#include <string.h>
	#include <stdint.h>
	#include <stdlib.h>

	#include "opus.h"
	
	//#define FRAMES_AT_ONCE 4096
	#define FRAMES_AT_ONCE 960
}

critcl::cinit {
	char s[32];
	Tcl_CreateNamespace(ip, "::opus", NULL, NULL);
	sprintf(s, "69");
	Tcl_SetVar2Ex(ip, "::opus::version", NULL, Tcl_NewStringObj(s, -1), 0);
} {}

# an Opus frame is 40 ms of PCM signal,
# in our case
critcl::ccommand ::opus::enc {cdata interp objc objv} {
	unsigned char *in_buf;
	unsigned char *in_cursor;
	Tcl_Size in_len;
	int framesize;
	int sr;
	int ch;
	OpusEncoder * enc;
	unsigned char *out_buf;
	unsigned char *out_cursor;
	Tcl_Size out_len;
	int ret;
	unsigned char *tmp;

	if (objc != 4) {
		puts("enc wrong args");
		Tcl_WrongNumArgs(interp, 1, objv, "data samplerate channels");
		return TCL_ERROR;
	}
	
	in_buf = (void *)Tcl_GetByteArrayFromObj(objv[1], &in_len);
	Tcl_GetIntFromObj(interp, objv[2], &sr);
	Tcl_GetIntFromObj(interp, objv[3], &ch);
	printf("enc in_len %td sr %d ch %d\n",in_len,sr,ch);

	if ( !(sr == 8000 || sr == 12000 || sr == 16000 || sr == 24000 || sr == 48000) ) {
		puts("enc wrong sr");
		return TCL_ERROR;
	}

	if ( !(ch == 1 || ch == 2) ) {
		puts("enc wrong ch");
		return TCL_ERROR;
	}

	enc = opus_encoder_create(sr,ch,OPUS_APPLICATION_VOIP,&ret);
	if ( ret != OPUS_OK ) {
		puts("enc failed init");
		return TCL_ERROR;
	} 
	ret = opus_encoder_ctl(enc, OPUS_SET_BITRATE(16000));
	if ( ret != OPUS_OK ) {
		puts("enc failed init");
		return TCL_ERROR;
	} 
	ret = opus_encoder_ctl(enc, OPUS_SET_COMPLEXITY(6));
	if ( ret != OPUS_OK ) {
		puts("enc failed init");
		return TCL_ERROR;
	} 

	out_buf = malloc(in_len);
	for(int i = 0 ; i < in_len ; i++) {
		out_buf[i] = 0;
	}

	out_len = 0;
	in_cursor = in_buf;
	out_cursor = out_buf;

	framesize = 0.001 * 60 * sr * ch;
	tmp = malloc(framesize);
	printf("enc tmp framesize %d\n",framesize);

	for (int c = 0; c < in_len; c += framesize * sizeof(opus_int16) ) {
		for(int i = 0 ; i < framesize ; i++) {
			tmp[i] = 0;
		}
		ret = opus_encode(enc,(opus_int16 *)in_cursor,framesize,(opus_int16 *)tmp,framesize);
		if ( ret < 0 ) {
			//printf("enc neg ret %d: %s\n",ret,opus_strerror(ret));
			return TCL_ERROR;
		}
		//printf("enc ret %d %x\n",ret, ret);
		in_cursor += framesize * sizeof(opus_int16);

		//printf("enc prefix:\n");
		for(int i = 0 ; i < 4 ; i++) {
			*out_cursor = (ret >> 8*i) & 0xff;
			//printf("%x ",*out_cursor);
			out_cursor += 1;
			out_len++;
		}
		//printf(".\n");

		//printf("enc packet:\n");
		for(int i = 0 ; i < ret ; i++) {
			*out_cursor = *(tmp+i);
			//printf("%x ",*out_cursor);
			out_cursor += 1;
			out_len++;
		}
		//printf(".\n");

		if ( out_len > in_len ) {
			//printf("enc overshot buffer: %d > %d\n",out_len,in_len);
			break;	
		}
	}

	Tcl_SetObjResult(interp, Tcl_NewByteArrayObj(out_buf, out_len));

	free(out_buf);
	free(tmp);
	opus_encoder_destroy(enc);

	return TCL_OK;
}

# an Opus frame is 40 ms of PCM signal,
# in our case
critcl::ccommand ::opus::dec {cdata interp objc objv} {
	unsigned char *in_buf;
	unsigned char *in_cursor;
	Tcl_Size in_len;
	int framesize;
	int sr;
	int ch;
	OpusDecoder * dec;
	int ret;
	int pl;
	unsigned char *out_buf;
	unsigned char *out_cursor;
	Tcl_Size out_len;
	unsigned char *tmp;

	if (objc != 4) {
		puts("dec wrong args");
		Tcl_WrongNumArgs(interp, 1, objv, "data samplerate channels");
		return TCL_ERROR;
	}
	
	in_buf = (void *)Tcl_GetByteArrayFromObj(objv[1], &in_len);
	Tcl_GetIntFromObj(interp, objv[2], &sr);
	Tcl_GetIntFromObj(interp, objv[3], &ch);
	printf("dec in_len %td sr %d ch %d\n",in_len,sr,ch);

	if ( !(sr == 8000 || sr == 12000 || sr == 16000 || sr == 24000 || sr == 48000) ) {
		puts("dec wrong sr");
		return TCL_ERROR;
	}

	if ( !(ch == 1 || ch == 2) ) {
		puts("dec wrong ch");
		return TCL_ERROR;
	}
	
	dec = opus_decoder_create(sr,ch,&ret);
	if ( ret != OPUS_OK ) {
		puts("dec failed init");
		return TCL_ERROR;
	} 

	framesize = 0.001 * 60 * sr * ch;

	in_cursor = in_buf;
	out_buf = malloc((FRAMES_AT_ONCE)*framesize);
	for(int i = 0 ; i < (FRAMES_AT_ONCE)*framesize ; i++) {
		out_buf[i] = 0;
	}
	out_cursor = out_buf;
	out_len = 0;

	int c = 0;
	int r = 0;
	while (r < in_len && c < (FRAMES_AT_ONCE)) {
		pl = 0;
		//printf("dec prefix:\n");
		for (int i = 0 ; i < 4 ; i++) {
			pl += (*in_cursor << 8*i) & (0xff << 8*i);
			//printf("%x ",*in_cursor);
			in_cursor += 1;
			r++;
		}
		//printf(".\n");
		
		if ( pl == 0 ) {
			break;
		}

		if ( pl < 0 ) {
			//printf("dec neg pl %x, (uint)pl %x\n",pl,(unsigned int)pl);
			return TCL_ERROR;	
		}
		//printf("dec pl %d sizeof(pl) %d\n",pl,sizeof(pl));

		ret = opus_decode(dec,(opus_int16 *)in_cursor,pl,(opus_int16 *)out_cursor,framesize,0);
		if ( ret < 0 ) {
			//printf("dec neg ret %d: %s\n",ret,opus_strerror(ret));
			return TCL_ERROR;	
		}
		//printf("dec ret %d\n",ret);

		in_cursor += pl;
		r += pl;
		//printf("dec in_cursor %d\n",*in_cursor);
		
		out_cursor += ret * sizeof(opus_int16);
		out_len += ret * sizeof(opus_int16);

		//printf("dec packet done\n");

		c++;
	}

	Tcl_SetObjResult(interp, Tcl_NewByteArrayObj(out_buf, out_len));

	free(out_buf);
	opus_decoder_destroy(dec);

	return TCL_OK;
}

critcl::load

#proc ::opus::test {sr ch} {
#	#::opus::init $sr $ch
#	puts "record start"	
#	set d [::pa::record 15000 $sr $ch]
#	puts "record end"	
#	#puts "play start"
#	#::pa::play $d $sr $ch
#	#puts "play end"
#	#return
#	puts "enc start"	
#	set de [::opus::enc $d $sr $ch]
#	puts "enc end"	
#	set path "test.opus"
#	set f [open $path w]
#	puts -nonewline $f $de
#	flush $f
#	close $f
#	puts "dec start"	
#	set dn [::opus::dec $de $sr $ch]
#	puts "dec end"	
#	puts "play start"
#	::pa::play $dn $sr $ch
#	puts "play end"
#	set path "test.raw"
#	set f [open $path w]
#	puts -nonewline $f $dn
#	flush $f
#	close $f
#}


#::opus::test 48000 1

package provide opus 69

#vwait forever
