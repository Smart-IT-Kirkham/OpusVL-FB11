package OpusVL::FB11X::SysParams::Brain;

use Moose;

has short_name => (
    is => 'rw',
    lazy => 1,
    default => 'sysparams',
);

has _schema => (
    is => 'rw'
);

with 'OpusVL::FB11::Role::Brain';

sub hats {
    qw/sysparams/
}

sub provided_services {
    qw/sysparams/
}

1;
