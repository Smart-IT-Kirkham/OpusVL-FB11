package OpusVL::EventLog::Schema::ResultSet::Event;

use v5.24;
use strict;
use warnings;

# ABSTRACT: Packaged queries for events
our $VERSION = '1';

use Moose;
use MooseX::NonMoose;
use JSON::MaybeXS;

extends 'DBIx::Class::ResultSet';

=head1 DESCRIPTION

Simplifies searching for events. This is a private interface for the
OpusVL::EventLog module; the external interface is in
L<OpusVL::EventLog::Hat::eventlog>.

=head1 METHODS

=head2 of_type

B<Arguments>: C<$type>

Searches for events of this type. There is no pre-defined list of types.

Calling this will I<always> filter by type, since passing the undefined value
will search for events with no type.

=cut

sub of_type {
    my $self = shift;
    my $type = shift;

    $self->search({type => $type });
}

=head2 for_object

B<Arguments>: C<$adapter>

Pass in any object adapter to search on that object. See
L<OpusVL::EventLog::Role::Adapter>.

This is a I<subset> search; meaning if your adapter resolves to an incomplete
identifier, multiple objects may be discovered. A typical example of this might
be to pass in an adapter that specifies the type but no identifier.

=cut

sub for_object {
    my $self = shift;
    my $adapter = shift;

    my $identifier = $adapter->fb11_unique_identifier;

    $self->search({
        object_identifier => {
            '@>' => encode_json($identifier)
        }
    });
}

=head2 with_payload_data

B<Arguments>: C<\%data>

Searches for events whose payload data is a superset of this data set.

=cut

sub with_payload_data {
    my $self = shift;
    my $data = shift;

    $self->search({
        payload => {
            '@>' => encode_json($data)
        }
    });
}

=head2 with_tags

B<Arguments>: C<\%data>

Searches for events whose tags data set is a superset of this data set.

=cut

sub with_tags {
    my $self = shift;
    my $data = shift;

    $self->search({
        tags => {
            '@>' => encode_json($data)
        }
    });
}

=head2 events_before

=head2 events_since

B<Arguments>: C<DateTime $d>

Finds events created before or since this point in time.

=cut

sub events_before {
    my $self = shift;
    my $datetime = shift;
    my $dtf = $self->result_source->schema->storage->datetime_parser;

    $self->search({
        timestamp => {
            '<=' => $dtf->format_datetime($datetime)
        }
    });
}

sub events_since {
    my $self = shift;
    my $datetime = shift;
    my $dtf = $self->result_source->schema->storage->datetime_parser;

    $self->search({
        timestamp => {
            '>=' => $dtf->format_datetime($datetime)
        }
    });
}

1;
