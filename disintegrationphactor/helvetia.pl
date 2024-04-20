#!/usr/local/bin/perl5 -w -I../Solaris/Audio/blib/lib -I../Solaris/Audio/blib/arch
use Solaris::Audio qw(:all);

#
# Helvetia
#
# In the future, we'll realize that the creatures
# we thought were from other planets are actually
# smart people who live in Switzerland.
# (from Adams' The Dilbert Future)
#

$frame = shift || 0;
$direct = 0;
$port = 2;
$rate = 16000;
$s = $rate; # one second
$b = ($s * 60) / 180; # one beat (quarter note, really)
$m = $b * 3; # one measure

audio_init($direct) or die "Couldn't open audio";
if ($direct) {
audio_set_port($port);
audio_set_rate($rate);
audio_set_gain(80);
}

require "disi.pl";

audio_zero($sintbl, $s);
audio_osc_add($sintbl, $s, 1, 32000);

@m = map {[split]} (split /\n/, <<EOF);
C E G C+
C F Ab C+
C Eb Ab C+
B- Eb Ab B
Bb- Eb Ab Bb
Bb- F Ab Bb
Eb G Bb Eb+
Eb G Bb Eb+
Eb G Bb E+
Eb Gb Bb Eb+
B- E Gb E+
B- Eb Gb Eb+
Bb- D F F+
A- C F# D+
G- C D C+
G- B- D B
F- B- D B
F- A- C A
G- A- C A
G- B- D G
E- G- D B
F- A- C# A
F#- A- D A
G- B- D G
EOF

if ($frame <= 0) {
  audio_zero($sound, 25 * $m);
  $i = 0;
  foreach (map {@{$_}[0, 1, 2, 3, 2, 1]} @m) {
    note($sound, ($b/2) * $i++, $_, $b/2, 3200);  
  }
  audio_play($sound, 24 * $m);
}

if ($frame <= 1) {
  audio_zero($sound, 25 * $m);
  $i = 0;
  foreach (map {@{$_}[0, 1, 2, 3, 2, 1]} @m) {
    note($sound, ($b/2) * $i++, $_, $b/2, 3200);  
  }
  $i = 0;
  foreach (map {@{$_}[2, 0, 2, 1, 2, 0]} @m) {
    note($sound, ($b/2) * $i++, $_, $b/2, 1600);  
  }
  audio_play($sound, 24 * $m);
}

if ($frame <= 2) {
  audio_zero($sound, 25 * $m);
  $i = 0;
  foreach (map {@{$_}[0, 1, 2, 3, 2, 1]} @m) {
    note($sound, ($b/2) * $i++, $_, $b/2, 1600);  
  }
  $i = 0;
  foreach (map {@{$_}[2, 0, 2, 1, 2, 0]} @m) {
    note($sound, ($b/2) * $i++, $_, $b/2, 3200);  
  }
  audio_play($sound, 24 * $m);
}


if ($frame <= 3) {
  audio_zero($sound, 25 * $m);
  $i = 0;
  foreach (map {@{$_}[0, 1, 2, 0, 2, 1]} @m) {
    note($sound, ($b/2) * $i++, $_, $b/2, 1600);  
  }
  $i = 0;
  foreach (map {@{$_}[2, 0, 2, 1, 3, 2]} @m) {
    note($sound, ($b/2) * $i++, $_, $b/2, 3200);  
  }
  audio_play($sound, 24 * $m);
}

if ($frame <= 4) {
  audio_zero($sound, 25 * $m);
  $i = 0;
  foreach (map {@{$_}[2, 0, 2, 1, 3, 2]} @m) {
    note($sound, ($b/2) * $i++, $_, $b/2, 3200);  
  }
  $i = 0;
  foreach (map {@{$_}[0, 1, 2, 0, 1, 2]} @m) {
    note($sound, ($b/2) * $i++, $_, $b/2, 1600);  
  }
  audio_play($sound, 24 * $m);
}

if ($frame <= 5) {
  audio_zero($sound, 25 * $m);
  $i = 0;
  foreach (map {@{$_}[2, 0, 2, 1, 3, 2]} @m) {
    organ_note($sound, ($b/2) * $i++, $_, $b/2, 1600);  
  }
  $i = 0;
  foreach (map {@{$_}[0, 1, 2, 0, 1, 2]} @m) {
    note($sound, ($b/2) * $i++, $_, $b/2, 3200);  
  }
  audio_play($sound, 24 * $m);
}

if ($frame <= 6) {
  audio_zero($sound, 25 * $m);
  $i = 0;
  foreach (map {@{$_}[0, 1, 2, 3, 2, 1]} @m) {
    organ_note($sound, ($b/2) * $i++, $_, $b/2, 3200);  
  }
  $i = 0;
  foreach (map {@{$_}[2, 1, 0, 0, 1, 2]} @m) {
    note($sound, ($b/2) * $i++, $_, $b/2, 1600);  
  }
  audio_play($sound, 24 * $m);
}

if ($frame <= 7) {
  audio_zero($sound, 25 * $m);
  $i = 0;
  foreach (map {@{$_}[0, 1, 2, 3, 2, 1]} @m) {
    organ_note($sound, ($b/2) * $i++, $_, $b/2, 1600);  
  }
  $i = 0;
  foreach (map {@{$_}[2, 1, 0, 0, 1, 2]} @m) {
    note($sound, ($b/2) * $i++, $_, $b/2, 3200);  
  }
  audio_play($sound, 24 * $m);
}

if ($frame <= 8) {
  audio_zero($sound, 25 * $m);
  $i = 0;
  foreach (map {@{$_}[0, 1, 2, 0, 2, 1]} @m) {
    note($sound, ($b/2) * $i++, $_, $b/2, 1600);  
  }
  $i = 0;
  foreach (map {@{$_}[2, 1, 0, 3, 1, 2]} @m) {
    organ_note($sound, ($b/2) * $i++, $_, $b/2, 3200);  
  }
  audio_play($sound, 24 * $m);
}

if ($frame <= 9) {
  audio_zero($sound, 25 * $m);
  $i = 0;
  foreach (map {@{$_}[0, 1, 2, 0, 2, 1]} @m) {
    note($sound, ($b/4) + ($b/2) * $i++, $_, $b/4, 3200);  
  }
  $i = 0;
  foreach (map {@{$_}[2, 1, 0, 3, 1, 3]} @m) {
    organ_note($sound, ($b/2) * $i++, $_, $b/2, 1600);  
  }
  audio_play($sound, 24 * $m);
}

if ($frame <= 10) {
  audio_zero($sound, 25 * $m);
  $i = 0;
  foreach (map {@{$_}[2, 3, 2, 1, 0, 3]} @m) {
    note($sound, ($b/2) * $i++, $_, $b/2, 3200);  
  }
  $i = 0;
  my @melody = map {@{$_}[0, 1, 2, 0, 1, 2]} @m;
  foreach (@melody[0..$#melody-1]) {
    organ_note($sound, ($b/4) + ($b/2) * $i++, $_, $b/2, 800);  
  }
  audio_play($sound, 24 * $m);
}

if ($frame <= 11) {
  audio_zero($sound, 25 * $m);
  $i = 0;
  foreach (map {@{$_}[2, 1, 2, 1, 0, 1]} @m) {
    note($sound, ($b/2) * $i++, $_, $b/2, 1600);  
  }
  $i = 0;
  my @melody = map {@{$_}[0, 1, 3, 0, 1, 2]} @m;
  foreach (@melody[0..$#melody-1]) {
    organ_note($sound, ($b/4) + ($b/2) * $i++, $_, $b/2, 1600);  
  }
  audio_play($sound, 24 * $m);
}

if ($frame <= 12) {
  audio_zero($sound, 25 * $m);
  $i = 0;
  foreach (map {@{$_}[0, 1, 2, 3, 2, 3]} @m) {
    note($sound, ($b/2) * $i, $_, $b/2, 3200);  
    organ_note($sound, ($b/2) * $i, "${_}-", $b/2, 800); 
    $i++;
  }
  audio_play($sound, 24 * $m);
}

if ($frame <= 13) {
  audio_zero($sound, 25 * $m);
  $i = 0;
  foreach (map {@{$_}[0, 1, 2, 3, 2, 1]} @m) {
    note($sound, ($b/2) * $i++, $_, $b/4, 3200);  
  }
  $i = 0;
  foreach (map {@{$_}[0, 1, 2, 1, 2, 3]} @m) {
    organ_note($sound, ($b/2) * $i++, "${_}-", $b/2, 800);  
  }
  audio_play($sound, 24 * $m);
}

if ($frame <= 14) {
  audio_zero($sound, 25 * $m);
  $i = 0;
  foreach (map {@{$_}[0, 1, 2, 3, 2, 1]} @m) {
    note($sound, ($b/2) * $i++, $_, $b/4, 3200);  
  }
  $i = 0;
  my @melody = map {@{$_}[0, 1, 2, 1, 2, 3]} @m;
  foreach (@melody[0..$#melody  - 1]) {
    organ_note($sound, ($b/4) + ($b/2) * $i++, "${_}-", $b/4, 3200);  
  }
  audio_play($sound, 24 * $m);
}


if ($frame <= 15) {
  audio_zero($sound, 25 * $m);
  $i = 0;
  foreach (map {@{$_}[0, 1, 2, 3, 2, 1]} @m) {
    note($sound, ($b/2) * $i++, $_, $b/4, 3200);  
  }
  $i = 0;
  my @melody = map {@{$_}[0, 1, 2, 1, 2, 3]} @m;
  foreach (@melody[0..$#melody  - 1]) {
    organ_note($sound, ($b/4) + ($b/2) * $i++, "${_}-", $b/4, 3200);  
  }
  $i = 0;
  foreach (@m) {
    note($sound, (3 * $b) * $i, $_->[0], 3 * $b, 3200);  
    note($sound, $b/2 + (3 * $b) * $i, $_->[3], 2.5 * $b, 3200);  
    $i++;
  }
  audio_play($sound, 24 * $m);
}

if ($frame <= 16) {
  audio_zero($sound, 25 * $m);
  $i = 0;
  foreach (map {@{$_}[0, 1, 2, 3, 2, 1]} @m) {
    note($sound, ($b/2) * $i++, $_, $b/4, 3200);  
  }
  $i = 0;
  foreach (map {@{$_}[0, 1, 2, 1, 2, 1]} @m) {
    organ_note($sound, ($b/2) * $i++, "${_}-", $b/2, 1600);  
  }
  $i = 0;
  foreach (map {$_->[0]} @m) {
    organ_note($sound, (3 * $b) * $i++, $_, 3 * $b, 1600);  
  }
  audio_linear_env($sound, 20 * $m, 1, 24 * $m, 0);
  audio_play($sound, 24 * $m);
}

audio_destroy();

sub note {
  my ($off, $which, $dur, $amp);
  (undef, $off, $which, $dur, $amp) = @_;
  my $tmp;
  audio_zero($tmp, $dur);
  audio_table_add($tmp, $dur, $sintbl, $s, tone_of_string($which), $amp / 32000);
  audio_linear_envs($tmp, 
		    0       => 0,
		    $s / 30 => 1,
		    $dur    => 0,
		    );
  audio_add($_[0], $off, $tmp, $dur);
}

sub organ_note {
  my ($off, $which, $dur, $amp);
  (undef, $off, $which, $dur, $amp) = @_;
  my $tmp;
  audio_zero($tmp, $dur);
  my $h = 1;
  for (1, .1, 0, .05, 0, .05, 0, .05) {
    audio_table_add($tmp, $dur, $sintbl, $s, $h++ * tone_of_string($which), $_ * $amp / 32000);
  }
  audio_linear_envs($tmp, 
		    0              => 0,
		    $s / 30        => 1,
		    $dur - $s / 30 => .75,
		    $dur           => 0,
		    );
  audio_add($_[0], $off, $tmp, $dur);
}
