package Device::ParallelPort;

use vars qw/$AUTOLOAD $VERSION/;
$VERSION = "0.03";

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

	L<Device::ParallelPort::drv::linux> - Direct hardware access to a base address.
	L<Device::ParallelPort::drv::parport> - Linux access to /dev/parport drivers
	L<Device::ParallelPort::drv::script> - Run a script with parameters
	L<Device::ParallelPort::drv::dummy_byte> - Pretending byte driver for testing
	L<Device::ParallelPort::drv::dummy_bit> - Pretending bit driver for testing
	L<Device::ParallelPort::drv::win32> - Windows 32 DLL access driver

=head1 DEVICE MODULES

	L<Device::ParallelPort::Printer> - An example that can talk to a printer
	L<Device::ParallelPort::JayCar> - Simple JayCar electronics latched, addressable controller

=head1 METHODS

=head2 new

=head1 CONSTRUCTOR

=over 4

=item new ( DRIVER )

Creates a C<Device::ParallelPort>. 

=back

=head1 METHODS

=over 4

=item get_bit( BITNUMBER )

You can get any bit that is supported by this particular driver. Normally you
can consider a printer driver having 3 bytes (that is 24 bits would you
believe). Don't forget to start bits at 0. The driver will most likely croak if
you ask for a bit out of range.

=item get_byte ( BYTENUMBER )

Bytes are some times more convenient to deal with, certainly they are in most
drivers and therefore most Devices. As per get_bit most drivers only have
access to 3 bytes (0 - 2).

=item set_bit ( BITNUMBER, VALUE )

Setting a bit is very handy method. This is the method I use above all others,
in particular to turn on and off rellays.

=item set_byte ( BYTENUMBER, VALUE )

Bytes again. Don't forget that some devices don't allow you to write to some
locations. For example the stock standard parallel controller does not allow
you to write to the status entry. This is actually a ridiculous limitation as
almost all parallel chips allow all three bytes to be inputs or outputs,
however drivers such as linux parallel port does not allow you to write to the
status byte.

=item get_data ( )

=item set_data ( VALUE )

=item get_control ( )

=item set_control ( VALUE )

=item get_status ( )

=item set_status ( VALUE )

The normal parallel port is broken up into three bytes. The first is data,
second is control and third is status. Therefore for this reason these three
bytes are controlled by the above methods.

=back

=head1 LIMITATIONS

Lots... This is not a fast driver. It is designed to give you simple access to
a very old device, the parallel chip. Don't, whatever you do, use this for
drivers that need fast access.

=head1 BUGS

Not known yet, but hey it is new...

=head1 TODO

Refer to TODO list with package.

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
