#!/usr/local/bin/perl5

open(OUT, ">sound") or die $!;
sub note {
my($which) = @_;
$f = (2 * 3.1415926535) * (440 / 8000) * (2 ** ($which / 12));
$a = 10;
$d = 500;
foreach(1..$d) 
  {
  print OUT (pack("c", 32 + int($a * sin($f * $_))));
  # print (int($a * sin($f * $_)), "\n");
  }
}

for $i (0, 2, 4, 5, 7, 9, 11, 12) { note($i); }

