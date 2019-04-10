package OpusVL::SysParams::Strategy::Namespaced;
use OpusVL::SysParams::Schema;

use v5.24;
use Moose;
with 'OpusVL::SysParams::Role::Strategy';

has component => (
    is => 'ro'
);

has schema => (
    is => 'ro',
    default => sub {
        OpusVL::SysParams::Schema->connect($_[0]->__brain->connect_info)
    }
);

sub value_of {
    my $self = shift;
    my $param = shift;

    $self->schema->resultset('SysInfo')->find({ name => $self->namespaced_param($param) });
}

sub namespaced_param {
    my $self = shift;
    my $parma = shift;
    join '::', $self->component, $param
}


1;
