#ifndef AUDIO_H
#define AUDIO_H
#include <sys/types.h>

int 
audio_init();

void 
audio_destroy();

ssize_t 
audio_play(short *sound, int n);

#endif
