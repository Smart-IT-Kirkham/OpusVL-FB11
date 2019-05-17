
package OpusVL::AuditTrail::Schema::ResultSet::SystemEvent;

=head1 NAME

OpusVL::AuditTrail::Schema::ResultSet::SystemEvent

=head1 SYNOPSIS



=head1 METHODS

=cut

use Moose;

extends 'DBIx::Class::ResultSet';

with 'OpusVL::AuditTrail::Schema::RoleForResultSet::EvtCreatorRole';

=head2 initdb_populate

This needs to be called after your dataset has been deployed to create the record the SystemEvent needs
in order to function.

=cut

sub initdb_populate
{
    my $self = shift;
    # create a single record to hang things off.

    $self->create({});
}

=head2 log

This returns the single L<OpusVL::AuditTrail::Schema::Result::SystemEvent> object that should be in the syetem.
This is used to create events for non table related items.

=cut

sub log
{
    my $self = shift;
    my $obj = $self->search({}, { rows => 1 })->first;
    return $obj;
}

=head1 LICENSE AND COPYRIGHT

Copyright (c) 2011 OpusVL.

This software is licensed according to the "IP Assignment Schedule" provided with the development project.

=cut
