#!/usr/local/bin/perl5 -I../Solaris/Audio/blib/lib -I../Solaris/Audio/blib/arch
use Solaris::Audio qw(:all);

#
# Flat Nine
#
# Funny, I don't see one. Maybe if I look harder...
#

$frame = shift || 0;
$direct = 1;
$port = 2;
$rate = 16000;
$s = $rate; # one second
$b = ($s * 60) / 120; # one beat


$m = $b * 4; # one measure

audio_init($direct) or die "Couldn't open audio";
if ($direct) {
audio_set_port($port);
audio_set_rate($rate);
audio_set_gain(80);
}

require "disi.pl";

audio_zero($sound, 4 * $m + $s);

audio_zero($sintbl, $s);
audio_osc_add($sintbl, $s, 1, 32000);
audio_zero($tontbl, $s);
audio_osc_add($tontbl, $s, 1, 16000);
audio_osc_add($tontbl, $s, 3, 16000);

audio_zero($bass, $s);
audio_omni_drum($bass, $s, $sintbl, $s, 12, 30, 0.5, 1);
audio_scale($bass, $s, 20);
audio_linear_env($bass, 0, 1.0, $s, 0);

audio_zero($snare, $s);
audio_zero($sh_snare, $s);

audio_zero($tmp, $s);
audio_noise($tmp, $s/4);
audio_linear_env($tmp, 0, 1, 3 * $s/16, 0);
audio_omni_drum($snare, 3 * $s/16, $sintbl, $s,  90, 30, 1, 1);
audio_linear_env($snare, 0, 1, 3 * $s / 16, 0);
audio_add($snare, 0, $tmp, 3 * $s /16);

audio_zero($tmp, $s);
audio_noise($tmp, $s/4);
audio_linear_env($tmp, 0, 1, $s/8, 0);
audio_omni_drum($sh_snare, $s/8, $sintbl, $s,  90, 30, 1, 1);
audio_linear_env($sh_snare, 0, 1, $s /8, 0);
audio_add($sh_snare, 0, $tmp, $s /8);

audio_zero($tick, $s);
audio_noise($tick, $s/8);
audio_linear_env($tick, 0, 1, $s/8, 0);

$loud_bass = $bass;
audio_scale($loud_bass, $s, 3/4);
audio_scale($bass, $s, 2/3);
audio_scale($snare, $s, 1/8);
audio_scale($sh_snare, $s, 1/8);
audio_scale($tick, $s, 1/4);

$| = 1;


#############

@bass_line = qw(A-- G-- C- A-- Eb-- Eb- D- G--);
for (0..7) {
 note($sound, 0 + $b * $_, $bass_line[$_], $b * 2/3, 1600, [1, .5, .25]);
 note($sound, $b * 2/3 + $b * $_, $bass_line[$_], $b * 1/3, 1600, [.5, 1, .25]);
}

if ($frame <= 0) {
  for (1..2) {
    audio_play($sound, 2* $m);
  }
}

for (0..3) {
  cymbal($sound, 2 * $b * $_ + 0, $b, 2000);
#  tick($sound, $b * (2 * $_ + 1), 1000);
#  tick($sound, $b * (2* $_ + 1+2/3), 800);
  cymbal($sound, $b * (2 * $_ + 1), $b / 8, 1000);
  cymbal($sound, $b * (2* $_ + 1+2/3), $b / 2, 800);
}

if ($frame <= 1) {
  for (1..2) {
    audio_play($sound, 2* $m);
  }
}

audio_zero($bit, 8 * $m); 
audio_table_add($bit, 8 * $m, $sound, 2 * $m, 1, 1);

@melody = (
  qw(x2/3 A4! C+2/3!~ B/3 A/3 C+/3 A(1+1/3)!), # under 1/3
  qw(A(4+1/3)!! D+2/3~ Eb+! D+/3? Eb+2/3! C+/3 D+/3 Eb+/3), # under 1/3
  qw(D+5! C+2/3!~ B/3 A/3 Eb+/3 C+(2+1/3)!), # over 2/3
  qw(E+! C+! A! Eb~ D!~~ C/3~~~ D/3?~~~ E/3?~~ G/3~~ B/3!~ A2/3?), # even
);

do_melody(\$bit, @melody);

if ($frame <= 2) {
    audio_play($bit, 8* $m);
}

my $bit2 = $bit;
my $bit3 = $bit;

for (0..2) {
  cymbal($bit2, (30 + $_ / 3) * $b, $b/3, 1000);
  lo_cymbal($bit2, (31 + $_ / 3) * $b, $b/3, 2000);
}

if ($frame <= 3) {
    audio_play($bit2, 8* $m);
}

### BRIDGE !

audio_zero($bsound, 4 * $m);

@bass_line = qw(Bb-- F-- Ab-- D-  A-- E-- G-- Db-
		Ab-- Eb-- Gb-- C- G-- D-- F-- B--);

for (0..15) {
  if ($_ % 4 == 0 || $_ % 4 == 3) {
    note($bsound, 0 + $b * $_, $bass_line[$_], $b * 2 / 3, 1600, [1, .5, .25]);
    note($bsound, $b * 2/3 + $b * $_, $bass_line[$_], $b * 1/3, 1600, [.5, 1, .25]);
  }
  else {
    note($bsound, 0 + $b * $_, $bass_line[$_], $b, 1600, [1, .5, .25]);
  }
}


for (0..3) {
  lo_cymbal($bsound, $b * (4 * $_ + 0), 2 * $b, 1000);
  lo_cymbal($bsound, $b * (4 * $_ + 2), 2 * $b, 1000);
  cymbal($bsound, $b * (4 * $_ + 0), $b, 3000);
  cymbal($bsound, $b * (4 * $_ + 1), $b, 3000);
  cymbal($bsound, $b * (4 * $_ + 2), $b, 3000);
  cymbal($bsound, $b * (4 * $_ + 3), $b, 2000);
  cymbal($bsound, $b * (4 * $_ + 3 + 2/3), $b/4, 1000);
}


@melody = (
	   qw(Bb(2+2/3) D+2/3! Bb2/3! 
	      A(2+2/3) C#+2/3! E+2/3! 
	      Ab(2+2/3) Bb/3 C+/3 Bb/3 Ab/3
	      G4),
	  );

lo_cymbal($bsound, 0, $b * 8, 2000);
$bsound1 = $bsound;
do_melody(\$bsound, @melody);
$bsound1m = $bsound;

if ($frame <= 4) {
  audio_play($bsound, 4* $m);
}

audio_zero($bsound, 4 * $m);

@bass_line = qw(Bb-- F-- Ab-- D-  A-- E-- G-- Db-
		Ab-- Eb-- Gb-- C- E-- Ab-- B--);
for (0..14) {
  if ($_ % 4 == 0 || $_ % 4 == 3 || $_ >= 12) {
    note($bsound, 0 + $b * $_, $bass_line[$_], $b * 2 / 3, 1600, [1, .5, .25]);
    note($bsound, $b * 2/3 + $b * $_, $bass_line[$_], $b * 1/3, 1600, [.5, 1, .25]);
  }
  else {
    note($bsound, 0 + $b * $_, $bass_line[$_], $b , 1600, [1, .5, .25]);
  }
}

$i=0;
foreach (qw(D- C- B--)) {
  note($bsound, $b * 15 + ($b / 3) * $i++, $_, $b * 1/3, 1600, [.5, 1, .25]);
}

for (0..3) {
  lo_cymbal($bsound, $b * (4 * $_ + 0), 2 * $b, 1000);
  lo_cymbal($bsound, $b * (4 * $_ + 2), 2 * $b, 1000);
  cymbal($bsound, $b * (4 * $_ + 0), $b, 3000);
  cymbal($bsound, $b * (4 * $_ + 1), $b, 3000);
  cymbal($bsound, $b * (4 * $_ + 2), $b, 3000);
  cymbal($bsound, $b * (4 * $_ + 3), $b, 2000);
  cymbal($bsound, $b * (4 * $_ + 3 + 2/3), $b/4, 1000);
}

for (0..2) {
  cymbal($bsound, (14 + $_ / 3) * $b, $b/3, 1000);
  lo_cymbal($bsound, (15 + $_ / 3) * $b, $b/3, 2000);
}

$bsound2 = $bsound;
@melody = (
	   qw(Bb(2+2/3) D+2/3! F+2/3! 
	      A(2+2/3) C#+2/3! A2/3! 
	      Ab(3) Bb/3 C+/3 D+/3 
	      E+2/3 D+2/3 C+2/3 B G),
	  );

do_melody(\$bsound, @melody);
$bsound2m = $bsound;

if ($frame <= 5) {
  audio_play($bsound, 4* $m);
}

## Back to main

lo_cymbal($bit, 0, $b * 8, 2000);

if ($frame <= 6) {
  audio_play($bit, 8 * $m);
}

## Solo time

if ($frame <= 7) {
  my $ssound = $sound;
  @melody = qw(x4 A2/3 A2/3 G2/3 A2);
  do_melody(\$ssound, @melody);
  audio_play($ssound, 2 * $m)
}

if ($frame <= 8) {
  my $ssound = $sound;
  @melody = qw(A2/3 A2/3 G2/3 A/3 B/3 C+/3 Eb/2 E/2 x2 A/6 A/6 G/6 A/6 A/6 G/6 E);
  do_melody(\$ssound, @melody);
  audio_play($ssound, 2 * $m)
}

if ($frame <= 9) {
  my $ssound = $sound;
  @melody = qw(A/3 A/3 C+/3 B/3 B/3 D+/3 
	       C+/3 C+/3 E+/3 E+/3 Eb+/3 D+/3
	      A/3 B/3 C+/3 
	       A/3 B/3 E+/3);
  do_melody(\$ssound, @melody);
  audio_play($ssound, 2 * $m)
}

if ($frame <= 10) {
  my $ssound = $sound;
  @melody = qw( A+/2 E+/2
	      A G G#
		x1 A2/3 C+2/3 B2/3 A);
  do_melody(\$ssound, @melody);
  audio_play($ssound, 2 * $m)
}

if ($frame <= 7) {
  my $ssound = $sound;
  @melody = qw(x1 D/6 Eb/6 E/6 D/6 Eb/6 E/6 A2 A/3 A/3 A/3 G E C);
  do_melody(\$ssound, @melody);
  audio_play($ssound, 2 * $m)
}

if ($frame <= 8) {
  my $ssound = $sound;
  @melody = qw(A2/3 G E C4/3 Eb E2/3 G/3 E2/3 D/3 A-);
  do_melody(\$ssound, @melody);
  audio_play($ssound, 2 * $m)
}

if ($frame <= 9) {
  my $ssound = $sound;
  @melody = qw(x/4 D/4 Eb/4 E/4 A2/3 G2/3 A2/3 Eb x/4 D/4 Eb/4 E/4 A E A-);
  do_melody(\$ssound, @melody);
  audio_play($ssound, 2 * $m)
}

if ($frame <= 10) {
  my $ssound = $sound;
  @melody = qw(D/4 Eb/4 E/4 A/4 
               D/4 Eb/4 E/4 A/8 E/8 
	       D/4 Eb/4 E/4 A/8 G/8 A
	       G2/3 A2/3 G2/3 Eb D);
  do_melody(\$ssound, @melody);
  audio_play($ssound, 2 * $m)
}

if ($frame <= 11) {
  my $sbsound = $bsound1;
  @melody = qw(x3/2  Bb/8 Ab/8 Bb/8 Ab/8 Bb Bb
	       A2/3 E2/3 E7/3 Eb/3
	       Eb2/3 Ab/3 Ab2/3 C+/3 C+2/3 Eb+/3 Eb+2/3
	       D+7/3 G B);
  do_melody(\$sbsound, @melody);
  audio_play($sbsound, 4 * $m);
}

if ($frame <= 12) {
  my $sbsound = $bsound2;
  @melody = qw(x3/2  Bb/6 Ab/6 F/6 D D
	       E2/3 C#2/3 E7/3 Eb/3
	       Ab2/3 Ab/3 Eb2/3 Eb/3 Gb2/3 Gb/3 Eb2/3
	       D4/3 E G# B);
  do_melody(\$sbsound, @melody);
  audio_play($sbsound, 4 * $m);
}

audio_zero($bit, 8 * $m); 
audio_table_add($bit, 8 * $m, $sound, 2 * $m, 1, 1);
lo_cymbal($bit, 0, $b * 8, 2000);

if ($frame <= 13) {
  @melody = qw(A4 A/3 E/3 E D/3 A2/3 G/3 E
	       D/6 Eb/6 E/6 G/2 A D/4 Eb/4 E/4 G/4 A D/2 Eb/6 E/6 G/6 C+ A G
	       x2 A2/3 A2/3 A2/3 Eb2/3 D4/3 C A
	       G/4 Ab/4 A/4 G/4 Eb/3 E/3 D/3 C2 G/4 Ab/4 A/4 G/4 Eb/3 E/3 D/3 B- G-
	      );
  do_melody(\$bit, @melody);

  # transitional cymbal shit
  for (0..2) {
    cymbal($bit, (30 + $_ / 3) * $b, $b/3, 1000);
    lo_cymbal($bit, (31 + $_ / 3) * $b, $b/3, 2000);
  }
  
  audio_play($bit, 8 * $m);
}

# redo the head

lo_cymbal($bit3, 0, $b * 8, 2000);

if ($frame <= 14) {
  audio_play($bit3, 8 * $m);
  audio_play($bit2, 8 * $m);
}

if ($frame <= 15) {

  audio_play($bsound1m, 4 * $m);
  audio_play($bsound2m, 4 * $m);
}

if ($frame <= 16) {
  audio_play($bit3, 8 * $m);
}

# ending

@melody = qw(A4 A/3 E/3 E4/3 E/3 G/3 G4/3);

if ($frame <= 17) {
  do_melody(\$sound, @melody);
  lo_cymbal($sound, 0, $b * 8, 2000);
  # transitional cymbal shit
  for (0..2) {
    cymbal($sound, (6 + $_ / 3) * $b, $b/3, 1000);
    lo_cymbal($sound, (7 + $_ / 3) * $b, $b/3, 2000);
  }
  audio_play($sound, 2 * $m);
  audio_linear_env($sound, 0, 1, 2 * $m, 1/2);
  audio_play($sound, 2 * $m);
  audio_linear_env($sound, 0, 1/2, 2 * $m, 0);
  audio_play($sound, 2 * $m);
}

audio_destroy(); 

## Subs

sub note {
  my ($off, $which, $dur, $amp, $harm); 
  (undef, $off, $which, $dur, $amp, $harm) = @_;
  my $tmp;
  $amp =  $amp || 1600;
  audio_zero($tmp, $dur);
  my $h = 0;
  foreach(@$harm) {
    $h++;
    audio_osc_add($tmp, $dur, $h * tone_of_string($which), $_ * $amp);
  }
  my $attack = $s / 64;
  my $sustain_level = 1/4;
  audio_linear_env($tmp, 0, 0, $attack , 1);
  audio_linear_env($tmp, $attack, 1, $attack * 2, $sustain_level);
  audio_linear_env($tmp, $attack * 2, $sustain_level, 
		   $dur - $attack, $sustain_level);
  audio_linear_env($tmp, $dur- $attack, $sustain_level, $dur, 0);
  audio_scale($tmp, $dur, 20);
  audio_scale($tmp, $dur, 1/2);
  audio_add($_[0], $off, $tmp, $dur);
}

sub fade_note {
  my ($off, $which, $dur, $amp, $harm); 
  (undef, $off, $which, $dur, $amp, $harm) = @_;
  my $tmp;
  $amp =  $amp || 1600;
  audio_zero($tmp, $dur);
  my $h = 0;
  foreach(@$harm) {
    $h++;
    audio_osc_add($tmp, $dur, $h * tone_of_string($which), $_ * $amp);
  }
  my $attack = $s / 200;
  my $sustain_level = 1/6;
 # audio_linear_env($tmp, 0, 0, $attack , 1);
#  audio_linear_env($tmp, $attack, 1, $attack * 2, $sustain_level);
#  audio_linear_env($tmp, $attack * 2, $sustain_level, 
#		   $dur - $attack, $sustain_level);
#  audio_linear_env($tmp, $dur- $attack, $sustain_level, $dur, 0);
my $attack_level;
$attack_level = $dur / $b; 
if ($attack_level > 1) { $attack_level = 1 }
$attack_level = 1 / 2 + $attack_level / 2;
  audio_linear_envs($tmp, 
		    0, 0, 
		    $attack , $attack_level,
		    $attack * 2, $sustain_level,
		    $dur - $attack, $sustain_level,
		    $dur, 0);
  audio_exp_env($tmp, $dur, 2/3 * $s);
  audio_scale($tmp, $dur, 20);
  audio_scale($tmp, $dur, 1/2);
  audio_add($_[0], $off, $tmp, $dur);
}

sub lo_cymbal {
  my ($off, $dur, $amp); 
  (undef, $off, $dur, $amp) = @_;
  my $tmp;
  $amp =  $amp || 1600;
  audio_zero($tmp, $dur);
  audio_zero($tmp2, $dur);
  audio_noise($tmp2, $dur);
  audio_table_iadd($tmp, $dur, $tmp2, $dur, 1/2, 1);
  audio_scale($tmp, $dur, $amp/32000);
  my $attack = $s / 200;
  my $sustain_level = 1/2;
  audio_linear_envs($tmp, 
		    0              => 0,
		    $attack        => 1,
		    $attack * 2    => $sustain_level,
		    $dur - $attack => $sustain_level,
		    $dur           => 0,
		   );

  audio_exp_env($tmp, $dur,  $s );
  audio_add($_[0], $off, $tmp, $dur);
}

sub cymbal {
  my ($off, $dur, $amp); 
  (undef, $off, $dur, $amp) = @_;
  my $tmp;
  $amp =  $amp || 1600;
  audio_zero($tmp, $dur);
  audio_noise($tmp, $dur);
  audio_scale($tmp, $dur, $amp/32000);
  my $attack = $s / 200;
  my $sustain_level = 1/8;
  audio_linear_envs($tmp, 
		    0              => 0,
		    $attack        => 1,
		    $attack * 2    => $sustain_level,
		    $dur - $attack => $sustain_level,
		    $dur           => 0,
		   );

  audio_exp_env($tmp, $dur,  $s / 4);
  audio_add($_[0], $off, $tmp, $dur);
}

sub tick {
  my ($off, $amp); 
  (undef, $off, $amp) = @_;
  my $tmp;
  my $attack = $s / 150;
  my $dur = $attack * 2;
  $amp =  $amp || 1600;
  audio_zero($tmp, $dur);
  audio_noise($tmp, $dur);
  audio_scale($tmp, $dur, $amp/32000);
  audio_linear_envs($tmp, 
		    0 => 0,
		    $attack  => 1,
		    $attack * 2 => 0);

  audio_add($_[0], $off, $tmp, $dur);
}

sub do_melody {
  my $sound = shift;
  $t = 0;
  foreach(@_) {
    # $h = [1, .75, .125, .125];
    $h = [1, .75, .5, .125, .125, .125, .125, .0625];
    $amp = 500;
    ($count = (s/!//g)) and $amp *= (1.25 ** $count);
    ($count = (s/\?//g)) and $amp /= (1.25 ** $count);
    ($count = (s/~//g)) and $h->[2] *= (.5 ** $count);
    {
      m,^([A-Gbx\#+-]+)$, and (($which,$dur) = ($1, 1)), last;
      m,^([A-Gbx\#+-]+)(\d+)$, and (($which,$dur) = ($1, $2)), last;
      m,^([A-Gbx\#+-]+)/(\d+)$, and (($which, $dur) = ($1, 1/$2)), last;
      m,^([A-Gbx\#+-]+)(\d+)/(\d+)$, and (($which,$dur) = ($1, $2/$3)), last;
      m,^([A-Gbx\#+-]+)\((.*)\)$, and (($which,$dur) = ($1,eval $2)), last;
      die "Invalid note spec: $_\n";
    }
    # print join(", ", $t, $which, $dur, $amp), "\n";
    if ($which ne "x") {
      fade_note($$sound, $t * $b, $which, $dur * $b, $amp, $h);
    }
    $t += $dur;
  }
}
