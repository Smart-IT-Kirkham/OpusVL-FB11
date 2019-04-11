package OpusVL::SysParams::Strategy::Global;

# ABSTRACT: The sysparams strategy where all params are global.

use Moose;
use OpusVL::SysParams;
with 'OpusVL::SysParams::Role::Strategy';

has _component => (
    is => 'rw'
);

has schema => (
    is => 'rw',
    lazy => 1,
    default => sub {
        OpusVL::SysParams::Schema->connect($_[0]->__brain->connect_info)
    },
);

has __brain => (
    is => 'rw'
);

sub value_of { shift ->schema->resultset('SysInfo')->get(@_) }

1;

=head1 DESCRIPTION

Only use this when dealing with old databases. New applications of sysparams
should be able to separate the stored params based on component.

This strategy just stores the keys and values in the DB without concern for the
component whose parameters they are.
