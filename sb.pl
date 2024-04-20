#!/usr/bin/perl5

use lib "/afs/andrew.cmu.edu/usr25/jcreed/rawtechno/Solaris/Audio/blib/lib";
use lib "/afs/andrew.cmu.edu/usr25/jcreed/rawtechno/Solaris/Audio/blib/arch";
use Solaris::Audio qw(:all);
use Tk;

$direct = 1;
$port = 2;
$rate = 16000;
$s = $rate; # one second
audio_init(1);
audio_set_port($port);
audio_set_rate($rate);
audio_set_gain(80);

$mw = MainWindow->new();
$st = $mw->Scrolled("Text", -scrollbars => "se")->pack();
$t = $st->Subwidget("text");
$e = $mw->Scrolled("Text", -scrollbars => "se", -height => 4)->pack();
$b = $mw->Button(-text => "Eval", -command => \&do_eval)->pack();
sub do_eval {
  eval $t->get("1.0", "end");
  my $error = $@;
  $e->delete("1.0", "end");
  $e->insert("end", $error);
}
$t->bind("eval", "<Meta-Key-c>", sub{ do_eval; Tk->break });
$t->bindtags(["eval", $t->bindtags]);
MainLoop();

END { audio_destroy() }		   
