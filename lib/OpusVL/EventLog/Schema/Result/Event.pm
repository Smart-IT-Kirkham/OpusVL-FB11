package OpusVL::EventLog::Schema::Result::Event;

use strict;
use warnings;
use DBIx::Class::Candy;

# ABSTRACT: Stores parameters in a naïve way
our $VERSION = '0';

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

table 'event_log';

primary_column id => {
    data_type => 'int',
    is_auto_increment => 1,
};

column object_identifier  => {
    data_type => 'jsonb',
    is_nullable => 0,
};

column payload => {
    data_type => 'jsonb',
    is_nullable => 0,
};

column environmental_data => {
    data_type => 'jsonb',
    is_nullable => 1,
};

column type => {
    data_type => 'text',
    is_nullable => 1,
};

column timestamp => {
    data_type => 'timestamptz',
    is_nullable => 0,
    default_value => \'NOW()',
};

1;
