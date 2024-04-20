#!/usr/local/bin/perl5 -ISolaris/Audio/blib/lib -ISolaris/Audio/blib/arch 
use Solaris::Audio qw(:all);

$rate = 16000;
audio_init(1);
audio_set_rate($rate);
audio_set_port(2);

{local $/; $sound = <>}

audio_play($sound, (length $sound) / 2);
audio_destroy();
