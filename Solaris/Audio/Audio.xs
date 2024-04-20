#ifdef __cplusplus
extern "C" {
#endif
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
#ifdef __cplusplus
}
#endif

#include "audio/audio.h"
#include <sys/types.h>

MODULE = Solaris::Audio		PACKAGE = Solaris::Audio		

double
answer_lue()

int
audio_init(direct)
int direct

void
audio_set_port(port)
int     port

void
audio_set_rate(rate)
int     rate

void
audio_set_gain(gain)
int     gain

int
audio_set_async()

void
audio_destroy()

ssize_t
audio_play(sound, n)
short*  sound
int     n

void
audio_flat(sv, n, level)
SV*     sv
int     n
short   level
CODE:	
  int i;	
  short *sound;
  sv_setpv(sv, ""); /* Eek, ugly hack. */
  SvGROW(sv, n * sizeof(short)); 
  SvCUR_set(sv, n * sizeof(short));
  sound = (short *)SvPV(sv,na);
  for(i=0; i < n; i++) {
    sound[i] = level;
  }

void
audio_drum(sound, n, base_freq, range_freq, amplitude)
short*  sound
int     n
int     base_freq
int     range_freq
int     amplitude

void
audio_drum2(sound, n, base_freq, range_freq, amplitude)
short*  sound
int     n
int     base_freq
int     range_freq
int     amplitude

void
audio_omni_drum(dst, dstn, src, srcn, base_freq, range_freq, step_freq, amplitude)
short*  dst
int     dstn
short*  src
int     srcn
int     base_freq
int     range_freq
double  step_freq
double  amplitude

void 
audio_scale(sound, n, k)
short*  sound
int     n
double  k 

void
audio_osc_add(dst, dstn, frequency, amplitude)
short*  dst
int     dstn
double  frequency
double  amplitude

void
audio_table_add(dst, dstn, src, srcn, frequency, amplitude)
short*  dst
int     dstn
short*  src
int     srcn
double  frequency
double  amplitude

void
audio_table_iadd(dst, dstn, src, srcn, frequency, amplitude)
short*  dst
int     dstn
short*  src
int     srcn
double  frequency
double  amplitude

void 
audio_add(dst, dstoff, src, srcn)
short*  dst
int     dstoff
short*  src
int     srcn

void 
audio_linear_env(sound, x1, y1, x2, y2)
short*  sound
int     x1
double  y1
int     x2
double  y2

void
audio_exp_env(sound, n, halflife)
short*  sound
int     n
double  halflife

void
audio_table_env(dst, dstn, src, srcn)
short*  dst
int     dstn
short*  src
int     srcn

void
audio_noise(sound, n)
short*  sound
int     n

void 
audio_distort(sound, n, in1, out1, in2, out2)
short*  sound
int     n
int     in1
int     out1
int     in2
int     out2

void
audio_extract_add(dst, dstn, src, srcoff)
short*  dst
int     dstn
short*  src
int     srcoff

void
audio_move(dst, dstoff, src, srcoff, n)
short*  dst
int     dstoff
short*  src
int     srcoff
int     n

void
audio_flange(dst, dstn, src, srcn, ctl, ctln, frequency, amplitude)
short*  dst
int     dstn
short*  src
int     srcn		
short*  ctl
int     ctln		
double  frequency
double  amplitude

void
audio_phase(dst, dstn, src, srcn, ctl, ctln, frequency, amplitude)
short*  dst
int     dstn
short*  src
int     srcn		
short*  ctl
int     ctln		
double  frequency
double  amplitude
