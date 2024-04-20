#!/usr/local/bin/perl5 -w -I../Solaris/Audio/blib/lib -I../Solaris/Audio/blib/arch
use Solaris::Audio qw(:all);
use Tk;
require "disi.pl";

$direct = 1;
$port = 2;
$rate = 16000;
$s = $rate;

###

$mw = new MainWindow;
$one = $mw->Frame(-width => 100, -height => 100, -bg => "white")->pack();

$bit = 1;
$one->bind("<Key-a>", sub{$bit = !$bit; $block = 0 unless $bit});
$one->focus();

$dur = $s / 40;



$block = 1;
$| = 1;

$i = 0;
sub loop {
  print "$i: $block\n";
  if (($block < 10) && $bit) {
    $i++;
    play($sound, $dur);
  }
  $mw->after(1000/80, \&loop);
}

$mw->after(250, \&loop);


###

$SIG{POLL} = 'IGNORE';
audio_init($direct) or die $!;
if ($direct) {
  audio_set_rate($rate);
  audio_set_port($port);
  audio_set_gain(80);
  audio_set_async() or die $!;
}
audio_zero($sound, $dur);
audio_osc_add($sound, $dur, 440, 1500);

$block = 0;
$SIG{POLL} = sub {$block--;};



sub play {
  &audio_play;
  audio_play("", 0);
  $block++;
}

sub destroy{
  $SIG{POLL} = 'IGNORE';
  audio_destroy();
}

MainLoop();

destroy();
