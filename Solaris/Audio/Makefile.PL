use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    'NAME'	=> 'Solaris::Audio',
    'VERSION_FROM' => 'Audio.pm', # finds $VERSION
    'LIBS'	=> [''],   # e.g., '-lm' 
    'DEFINE'	=> '',     # e.g., '-DHAVE_SOMETHING' 
    'INC'	=> '',     # e.g., '-I/usr/include/other' 
    'MYEXTLIB'  => 'audio/libaudio.a',
);

sub MY::postamble {
'
$(MYEXTLIB): audio/Makefile audio/audio.c audio/audio.h
	cd audio && $(MAKE) all
';
}
