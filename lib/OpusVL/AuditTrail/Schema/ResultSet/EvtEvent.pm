
package OpusVL::AuditTrail::Schema::ResultSet::EvtEvent;

=head1 NAME

OpusVL::AuditTrail::Schema::ResultSet::EvtEvent

=head1 SYNOPSIS

Events resultset provides common searches for the EvtEvent objects.

=head1 METHODS

=cut

use strict;
use base 'DBIx::Class::ResultSet';

__PACKAGE__->load_components(qw{Helper::ResultSet::SetOperations});

=head2 oldest_first

Applies an order to the resultset (actually puts it into order of ID so hope that 
nobody has been fudging the dates when adding new events).

=cut

sub oldest_first
{
	my $self = shift;
	my $me   = $self->current_source_alias;

	return $self->search_rs ({}, { order_by => { -asc => "$me.id" }});
}

=head2 newest_first

Orders the resultset by newest events first.  Again done by id so it assumes
there has been no fudging of dates.

=cut

sub newest_first
{
	my $self = shift;
	my $me   = $self->current_source_alias;

	return $self->search_rs ({}, { order_by => { -desc => "$me.id" }});
}

=head2 significant

This search filters out the db-update events.

=cut

sub significant
{
	my $self = shift;

	return $self->search_rs
	({
		'type.event_type' => { '!=' => 'db-update' }
	},{
		join => 'type'
	});
}

=head2 most_recent

Returns the 10 most recent results unless you specify a different number using the rows parameter.

    $schema->resultset('EvtEvent')->most_recent({ rows => 20 });

=cut

sub most_recent
{
	my $self = shift;
	my $args = shift;

	my $rows = $args->{rows} || 10;

	my $me   = $self->current_source_alias;
	return $self->search_rs
	(
		{},
		{
			order_by => { -desc => "$me.id" },
			rows     => $rows
		}
	);
}


return 1;
=head1 LICENSE AND COPYRIGHT

Copyright (c) 2011 OpusVL.

This software is licensed according to the "IP Assignment Schedule" provided with the development project.

=cut
