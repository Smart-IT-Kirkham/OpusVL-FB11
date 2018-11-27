package OpusVL::FB11X::AuditTrail::Model::AuditTrail;

use strict;
use warnings;
use Moose;
BEGIN {
    extends 'Catalyst::Model::DBIC::Schema';
}

__PACKAGE__->config(
    schema_class => 'OpusVL::AuditTrail::Schema',
    traits => 'SchemaProxy',
);

# FIXME
# This brain is inside out. It is allowing Catalyst to construct it rather than
# taking its construction info from the hive. Correctly, this model should be a
# thin interface into the object constructed by the hive.
has short_name => (
    is => 'rw',
    lazy => 1,
    default => 'audittrail'
);

sub hats {
    (
        dbic_schema => {
            class => 'dbic_schema::is_brain',
        },
        'audit-trail' => {
            class => '+OpusVL::AuditTrail::Hat::audit_trail'
        },
    )
}

sub provided_services {
    qw/audit-trail/
}

with 'OpusVL::FB11::Role::Brain';

after BUILD => sub {
    my $self = shift;
    OpusVL::FB11::Hive->register_brain($self);
};

=head1 COPYRIGHT and LICENSE

Copyright (C) 2015 OpusVL

This software is licensed according to the "IP Assignment Schedule" provided with the development project.

=cut

1;


