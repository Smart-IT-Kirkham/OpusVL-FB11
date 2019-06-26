package OpusVL::ObjectParams;

use v5.24;
use warnings;
use strict;

use Moose;
use OpusVL::ObjectParams::Schema;

# ABSTRACT: Module to handle extensions to others' core data.
our $VERSION = '0';

=head1 DESCRIPTION

Like L<OpusVL::SysParams>, this module's purpose is to allow an application or
component to register extensions to another component's core data, and to define
the schema by which that is achieved. The purpose of this is to ensure that the
needs of a component can be met before the application gets to the point where
it's happily running, oblivious to its impending crash.

This module orchestrates two sets of Brains: those with extensible data
(I<extendees>), and those providing extensions (I<extenders>).

=head1 SYNOPSIS

    package MyComponent::Brain;

    # ... brain boilerplate ...

    sub hats {
        'objectparams::extendee'
    }

Z<>

    package MyComponent::Brain::Hat::objectparams::extendee;

    sub extendee_spec {
        'mycomponent::somedata' => {
            # ... FIXME
        }
    }

Z<>

    package AnotherComponent::Brain;

    # ...
    sub hats {
        'objectparams::extender'
    }

Z<>

    package AnotherComponent::Brain::Hat::objectparams::extender;

    use Moose;
    with 'OpusVL::ObjectParams::Role::Hat::objectparams::extender';

    # Required
    sub schemas {
        'mycomponent::somedata' => {
            # ... OpenAPI Spec
        }
    }

    # Not required
    sub get_parameters_for {
        my $self = shift;
        my $adapter = shift;

        # Custom way of storing params on this hat!
        my $rs = $self->__brain->schema->parameters_resultset($adapter->type);
        $rs->parameters_for($adapter->id);
    }

=head1 EXTENDING DATA

=head2 Extendees

For more information on Extendees, see
L<OpusVL::ObjectParameters::Role::Hat::objectparams::extendee>.

It is not strictly necessary to export any information about extendable objects.
Any Brain can, in theory, extend any other Brain's objects if it wants to. The
strict difference is that if you are declaring your objects as extendable, I<you
will be looking for extensions>.

Generally, this means that you will provide a form (probably in a separate UI
module, but still under your control), or at least some sort of behaviour, that
can make use of extensions to your object.

When you declare your objects as being extensible, you give them semantic names.
This is usually represented as a namespaced short name, for example
C<fb11core::user> would represent the core FB11 user object.

(Note that this interface also avoids exposing any knowledge about I<how> the
C<fb11core::user> object is represented. This supports the later possibility of
replacing the source of this data while maintaining compatibility with existing
extensions.)

=head3 Wear the C<objectparams::extendee> hat

A Brain with extensible objects would wear the C<objectparams::extendee> hat,
and implement it. The implementation provides a single method, C<extendee_spec>,
which returns a hashref keyed on the aforementioned semantic names, with values
configuring the Parameters service itself.

=head3 Parameter configuration

An example hashref looks like this:

    {
        'fb11core::user' => {
            # TODO
            adapter => 'dbic'
        }
    }

We explain adapters L<further down|/Extensibles>. Normally the name would
represent the I<type> of object your extensible object is, but some adapters
might represent behaviour specific to an individual class or component.

=head2 Extenders

For more information on Extenders, see
L<OpusVL::ObjectParameters::Role::Hat::objectparams::extender>.

An I<Extender>, on the other hand, declares that it has extensions for the
objects named by the extendee's Parameters configuration.

The extension is twofold. First, in the abstract sense, the extender declares an
OpenAPI schema defining the extra data that will be added onto the type. This
can be read by anything that cares. Second, the extender accepts a I<type> and a
I<key> for an object being extended, and either stores or returns the extended
data.

=head3 Define an OpenAPI schema

The idea is that you add data that you are going to use. You are responsible for
correctly defining the schema, and for storing and retrieving the extension you
say you provide.

The component that owns the object - the one that provides the semantic name for
it - will be responsible for marshalling the data. It will render the form, or
otherwise collect user data, and merge your extension data with its own whenever
the object is rendered.

That component is unlikely to make any further use of your data, because it
doesn't know what it is for.

=head3 Wear the C<objectparams::extender> hat

Wear, and define, a Hat of this type.  Your Hat will be responsible for
retrieving data for an object, and storing it. The data you return, or receive,
will conform to your OpenAPI schema.

This hat requires three methods. The first two of them are used to set and
retrieve extension data; the third defines the OpenAPI schemata you will conform
to, and associates them with the semantic names from the component(s) you are
extending.

=head4 C<schemas>

This returns a hash-shaped list of OpenAPI specifications, a concept out of
scope of this document. Each schema defines the parameters that your Hat
associates with the object identified by the key.

    sub schemas {
        'fb11core::user' => {
            # OpenAPI spec
        }
    }

By mentioning that object type as a key, the Parameters Brain knows that you
will accept and return parameters for it.

=head4 C<get_parameters_for>, C<set_parameters_for>

These methods are provided for you by the role
L<OpusVL::ObjectParams::Role::Hat::objectparams::extender>. By default they just
store and retrieve the data using the built-in storage mechanism. However, you
can override them if you want to handle the data in a customised way.

Both of these methods will receive an C<$adapter> parameter, containing
sufficient information to identify the object in question. L</Adapters>.

Naturally, C<set_parameters_for> will also receive a hashref conforming to the
OpenAPI specification you defined in C<schemas>, and C<get_parameters_for> is
expected to return a similar hashref.

=head2 Extensibles

An object that can be extended makes itself I<extensible> by means of adapter
objects.

An adapter object is an object that contains, in this case, the object being
extended. Communication with the C<objectparams> service is done by putting your
extensible object into an adapter and then sending that to the service.

=head3 Adapters

The adapters are used to tell the service a) the type of the object and b) the
identifier. The simplest adapter is the I<static> adapter, which does not
actually contain the extensible object at all, and simply has these two data
items as properties on the adapter itself.

    OpusVL::FB11::Hive->service('objectparams')->get_params_for(
        object => OpusVL::ObjectParams::Adapter::Static(
            type => 'fb11core::user',
            id => $user->id_for_params
        ),
        extender => 'audit-trail'
    );

Other adapter types can be used as convenient ways of interfacing with common
object types.

=head3 Extensible Role

The L<OpusVL::ObjectParameters::Role::Extensible|Extensible Role> can be applied
to a class to expose the C<extension_adapter> method on the object itself. This
can either be implemented by the object, by another role, or by an extension of
the Extensible Role that implements a specific adapter type.

=head1 BRAIN INFO

This class is a Brain!

=head2 Construction

=over

=item short_name

The default short name of this Brain is C<objectparams>.

=item connect_info

If you ever need to rely on the built-in storage behaviour (which is very
likely) you will need to pass connect_info so we can connect to the database.
This is the normal DBI connect_info arrayref.

=item schema

If you want to, you can pass a connected schema instead of connect_info

=back

=head2 Hats and Services

The class wears the following hats:

=over

=item objectparams

This fulfils the objectparams service.

=item objectparams::storage

This can be requested as a L<fancy hat|OpusVL::FB11::Hive/fancy_hat> to access
built-in parameter storage. See
L<OpusVL::ObjectParams::Hat::objectparams::storage>.

=back

And provides the following services:

=over

=item objectparams

The C<objectparams> service is documented in
L<OpusVL::ObjectParams::Hat::objectparams>.

=back

=cut

has short_name => (
    is => 'ro',
    default => 'objectparams'
);

has connect_info => (
    is => 'ro',
);

has schema => (
    is => 'ro',
    default => sub { OpusVL::ObjectParams::Schema->connect($_[0]->connect_info->@*) },
    lazy => 1,
);

with 'OpusVL::FB11::Role::Brain';

sub hats {
    'objectparams',
    'objectparams::storage',
    'dbicdh::consumer' => {
        class => '+OpusVL::FB11::Hat::dbicdh::consumer::is_brain'
    }
}

sub provided_services {
    'objectparams'
}

sub dependencies {
    services => [qw/ dbicdh::manager /]
}

sub hive_init {
    my $self = shift;
    my $hive = shift;

    # TODO : This might be where we register extenders with their names so we
    # don't have to look them up later.
}

1;
