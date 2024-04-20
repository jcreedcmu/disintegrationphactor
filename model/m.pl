#!/usr/bin/perl

use Tk;

$pi = 3.14159265358979;

$mw = MainWindow->new();

$L = 1;
$N = 9;
$f = 1;
$C = 2 * $f * $L;
$dt = 0.005;
$dx = $L / ($N - 1);
print "Max speed: ", $dx / $dt, "\n";
print "Wave speed: $C\n";
$size = 10;
$spacing = 30;
$height = 100;

$c = $mw->Canvas(-height => $height, -width => $N * $spacing)->pack();

@y = map {rand(1)/1} (0..$N-1);
#@yd = map {2 * $pi * $f * sin($pi * $_ / ($N-1))} (0..$N-1);

for (0..$N-1) {
 $ci[$_] = $c->createOval(0,0,0,0, -fill => white);
}

sub redraw {
  for (0..$N-1) {
    my $xpos =  ($_ + .5) * $spacing;
    my $ypos = $height * ((1 - $y[$_]) / 2);
    $c->coords($ci[$_], 
	       $xpos - .5 * $size,
	       $ypos - .5 * $size,
	       $xpos + .5 * $size,
	       $ypos + .5 * $size,
	      );
  }
}

sub recalc {
  my @nyd = (0, 
	     (map {
	       $yd[$_] + ($dt * $C * $C / ($dx * $dx)) *
		 ($y[$_-1] + $y[$_+1] - 2 * $y[$_])
	       } (1..$#y-1)),
	     0);
#print join (", ", @nyd), "\n";
  my @ny = (0, (map {$y[$_] + $dt * $yd[$_]} (1..$#y-1)), 0);
#print join (", ", @ny), "\n";
  @y = @ny;
  @yd = map {0.95 * $_} @nyd;
  redraw();
}

redraw();
$mw->repeat($dt * 1000, \&recalc);

MainLoop();
