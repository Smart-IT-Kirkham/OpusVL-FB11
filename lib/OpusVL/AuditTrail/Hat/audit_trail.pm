package OpusVL::AuditTrail::Hat::audit_trail;

# ABSTRACT: Stub implementation of stub hat.

use Moose;
with 'OpusVL::FB11::Role::Hat::audit_trail';

sub events {
    my $self = shift;
    $self->__brain->resultset('EvtEvent')
        ->search(@_);
}

1;
