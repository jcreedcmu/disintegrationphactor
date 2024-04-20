#include <stdio.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/conf.h>
#include <sys/audioio.h>
#include <fcntl.h>
#include <math.h>
#include <stropts.h>

#define SOUND_SIZE 1000
#define DIRECT 0
#if DIRECT
#define FILENAME "/dev/audio"
#else
#define FILENAME "sound"
#endif

typedef short frame_t;

#define oscillator(freq, amplitude, frame) \
((frame_t)((amplitude) * sin((2.0 * M_PI / 8000.0) * (freq) * (frame))))


void drum(int base_freq, int range_freq, int amplitude, int frames, frame_t *sound) {
int i, j;
 for(i=0; i < frames; i++) {
   sound[i] = 0;
   for(j=0; j < range_freq; j++) {
     sound[i] +=  oscillator(base_freq + j, ((amplitude * (frames - i)) / frames) / range_freq, i);
   } 
 }
}
int main(void) {
  int i, j, k, fd;
  audio_info_t ainfo;
  frame_t bass[SOUND_SIZE], snare[SOUND_SIZE], hitom[SOUND_SIZE], lotom[SOUND_SIZE];
  frame_t sound[SOUND_SIZE];
  double scale[12];
  
  for(i=0; i< 12; i++) {
    scale[i] = pow(2, i / 12.0);
  }
  
  fd = open(FILENAME, O_WRONLY);
  if (fd == -1) {
    printf("Couldn't open /dev/audio\n");
    return 1; 
  }
  else {
    printf("Successfully opened /dev/audio on fd %d...\n", fd);
  }
#if DIRECT
  ioctl(fd, AUDIO_GETINFO, &ainfo);
  ainfo.play.gain = 130;
  ainfo.play.encoding = AUDIO_ENCODING_LINEAR;
  ainfo.play.port = 1;
  printf("Playing on port %d\n", ainfo.play.port);
  ioctl(fd, AUDIO_SETINFO, &ainfo);
  ioctl(fd, AUDIO_GETINFO, &ainfo);
  printf("Sample rate, precision, encoding, channels: %d, %d, %d, %d\n", ainfo.play.sample_rate, ainfo.play.precision, ainfo.play.encoding, ainfo.play.channels);
#endif
  /*
    for(i=0; i<SOUND_SIZE; i++) {
    sound[i] = ((rand() % 8000) - 4000) * ((SOUND_SIZE - i) / (double)SOUND_SIZE);
    i++;
    sound[i] = sound[i-1];
    
    }*/

  /*
    drum(100, 50, 16000, SOUND_SIZE, bass);
    drum(120, 10, 16000, SOUND_SIZE, hitom);
    drum(90, 30, 16000, SOUND_SIZE, lotom);
  */
  for(i=0; i<SOUND_SIZE/2 ; i++) {
    snare[i] = ((rand() % 8000) - 4000) * (((SOUND_SIZE/2) - i) / (double)(SOUND_SIZE/2));
    i++;
    snare[i] = snare[i-1];
    if ((rand() & 7) <= 5) {
      i++;
      snare[i] = snare[i-1];
    }
  }
  for(i=0; i<SOUND_SIZE/2; i++) {
    snare[SOUND_SIZE/2 + i] = snare[i];
  }
for(j=0; j< 1; j++) {
    for(k=0; k< 8; k++) {
      drum(100 + (k * 10) , 50, 16000, SOUND_SIZE, bass);
      if ((k & 3) == 2) {
	for(i=0; i<SOUND_SIZE; i++) {
	  /* snare[i] = ((rand() % 8000) - 4000) * ((SOUND_SIZE - i) / (double)SOUND_SIZE) ; */
	  
	  /*	  i++;
		  snare[i] = snare[i-1];
		  bass[i-1] += snare[i-1]; */
	  bass[i] += snare[i];
	  
	}
      }
      write(fd, bass, SOUND_SIZE * sizeof(frame_t));  
    }
    
 } 
  close(fd);
  return 0;
}
