
package OpusVL::AuditTrail::Schema::RoleForResultSet::EvtCreatorRole;

use strict;
use warnings;
use Moose::Role;

=head2 evt_events

Provides resultset of EvtEvents associated with this objects resultset.

  my $events = $obj->search( ... )->evt_events;

=cut

sub evt_events
{
	my $self = shift;

	return $self->search_related_rs ('evt_creator')
	            ->search_related_rs ('evt_events')
}

return 1;
=head1 LICENSE AND COPYRIGHT

Copyright (c) 2011 OpusVL.

This software is licensed according to the "IP Assignment Schedule" provided with the development project.

=cut
