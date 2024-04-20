#include <stdio.h>
#include <math.h>
#include <gd.h>

#define RATE       16000.0
#define DUR        11.0
#define FREQ_START 110.0
#define BLUR       149.0 /* how many samples to average over */
#define HEIGHT     72
#define WIDTH      ((int)(RATE * DUR) / BLUR)

int main() {
  FILE *in, *out, *out2;
  double 
    buffer[(int)(RATE * DUR)],
    sample[(int)(RATE * DUR)];
  int i, j, k;
  double f, df, a, b, freq, freq_inc;
  gdImagePtr im;

  /* read in sample */
  in = fopen("sound.sw", "r");
  if (!in) { perror ("Opening input file"); exit(1); }
  for (i  = 0; i < (int)(RATE * DUR); i++) {
    short tmp;
    fread(&tmp, sizeof(short), 1, in);
    sample[i] = (double)tmp;
  }
  fclose(in);

  /* set up output file */
  out = fopen("spectrum.gif", "w");
  if (!out) { perror("Opening output file"); exit(1); }

  /* set up debugging output file */
  out2 = fopen("audio.out", "w");
  if (!out2) { perror("Opening debugging file"); exit(1); }

  /* set up image */
  im = gdImageCreate(WIDTH, HEIGHT);
  for (i = 0; i < 256; i++) 
    gdImageColorAllocate(im, 255 - i, 255 - i, 255 - i);

  /* precalculate the half-step multiplier */
  freq_inc = pow(2.0, 1.0/12.0);

  /* start the actual work */
  for (freq = FREQ_START, j = 0;  j < HEIGHT; freq *= freq_inc, j++) {

    /* parameter setup */
    f = 0.0;
    df = 0.0;
    a = 50.0;
    b = 4.0 * M_PI * M_PI * freq * freq;

    /* simulate the resonance */
    for(i = 0; i < (int)(RATE * DUR); i++) {
      df -= (1/RATE) * (a * df + b * f);
      df +=  freq / 2.0 * sample[i];
      f  += (1/RATE) * df;
      buffer[i] = f;

    }

    /* calculate RMS amplitude and write to image */
    for(i = 0; i < WIDTH; i++) {
      double tmp, val;
      tmp = 0;
      for (k = 0; k < BLUR; k++) {
	double s = buffer[(int)BLUR * i + k];
	tmp += s * s;
      }
      val = (sqrt(tmp / BLUR) / 32000.0) * 256.0;
      if (val > 255.0) val = 255.0;
      if (val < 0.0) val = 0.0;
      gdImageSetPixel(im, i, j, val);
    }
  }
  gdImageGif(im, out);
  fclose(out);
  gdImageDestroy(im);
}
