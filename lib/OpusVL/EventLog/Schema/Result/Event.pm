package OpusVL::EventLog::Schema::Result::Event;

use strict;
use warnings;
use DBIx::Class::Candy;

# ABSTRACT: Stores parameters in a naïve way
our $VERSION = '1';

=head1 DESCRIPTION

This table holds all the event data!

=head1 COLUMNS

=head2 id

Just a primary key since we have no truly unique data except maybe timestamp.

=head2 object_identifier

JSON object containing the object type and any other identifying information
someone told us they will recognise later.

=head2 payload

JSON object containing the payload that the aforementioned developer sent us.

=head2 environmental_data

Any environmental data in effect at the time the event was created.

=head2 type

An event type, optionally supplied by the event creator.

=head2 timestamp

Date and time of the creation of the event.

=cut


#FIXME we need an index on environmental_data || payload
#and on payload || environmental_data (which might be different if keys collide)

__PACKAGE__->load_components(qw/InflateColumn::Serializer InflateColumn::DateTime/);

table 'event_log';

primary_column id => {
    data_type => 'int',
    is_auto_increment => 1,
};

column object_identifier  => {
    data_type => 'jsonb',
    is_nullable => 0,
    serializer_class => 'JSON',
};

column payload => {
    data_type => 'jsonb',
    is_nullable => 0,
    serializer_class => 'JSON',
};

column tags => {
    data_type => 'jsonb',
    is_nullable => 1,
    serializer_class => 'JSON',
};

column message => {
    data_type   => 'text',
    is_nullable => 0,
};

column type => {
    data_type => 'text',
    is_nullable => 1,
};

column timestamp => {
    data_type => 'timestamptz',
    is_nullable => 0,
    default_value => \'NOW()',
    inflate_datetime => 1,
};

=head1 METHODS

=head2 to_event_hashref

Returns the object as the hashref documented in
L<OpusVL::EventLog::Hat::eventlog/EVENT DATA>.

=cut

sub to_event_hashref {
    my $self = shift;

    {
        message => $self->message,
        payload => $self->payload,
        tags => $self->tags,
        type => $self->type,
        timestamp => $self->timestamp,
    }
}

1;
