#!/usr/local/bin/perl5 -I../Solaris/Audio/blib/lib -I../Solaris/Audio/blib/arch
use Solaris::Audio qw(:all);

#
# What Pipe?
#
# This is not a fugue.
#

$frame = shift || 0;
$f = 0;
$direct = 0;
$port = 2;
$rate = 16000;
$s = $rate; # one second
$b = ($s * 60) / 160; # one beat

$m = $b * 8; # one measure
$M = $b * 7; # one measure in 7/8

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
audio_linear_env($bass, 0, 1.0, $s, 0);
audio_scale($bass, $s, 1.5);

$s_dur = $b / 4;
audio_zero($snare, $s);
audio_zero($tmp, $s);
audio_noise($tmp, $s/4);
audio_linear_env($tmp, 0, .1, $s_dur, 0);
audio_omni_drum($snare, $s_dur, $sintbl, $s,  90, 30, 1, 1);
audio_linear_env($snare, 0, 1, $s_dur, 0);
audio_add($snare, 0, $tmp, $s_dur);
audio_linear_env($snare, 0, .4, $s_dur, .4);
audio_exp_env($snare, $s_dur, $s_dur / 2);
$qsnare = $snare;
audio_linear_env($qsnare, 0, .5, $s_dur, .5);

$| = 1;
#############

foreach(0, 2, 4) {
  $emp{$_} = 1;
}

canon7 ("C D Eb D F D Eb",
	"D Eb F Eb G Eb F",
	"Eb F G F Ab F G",
	"F G Ab G Bb G Ab",
	"C+ Bb Ab Bb G Bb Ab",
	"Bb Ab G Ab F Ab G",
	"Ab G F G Eb G F",
	"G F Eb F D F Eb",
	"C Eb G Eb C D Eb",
	"C Eb G Eb C D Eb",
	"Eb G C G Eb D C",
	"Eb G C G Eb D C",
	"C D Eb F G F G",
	"D Eb F G Ab Bb C+",
       ); 


canon8 ("C E G F D G C G",
	"C E G F D B- G C",
	"C+ G E A D+ B D E",
	"C+ G E A D+ G D E",
	"E+ C D C G+ D+ B C",
	"E+ G D C G+ B D+ C",
	"G+ F+ E+ D+ C+ B A G",
	"G+ F+ C+ D+ A  D A B",
	"G+ A+ G+ A+ G+ A+ G+ A+",
	"F+ G+ F+ G+ F+ G+ F+ G+",
	"D+ E+ C+ B  A G  F E",
	"D+ E+ C+ D+ B C+ A B",
	"C+ G E A D+ B D E",
	"C+ G E A G B D+ B",
	"G+ C+ C G D+ E+ G+ F+",
	"E+ F+ E+ D+ C+:4",
       );

canon7 ("D E F E G E F",
	"G F E F A F G",
	"F G A G B G A",
	"E D C D F D E",
	"C+ D+ E+ D+ F+ D+ E+",
	"F+ E+ D+ E+ G+ E+ F+",
	"G A B A F+ A B",
	"D C B- C E C D",
	"A G A G A G A",
	"F E F E F E F",
	"A+ F+ D+ A+ F+ D+ C+",
	"F+ D+ C+ F+ D+ C+ A",
	"C D F A D F A",
	"A C D E F E D",
       );

canon8 ("D F# A G E A D A",
	"D F# A G E C# A D",
	"F# A D B G D+ F# D+",
	"F# A C#+ B G E D+ F#",
	"A F# B D D+ F# D+ G",
	"A F# B C#+ E D+ F# G",
	"D+ A D+ F# D+ A D+ F#",
	"D D+ D F#+ D D+ D F#+",
	"D+ F#+ A D+ F#+ A E+ G+",
	"A D+ F# A D+ F# C+ E+",
	"G+ C+ G+ C+ G+ D+ B G",
	"G  C  G  C  G A F# D",
	"D F# A G E A D A",
	"D F# A G E C# A D",
	"F# A D B G E+ G C#+",
	"D+ E+ F#+ E+ D+:4",
      );

canon7 ("E F# G F# A F# G",
	"E G B G D+ G B",
	"E G B G D+ G B",
	"G F# A F# G E F#",
	"D+ E+ B E+ B D+ E+",
	"E+ F#+ B F#+ B E+ F#+", 
	"F#+ G+ D+ G+ D+ F#+ G+",
	"G+ A+ D+ A+ D+ F#+ A+", 
	"D E B E B D E",
	"E F# B F# B E F#", 
	"F# G D G D F# G",
	"G A D A D F# A", 
	"E F# G F# A F# G",
	"E G B A G F# E", 
      );

canon8 ("E G# B A F# B E B",
	"B A F# B E B E G#",
	"B A F# B E B E G#",
	"F# B E B E G# B A",
	"E+ D#+ E+ D#+ G#+ F#+ A+ E+",
	"E+ D+ E+ D+ G# B A D",
	"G#+ A+ G#+ A+ D#+ E+ G#+ B",
	"D+ E+ D+ E+ D+ A G# B",
	"E G# B A F# B E B",
	"B A F# B E B E G#",
	"D F# A D F# A D A",
	"F# A D+ F# A D+ D D+",
	"F#+ E+ D+ F#+ E+ D+ E+ D+",
	"D+ F#+ E+ D+ F#+ E+ D+ E",
	"D+ G#+ E+ D+ G#+ E+ D+ E+",
	"E+ D+ G#+ F#+ E+:4",
       );

canon7 ("F# G# A G# B G# A",
	"F# A C#+ A E+ A C#+",
	"C#+ A E+ A C#+ A F#",
	"A G# B G# A G# F#",
	"A F# A F# A F# A",
	"C# F# D F# E F# A",
	"C# F# D F# E F# A",
	"F# A C#+ A E+ A C#+",
	"F# G# A G# B G# A",
	"A F# A F# A F# A",
	"F#+ C#+ D+ A C#+ F#+ F#+",
	"C#+ A F C#+ F# C#+ C#",
	"C#+ A F C#+ F# C#+ C#",
	"F#+ C#+ D+ C#+ A G# F#",
      );

canon8 ("F# A# C#+ B G# C#+ F# C#+",
	"F# C#+ G# F# A# B C#+ F#",
	"A# C#+ E+ D# B E+ A# E+",
	"A# E+ B A# C#+ D# E+ A#",
	"F# G# A# F# G# B C#+ G#",
	"F# G# B C#+ G# F# G# A# ",
	"C# F# A# C#+ C# F# A# C#+",
	"F# C#+ G# F# A# B C#+ F#",
	"F# A# C#+ B G# C#+ F# C#+",
	"A# E+ B A# C#+ D# E+ A#",
	"C# F# A# C#+ A# F# A# C#+",
	"C#+ F# A# C#+ A# F# A# C#",
	"A# G# A# G# F# E F# E",
	"F#+ E+ F#+ E+ C#+ B C#+ B",
	"F#+ E+ F#+ E+ C#+ B C#+ B",
	"A#+ G#+ A#+ G#+ F#+:4",
       );

canon7 ("G# A# B A# C#+ A# B",
	"B G# A# B A# C#+ A#",
	"A# B G# A# B A# C#+",
	"G# B D#+ B E#+ B D#+",
	"G# B D#+ B F#+ B D#+",
	"A# B G# A# B A# C#+",
	"G# A# B A# C#+ A# B",
	"G# B D#+ B F#+ B D#+",
	"G#+ D#+ F#+ B F#+ B D#+",
	"G#+ D#+ F#+ B G#+ B D#+",
	"D# B- D# B G# C# E#",
	"D# B- D# B B A# G#",
	"G# D# G# D# E# E# C#",
	"G# D# G# D# E# F# G#",
      );

canon8 ("G# B# D#+ C#+ A# D#+ G# D#+",
	"G# D#+ A# G# B# C#+ D#+ G#",
	"B# D#+ B# G# E#+ D#+ A# B#",
	"B# D#+ B# G# A# F# A# E#",
	"G# D#+ A# G# B# C#+ D#+ G#",
	"G# B# D#+ C#+ A# D#+ G# D#+",
	"F#+ E# D# B# B# D# G# B#",
	"G#+ E# D# B# B# D# G# B#",
	"D#+ B# B# D# G# B# E# D#",
	"D#+ G# B# E# D# B# B# D#",
	"G#+ E#+ F#+ E# D#+ B# A# B#",
	"F#+ E#+ G#+ E# D#+ C# A# B#",
	"D#+ E#  D#+ B# C#+ D# E# D#",
	"D#+ E#  D#+ B# C#+ E# D# B#",
	"G#+ E#+ F#+ E# D#+ A# B# A#",
	"F#+ G#+ E#+ E# G#+:4",
       );


canon7 ("Bb- C Db C Eb C Db",
	"Bb- C Eb C F C Db",
	"Db  Db F Eb G Db Bb-",
	"Db  Db F Eb G Db Bb-",
	"Bb- C Eb C F C Db",
	"Bb- C Db C Eb C Db",
	"Bb F Bb Ab F Eb C",
	"Bb F Eb C Bb Ab Bb",
	"Db C+ Eb C Bb Ab Bb",
	"C+ Bb Db Ab F Eb C",
	"F Db Bb F Db Eb Db+",
	"Bb F Db Bb Db+ F Db",
	"Bb F Eb C Bb Ab Bb",
	"Db C+ Eb C G Ab Bb",
      );

canon8 ("Bb- D F Eb C F Bb- F",
	"Bb- Bb D Bb F Bb  Eb Bb",  
	"C Ab F G Bb- F F Eb",
	"Bb D F Eb C F Bb- F",
	"Bb- D F Ab Bb Ab Ab F",
	"C D F Ab C Ab Ab F",
	"G F C+ F C+ Eb+ G G",
	"F G C+ Eb+ C+ G G F",
	"Eb G Bb D+ Bb F+ Bb D+",
	"G Bb D+ Bb F+ Bb D+ Eb",
	"D F A D+ D F A D+",
	"F A D+ F+ F A D+ F+",
	"G B D+ G+ G B D+ G+",
	"E G C+ G E G C+ G",
	"D F G D+ D F G D+",
	"C E D+ B C+:4",
       );
audio_destroy(); 

## Subs

sub canon7 {
  my ($i, $j, @notes);
  if (check_frame()) {
    audio_zero($sound, 9 * $M);
    $i = 0;
    for (@_) {
      if ($i >= 28) {
	audio_add($sound, $i * $b/2, $bass, $s); 
	for (0..13) {
	  tick($sound, ($i + $_/2) * $b / 2, $b / 8, 350);
	}
      }
      if ($i >= 14) {
	for (qw(2 4 6)) {
	  audio_add($sound, ($i + $_) * $b/2, $snare, $s);
	}
      }
      for (qw(0 1 1.5 3)) {
	audio_add($sound, ($i + $_) * $b/2, $qsnare, $s);
      }

      @notes = split;
      $j = 0;
      foreach (@notes) {
	note($sound, $b / 2 * $i, $_, $b / 2, $emp{$j} ? 1750 : 1000, [1, .8, .25, .75, .125, .125]);
        note($sound, $M +  $b / 2 * $i, $_, $b / 2, $emp{$j} ? 1750 : 1000, [1 - $j/7, $j/7, .5]);
	note($sound, 2 * $M +  $b / 2 * $i, $_, $b / 2, $emp{$j} ? 1750 : 1000, [1, $j / 4, .5]);
	$i++; $j++;
      }
    }
    audio_play($sound, 7 * $M);
  }
}

sub canon8 {
  my ($i, $j, @notes);
  if (check_frame()) {
    audio_zero($sound, 10 * $m);
    $i = 0;
    for (@_) {
      if ($i >= 32) {
	audio_add($sound, $i * $b/2, $bass, $s); 
	for (0..15) {
	  tick($sound, ($i + $_/2) * $b / 2, $b / 8, 350);
	}
      }
      if ($i >= 16) {
	for (qw(2 6)) {
	  audio_add($sound, ($i + $_) * $b/2, $snare, $s);
	}
	for (qw(4 7.5)) {
	  audio_add($sound, ($i + $_) * $b/2, $qsnare, $s);
	}
      }
      for (qw(0 1 1.5 3 7)) {
	audio_add($sound, ($i + $_) * $b/2, $qsnare, $s);
      }
 
      @notes = split;
      $j = 0;
      foreach (@notes) {
	my ($which, $dur) = split /:/;
	$dur ||= 1;
	note($sound, $b / 2 * $i, $which, $b / 2 * $dur, $emp{$j} ? 1500 : 1000, [1, .8, .25, .75, .125, .125]);
	note($sound, $m +  $b / 2 * $i, $which, $b / 2 * $dur, $emp{$j} ? 750 : 1500, [1, 1, $emp{$j} ? 0 : .25]);
	$i+=$dur; $j+=$dur;
      }
    }
    audio_play($sound, 8 * $m);
  }
}

sub note {
  my ($off, $which, $dur, $amp, $harm); 
  (undef, $off, $which, $dur, $amp, $harm) = @_;
  my $tmp;
  $amp =  $amp || 1600;
  audio_zero($tmp, $dur);
  my $h = 0;
  foreach(@$harm) {
    $h++;
    audio_table_add($tmp, $dur, $sintbl, $s, $h * tone_of_string($which), $_ * $amp / 32000);
  }
  

  my $attack = $b / 64;
  audio_linear_envs($tmp, 0, 0, 
		    $attack , 1,
		    $attack * 2, .6,
		    $dur - $attack, .5, 
		    $dur, 0
);
 
  audio_exp_env($tmp, $dur, 1.5 * $dur);

  audio_add($_[0], $off, $tmp, $dur);
}

sub check_frame {
  my $ret = ($frame <= $f);
   print "($f)" unless $ret;
   print "[$f]" if $ret;
  $f++;
  return $ret;
}


sub tick {
  local *sound = \$_[0]; shift;
  my ($off, $dur, $amp) = @_; 
  my $tmp;
  audio_zero($tmp, $dur);
  audio_noise($tmp, $dur);
  audio_linear_envs($tmp, 0, 0, $dur / 20, $amp / 32000, $dur, 0);
  audio_add($sound, $off, $tmp, $dur);
}
