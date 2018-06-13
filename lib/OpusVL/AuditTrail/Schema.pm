package OpusVL::AuditTrail::Schema;

=head1 NAME

OpusVL::AuditTrail::Schema

=head1 SYNOPSIS

This is the DBIx::Class schema for the AuditTrail module.

=head1 AUTHOR

OpusVL, C<< <colin at opusvl.com> >>

=head1 LICENSE AND COPYRIGHT

Copyright 2011 OpusVL.

This software is licensed according to the "IP Assignment Schedule" provided with the development project.

=cut

use Moose;
use namespace::autoclean;
extends 'DBIx::Class::Schema';

__PACKAGE__->load_namespaces;

with 'OpusVL::AuditTrail::RolesFor::Schema';

__PACKAGE__->meta->make_immutable(inline_constructor => 0);

sub schema_version { 1 }

1;

