package OpusVL::EventLog::Role::Adapter;

# ABSTRACT: Adapts arbitrary data for event storage
our $VERSION = '1';

use Moose::Role;

requires 'get_identifier';

1;

=head1 DESCRIPTION

To store event data against an object, that object must be identifiable. The
identification of the object must be both serialisable and reproducible, which
is to say that the same object must produce the same serialisation of its
identification in all situations.

The expected use of the event log is that both creation and retrieval of events
can only be performed against an object you already have a handle on. It is not
possible to take the object identifier from an event and completely reproduce
the object from which it came: this would require knowledge of services or even
Brains that do not even exist in the Hive any more.

As a result, the only information we need in order to be able to store events
against an object is a consistent identifier for that object. The only
constraint is that the identification of the object be given as a hashref, and
that it at least contains an C<object_type> key in case multiple sources
identify themselves in different ways. (Most database objects would otherwise
return simply C<< { id => $object->id } >>.)

This Role provides an interface for Adapter objects, whose construction and
definition is otherwise entirely arbitrary and up to the system implementing it.

=head1 SYNOPSIS

    package MyApp::Adapter::Example;

    use Moose;
    with 'OpusVL::EventLog::Role::Adapter';

    has the_object => ( isa => 'MyApp::Example::Type' );

    sub get_identifier {
        my $self = shift;
        +{
            object_type => 'myapp::type',
            key1 => $self->the_object->key1,
            key2 => $self->the_object->key2
        }
    }


=head1 REQUIRED METHODS

=head2 get_identifier

Returns a hashref that identifies the object you want to access the event log
for. This hashref must contain the C<object_type> key, and then any further keys
you wish in order to identify your object later.

=head1 SEMANTIC TYPES

As of writing, the concept of "semantic types" is floating around. This is the
idea that FB11, or the Hive, or something, would have an index of types of
objects that exist in the system. A Brain would announce the types it has, and
anything that cares could make use of that information.

To assist with this concept in the future we recommend that your Adapter classes
use a semantic type name in the C<object_params> key. Since your objects are
likely to be DBIC objects, it would make some sense to require your Result
classes to declare their semantic type name somehow, and then tow write a
generic DBIC adapter that can adapt any such object.

This closely mirrors the behaviour of the L<OpusVL::ObjectParams::Role::Adapter>
role, which has a very similar paradigm but is a totally separate system and we
don't want to couple them together.

A benefit of using semantic types is that we could very well allow a Brain to
reconstruct for us an object of a given type, because the type would be unique
in the system and we know who is in control of it.

=head1 SYSTEM LOG

The "system" adapter, L<OpusVL::EventLog::Adapter::System>, is available as
C<$OpusVL::EventLog::SYSTEM>. This is trivially an adapter that always returns a
hashref with the undefined value for C<object_type>, and no other
identification. This allows events to be logged in the system log instead of
against an object.
