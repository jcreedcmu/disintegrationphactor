use Carp; # <- don't remember why this is here

# this code has been cargo-culted around
# ever since I wrote it for marvin. Figured I might as
# well stick it here.

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
sub tone_of_string {
my $mymult = 1;
my ($st) = @_;
for ($st) {
  while (s/b//) {$mymult /= $mult}
  while (s/\#//) {$mymult *= $mult}
  while(s/\+//) {$mymult *= 2}
  while(s/\-//) {$mymult /= 2}
}
return $tone{$st} * $mymult;
}

"disi.pl";
