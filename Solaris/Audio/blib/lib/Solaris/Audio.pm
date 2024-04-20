package Solaris::Audio;

use strict;
use Carp;
use vars qw($VERSION @ISA @EXPORT_OK %EXPORT_TAGS);

require Exporter;
require DynaLoader;

@ISA = qw(Exporter DynaLoader);


@EXPORT_OK = qw(
answer_lue
audio_init
audio_set_port
audio_set_rate
audio_set_gain
audio_set_async
audio_destroy
audio_play
audio_zero
audio_flat
audio_drum
audio_drum2
audio_omni_drum
audio_scale
audio_osc_add
audio_table_add
audio_table_iadd
audio_add
audio_linear_env
audio_linear_envs
audio_exp_env
audio_table_env
audio_noise
audio_distort
audio_extract_add
audio_move
audio_flange
audio_phase
);

%EXPORT_TAGS = (all => [@EXPORT_OK]);

$VERSION = '0.01';

sub audio_zero {
  audio_flat(@_, 0);
}

sub audio_linear_envs {
  if ($#_ % 2) {
    die "Even number of args to audio_linear_envs!";
  }

  foreach (0..$#_ / 2 - 2) {
    audio_linear_env($_[0], @_[$_*2+1..$_*2+4]); # eek!
  }
}

bootstrap Solaris::Audio $VERSION;

1;
__END__

=head1 NAME

Solaris::Audio - Quick'n'dirty audio hack for disintegrationphactor

=head1 SYNOPSIS

  use Solaris::Audio;
  audio_init();
  ...
  audio_play($sound, $length);
  ...
  audio_destroy();

=head1 DESCRIPTION

Some sound munging routines, with a playback driver for Solaris.

=head1 BUGS

Sound munging routines should probably be in a separate module
from sound playing routines. A player for Solaris is 
a previously-invented wheel, anyway.

=head1 AUTHOR

Jason Reed <godel+@cmu.edu>

=head1 SEE ALSO

perl(1).

=cut
