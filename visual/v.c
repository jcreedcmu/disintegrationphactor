#include <gd.h>
#include <stdio.h>

#define HEIGHT 100
#define WIDTH 10000
#define VWIDTH 80000.0

int main() {
FILE *in, *out;
int i;
gdImagePtr im;
int black, white;
double oldy = 0;

in = fopen("audio.out", "r");
if (!in) { perror("Opening input file"); exit(1); }

im = gdImageCreate(WIDTH, HEIGHT);
white = gdImageColorAllocate(im, 255, 255, 255);
black = gdImageColorAllocate(im, 0, 0, 0);


for(i=0; i<VWIDTH; i++) {
  short sample;
  double x, y;
  fread(&sample, sizeof(short), 1, in);
  x = (double)i / (double)VWIDTH * (double)WIDTH;
  y = (((double)sample + 32768.0) / 65535.0) * HEIGHT;
/*  gdImageLine(im, x, y, x, HEIGHT / 2, black); */
  gdImageSetPixel(im, x, y, black);  
/*  gdImageLine(im, x, y, x-1, oldy, black); */
  oldy = y;
}

fclose(in);
out = fopen("vis.gif", "wb");
if (!out) { perror("Opening output file"); exit(1); }
gdImageGif(im, out);
fclose(out);

gdImageDestroy(im);
}
