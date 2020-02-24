package OpusVL::FB11::Role::Object::Identifiable;

# ABSTRACT: Adapts arbitrary data for event storage

our $VERSION = '1';

use strict;
use warnings;
no warnings 'experimental::signatures';;

use Moose::Role;

requires 'fb11_unique_identifier';

1;

=head1 SYNOPSIS

    package MyApp::Object::Example;

    use Moose;
    with 'OpusVL::FB11::Role::Object::Identifiable';

    has the_object => ( isa => 'MyApp::Example::Type' );

    sub fb11_unique_identifier {
        my $self = shift;
        +{
            object_type => 'myapp::type',
            key1 => $self->the_object->key1,
            key2 => $self->the_object->key2
        }
    }

=head1 REQUIRED METHODS

=head2 fb11_unique_identifier

Returns a hashref that identifies the object you want to access the event log
for. This hashref must contain the C<object_type> key, and then any further keys
you wish in order to identify your object later.

The identifier of the object 
must be both serialisable and reproducible, which is to say that the same object 
must produce the same serialisation of its identifier in all situations.

The only
constraint is that the identification of the object be given as a hashref, and
that it at least contains an C<object_type> key in case multiple sources
identify themselves in different ways. (Most database objects would otherwise
return simply C<< { id => $object->id } >>.)

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