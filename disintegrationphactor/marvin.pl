#!/usr/local/bin/perl5 -w -I../Solaris/Audio/blib/lib -I../Solaris/Audio/blib/arch
use Solaris::Audio qw(:all);

#
# Marvin
#
# The styrofoam of electronic music:
# Nifty stuff, but full of holes.
#
$direct = 0;
$port = 2;
$frame = shift || 0;
$rate = 16000;
$speed = 1.85;
$seconds = 5;

require "disi.pl";

audio_init($direct);
if ($direct) {
audio_set_port($port);
audio_set_rate($rate);
audio_set_gain(40);
}
$sound = " " x ($rate * 2 * $seconds);
$bass = " " x ($rate * 2);
$snare = " " x ($rate * 2);
$sintbl = " " x ($rate * 2);
$sqrtbl = " " x ($rate * 2);
$tmp = " " x ($rate * 2);

audio_zero($sound, $rate * $seconds);

audio_zero($sintbl, $rate);
audio_osc_add($sintbl, $rate, 1, 32000);

audio_flat($sqrtbl, $rate, 32000);
audio_linear_env($sqrtbl, $rate/2, -1, $rate, -1);

audio_zero($bass, $rate);
audio_omni_drum($bass, $rate, $sintbl, $rate, 12, 30, 0.5, 1);
audio_scale($bass, $rate, 20);
audio_linear_env($bass, 0, 1.0, $rate, 0);

audio_zero($snare, $rate);
audio_zero($tmp, $rate);
audio_noise($tmp, $rate/8);
audio_linear_env($tmp, 0, 1, $rate/8, 0);

audio_omni_drum($snare, $rate/8, $sintbl, $rate,  90, 30, 1, 1);
audio_linear_env($snare, 0, 1, $rate / 8, 0);
audio_add($snare, 0, $tmp, $rate /8);

@drum_line = (
	      [0.000 => \$snare],

	      [1.000 => \$bass],
	      [1.500 => \$snare],
	      [2.000 => \$bass], [2.000 => \$snare],

	      [3.000 => \$snare],



	      [5.000 => \$bass],

	      [6.000 => \$snare],
	      [6.500 => \$snare],
	      [7.000 => \$bass], [7.000 => \$snare],
	    
);

foreach(@drum_line) {
  audio_add($sound, ($rate/8) * $speed * $_->[0], ${$_->[1]}, $rate);
}
$drum = $sound;

if ($frame <= 0) {
  for (1..4) {
    $frame < 1 and audio_play($sound, $rate * $speed);
  }
}
$ping = " " x ($rate/2);
audio_zero($ping, $rate/8);
audio_osc_add($ping, $rate/8, tone_of_string("A+"), 32000);
audio_linear_env($ping, 0, 1, $rate/8, 0);

for (0..7) {
  audio_add($sound, $_ * $rate/8 * $speed, $ping, $rate/8);
}

$frame_1 = $sound; # save
if ($frame <= 1) {
  for (1..4) {
    audio_play($sound, $rate * $speed);
  }
}
sub light_zorch {
my $zorch = " " x ($rate * 2);
audio_zero($zorch, $rate);

audio_omni_drum($zorch, $rate, $sqrtbl, $rate, 
		tone_of_string($_[0])-4, 2, .5, 1);
# print "b\n";
audio_zero($tmp, $rate);
audio_noise($tmp, $rate);
audio_linear_env($tmp, 1/4 * $rate, .5, $rate, 0);
audio_linear_env($tmp, 0, 1.0, 1/4 * $rate, .5);
audio_add($zorch, 0, $tmp, $rate);
audio_scale($zorch, $rate, 1/4);
$zorch;
}
 
$zorch = light_zorch("A--");
$asound = $sound;
audio_add($asound, 0, $zorch, $rate);
$zorch = light_zorch("G-");
$gsound = $sound;
audio_add($gsound, 0, $zorch, $rate);

if ($frame <= 2) {
  for (1..4) {
    audio_play($asound, $rate * $speed);
  }
}
$zorch = light_zorch("G--");
audio_add($asound, 3/8 * $rate * $speed, $zorch, $rate);
$zorch = light_zorch("A--");
audio_add($gsound, 3/8 * $rate * $speed, $zorch, $rate);

if ($frame <= 3) {
  for (1..2) {
    audio_play($asound, $rate * $speed);
    audio_play($gsound, $rate * $speed);
  }
}
$drum_tmp = $drum;
$snarev = $snare;
audio_scale($snarev, $rate, 1/2);
@drum_line = (
#	      [0.000 => \$snare],
	      0.500,
#	      [1.000 => \$bass],
#	      [1.500 => \$snare],
#	      [2.000 => \$bass], [2.000 => \$snare],
	      2.500,
#	      [3.000 => \$snare],


	      4.500,
#	      [5.000 => \$bass],

#	      [6.000 => \$snare],
	      6.250,
#	      [6.500 => \$snare],
#	      [7.000 => \$bass], [7.000 => \$snare],
	      7.250,
	      7.500,
	      7.750,
);

foreach(@drum_line) {
  audio_add($drum_tmp, ($rate/8) * $speed * $_, $snarev, $rate);
}
if ($frame <= 4) {
  for (1..4) {
    audio_play($drum_tmp, $rate * $speed);
  }
}
$drum_kickass = $drum_tmp; # save for later

# $drum_tmp = $drum;
audio_zero($snarev, $rate/8);
audio_omni_drum($snarev, $rate/8, $sintbl, $rate,  100, 10, 1, 1);
audio_scale($snarev, $rate/8, 3);

@drum_line = (
#	      [0.000 => \$snare],
 	      1.500,
#	      [1.000 => \$bass],
#	      [1.500 => \$snare],
#	      [2.000 => \$bass], [2.000 => \$snare],
	      2.500,
#	      [3.000 => \$snare],


	      4.000,
#	      [5.000 => \$bass],

#	      [6.000 => \$snare],
#	      [6.500 => \$snare],
#	      [7.000 => \$bass], [7.000 => \$snare],
	   #   7.500,	  
);

foreach(@drum_line) {
  audio_add($drum_tmp, ($rate/8) * $speed * $_, $snarev, $rate);
}
if ($frame <= 5) {
  for (1..4) {
    audio_play($drum_tmp, $rate * $speed);
  }
}

####
$drum_tmp_g = $drum_tmp_a = $drum_tmp;

audio_zero($ping, $rate/4);
audio_noise($ping, $rate/8);
audio_scale($ping, $rate/8, 1/4);
$pa = $pg = $ping;
audio_osc_add($pg, $rate/8, tone_of_string("G"), 32000);
audio_osc_add($pa, $rate/8, tone_of_string("A"), 32000);
audio_linear_env($pg, 0, .5, $rate/8, 0);
audio_linear_env($pa, 0, .5, $rate/8, 0);
for (0..7) {
  audio_add($drum_tmp_g, $_ * $rate/8 * $speed, $pg, $rate/8);
}
for (0..7) {
  audio_add($drum_tmp_a, $_ * $rate/8 * $speed, $pa, $rate/8);
}
if ($frame <= 6) {
  for (1..2) {
    audio_play($drum_tmp_g, $rate * $speed);
    audio_play($drum_tmp_a, $rate * $speed);
  }
}

#### Frame 7 change the timbre a bit
$drum_tmp_g = $drum_tmp_a = $drum;

$ping_dur = 3/16;
audio_zero($ping, $rate/4);
 audio_noise($ping, $rate/16);
 audio_linear_env($ping, 0, .5, $rate/16, .25);
$pa = $pg = $ping;
audio_osc_add($pg, $ping_dur * $rate, tone_of_string("G-"), 25000);
audio_osc_add($pg, $ping_dur * $rate, tone_of_string("G"), 2000);
audio_osc_add($pa, $ping_dur * $rate, tone_of_string("A-"), 25000);
audio_osc_add($pa, $ping_dur * $rate, tone_of_string("A"), 2000);
audio_linear_env($pg, 0, .65, $ping_dur * $rate, .125);
audio_linear_env($pa, 0, .65, $ping_dur * $rate, .125);
audio_scale($pg, $ping_dur * $rate, 1.25);
audio_scale($pa, $ping_dur * $rate, 1.25);
for (0..7) {
  audio_add($drum_tmp_g, $_ * $rate/8 * $speed, $pg, $rate/4);
}
for (0..7) {
  audio_add($drum_tmp_a, $_ * $rate/8 * $speed, $pa, $rate/4);
}
if ($frame <= 7) {
  for (1..2) {
    audio_play($drum_tmp_g, $rate * $speed);
    audio_play($drum_tmp_a, $rate * $speed);
  }
}

### Frame 8 ... phone-like shit

$drum_g = $drum_tmp_g; 
$drum_a = $drum_tmp_a;

for (0..15) {
  audio_zero($pg, $rate / 4);
  audio_osc_add($pg, $rate /4, tone_of_string("G+") * (sqrt(2) ** ($_ % 3)), 10000);
  #audio_linear_env($pg, 0, 1, $rate / 4, 0);
  audio_add($drum_tmp_g, $_ * $rate * $speed / 16, $pg, $rate / 4);

  audio_zero($pa, $rate / 4);
  audio_osc_add($pa, $rate /4, tone_of_string("G+") / (sqrt(2) ** ($_ % 6)), 10000);
  #audio_linear_env($pa, 0, 1, $rate / 4, 0);
  audio_add($drum_tmp_a, $_ * $rate * $speed / 16, $pa, $rate / 4);
}

if ($frame <= 8) {
  for (1..2) {
    audio_play($drum_tmp_g, $rate * $speed);
    audio_play($drum_tmp_a, $rate * $speed);
  }
}

###

### Frame 9 ... even more phone-like shit

$drum_tmp_g = $drum_g; 
$drum_tmp_a = $drum_a;

for (0..15) {
  audio_zero($pg, $rate / 4);
  audio_osc_add($pg, $rate /4, tone_of_string("G+") * (sqrt(2) ** ($_ % 4)), 10000);
  #audio_linear_env($pg, 0, 1, $rate / 4, 0);
  audio_add($drum_tmp_g, $_ * $rate * $speed / 16, $pg, $rate / 4);

  audio_zero($pa, $rate / 4);
  audio_osc_add($pa, $rate /4, tone_of_string("A+") / (sqrt(2) ** ($_ % 3)), 10000);
  #audio_linear_env($pa, 0, 1, $rate / 4, 0);
  audio_add($drum_tmp_a, $_ * $rate * $speed / 16, $pa, $rate / 4);
}

if ($frame <= 9) {
  for (1..2) {
    audio_play($drum_tmp_g, $rate * $speed);
    audio_play($drum_tmp_a, $rate * $speed);
  }
}

###

### Frame 10 ... drop back a bit.

audio_zero($drum_tmp, $rate * $speed);
@drum_line = (
	      [0.000 => \$snare],
# 	      1.500,
	     #[1.000 => \$bass],
	      [1.500 => \$snare],
	      [2.000 => \$bass], #[2.000 => \$snarev],
#	      2.500,
	      [3.000 => \$snare],


#	      4.000,
	      [5.000 => \$bass],

	      [6.000 => \$snare], #[6.000 => \$snarev],
	      #[6.500 => \$snarev],
#	      [7.000 => \$bass], [7.000 => \$snare],
#              7.500,	  
);

foreach(@drum_line) {
  audio_add($drum_tmp, ($rate/8) * $speed * $_->[0], ${$_->[1]}, $rate);
}

if ($frame <= 10) {
  for (1..4) {
    audio_play($drum_tmp, $rate * $speed);
  }
}

### Frame 11 ... pick up.

@drum_line = (
	      #[0.000 => \$snare],
# 	      1.500,
	      [1.000 => \$bass],
	      #[1.500 => \$snare],
	      #[2.000 => \$bass], 
	      [2.000 => \$snarev],
#	      2.500,
	      #[3.000 => \$snare],


#	      4.000,
	      #[5.000 => \$bass],

	      #[6.000 => \$snare], 
	      [6.000 => \$snarev],
	      [6.500 => \$snarev],
#	      [7.000 => \$bass], [7.000 => \$snare],
#              7.500,	  
);

foreach(@drum_line) {
  audio_add($drum_tmp, ($rate/8) * $speed * $_->[0], ${$_->[1]}, $rate);
}

if ($frame <= 11) {
  for (1..4) {
    audio_play($drum_tmp, $rate * $speed);
  }
}

### Frame 12: echo

@drum_line = (
	      [0.500 => \$snare],
# 	      1.500,
	      [1.500 => \$bass],
	      [2.000 => \$snare],
	      [2.500 => \$bass], [2.000 => \$snarev],
#	      2.500,
	      [3.500 => \$snare],


#	      4.000,
	      [5.500 => \$bass],

	      [6.500 => \$snare], [6.000 => \$snarev],
	      [7.000 => \$snarev],
#	      [7.000 => \$bass], [7.000 => \$snare],
	   #   7.500,	  
);

foreach(@drum_line) {
  audio_add($drum_tmp, ($rate/8) * $speed * $_->[0], ${$_->[1]}, $rate);
}

if ($frame <= 12) {
  for (1..4) {
    audio_play($drum_tmp, $rate * $speed);
  }
}

### Frame 13: flashback...
audio_add($drum_kickass, 0, $drum_tmp, $rate * $speed);
if ($frame <= 13) {
  for (1..4) {
    audio_play($drum_kickass, $rate * $speed);
  }
}

### Frame 14: two...

audio_scale($drum_kickass, $rate * $speed, 3/4);
audio_scale($drum_tmp_g, $rate * $speed, 1/4);
audio_scale($drum_tmp_a, $rate * $speed, 1/4);
audio_add($drum_tmp_g, 0, $drum_kickass, $rate * $speed);
audio_add($drum_tmp_a, 0, $drum_kickass, $rate * $speed);
if ($frame <= 14) {
  for (1..2) {
    audio_play($drum_tmp_g, $rate * $speed);
    audio_play($drum_tmp_a, $rate * $speed);
  }
}
### Frame 15: three...


audio_scale($frame_1, $rate * $speed, 1/4);
audio_scale($drum_tmp_g, $rate * $speed, 7/8);
audio_scale($drum_tmp_a, $rate * $speed, 7/8);
$off = $rate * $speed / 16;
audio_add($drum_tmp_g, $off, $frame_1, $rate * $speed - $off);
audio_add($drum_tmp_a, $off, $frame_1, $rate * $speed - $off);
if ($frame <= 15) {
  for (1..2) {
    audio_play($drum_tmp_g, $rate * $speed);
    audio_play($drum_tmp_a, $rate * $speed);
  }
}

### Frame 16: four...

# audio_scale($drum_tmp_g, $rate * $speed, 3/4);
# audio_scale($drum_tmp_a, $rate * $speed, 3/4);
$off = $rate * $speed / 8;
audio_add($drum_tmp_g, $off, $frame_1, $rate * $speed - $off);
audio_add($drum_tmp_a, $off, $frame_1, $rate * $speed - $off);
if ($frame <= 16) {
  for (1..2) {
    audio_play($drum_tmp_g, $rate * $speed);
    audio_play($drum_tmp_a, $rate * $speed);
  }
}

### Frame 17: closing time
$tone_tmp = $drum_tmp;
audio_zero($tone_tmp, $rate * $speed);
audio_osc_add($tone_tmp, $rate * $speed, tone_of_string("A--"), 8000);
audio_linear_env($tone_tmp, 0, 1, $rate * $speed, 0);
audio_linear_env($drum_tmp, 0, 0, $rate * $speed, 1);
audio_add($drum_tmp, 0, $tone_tmp, $rate * $speed);



if ($frame <= 17) {
  for (1..3) {
    audio_play($drum_tmp, $rate * $speed);
  }
}

audio_noise($tone_tmp, $rate * $speed);
audio_linear_env($tone_tmp, 0, 0, $rate * $speed, 1);
audio_linear_env($drum_tmp, 0, 1, $rate * $speed, 0);
audio_add($drum_tmp, 0, $tone_tmp, $rate * $speed);

audio_play($drum_tmp, $rate * $speed);
audio_destroy();
