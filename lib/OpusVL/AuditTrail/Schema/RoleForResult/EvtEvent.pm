
package OpusVL::AuditTrail::Schema::RoleForResult::EvtEvent;

use strict;
use Moose::Role;
use JSON;

before insert => sub
{
	my $self = shift;

	$self->username ($self->result_source->schema->evt_username)
		unless $self->username;
    
    $self->ip_addr($self->result_source->schema->evt_addr)
        unless $self->ip_addr;
};

=head2 get_data

Returns the data for the event decoded into a regular perl structure.

=cut

sub get_data
{
    my $self = shift;

    return JSON->new->allow_nonref->decode($self->data) 
}

return 1;

=head1 LICENSE AND COPYRIGHT

Copyright (c) 2011 OpusVL.

This software is licensed according to the "IP Assignment Schedule" provided with the development project.

=cut
