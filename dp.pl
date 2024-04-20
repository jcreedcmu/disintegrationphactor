#!/usr/local/bin/perl5 -ISolaris/Audio/blib/lib -ISolaris/Audio/blib/arch 
use Solaris::Audio qw(:all);
use Tk;

$rate = 16000;

audio_init(1);
audio_set_rate($rate);
audio_set_port(2);
$sound = " " x (8 * $rate);
$sintbl = " " x (2 * $rate);
$sawtbl = " " x (2 * $rate);
$sqrtbl = " " x (2 * $rate);
$tritbl = " " x (2 * $rate);
$length = $rate /4;

$| = 1;
# audio_play($sound, 8000);
#print "Starting drum...\n";

#print "About to play...\n";
#for (1..10) {audio_play($sound, 1000);}

$freq = 440;
$mult = 2 ** (1/12);
for('A'..'G') {
  $_ eq "C" and $freq /= 2;
  $tone{$_} = $freq;
  $freq *= $mult;
  next if $_ eq "B";
  next if $_ eq "E";
  $freq *= $mult;
}

audio_zero($sintbl, $rate);
audio_osc_add($sintbl, $rate, 1, 32000);
audio_flat($sqrtbl, $rate, 32000);
audio_linear_env($sqrtbl, $rate / 2, -1, $rate, -1);
audio_flat($tritbl, $rate, 32000);
audio_linear_env($tritbl, 0, 0, $rate / 4, 1);
audio_linear_env($tritbl, $rate / 4, 1, (3/4)*$rate, -1);
audio_linear_env($tritbl, (3/4) * $rate, -1, $rate, 0);
audio_flat($sawtbl, $rate, 32000);
audio_linear_env($sawtbl, 0, 0, 31 * $rate / 32, 1);
audio_linear_env($sawtbl, 31 * $rate / 32, 1, $rate, 0);
sub tone_of_string {
my $mymult = 1;
my ($s) = @_;
for ($s) {
  while (s/b//) {$mymult /= $mult}
  while (s/\#//) {$mymult *= $mult}
  while(s/\+//) {$mymult *= 2}
  while(s/\-//) {$mymult /= 2}
}
return $tone{$s} * $mymult;
}

$mw = MainWindow->new();

$f = $mw->Frame()->pack(-side => "left", -fill => "y");
$cb = $f->Checkbutton(-text => "Speaker", -variable => \$speaker, -command => sub {
if ($speaker) {audio_set_port(1);} else {audio_set_port(2)}})->pack(-side => "top");
$wte = $f->Optionmenu(-relief => "sunk", -variable => \$wt, -options => [
						       [Sine => "sin"],
						       [Square => "sqr"],
						       [Triangle => "tri"],
                                                       [Saw => "saw"],
						      ])->pack(-side => "top");
%wth = (sin => \$sintbl, tri => \$tritbl, sqr => \$sqrtbl, saw, \$sawtbl);

$v = $f->LabEntry(-label => "Volume", -textvariable => \$volume)->pack(-side => "top");
$volume = 50;
$d = $f->LabEntry(-label => "Distortion", -textvariable => \$dist)->pack(-side => "top");
$dist = 33000;
$f->Checkbutton(-text => "Full", -variable => \$full_distortion)->pack(-side => "top");

# Harmonics Canvas
$num_harmonics = 20;
$hwidth = 200;
$hheight = 400;
$vunit = $hheight / $num_harmonics;
$hunit = $hwidth / 10;

$harms = $f->Canvas(-width => $hwidth, -height => $hheight, -relief => "sunk", -borderwidth => 1)->pack(-side => "top");
 
for (1..$num_harmonics) {
 $s =  $harms->create("rectangle", 0, 0, 100, 100, -tags => "slider", -fill => "wheat");
 $h_sliders[$_] = $s;

  $num_of_harms_canvasitem{$s} = $_; # inverse map
  slider_set_value($_, ($_ == 1 ? 1 : 0));
}

$harms->bind("slider", "<1>", 
	     [ sub {
		 my ($self, $x) = @_;
		 $oldx = $x;
		 $c = $self->gettags("current");
		 ($virtualx) = $self->coords($c);
	       }, Ev("x")]);
		
$harms->bind("slider", "<Button1-Motion>", 
	     [ sub { 
		 my ($self, $x) = @_;
		 $virtualx += $x - $oldx;
		 $c = $harms->find("withtag", "current");


		 slider_set_position($num_of_harms_canvasitem{$c}, $virtualx);
		 $oldx = $x;
	       }, Ev("x")]);
$f->Button(-text => "Reset", -background => "Wheat", -command => 
	   sub { for (1..$num_harmonics) { slider_set_value($_, ($_ == 1 ? 1 : 0)); }})->pack(-side => "top");
$f->Button(-text => "Print", -background => "Wheat", -command => 
	   sub { print "( "; for (1..$num_harmonics) { print "$harmonics[$_], "} print ")\n";})->pack(-side => "top");
### Frame

$f2 = $mw->Frame()->pack(-side => "left", -expand => "true", -fill => "both");

$f2->Scale(qw(-orient horizontal -length 500 -from 0 -to 255
-tickinterval 50 -label), "Gain", -variable => \$gain,
-command => sub { audio_set_gain( $gain ) } )
->pack(-side => "top");

$f2->Scale(qw(-orient horizontal -length 500 -from 0 -to 2
-tickinterval .25 -label), "Duration", -variable => \$dur, -resolution => .0625,
-command => sub { $length = $dur * $rate } )
->pack(-side => "top");

$f3 = $f2->Frame()->pack(-side => "top", -expand => "true", -fill => "x");

# text box

$t = $f3->Scrolled("Text", -scrollbars => "se", -height => 5, -width => 20)->pack(-side => "left", -fill => "both", -expand => "true");

$t->bind("Tk::Text", "<Meta-c>", sub{$chord =  
$t->get("insert linestart", "insert lineend"); do_chord(); Tk->break});
$t->bind("Tk::Text", "<Meta-x>", sub{$sequence =  
$t->get("insert linestart", "insert lineend"); do_sequence(); Tk->break});
### Envelope canvas

$num_env_points = 9;
$ewidth = 200;
$eheight = 200;
$env_unit = 8;
$env_c = $f3->Canvas( -highlightthickness => 0, -width => $ewidth, -height => $eheight, -relief => "sunk", -borderwidth => 1)->pack(-side => "left");

for (1.. ($num_env_points - 1)) {
  $env_lines[$_] = $env_c->create("line", 0, 0, 1, 1);
}
for (1..$num_env_points) {
  $env_pt = $env_c->create("rectangle", 0, 0, 1, 1, -fill => "white", -tags => "env");
  $env_points[$_] = $env_pt;
  $num_of_env_canvasitem{$env_pt} = $_;
  env_set_value($_, ($_ - 1) / ($num_env_points -1), 1);
}

for (1..($num_env_points - 1)) {
  
}
$env_c->bind("env", "<1>", 
	     [ sub {
		 my ($self, $x, $y) = @_;
		 $oldx = $x;
		 $oldy = $y;
		 ($virtualx, $virtualy) = $self->coords("current");
	       }, Ev("x"), Ev("y")]);
$env_c->bind("env", "<Button1-Motion>", 
	     [ sub { 
		 my ($self, $x, $y) = @_;
		 $virtualx += $x - $oldx;
		 $virtualy += $y - $oldy;
		 $c = $env_c->find("withtag", "current");
		 env_set_position($num_of_env_canvasitem{$c}, $virtualx, $virtualy);
		 $oldx = $x;
		 $oldy = $y;
	       }, Ev("x"), Ev("y")]);


###


#############

$f = $f2->Frame()->pack(-side => "top");

$f->Scale(qw(-orient vertical -length 200 -from 0 -to 500 
-tickinterval 200 -label), "BF", -variable => \$base_freq)
->pack(-side => "left");

$f->Scale(qw(-orient vertical -length 200 -from .1 -to 20 
-tickinterval 2 -label), "SF", -resolution => .1, -variable => \$step_freq)
->pack(-side => "left");

$f->Scale(qw(-orient vertical -length 200 -from 1 -to 200 
-tickinterval 40 -label), "FR", -variable => \$range_freq)
->pack(-side => "left");

$f->Scale(qw(-orient vertical -length 200 -from 0 -to 32000 
-tickinterval 6400 -label), "Amp", -variable => \$amp)
->pack(-side => "left");

$f->Scale(qw(-orient vertical -length 200 -from 1 -to 20 
-tickinterval 6400 -label), "S", -variable => \$scale)
->pack(-side => "left");

$f2->Button(-background => 'wheat', -text => "Beat", -command => \&do_drum)->pack(-side => "bottom");


#############

MainLoop();
audio_destroy();

sub do_chord {
  my $h;
  my $i;

  audio_zero($sound, $length);
  foreach $i (1..$num_harmonics) {
    my $h = $harmonics[$i];
    if ($h) {
      $chord =~ s/\b(.*)maj\b/$1 $1#### $1#######/g;
	$chord =~ s/\b(.*)m\b/$1 $1### $1#######/g;
      foreach(split(/\s+/, $chord)) {
	audio_table_add($sound, $length, ${$wth{$wt}}, $rate, $i * tone_of_string($_), $h * $volume/1000);
      }
    }  
  }
  
foreach(1..($num_env_points - 1)) {
    audio_linear_env($sound, 
		     $env[$_][0] * $length, $env[$_][1], 
		     $env[$_+1][0] * $length, $env[$_+1][1]);
  }

  audio_distort($sound, $length, $dist, $dist, 33000, $dist);
  if ($full_distortion) {
    audio_distort($sound, $length, -33000, -$dist, -$dist, -$dist);
  }
  audio_scale($sound, $length, $scale);
  

  audio_play($sound, $length);
}

sub do_sequence {
  my $h;
  my $i;
  
  foreach(split(/\s+/, $sequence)) {
    audio_zero($sound, $length);
    foreach $i (1..$num_harmonics) {
      my $h = $harmonics[$i];
      if ($h) {
	audio_table_add($sound, $length, ${$wth{$wt}}, $rate, $i * tone_of_string($_), $h * $volume/1000);
      }  
    } 

    foreach(1..($num_env_points - 1)) {
      audio_linear_env($sound, 
		       $env[$_][0] * $length, $env[$_][1], 
		       $env[$_+1][0] * $length, $env[$_+1][1]);
    }

    audio_distort($sound, $length, $dist, $dist, 33000, $dist);
    if ($full_distortion) {
      audio_distort($sound, $length, -33000, -$dist, -$dist, -$dist);
    }
    audio_scale($sound, $length, $scale);
  
    
    audio_play($sound, $length);
  }
}

sub do_drum {
audio_zero($sound, $rate);
  audio_omni_drum($sound, $rate, ${$wth{$wt}}, $rate, $base_freq, $range_freq, $step_freq, $amp / 32000);
  audio_scale($sound, $rate, $scale);
  audio_play($sound, $rate);
}

sub slider_set_value {
  my($i, $v) = @_;
  
  $harmonics[$i] = $v;
  display_slider($i);
}

sub slider_set_position {
  my ($i, $p) = @_; # p is the x-coord of the left edge
  $harmonics[$i] = $p / ($hwidth - $hunit);
  display_slider($i);
}

sub display_slider{
  my ($i) = @_;
  if ($harmonics[$i] >= 1) {
    $harmonics[$i] = 1; 
    $harms->itemconfigure($h_sliders[$i], -fill => "white");
  }
  elsif ($harmonics[$i] <= 0) {
    $harmonics[$i] = 0; 
    $harms->itemconfigure($h_sliders[$i], -fill => "black");
  }
  else {
  $harms->itemconfigure($h_sliders[$i], -fill => "wheat");
}
  my $h = $harmonics[$i] * ($hwidth - $hunit);
  $harms->coords($h_sliders[$i], 
		 $h, ($i-1) * $vunit,
		 $h + $hunit, $i * $vunit);
}

sub env_set_value {
  my ($i, $t, $a) = @_;
  $env[$i] = [$t, $a];
  display_env($i);
}

sub env_set_position {
  my ($i, $x, $y) = @_;
  $env[$i] = [$x / ($ewidth - $env_unit), 1 - $y / ($eheight - $env_unit)];
  #print join(", ", @{$env[$i]}, "\n");
  display_env($i);
}

sub display_env {
  my ($i) = @_;
#print "$env[$i][0] $env[$i][1] *\n";
  if ($i == 1) {
    $max = 0;
    $min = 0;
  }
  elsif ($i == $num_env_points) {
    $max = 1;
    $min = 1;
  }
  else {
   $max = $env[$i+1][0];
   $min = $env[$i-1][0] ;
  }
#print "maxmin: $max $min\n";
  if (defined $max and defined $min) {
    if ($env[$i][0] > $max) { $env[$i][0] = $max }
    elsif ($env[$i][0] < $min) {$env[$i][0] = $min }
    if ($env[$i][1] > 1) { $env[$i][1] = 1 }
    elsif ($env[$i][1] < 0) { $env[$i][1] = 0 }
  }
  $x = ($ewidth - $env_unit) * $env[$i][0];
  $y = ($eheight - $env_unit) * (1-$env[$i][1]);
#print "$x $y\n";
  $env_c->coords($env_points[$i], $x , $y , $x + $env_unit, $y + $env_unit);
  if ($i != $num_env_points) {
    @coords = $env_c->coords($env_lines[$i]);
    $env_c->coords($env_lines[$i], $x + $env_unit / 2, $y + $env_unit / 2, @coords[2, 3]);
  }
  if ($i != 1) {
    @coords = $env_c->coords($env_lines[$i-1]);
    $env_c->coords($env_lines[$i-1], @coords[0, 1], $x + $env_unit / 2, $y + $env_unit / 2);
  }
}
