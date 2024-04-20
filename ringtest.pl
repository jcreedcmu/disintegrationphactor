#!/usr/local/bin/perl5 -ISolaris/Audio/blib/lib -ISolaris/Audio/blib/arch 
use Solaris::Audio qw(:all);

use Tk;

my $s = 16000;

audio_init(1);
audio_set_rate($s);
audio_set_port(2);
audio_set_gain(80);

$mw = MainWindow->new();

$e = $mw->LabEntry(-label => "Freq", -textvariable => \$freq)->pack();
$e = $mw->LabEntry(-label => "NoiseFreq", -textvariable => \$rel_freq)->pack();
$e = $mw->LabEntry(-label => "Dur", -textvariable => \$dur)->pack();
$e = $mw->LabEntry(-label => "HL", -textvariable => \$hl)->pack();
$mw->Checkbutton(-text => "Fade?",  -variable => \$fade)->pack();
$mw->Checkbutton(-text => "Interpolate?",  -variable => \$int)->pack();
$B = $mw->Button(-text => "Note", -command => \&make_note)->pack();

sub make_note {
  my ($sound, $noise, $noise2);
  audio_zero($sound, $dur * $s);
  audio_zero($noise, $dur * $s);
  audio_zero($noise2, $dur * $s);
  audio_noise($noise, $dur * $s);
  $table_add = ($int ? \&audio_table_iadd : \&audio_table_add);
  &$table_add($noise2, $dur * $s, $noise, $dur * $s, $rel_freq, 1);
  audio_osc_add($sound, $dur * $s, $freq, 16000);
  audio_table_env($sound, $dur * $s, $noise2, $dur * $s);
  if ($fade) {
    audio_exp_env($sound, $dur * $s, $hl * $s);
  }
  audio_play($sound, $dur * $s);
}

MainLoop();
audio_destroy();
