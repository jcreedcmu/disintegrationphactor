#!/usr/local/bin/perl5 -I../Solaris/Audio/blib/lib -I../Solaris/Audio/blib/arch
use Solaris::Audio qw(:all);

#
# Social Engineering
#
# You're not cleared for that, Citizen.
#

$frame = shift || 0;
$f = 0;
$direct = 1;
$port = 2;
$rate = 16000;
$s = $rate; # one second
$b = ($s * 60) / 180; # one beat

$m = $b * 13 / 2; # one measure

audio_init($direct) or die "Couldn't open audio";
if ($direct) {
audio_set_port($port);
audio_set_rate($rate);
audio_set_gain(80);
}

require "disi.pl";

audio_zero($sintbl, $s);
audio_osc_add($sintbl, $s, 1, 32000);

$p_dur = $b / 2;

sub bongo {
  my $freq = shift;
  my $sound;
  audio_zero($bongo, $p_dur);
  audio_omni_drum($bongo, $p_dur, $sintbl, $s, $freq, 35, 1, 1);
  my $attack = $p_dur / 50;
  audio_linear_envs($bongo, 0, 0, 
		    $attack, 1,
		    2 * $attack, 1 /2,
		    $p_dur, 1/2);
  audio_exp_env($bongo, $p_dur, $p_dur /2);
  audio_scale($bongo, $p_dur, 1 / 4);
  $bongo;
}

$hhb = bongo(725);
$hb = bongo(600);
$mb = bongo(500);
$lb = bongo(400);
$llb = bongo(375);
$lllb = bongo(350);

audio_zero($bass, $p_dur);
audio_omni_drum($bass, $p_dur, $sintbl, $s, 12, 30, .5, 1);
audio_scale($bass, $p_dur, 20);
audio_scale($bass, $p_dur, 1/5);
audio_linear_envs($bass, 0, 0, $p_dur / 30, 1, $p_dur, 0);

audio_zero($snare, $p_dur);
audio_noise($snare, $p_dur);
audio_linear_envs($snare, 0, 0, $p_dur / 50, .3, $p_dur / 30, .05, $p_dur, 0);
audio_exp_env($snare, $p_dur, $p_dur / 4);
$| = 1;

audio_zero($sound, 2 * $m);

$i = 0;
%note = (h => $hb, l => $lb);
@drum_line = qw(h l h l h l l 
		h l h l h l l
		h l h l h l l
		h l l h l);
foreach(@drum_line) {
  audio_add($sound, $i * $b / 2, $note{$_}, $p_dur);
  $i++;
}

if (check_frame()) {
   for (0..1) {
   audio_play($sound, 2 * $m);
 }
}

$i = 0;
%note = (b => $mb);
@drum_line = qw(b x x x b b x x x b x x x 
		b x x x b b x x x b x x x);
foreach(@drum_line) {
  exists $note{$_} and 
    audio_add($sound, $i * $b / 2, $note{$_}, $p_dur);
  $i++;
}

if (check_frame()) {
   for (0..1) {
   audio_play($sound, 2 * $m);
 }
}

$i = 0;
%note = (h => $hhb);
@drum_line = qw(h h h x h h h x h x h x h
		h h h x h h h x h x h x h);
foreach(@drum_line) {
  exists $note{$_} and 
    audio_add($sound, $i * $b / 2, $note{$_}, $p_dur);
  $i++;
}

if (check_frame()) {
   for (0..1) {
   audio_play($sound, 2 * $m);
 }
}

$i = 0;
%note = (l => $lllb);
@drum_line = qw(x l x l l l l 
		x l x l l l l
		x l x l l l l
		l x x l x);
foreach(@drum_line) {
  exists $note{$_} and 
    audio_add($sound, $i * $b / 2, $note{$_}, $p_dur);
  $i++;
}

if (check_frame()) {
   for (0..1) {
   audio_play($sound, 2 * $m);
 }
}

$i = 0;
%note = (l => $llb);
@drum_line = qw(x l x l x l x l x l x l x
		l x l x l x l x l x l x l);
foreach(@drum_line) {
  exists $note{$_} and 
    audio_add($sound, $i * $b / 2, $note{$_}, $p_dur);
  $i++;
}

if (check_frame()) {
 for (0..1) {
   audio_play($sound, 2 * $m);
 }
}

$snareless_beat = $sound;

$i = 0;
%note = (n => $snare);
@drum_line = qw(x n x n x n x
		x n x n x x x
		x n x n x n x
		x n x x n);
foreach(@drum_line) {
  exists $note{$_} and 
    audio_add($sound, $i * $b / 2, $note{$_}, $p_dur);
  $i++;
}

if (check_frame()) {
 for (0..1) {
   audio_play($sound, 2 * $m);
 }
}

$i = 0;
%note = (b => $bass);
@drum_line = qw(x x b x x x x
		b x b x x x x
		b x b x x x x
		b x b x x);
foreach(@drum_line) {
  exists $note{$_} and 
    audio_add($sound, $i * $b / 2, $note{$_}, $p_dur);
  $i++;
}

if (check_frame()) {
 for (0..1) {
   audio_play($sound, 2 * $m);
 }
}

$i = 0;
@drum_line = qw(t c x x x x x
		t c x t c x x
		t c x x x x x
		c t c t x);
foreach(@drum_line) {
  if ($_ eq "c") {
    cymbal($sound, $i * $b / 2, $p_dur, 1600);
  }
  if ($_ eq "t") {
    tick($sound, $i * $b / 2, $p_dur, 1600);
  }
  $i++;
}

if (check_frame()) {
 for (0..1) {
   audio_play($sound, 2 * $m);
 }
}

$i = 0;
@drum_line = qw(x x x c x x c
		x x x c x x c
		x x x c x x c
		t x c c c);
foreach(@drum_line) {
  if ($_ eq "c") {
    cymbal($sound, $i * $b / 2, $p_dur, 1600);
  }
  if ($_ eq "t") {
    tick($sound, $i * $b / 2         , $p_dur / 3, 1600);
    tick($sound, $i * $b / 2 + $b / 6, $p_dur / 3, 1600);
    tick($sound, $i * $b / 2 + $b / 3, $p_dur / 3, 1600);
  }
  $i++;
}

if (check_frame()) {
 for (0..1) {
   audio_play($sound, 2 * $m);
 }
}

$beat = $sound;
do_melody($sound, [1, 1], "-", 
	  qw(
	   C:4 C x:2
	   x:7
	     Bb-:4 Bb- x:2
	    ));
if (check_frame()) {
  for (0..1) {
    audio_play($sound, 2 * $m);
  }
}

$sound = $beat;
do_melody($sound, [1, 1, .1, .1, .1], "-", 
	  qw(C:3 C Bb-:3
	   x:6
	     Bb-:4 C x:2
	    ));
if (check_frame()) {
  for (0..1) {
    audio_play($sound, 2 * $m);
  }
}

$sound = $beat;
@bass_line = qw(C:3 C Bb-:3
	      C:3 C x Bb-:2 
		C x C:2 Bb-:3
		F-:3 G-:2
	       );
do_melody($sound, [1, 1, .1, .1, .1], "-", @bass_line);

if (check_frame()) {
  for (0..1) {
    audio_play($sound, 2 * $m);
  }
}

do_melody($sound, [1, 1, .1, .1, .1], "", 
	  qw(
	     x Eb G C+ x:3
	   x D F x:4
	   x C x:5
	   x Eb F x:2
	    ));

if (check_frame()) {
  for (0..1) {
    audio_play($sound, 2 * $m);
  }
}

sub head {
  my $h = shift;
  my $skip = shift;
  my $base_sound =  $skip < 3 ? $beat : $snareless_beat;
  
  my @melody = qw(x Eb G C+ G Eb C
		  x D F Bb F D C
		  x C Eb Ab Eb C F
		  x Eb F Eb C);

  if (check_frame()) {
    $sound = $base_sound;
    $skip < 2 and do_melody($sound, $h, "-", @bass_line);
    do_melody($sound, $h, "", @melody); 
    for (0..1) {
      audio_play($sound, 2 * $m);
    }
  }

  if (check_frame()) {
    $sound = $base_sound;
    $skip < 1 and do_melody($sound, [@$h[0..1]], "bbbbbbb", @bass_line);
    do_melody($sound, $h, "", 
	      qw(x Eb F C+ F Eb C
		 x D F Bb F D C
		 x C Eb Ab Eb C F
		 x Eb F Eb C)); 
    audio_play($sound, 2 * $m);
  }

  if (check_frame()) {
    $sound = $base_sound;
    $skip < 2 and do_melody($sound, $h, "-", @bass_line);
    @melody[-3, -2, -1] = ("G", "x", "C");
    do_melody($sound, $h, "", @melody);
    if ($skip >= 3) {
      audio_linear_env($sound, 0, 1, 2 * $m, 0);
    }
    audio_play($sound, 2 * $m);
  }
}

head([1, 1, .1, .1, .1]);
head([1, 1, .1, .1], 1);
head([1, 1, .2, .1], 1);
head([1, 1, .1, .1, .1]);

if (check_frame()) {
  $sound = $beat;
  audio_play($sound, 2 * $m);
}

for ("", "+") {
  if (check_frame()) {
    $sound = $beat;
    do_melody($sound, [1, 0, 1], "-", @bass_line);
    do_melody($sound, [1, 1, .1, .1, .1], "$_", 
	      qw(C D C D Eb x C
		 Bb- D Bb- x D x C
		 Ab- C Ab- x C x Eb
		 C Eb x C x
		)); 
    for (0..1) {
      audio_play($sound, 2 * $m);
    }
  }
}

for ("", "+") {
  if (check_frame()) {
    $sound = $beat;
    do_melody($sound, [1, 1, .1, .1, .1], "-", @bass_line);
    do_melody($sound, [1, 1, .1, .1, .1], "$_", 
	      qw(C D Eb F C Bb G F
		 Bb Eb G Gb F
		 C D Eb F G Bb G F
		 G Eb G Gb F
		)); 
    for (0..1) {
      audio_play($sound, 2 * $m);
    }
  }
}

if (check_frame()) {
  $sound = $beat;
  audio_play($sound, 2 * $m);
}

if (check_frame()) {
  $sound = $beat;
  do_melody($sound, [1, 1, .1, .1, .1], "-", @bass_line);
  do_melody($sound, [1, 1, .1, 0, .1], "", 
	    qw(x:2 C x:2 C Eb
	     x:2 C x:2 C F
	     x:2 C x:2 C G
	     x:2 C x:2
	      )); 
  for (0..1) {
    audio_play($sound, 2 * $m);
  }
  do_melody($sound, [1, 1, .1, 0, .1], "", 
	    qw(
	       Eb D x:5
	       Eb x:6
	       Eb x:6
	       Eb x:4
	      )); 
  for (0..1) {
    audio_play($sound, 2 * $m);
  }
}

if (check_frame()) {
  $sound = $snareless_beat;
  $i = 0;
  @drum_line = qw(h x h x h l x
		  h x x h x l x
		  x h x h x x x
		  x x x l x);
  %note = (h => $hb, l => $lb);
  foreach(@drum_line) {
    if ($_ ne "x") {
      audio_add($sound, $i * $b / 2 + $b / 8, $note{$_}, $p_dur);
    }
    $i++;
  }
  for (0..1) {
    audio_play($sound, 2 * $m);
  }
  $i = 0;
  @drum_line = qw(h h h h h l l
		  h x x h x l l
		  x h h h x x x
		  x x x l x);
  %note = (h => $hb, l => $lb);
  foreach(@drum_line) {
    if ($_ ne "x") {
      audio_add($sound, $i * $b / 2 + $b / 8, $note{$_}, $p_dur);
    }
    $i++;
  }
  for (0..1) {
    audio_play($sound, 2 * $m);
  }
 $i = 0;
  @drum_line = qw(l l l l l l l
		  x x x x x x x
		  h h h h h h h
		  x x x x x);
  %note = (h => $hb, l => $lb);
  foreach(@drum_line) {
    if ($_ ne "x") {
      audio_add($sound, $i * $b / 2 + $b / 8, $note{$_}, $p_dur);
    }
    $i++;
  }
  for (0..1) {
    audio_play($sound, 2 * $m);
  }
  $i = 0;
  @drum_line = qw(c n x c n x c
		  c x n c x n c
		  c n n c n n c
		  t c c c c);
  foreach(@drum_line) {
    if ($_ eq "c") {
      cymbal($sound, $i * $b / 2, $p_dur, 1600);
    }
    if ($_ eq "n") {
      audio_add($sound, $i * $b / 2, $snare, $p_dur);
    }
    if ($_ eq "t") {
      tick($sound, $i * $b / 2         , $p_dur / 3, 1600);
      tick($sound, $i * $b / 2 + $b / 6, $p_dur / 3, 1600);
      tick($sound, $i * $b / 2 + $b / 3, $p_dur / 3, 1600);
    }
    $i++;
  }
  for (0..1) {
    audio_play($sound, 2 * $m);
  }
}
if (check_frame()) {
  $sound = $beat;
  for (0..1) {
    audio_play($sound, 2 * $m);
  }
}


do_melody($sound, [1, 1, .1, .1, .1], "-", @bass_line);

if (check_frame()) {
  for (0..1) {
    audio_play($sound, 2 * $m);
  }
}

head([1, 1, .1, .1, .1]);
head([1, 1, .1, .1], 2);
head([1, 1, .1], 3);
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
    audio_table_add($tmp, $dur, $sintbl, $s, $h * tone_of_string($which), $_ * $amp / 32000);
  }
  my $attack_str = $dur > .9 ? 1 : .25;  
  my $attack = $s / 128;
  audio_linear_envs($tmp, 0, 0, 
		    $attack , $attack_str,
		    $dur - $attack, .5,
		    $dur, 0
		   );
 
  audio_scale($tmp, $dur, 1);

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

sub cymbal {
  my ($off, $dur, $amp); 
  (undef, $off, $dur, $amp) = @_;
  my $tmp;
  $amp =  $amp || 1600;
  audio_zero($tmp, $dur);
  audio_noise($tmp, $dur);
  audio_scale($tmp, $dur, $amp/32000);
  my $attack = $s / 100;
  my $sustain_level = 1 / 2;
  audio_linear_envs($tmp, 
		    0              => 0,
		    $attack        => 1,
		    $attack * 2    => $sustain_level,
		    $dur - $attack => $sustain_level,
		    $dur           => 0,
		   );

  audio_exp_env($tmp, $dur,  $b / 8);
  audio_add($_[0], $off, $tmp, $dur);
}

sub do_melody {
  local *sound = \$_[0]; shift;
  my $h = shift;
  my $tr = shift;
  my (@melody) = @_;
  my $i = 0;
  foreach(@melody) {
    my ($note, $dur) = split /:/;
    $dur ||= 1;
    $note ne "x" and
      note($sound, $b / 2 * $i, "$note$tr", $b / 2 * $dur, 2400, $h);
    $i+= $dur;
  }
}
