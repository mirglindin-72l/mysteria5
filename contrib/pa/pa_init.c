/** @file paex_record.c
    @ingroup examples_src
    @brief Record input into an array; Save array to a file; Playback recorded data.
    @author Phil Burk  http://www.softsynth.com
*/
/*
 * $Id$
 *
 * This program uses the PortAudio Portable Audio Library.
 * For more information see: http://www.portaudio.com
 * Copyright (c) 1999-2000 Ross Bencina and Phil Burk
 *
 * Permission is hereby granted, free of charge, to any person obtaining
 * a copy of this software and associated documentation files
 * (the "Software"), to deal in the Software without restriction,
 * including without limitation the rights to use, copy, modify, merge,
 * publish, distribute, sublicense, and/or sell copies of the Software,
 * and to permit persons to whom the Software is furnished to do so,
 * subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
 * IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR
 * ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF
 * CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
 * WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

/*
 * The text above constitutes the entire PortAudio license; however,
 * the PortAudio community also makes the following non-binding requests:
 *
 * Any person wishing to distribute modifications to the Software is
 * requested to send the modifications to the original developer so that
 * they can be incorporated into the canonical version. It is also
 * requested that these non-binding requests be included along with the
 * license above.
 */

#include <stdio.h>
#include <stdlib.h>
#include "portaudio.h"

#define FRAMES_PER_BUFFER (960)

/* Select sample format. */

#if 0
#define PA_SAMPLE_TYPE  paFloat32
typedef float SAMPLE;
#define SAMPLE_SILENCE  (0.0f)
#elif 1
#define PA_SAMPLE_TYPE  paInt16
typedef short SAMPLE;
#define SAMPLE_SILENCE  (0)
#elif 0
#define PA_SAMPLE_TYPE  paInt8
typedef char SAMPLE;
#define SAMPLE_SILENCE  (0)
#else
#define PA_SAMPLE_TYPE  paUInt8
typedef unsigned char SAMPLE;
#define SAMPLE_SILENCE  (128)
#endif

typedef struct
{
    int		sr;
    int		ch;
    PaStream 	*stream;
    char  *cname;
    void  *interp;
}
paData;

paData gdata_rec;
paData gdata_play;

/* This routine will be called by the PortAudio engine when audio is needed.
** It may be called at interrupt level on some machines so don't do anything
** that could mess up the system like calling malloc() or free().
*/
static int recordCallback( const void *inputBuffer, void *outputBuffer,
                           unsigned long framesPerBuffer,
                           const PaStreamCallbackTimeInfo* timeInfo,
                           PaStreamCallbackFlags statusFlags,
                           void *userData )
{
    paData *data = (paData*)userData;
    unsigned long finished;
    char * buf = (char *)inputBuffer;

    (void) outputBuffer; /* Prevent unused variable warnings. */
    (void) timeInfo;
    (void) statusFlags;
    (void) userData;

    finished = paContinue;
    if ( inputBuffer != NULL ) {
    	int mode = 0;
    	Tcl_Channel chan = Tcl_GetChannel(data->interp,data->cname,&mode);
	if ( chan == NULL || Tcl_Eof(chan) ) {
    		finished = paComplete;
	} else if ( (mode & TCL_WRITABLE) ) {
		Tcl_Write(chan,(char *)buf,framesPerBuffer*sizeof(SAMPLE));
	}
    } else {
    	finished = paComplete;
    }

    return finished;
}

/* This routine will be called by the PortAudio engine when audio is needed.
** It may be called at interrupt level on some machines so don't do anything
** that could mess up the system like calling malloc() or free().
*/
static int playCallback( const void *inputBuffer, void *outputBuffer,
                         unsigned long framesPerBuffer,
                         const PaStreamCallbackTimeInfo* timeInfo,
                         PaStreamCallbackFlags statusFlags,
                         void *userData )
{
    paData *data = (paData*)userData;
    unsigned long finished;
    char * buf = (char *)outputBuffer;

    (void) inputBuffer; /* Prevent unused variable warnings. */
    (void) timeInfo;
    (void) statusFlags;
    (void) userData;

    Tcl_Size len;

    finished = paContinue;
    if ( outputBuffer != NULL ) {
    	int mode = 0;
    	Tcl_Channel chan = Tcl_GetChannel(data->interp,data->cname,&mode);
	if ( chan == NULL || Tcl_Eof(chan) ) {
    		finished = paComplete;
	} else if (mode & TCL_READABLE) {
		len = Tcl_Read(chan,(char *)buf,framesPerBuffer*sizeof(SAMPLE));
		if (len < framesPerBuffer*sizeof(SAMPLE)) {
			for ( int i = len ; i < FRAMES_PER_BUFFER*sizeof(SAMPLE) ; i++) {
				buf[i] = 0;
			}
		}
	} else {
		for (int i = 0 ; i < FRAMES_PER_BUFFER*sizeof(SAMPLE) ; i++) {
			buf[i] = 0;	
		}
	}
    } else {
    	finished = paComplete;
    }

    return finished;
}

int pa_init(void *interp, int sr, int ch) {
	PaError err = paNoError;
	gdata_rec.sr = sr;
	gdata_rec.ch = ch;
	gdata_rec.interp = interp;
	if ( gdata_rec.cname != NULL ) free(gdata_rec.cname);
	gdata_rec.cname = NULL;
	gdata_rec.stream = NULL;
	gdata_play.sr = sr;
	gdata_play.ch = ch;
	gdata_play.interp = interp;
	if ( gdata_play.cname != NULL ) free(gdata_play.cname);
	gdata_play.cname = NULL;
	gdata_play.stream = NULL;
	err = Pa_Initialize();
	return err;
}

