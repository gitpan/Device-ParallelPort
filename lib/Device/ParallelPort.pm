package Device::ParallelPort;

use vars qw/$AUTOLOAD $VERSION/;
$VERSION = "0.02";

=head1 NAME

Device::ParallelPort - Parallel Port Driver for Perl

=head1 SYNOPSIS

	my $port = Device::ParallelPort->new('auto:0');
	$port->set_bit(3,1);
	print $port->get_bit(3) . "\n";
	print ord($port->get_byte(0)) . "\n";

=head1 DESCRIPTION

A parallel port driver module. This module provides an API to all parallel ports, by
providing the ability to write any number of drivers. Modules are available for linux
(both directly and via parport), win32 and a simple script version.

=head1 DRIVER MODULES

	Device::ParallelPort::drv::linux - Direct hardware access to a base address.
	Device::ParallelPort::drv::parport - Linux access to /dev/parport drivers
	Device::ParallelPort::drv::script - Run a script with parameters
	Device::ParallelPort::drv::dummy_byte - Pretending byte driver for testing
	Device::ParallelPort::drv::dummy_bit - Pretending bit driver for testing
	Device::ParallelPort::drv::win32 - Windows 32 DLL access driver

=head1 DEVICE MODULES

	Device::ParallelPort::Printer - An example that can talk to a printer
	Device::ParallelPort::JayCar - Simple JayCar electronics latched, addressable controller

=head1 AUTHOR

Scott Penrose L<scottp@dd.com.au>, L<http://linux.dd.com.au/>

=head1 SEE ALSO

L<Device::ParallelPort>

=cut

sub new {
	my ($class, $drvstr, @params) = @_;
	my $this = bless {}, ref($class) || $class;
	my ($drv, $str) = split(/:/, $drvstr, 2);
	eval qq{
		use Device::ParallelPort::drv::$drv;
		\$this->{DRV} = Device::ParallelPort::drv::$drv->new(\$str, \@params);
	};
	die "Can't create driver $drv - $@" if ($@);
	return $this;
}

# INHERITED METHODS FROM DRIVER, or contains ?
#	- set_bit
#	- get_bit
#	- set_byte
#	- get_byte

sub _drv {
	my ($this) = @_;
	return $this->{DRV};
}

sub AUTOLOAD {
	my ($this, @params) = @_;

        my $name = $AUTOLOAD;
        $name =~ s/.*://;   # strip fully-qualified portion
	if (defined($this->_drv) && $this->_drv->can($name)) {
		$this->_drv->$name(@params);
	} elsif ($name eq "DESTROY") {
		# Do nothing if there was no DESTROY above
	} else {
		die "Invalid method $name";
	}
}

1;
