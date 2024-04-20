#!/usr/local/bin/perl5 -I../Solaris/Audio/blib/lib -I../Solaris/Audio/blib/arch
use Solaris::Audio qw(:all);

#
# Blue Star
#
# Azhural raised his staff.
# 'It's fifteen hundred miles to Ankh-Morpork,' he said.
# 'We've got three hundred and sixty-three elephants, fifty
# carts of forage, the monsoon's about to break and we're
# wearing ... we're wearing ... sort of things, like glass,
# only dark ... dark glass things on our eyes ...' His
# voice trailed off. His brow furrowed, as if he'd just
# been listening to his own voice and hadn't understood
# it.
# The air seemed to glitter.
# He saw M'Bu staring at him. 
# He shrugged. 'Let's go,' he said. 
# (From Pratchett's `Moving Pictures' via 
#  the alt.fan.blues-brothers faq)
#

$frame = shift || 0;
$f = 0;
$direct = 1;
$port = 2;
$rate = 16000;
$s = $rate; # one second
$b = ($s * 60) / 300; # one beat

$m = $b * 5; # one measure

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

$p_dur = $b / 2;
audio_zero($bass, $s);
audio_omni_drum($bass, $s / 2, $sintbl, $s, 12, 30, 0.5, 1);
$qqbass = $qbass = $bass;
audio_scale($bass, $p_dur, 3);
audio_scale($qbass, $p_dur, 2);
audio_scale($qqbass, $p_dur, 1.5);

audio_zero($snare, $p_dur);
audio_noise($snare, $p_dur);
audio_linear_envs($snare, 0, 0, $p_dur / 50, .05, $p_dur / 30, .03, $p_dur, 0);
audio_exp_env($snare, $p_dur, $p_dur / 4);

$| = 1;
#############


audio_zero($sound, $m * 13);
$i = 0;
foreach(split /\s+/, 
	"C G C G F# F A F G- Bb- C G C F Eb C G C F Eb 
F A F C+ Bb F A F Eb F C E G C E A- C# E G C#
D F D E F B- D B- F Eb C Eb C F F# G Bb G F Eb") {
  note($sound, $i * $b, 
       $_,
       $b * 1,
       ($i % 5 == 0 || $i % 5 == 3)? 2400 : 1600, 
       [ .5, ($i % 5 / 5), .75 * ($i % 10 / 10), .5 * (i % 15 / 15)]
      );
  $i++;
}

check_frame() and audio_play($sound, 12 * $m);

sub do_ticks {
  for ($i = 0; $i < 12; $i++) {
    tick($sound, $m * $i + $b * 1, $b / 8, 1600);
    tick($sound, $m * $i + $b * 1.5 , $b / 8, 800);
    tick($sound, $m * $i + $b * 2 , $b / 8, 400);
    tick($sound, $m * $i + $b * 3 , $b / 8, 400);
    tick($sound, $m * $i + $b * 4 , $b / 8, 400);
    tick($sound, $m * $i + $b * 4.5 , $b / 8, 400);
  }
}

do_ticks();
check_frame() and audio_play($sound, 12 * $m);

sub do_cymbals {
  for ($i = 0; $i < 12; $i++) {
    cymbal($sound, $m * $i + $b * 0, $b * 1.5, 800);
    cymbal($sound, $m * $i + $b * 2.5, $b * 0.5, 800);
    cymbal($sound, $m * $i + $b * 3, $b * 2, 800);
  }
}

do_cymbals();
check_frame() and audio_play($sound, 12 * $m);

sub do_bass {
  for ($i = 0; $i < 12; $i++) {
    audio_add($sound, $m * $i, $bass, $p_dur);
    audio_add($sound, $m * $i + $b * 1, $qbass, $p_due);
    audio_add($sound, $m * $i + $b * 2, $qbass, $p_dur);
    audio_add($sound, $m * $i + $b * 3, $qqbass, $p_dur);
    audio_add($sound, $m * $i + $b * 4, $qbass, $p_dur);
    for (0..4) {
      audio_add($sound, $m * $i + $b * $_ +  $b / 2, $snare, $p_dur); # relies on $p_dur <= $b/2!
    }
  }
}

do_bass();
check_frame() and audio_play($sound, 12 * $m);

audio_zero($sound, $m * 13);

sub main_melody {
  $i = 0;
  foreach(split /\s+/, 
	  "C G C G F# F A F G- Bb- C G C F Eb C G C F Eb 
F A F C+ Bb F A F Eb F C E G C E A- C# E G C#
D F D E F B- D B- F Eb C Eb C F F# G Bb G F Eb") 
  {
    note($sound, $i * $b, 
	 $_,
	 $b * 1,
	 ($i % 5 == 0 || $i % 5 == 3)? 3200 : 2400, 
       [ 1, ($i % 5 / 5), .75 * ($i % 10 / 10), .5 * (i % 15 / 15)]
	);
    $i++;
  }
}

sub back1 {
  $i = 0;
  foreach(split /\s+/, 
	  "C- F- C- C- F- F- C- C#- D- G-- C- G-- ") {
    foreach $o (0..4) {
      back_note($sound, $m  * $i + $b * $o, $_, $o == 1 ? $b / 2 : $b , $o == 1 ? 1600 : 1000, [ 1, 1]);
    }
    $i++;
  }
}

main_melody();
back1();
do_ticks();
do_cymbals();
do_bass();
check_frame() and audio_play($sound, 12 * $m);

sub back2 {
  $i = 0;
  foreach(split /\s+/, 
	  "C- F- C- C- F- F- C- C#- D- G-- C- G-- ") {
    back_note($sound, $m  * $i , $_, $b/2 , 1600, [ 1, 0,1]);
    back_note($sound, $m  * $i + $b * 0.5, $_, $b , 1200, [ 1, 0, 1]);
    back_note($sound, $m  * $i + $b * 1.5, $_, $b , 1600, [ 1, 0, 1]);
    back_note($sound, $m  * $i + $b * 2.5, $_, $b , 1200, [ 1, 0, 1]);
    back_note($sound, $m  * $i + $b * 3.5, $_, $b , 800, [ 1, 0,1]);
    back_note($sound, $m  * $i + $b * 4.5, $_, $b/2 , 1200, [ 1, 0,1]);
    $i++;
  }
}

back2();
check_frame() and audio_play($sound, 12 * $m);

sub back3 {
  $i = 0;
  foreach(split /\s+/, 
	  "C- F- C- E- F- A- G- E- F- G- E- D- ") {
    foreach $o (0, 2, 4) {
      back_note($sound, $m  * $i + $b * $o, "$_++", $b , 1600, [ 1, .5, .5]);
    }
    $i++;
  }
}
back3();
check_frame() and audio_play($sound, 12 * $m);

sub back4 {
  $i = 0;
  foreach(split /\s+/, 
	  "G- C G- G- C Bb- G- A- A- D- G- D- ") {
    back_note($sound, $m  * $i + $b, "$_", $b * 4 , 800, [ 1, , 0, 0, .5]);
    $i++;
  }
}

back4();
check_frame() and audio_play($sound, 12 * $m);

sub beeps {
  $i = 0;
  foreach(split /\s+/, 
	  "G C+ G G C+ Bb G A F D C D ") {
    
    $k = 0;
    foreach $h ([0, .5, .5], [0, 0, 1], [0, 1], [.5, .5], [0, .5, .5], 
		[0, 0, 1], [0, 1], [0, 1], [.5, 1, .5], [.5, .5, 1]) {
      back_note($sound, $m  * $i + $b * .5 * $k, $k % 5 ? "$_+" : $_, $b/2 , 800, $h);
      $k++;
    }
    
    $i++;
  }
}
beeps();
check_frame() and audio_play($sound, 12 * $m);
sub beeps2 {
  $i = 0;
  foreach(split /\s+/, 
	  "C F E C F D C A- D G- G Bb ") {
    
    $k = 0;
    foreach $h ( [0, 0, 1], [0, 1], [.5, .5], [0, .5, .5], 
		 [0, 0, 1], [0, 1], [0, 1], [.5, 1, .5], [.5, .5, 1], [0, .5, .5]) {
      back_note($sound, $m  * $i + $b * .5 * $k, $_, $b/2 , 800, $h);
      $k++;
    }
    
    $i++;
  }
}
beeps2();
check_frame() and audio_play($sound, 12 * $m);


sub back5 {
  $i = 0;
  foreach(split /\s+/, 
	  "C- F- C- E- F- A- G- E- F- G- E- D- ") {
    foreach $o (1, 3) {
      back_note($sound, $m  * $i + $b * $o, "$_+", $b , 800, [ 1, 1, 0, 1]);
    }
    $i++;
  }
}

back5();
check_frame() and audio_play($sound, 12 * $m);

$old_sound = $sound;
audio_zero($sound, 12 * $m);

do_ticks();
do_cymbals();
check_frame() and audio_play($sound, 4 * $m);

audio_zero($sound, 12 * $m);
do_ticks();
do_cymbals();
sub do_sparse {
  my ($swing) = @_;
  my $i = 0;
  foreach(split /\s+/, 
	  "C G C G F# F A F G- Bb- C G C F Eb C G C F Eb 
F A F C+ Bb F A F Eb F C E G C E A- C# E G C#
D F D E F B- D B- F Eb C Eb C F F# G Bb G F Eb") 
  {
    $i % 3   and
      note($sound, ($i + $swing * (1- $i % 4 / 6)) * $b, 
	   "$_+",
	   $b,
	   1600 - $i * 20,
	   [ 1, 0, .5]
	  );
    $i++;
  }
}
do_sparse(1);
check_frame() and audio_play($sound, 12 * $m);

$sound = $old_sound;

do_sparse(0);
check_frame() and audio_play($sound, 12 * $m);
check_frame() and audio_play($sound, 12 * $m);
audio_zero($sound, 12 * $m);
main_melody();
back1();
back2();
back3();
back4();
back5();
do_ticks();
check_frame() and audio_play($sound, 12 * $m);

audio_zero($sound, 12 * $m);
do_ticks();
do_cymbals();
do_bass();
beeps();
beeps2();
check_frame() and audio_play($sound, 12 * $m);
main_melody();
check_frame() and audio_play($sound, 12 * $m);

audio_zero($sound, 12 * $m);
main_melody();
audio_linear_env($sound, 11 * $m, 1, 12 * $m, 0);
check_frame() and audio_play($sound, 12 * $m);

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
  

  my $attack = $s / 128;
  audio_linear_envs($tmp, 0, 0, 
		    $attack , 2,
		    $attack * 2, 1, 
		    $dur / 1.1, .25,
		    $dur, 0
);
 
  audio_scale($tmp, $dur, 3);
  audio_scale($tmp, $dur, 1/3);

  audio_add($_[0], $off, $tmp, $dur);
}

sub back_note {
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
  

  my $attack = $s / 64;
  audio_linear_envs($tmp, 0, 0, 
		    $attack, 1,
		    $dur - $attack, .5,
		    $dur, 0
);
 
  audio_scale($tmp, $dur, 20);
  audio_scale($tmp, $dur, 1/20);

  audio_add($_[0], $off, $tmp, $dur);
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

sub check_frame {
  my $ret = ($frame <= $f);
   print "($f)" unless $ret;
   print "[$f]" if $ret;
  $f++;
  return $ret;
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
  my $sustain_level = 1 / 4;
  audio_linear_envs($tmp, 
		    0              => 0,
		    $attack        => 1,
		    $attack * 2    => $sustain_level,
		    $dur - $attack => $sustain_level,
		    $dur           => 0,
		   );

  audio_exp_env($tmp, $dur,  $s / 12);
  audio_add($_[0], $off, $tmp, $dur);
}
