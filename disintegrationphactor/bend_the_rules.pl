#!/usr/local/bin/perl5 -w -I../Solaris/Audio/blib/lib -I../Solaris/Audio/blib/arch
use Solaris::Audio qw(:all);

#
# Bend the Rules
#
# Many problem gamblers find it difficult
# to delay gratification; they have a tendency
# to bend rules and resent authority. A common
# diagnosis is narcissistic personality.
# (http://www.mentalhealth.com/mag1/p5h-gam1.html)
#

$frame = shift || 0;
$f = 0;
$direct = 0;
$port = 2;
$rate = 16000;
$s = $rate; # one second
$b = ($s * 60) / 280; # one beat (quarter note, really)
$m = $b * 4; # one measure


audio_init($direct) or die "Couldn't open audio";

if ($direct) {
audio_set_port($port);
audio_set_rate($rate);
audio_set_gain(80);
}

require "disi.pl";

audio_zero($sintbl, $s);
audio_osc_add($sintbl, $s, 1, 32000);

audio_zero($bass, $s);
audio_omni_drum($bass, $s, $sintbl, $s, 12, 30, 0.5, 1);
audio_scale($bass, $s, 4);
audio_scale($bass, $s, 1/2);
audio_linear_env($bass, 0, 1.0, $s, 0);

audio_zero($alt_bass, $s);
audio_omni_drum($alt_bass, $s, $sintbl, $s, 12, 15, 1, 1);
audio_scale($alt_bass, $s, 6);
audio_scale($alt_bass, $s, 1/2);
audio_linear_env($alt_bass, 0, 1.0, $s, 0);

@m = map {[split]} (split /\n/, <<EOF);
C Eb F Eb F# Eb F Eb
Bb- D F D F# D F D
Eb C F C F# C F C
Eb Bb- F Bb- F# Bb- F Bb-
Eb G- F D F# C F Bb-
Eb A- F A F# D F C
Eb Bb- F Bb F# Eb F D
Eb C F C+ F# C F Bb-
Eb A- F A F# D F C
Eb Bb- F Bb F# Eb F D
Eb C F C+ F# A F F#
Eb D F D+ F# A F# D
A- D A D+ F A F D
C+ D A D F A F D
G- B- F D+ F G F B-
B B- F D F G F B-
Bb- D Bb D+ F A F D
C+ D A D F Bb F D
F- A- Eb C+ F A F# A-
D+ B- F D E G# B A
A- D A D+ F A F D
C+ D A D F A F D
G- B- F D+ F G F B-
B B- F D F G F B-
Bb- D Bb D+ F A F D
C+ D A D F Bb F D
F- A- Eb C+ F A F# A-
D+ B- F D G D F B-
EOF

if (check_frame()) {
  audio_zero($sound, 29 * $m);
  $i = 0;
  foreach (map {@$_} @m) {
    organ_note($sound, ($b/2) * $i, $_, $b * 3/4 , 1600); 
  
    if ($i % 4 == 0) {
      tick($sound, $b/2 * $i, 800);
    }
    $i++;
  }
  audio_play($sound, 28 * $m);
}

if (check_frame()) {
  audio_zero($sound, 29 * $m);
  $i = 0;
  $wait = 0;
  foreach (map {@$_} @m) {
    organ_note($sound, ($b/2) * $i, $_, $b * 3 /4 , 1600); 
    if ($i % 8 == 0) { 
      audio_add($sound, $i * $b / 2, $alt_bass, $s);
    }
    if ($i % 8 != 3 && $i % 8 != 6 && $i % 8 != 0){ 
      snare($sound, ($b/2) * $i, $b / 4, 1600);
      audio_add($sound, $i * $b / 2, $bass, $s);
    }
    else {
      cymbal($sound, ($b/2) * $i, 3 * $b / 4, 1200);
    }
    if ($wait || $i % 8 == 0 || $i % 8 == 3 ) {
      if ($_ eq "Eb"&& $i && 8 == 0) 
	{ $wait = 1 } 
      else 
	{ note($sound, ($b/2) * ($i-$wait), "$_-", $b * 3 / 2, 3200); $wait = 0 }
    }
    tick($sound, $b/4 + $b/2 * $i, 800);
    $i++;
  }
  audio_play($sound, 28 * $m);
}

#if (check_frame()) {
#  audio_zero($sound, 8 * $m);
#  $i = 0;
#  foreach (1..56) {
#    if ($i % 8 == 0) { 
#      # audio_add($sound, $i * $b / 2, $alt_bass, $s);
#    }
#    if ($i % 8 != 3 && $i % 8 != 6 && $i % 8 != 0){ 
#      snare($sound, ($b/2) * $i, $b / 4, 1600);
#      audio_add($sound, $i * $b / 2, $bass, $s);
#    }
#    else {
#      cymbal($sound, ($b/2) * $i, 3 * $b / 4, 1200);
#    }
 
#    tick($sound, $b/4 + $b/2 * $i, 800);
#    $i++;
#  }
#  audio_play($sound, 7 * $m);
#}


audio_zero($sound, 29 * $m);
$i = 0;
$wait = 0;

foreach (map {@$_} @m) {
  organ_note($sound, ($b/2) * $i, $_, $b /2 , 400); 
  organ_note($sound, ($b/4) + ($b/2) * $i, "$_+", $b / 2, 400);
  
  if ($i % 8 == 2 || $i % 8 == 5 || $i % 8 == 7){ 
    snare($sound, ($b/2) * $i, $b / 4, 800);
    audio_add($sound, $i * $b / 2, $alt_bass, $s);
  }
  
  if ($wait || $i % 8 == 0 || $i % 8 == 3 || $i % 8 == 6 ) {
    if ($_ eq "Eb"&& $i && 8 == 0) 
      { $wait = 1 } 
    else 
	{ note($sound, ($b/2) * ($i-$wait), "$_-", $b * 3 / 2, 3200); $wait = 0 }
  }
  tick($sound, $b/4 + $b/2 * $i, 800);
  $i++;
}

if (check_frame()) {
  audio_play($sound, 28 * $m);
}

if (check_frame()) {
  audio_zero($echo, $m);
  
  audio_move($echo, 0, $sound, 27 * $m, $m);
  for (0..3) {
    audio_scale($echo, $m, 1 / 2);
    audio_play($echo, $m);
  }
}

if (check_frame()) {
  audio_zero($sound, 4 * $m);
  foreach(qw(C E G C+)) {
    note($sound, 0, $_, 4 * $m, 1600);
  }
  audio_linear_env($sound, 0, 0, 4 * $m, 1);
  audio_play($sound, 4 * $m);
}

audio_destroy();

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

sub cymbal {
  my ($off, $dur, $amp); 
  (undef, $off, $dur, $amp) = @_;
  my $tmp;
  $amp =  $amp || 1600;
  audio_zero($tmp, $dur);
  audio_noise($tmp, $dur);
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

  audio_exp_env($tmp, $dur,  $s / 4);
  audio_add($_[0], $off, $tmp, $dur);
}

sub snare {
  my ($off, $dur, $amp); 
  (undef, $off, $dur, $amp) = @_;
  my ($tmp, $noise);
  $amp =  $amp || 1600;
  audio_zero($noise, $dur / 4);
  audio_noise($noise, $dur / 4);
  audio_zero($tmp, $dur);
  audio_table_iadd($tmp, $dur, $noise, $dur / 4, 1 / 4, 1);
  audio_scale($tmp, $dur, $amp/32000);
  audio_table_add($tmp, $dur, $sintbl, $s, 50, $amp / 16000);
  audio_linear_envs($tmp, 
		    0              => 1,
		    $dur           => 0,
		   );
  audio_add($_[0], $off, $tmp, $dur);
}

sub note {
  my ($off, $which, $dur, $amp);
  (undef, $off, $which, $dur, $amp) = @_;
  my $tmp;
  audio_zero($tmp, $dur);
  audio_table_add($tmp, $dur, $sintbl, $s, tone_of_string($which), $amp / 32000);
  audio_linear_envs($tmp, 
		    0                 => 0,
		    $s / 30           => 1,
		    $dur - $s / 30    =>.5,
		    $dur              => 0,
		    );
  audio_add($_[0], $off, $tmp, $dur);
}

sub organ_note {
  my ($off, $which, $dur, $amp);
  (undef, $off, $which, $dur, $amp) = @_;
  my $tmp;
  audio_zero($tmp, $dur);
  my $h = 1;
  for (1, .25, .125, .125, .125, .125) {
    audio_table_add($tmp, $dur, $sintbl, $s, $h++ * tone_of_string($which), $_ * $amp / 32000);
  }
  audio_linear_envs($tmp, 
		    0              => 0,
		    $s / 100        => 2,
		    $s / 50        => .75,
		    $dur - $s / 30 => .75,
		    $dur           => 0,
		    );
  audio_exp_env($tmp, $dur,  $s * .1);
  audio_add($_[0], $off, $tmp, $dur);
}

sub check_frame {
  my $ret = ($frame <= $f);
   print "($f)" unless $ret;
   print "[$f]" if $ret;
  $f++;
  return $ret;
}
