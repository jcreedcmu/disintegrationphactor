#ifndef AUDIO_H
#define AUDIO_H
#include <sys/types.h>

int audio_init(int direct);
void audio_set_port(int port);
void audio_set_rate(int rate);
void audio_set_gain(int gain);
void audio_destroy();
ssize_t audio_play(short *sound, int n);
/* void audio_flat(short *sound, int n, short level);*/
/*#define audio_zero(sound, n) (audio_flat((sound), (n), 0))*/
void audio_drum(short *sound, int n, int base_freq, int range_freq, int amplitude);
void audio_drum2(short *sound, int n, int base_freq, int range_freq, int amplitude);
void audio_omni_drum(short *dst, int dstn, 
		     short *src, int srcn, 
		     int base_freq, int range_freq, 
		     double step_freq, double amplitude);
void audio_scale(short *sound, int n, double k);
void audio_osc_add(short *dst, int dstn, double frequency, double amplitude);
void audio_table_add(short *dst, int dstn, 
		     short *src, int srcn, 
		     double frequency, double amplitude);
void audio_table_iadd(short *dst, int dstn, 
		     short *src, int srcn, 
		     double frequency, double amplitude);
void audio_add(short *dst, int dstoff,
	       short *src, int srcn);
void audio_linear_env(short *sound, int x1, double y1, int x2, double y2);
void audio_exp_env(short *sound, int n, double halflife);
void audio_table_env(short *dst, int dstn, 
		     short *src, int srcn);
void audio_noise(short *sound, int n);
void audio_distort(short *sound, int n,  int in1, int out1, int in2, int out2);
void audio_extract_add(short *dst, int dstn, short *src, int srcoff);
void audio_move(short *dst, int dstoff, short *src, int srcoff, int n);
void audio_flange(short *dst, int dstn, 
		  short *src, int srcn,
		  short *ctl, int ctln,
		  double frequency, double amplitude);
void audio_phase(short *dst, int dstn, 
		 short *src, int srcn,
		 short *ctl, int ctln,
	         double frequency, double amplitude);
#endif
