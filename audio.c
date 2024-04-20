#include <stdio.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/conf.h>
#include <sys/audioio.h>
#include <fcntl.h>
#include "audio.h"

int fd;

int audio_init() {
  audio_info_t ainfo;

 fd = open("/dev/audio", O_WRONLY);
  if (fd == -1) {
    return 0; 
  }
  ioctl(fd, AUDIO_GETINFO, &ainfo);
  ainfo.play.gain = 120;
  ainfo.play.encoding = AUDIO_ENCODING_LINEAR;
  ainfo.play.port = 1;

  ioctl(fd, AUDIO_SETINFO, &ainfo);
}

void audio_destroy() {
  close(fd);
}

ssize_t audio_play(short *sound, int n) {
    return (write(fd, sound, n * sizeof(short)));
}
