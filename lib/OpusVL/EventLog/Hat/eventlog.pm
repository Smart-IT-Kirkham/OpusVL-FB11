package OpusVL::EventLog::Hat::eventlog;

# ABSTRACT: Implements the eventlog service
our $VERSION = '0';

use PerlX::Maybe;
use Scope::Guard 'guard';

use Moose;
with 'OpusVL::FB11::Role::Hat';

has _environmental_data => ( is => 'rw' );

=head1 DESCRIPTION

The eventlog service allows you to create and retrieve events against objects in
the system. A common use of this is to audit changes.

The basic interface into the event log - getting and setting events - requires
you to identify the object against which the events are to be stored. This is
done by means of the adapter pattern: pass in an object that implements
L<OpusVL::EventLog::Role::Adapter>, and we will use it to identify your object
in our event storage.

This process is similar to L<OpusVL::ObjectParams>, with the principle
difference being that the event log stores I<multiple> events against an object,
while each Brain can only store a I<single> tuple against an object.

(Storing events as object parameters was considered, but the need to index and
search on data meant that a JSON array was not suitable.)

That's the basic usage: create an Adapter and pass it around; we'll handle the
storage for you.

=head3 System events

System events are created and retrieved simply by providing the special adapter
stored in C<$OpusVL::EventLog::SYSTEM>.

Please be careful when providing types to system events: it is much more likely
that you provide a type that someone else has used, and thus pollute one another
with unexpected data in future, if you don't use namespaced type names.

=head2 Environmental data

Riffing off the old Audit Trail, we wanted to support behaviour that seemed
hacky but also necessary. An example of such behaviour was the setting of a
global set of user data so that events created during the course of a web
request were stored with the user data against them.

Event Log calls this stuff "environmental data" and can be set using the
C<set_environmental_data> mutator. This returns a L<Scope::Guard> object, which
you I<must> keep hold of. When it is destroyed, the environmental data is
reverted to what it was before you called it.

An example usage of this is to store the guard in the Catalyst stash so that
when the request is complete the guard is destroyed. As long as your process is
only handling one request at a time this will not leak data between requests.

    $c->stash->{eventlog_guard} = OpusVL::FB11::Hive
        ->service('eventlog')
        ->set_environmental_data({
            username => $c->user->name,
            ip => $c->req->ip_addr
        });

Environmental data will be added to the C<tags> for an event.

=head2 A note on searching

At the time of writing there is no service available to provide searching
behaviour on Brains. This means that you should implement your own form to
search on event data.

The reason we can't provide a generic form is there is no way to communicate to
that generic form the data types in your tags and payloads. This is because we
also do not have the semantic types in the Hive either.

Since your event creator will know the structure of your payload data, you have
the opportunity to coerce search data into the correct types before passing the
request to the search method.

However, you do not have control on what data appear in the environmental data.
Therefore, anything that adds data into the environmental data should, for now,
ensure everything is a string.

=head3 C<user> tag

The single exception is that we are provisionally supporting C<fb11core::user>
as a "semantic type" across all of FB11. Adapted users may be put into tags,
either via environmental data or at the point of event creation, and passed to
search, by using the C<user> field.

This is informational only, since any system using the events service currently
is required to implement its own search form, and therefore the ability to
support user search is done bespoke per system.

=head1 EVENT DATA

This defines the structure of the hashrefs returned by L</get_events_for>.

=over

=item payload

This is the data you (or someone) sent to the system via L<add_event>. Its
structure is irrelevant to Event Log; it is just a hashref of whatever.

This field is intended for display only.

=item tags

Tags are fields in the event that can be searched on. This is arbitrary data, a
merger of the L</Environmental data> in effect at the time, and the C<tags>
passed into L</add_event>.

=item type

The event type set via L<add_event>. Events do not need a type and there is no
current way of defining a list of them, but it is encouraged to provide a value
meaningful to the system whenever possible.

=item timestamp

The all-important information about when the event was created. Provided as a
DateTime object.

=back

=head1 SEMANTIC TYPES

As mentioned in L<OpusVL::EventLog::Role::Adapter/SEMANTIC TYPES> we want to
support the idea of semantic types in the Hive, but we don't yet.

When we have them we can identify them in the event log data by looking for hash
values that define a C<type> key, which will point to a semantic type. The
C<value> in that hash will then tell us how to recover the object of that type.

=head1 METHODS

=head2 search_events

B<Arguments>: C<%args>

C<object>: Optional. Any object that consumes the
L<OpusVL::EventLog::Role::Adapter> role. If not provided, all events are searched.

C<type>: Optional. A single string or arrayref of strings. Events registered
against any of these types will be returned. C<undef> may be used for untyped
events.

C<since>: Optional. A L<DateTime> object representing the earliest bound of the
time range to search on.

C<before>: Optional. A L<DateTime> object representing the latest bound of the
time range to search on.

C<tags>: Optional. A hashref of data to compare to the tags of the events. After
C<object> and C<type> this is the main way to search for events by the data
associated with them.

C<payload>: Optional. A hashref of data to compare to the payload data stored in
the events. Using this may be slow.

Returns an array of event data hashrefs constrained by the provided arguments.

All filters are applied with AND, except that when C<type> is an array, its
values are compared with OR (actually with IN).

Note that providing an undef type (find events with no type) is different from
not providing type at all (find events irrespective of type).

Canny readers may realise that they can probably provide an Adapter that only
specifies a subset of the required keys, in order to return the history of more
than one object. This may or may not work as expected. Caveat computator.

=cut

sub search_events {
    my $self = shift;
    my %user_search = @_;

    my $schema = $self->__brain->schema;
    my $rs = $schema->resultset('Event');

    $rs = $rs->of_type($user_search{type})
        if exists $user_search{type};
    $rs = $rs->for_object($user_search{object})
        if $user_search{object};

    $rs = $rs->with_payload_data($user_search{payload})
        if $user_search{payload};
    $rs = $rs->with_tags($user_search{tags})
        if $user_search{tags};

    $rs = $rs->events_since($user_search{since})
        if $user_search{since};
    $rs = $rs->events_before($user_search{before})
        if $user_search{before};

    return map $_->to_event_hashref, $rs->all;
}

=head2 add_event

B<Arguments>: C<%args>

C<object>: Required. Any object that consumes the
L<OpusVL::EventLog::Role::Adapter> role.

C<payload>: Required. This is an arbitrary hashref of data describing your
event.

C<type>: Optional and arbitrary string type for later retrieval. Try to ensure
the type is meaningful in context, especially if you use the system adapter.

C<tags>: Optional. Adds searchable tags to the event. Merged with environmental
data, with C<tags> taking precedence.

Adds an event to the history. What it looks like is entirely up to you.

Besides the data here, the event will also have a timestamp generated, and the
current value of the L</Environmental data> will be stored as well.

=cut

sub add_event {
    my $self = shift;
    my %args = @_;

    my $tags = $args{tags} || {};
    my $env = $self->_environmental_data || {};
    $tags = {
        %$env,
        %$tags
    };

    # TODO: validation. We like Params::ValidationCompiler
    $self->__brain->schema->resultset('Event')->create({
        object_identifier => $args{object}->get_identifier,
        payload => $args{payload},
        tags => $tags,
  maybe type => $args{type},
    })
}

=head2 set_environmental_data

B<Arguments>: C<\%data>

Merges this data with any existing environmental data. Returns a L<Scope::Guard>
which will reset the data back to what it was when it leaves scope.

Failing to properly nest your scopes is on you.

This hashref, if it is set, is stored against all events that are created.

=cut

sub set_environmental_data {
    my $self = shift;
    my $data = shift;

    my $current_data = $self->_environmental_data;

    $self->_environmental_data({
        %{$current_data || {}},
        %$data
    });

    return guard { $self->_environmental_data($current_data) };
}

1;
