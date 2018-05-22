package OpusVL::FB11X::SysParams::Brain::Strategy::Global;

# ABSTRACT: The sysparams strategy where all params are global.

use Moose;
use OpusVL::SysParams;

has _component => (
    is => 'rw'
);

has _sysparams => (
    is => 'rw',
    lazy => 1,
    default => sub {
        OpusVL::SysParams->new({ schema => $_[0]->__brain->_schema })
    },
);

has __brain => (
    is => 'rw'
);

sub set { shift->_sysparams->set(@_) }

sub get { shift ->_sysparams->get(@_) }

1;

=head1 DESCRIPTION

Only use this when dealing with old databases. New applications of sysparams
should be able to separate the stored params based on component.

This strategy just stores the keys and values in the DB without concern for the
component whose parameters they are.
