package Device::ParallelPort::drv::auto;
use strict;
use Carp;

=head1 NAME

Device::ParallelPort::drv::auto - Automatically choose driver.

=head1 SYNOPSIS

	use Device::ParallelPort;
	my $pp = Device::ParallelPort->new('auto:0');

=head1 DESCRIPTION

This module should be used if you do not care what driver is used.
It is very handy for writing cross platform applications in that it
will autoamtically determine which parallel port driver is appropriate.

=head1 DEVELOPMENT

The current nature of it requires modifications to this module to add new 
drivers. Longer term it would be better if it tried each driver installed on 
the system in turn allowing new drivers to add their own interfaces.

=head1 AUTHOR

Scott Penrose L<scottp@dd.com.au>, L<http://linux.dd.com.au/>

=head1 SEE ALSO

L<Device::ParallelPort>

=cut

sub init {
	if ($^W =~ /linux/i) {
		# TODO - not a file, use just exists
		if (-f "/dev/parport0" || -f "/dev/ppuser00") {
			carp "parport";
		} else {
			carp "linux";
		}
	} elsif ($^W =~ /win32/i) {
		carp "win32";
	} else {
		carp "Unable to automatically detect a parllel port";
	}
}

1;
