#include <stdio.h>
#include <fcntl.h>
#include <gd.h>
#include <math.h>

#define MAX_L 1.0 /* m */
#define NUM_PTS 20
#define DL (MAX_L / (double)NUM_PTS) /* m */
#define C 50.0 /* m / s */
#define BETA -100.0 /* ?? */
#define DT 0.0000625 /* s */
#define MAX_T 2.0 /* s */

typedef double pt;

pt wire_r[NUM_PTS];    
pt wire_l[NUM_PTS];

#define HEIGHT 50

gdImagePtr im;

void snapshot_init() {
  int i;

  im = gdImageCreate(NUM_PTS, HEIGHT);
  /*
  for (i = 0; i < 256; i++) {
    gdImageColorAllocate(im, 255-i, 255-i, 255-i);
  }
  */
  gdImageColorAllocate(im, 255, 255, 255);
  gdImageColorAllocate(im, 0, 0, 0);
  gdImageColorAllocate(im, 255, 0, 255);
}

void snapshot_update (pt wire[NUM_PTS]) {
  int i;
  
  for (i = 0; i < NUM_PTS; i++) {
    gdImageSetPixel(im,  i, ((1. - wire[i]) / 2.) * HEIGHT, 1);
  }
}

void snapshot_write() {
  FILE *out;

  out = fopen("m.gif", "wb");
  if (!out) { perror("Opening output file"); exit(1); }
  gdImageGif(im, out);
  fclose(out);
}

int main(void) {

  int i, t, fd;
  int ll = 0, rr = 0;
  pt x = .3;
  short buffer[(int)(MAX_T / DT)];

  unlink("audio.out");
  fd = open("audio.out", O_CREAT | O_RDWR, 0644);
  if (fd == -1) {
    printf("Couldn't open audio file\n");
    exit(1);
  }
  srand();
  snapshot_init();

  for(i=0; i<NUM_PTS; i++) {
    double val;
    val = (rand() % 8) / 2.0;
    wire_l[i] = 0.10 * val;
    val = (rand() % 8) / 2.0;
    wire_r[i] = 0.10 * val;
  }

  for(t = 0; t < (MAX_T / DT); t++) {
    pt ol = wire_l[ll]*-0.9 + wire_l[(ll+1)%NUM_PTS]*-0.099, 
      or = wire_r[rr]*-0.9 + wire_r[(rr+NUM_PTS-1)%NUM_PTS]*-0.099;
    if (0) {
      pt real_wire[NUM_PTS];
      for(i = 0; i<NUM_PTS; i++) {
	real_wire[i] = (wire_l[(ll + i) % NUM_PTS] + wire_r[(NUM_PTS + rr + i - 1) % NUM_PTS]) / 2;
      }
      printf("writing\n");
      snapshot_update(real_wire);
      snapshot_write();
      exit(0);
    }
  
    /* buffer[t] = (short)(8000 * (wire_l[(ll+NUM_PTS/2) % NUM_PTS])+wire_r[(rr) % NUM_PTS]);*/
    buffer[t] = (short)(8000 * (wire_l[(ll+NUM_PTS/2) % NUM_PTS]));
    
    if (!(t%10)) x = 3.9 * x * (1.0 - x);
    wire_l[ll] = or;
    wire_r[rr] = ol;
    /*    if (t < (MAX_T / DT) / 4.0) {
      wire_l[(ll + NUM_PTS/2) % NUM_PTS] -= 0.2 * x;
      }*/
    /*    if (t > (MAX_T / DT) / 2.0) {
      wire_r[rr] *= 0.9;
      }*/

    ll++;
    rr--;
    if (ll >= NUM_PTS) ll = 0;
    if (rr < 0) rr = NUM_PTS - 1;
  }
  write(fd, &buffer, (int)(MAX_T / DT) * sizeof(short));
}


