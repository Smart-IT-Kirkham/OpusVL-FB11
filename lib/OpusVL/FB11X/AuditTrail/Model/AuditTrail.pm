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

=head1 COPYRIGHT and LICENSE

Copyright (C) 2015 OpusVL

This software is licensed according to the "IP Assignment Schedule" provided with the development project.

=cut

1;


